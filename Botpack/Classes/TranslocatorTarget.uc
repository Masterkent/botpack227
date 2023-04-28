//=============================================================================
// TranslocatorTarget.
//=============================================================================
class TranslocatorTarget extends B227_SyncedProjectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var float Disruption, SpawnTime;
var() float DisruptionThreshold;
var pawn Disruptor;
var Translocator Master;
var Actor DesiredTarget;
var bool bAlreadyHit, bTempDamage;
var vector RealLocation;
var TranslocGlow Glow;
var class<TranslocGlow> GlowColor[4];
var Decal Shadow;

var bool B227_bOnlySyncInTick; // Use Tick only for network synchronization
var rotator B227_SyncRotation;
var bool B227_bIsMoving;
var bool B227_bIsRecoverable;

Replication
{
	UnReliable if ( Role == ROLE_Authority )
		RealLocation, Glow;

	reliable if (Role == ROLE_Authority)
		B227_SyncRotation,
		B227_bIsMoving;
}

simulated function Destroyed()
{
	if ( Shadow != None )
		Shadow.Destroy();
	if ( Glow != None )
		Glow.Destroy();
	Super.Destroyed();
}

function bool Disrupted()
{
	return ( Disruption > DisruptionThreshold );
}

function DropFrom(vector StartLocation)
{
	if ( !SetLocation(StartLocation) )
		return;

	SetPhysics(PHYS_Falling);
	GotoState('PickUp');
	B227_bIsMoving = true;
}

simulated singular function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if( NewZone.bWaterZone )
	{
		if( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			// Else play a splash.
			splashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 3.0 );
			if( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor);
				if ( splash != None )
				{
					splash.DrawScale = splashSize;
					splash.RemoteRole = ROLE_None;
				}
			}
		}
	}
}

function Throw(Pawn Thrower, float force, vector StartPosition)
{
	local vector dir;

	dir = vector(Thrower.ViewRotation);
	if ( Bot(Thrower) != none )
		Velocity = force * dir + vect(0,0,200);
	else
	{
		dir.Z = dir.Z + 0.35 * (1 - Abs(dir.Z));
		Velocity = FMin(force,  Master.MaxTossForce) * Normal(dir);
	}

	if (VSize(Velocity) > 0)
		SetRotation(rotator(Velocity));
	else
		SetRotation(Thrower.ViewRotation);

	bBounce = true;
	DropFrom(StartPosition);
}

////////////////////////////////////////////////////////
auto state Pickup
{
	function Timer()
	{
		local Bot P;

		//-if ( (Physics == PHYS_None) && (Role != ROLE_Authority)
		//-	&& (RealLocation != Location) && (RealLocation != vect(0,0,0)) )
		//-		SetLocation(RealLocation);

		//disruption effect
		if ( Disrupted() )
		{
			Spawn(class'Electricity',,,Location + Vect(0,0,6));
			PlaySound(sound'TDisrupt', SLOT_None, 4.0);
		}
		else
		{
			// tell local bots about self
			foreach AllActors(class'Bot', P)
				if (P.Weapon != none && !P.Weapon.bMeleeWeapon && (!Level.Game.bTeamGame || !B227_SameTeamAsOf(P)))
				{
					if ( (VSize(P.Location - Location) < 500) && P.LineOfSightTo(self) )
					{
						P.ShootTarget(self);
						break;
					}
					else if ( P.IsInState('Roaming') && P.bCamping
								&& Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).CheckThisTranslocator(P, self) )
					{
						P.SetPeripheralVision();
						P.TweenToRunning(0.1);
						P.bCamping = false;
						P.GotoState('Roaming', 'SpecialNavig');
						break;
					}
				}
		}
		AnimEnd();
		SetTimer(1 + 2 * FRand(), false);
	}

	event Landed( vector HitNormal )
	{
		local rotator newRot;

		SetTimer(2.5, false);
		//-newRot = Rotation;
		//-newRot.Pitch = 0;
		//-newRot.Roll = 0;
		newRot.Yaw = Rotation.Yaw;
		TransformRotatorByNormal(newRot, HitNormal);
		SetRotation(newRot);
		if (Glow == none)
			PlayAnim('Open',0.1);
		if ( Role == ROLE_Authority )
		{
			//-RemoteRole = ROLE_DumbProxy;
			//-RealLocation = Location;
			if (Bot(Instigator) != none)
			{
				if (Instigator.Weapon == Master)
					Instigator.SwitchToBestWeapon();
				LifeSpan = 10;
			}
			//-Disable('Tick');
			B227_bOnlySyncInTick = true;
			B227_bIsMoving = false;
			B227_SyncMovement();
		}
	}

	function AnimEnd()
	{
		local int glownum;

		if (Physics != PHYS_None ||
			Glow != none ||
			Instigator == none ||
			Instigator.PlayerReplicationInfo == none ||
			Disrupted())
		{
			return;
		}

		if (Instigator != none && Instigator.PlayerReplicationInfo != none)
			glownum = Instigator.PlayerReplicationInfo.Team;
		if ( glownum > 3 )
			glownum = 0;

		Glow = spawn(GlowColor[glownum], self);
	}

	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		SetPhysics(PHYS_Falling);
		Velocity = Momentum/Mass;
		Velocity.Z = FMax(Velocity.Z, 0.7 * VSize(Velocity));
		B227_bIsMoving = true;
		B227_SyncMovement();

		if (Level.Game.bTeamGame && B227_SameTeamAsOf(EventInstigator))
			return;

		Disruption += Damage;
		Disruptor = EventInstigator;
		if ( !Disrupted() )
			SetTimer(0.3, false);
		else if ( Glow != None )
			Glow.Destroy();
	}

	singular function Touch( Actor Other )
	{
		local bool bMasterTouch;
		local vector NewPos;

		if ( !Other.bIsPawn )
		{
			if (Physics == PHYS_Falling &&
				(Other.bWorldGeometry || Other.bBlockActors && Other.bBlockPlayers))
			{
				HitWall(-1 * Normal(Velocity), Other);
			}
			return;
		}
		bMasterTouch = ( Other == Instigator );

		if ( Physics == PHYS_None )
		{
			if ( bMasterTouch )
			{
				PlaySound(Sound'Botpack.Pickups.AmmoPick',,2.0);
				if (Master != none)
				{
					Master.TTarget = None;
					Master.bTTargetOut = false;
				}
				if (PlayerPawn(Other) != none)
					class'UTC_PlayerPawn'.static.UTSF_ClientWeaponEvent(PlayerPawn(Other), 'TouchTarget');
				Destroy();
			}
			return;
		}
		if ( bMasterTouch || !Other.bBlockActors && !Other.bBlockPlayers)
			return;
		NewPos = Other.Location;
		NewPos.Z = Location.Z;
		SetLocation(NewPos);
		Velocity = vect(0,0,0);
		B227_SyncMovement();
		if (Level.Game.bTeamGame && B227_SameTeamAsOf(Pawn(Other)))
			return;

		if (Bot(Instigator) != none && Master != none && Instigator.Weapon == Master)
			Master.Translocate();
	}

	simulated function HitWall(vector HitNormal, actor Wall)
	{
		local rotator NewRot;

		if ( bAlreadyHit )
		{
			bBounce = false;
			B227_SyncMovement();
			return;
		}
		bAlreadyHit = ( HitNormal.Z > 0.7 );
		B227_PlayImpactSound();
		Velocity = 0.3*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		speed = VSize(Velocity);
		if (bAlreadyHit)
		{
			NewRot.Yaw = Rotation.Yaw;
			TransformRotatorByNormal(NewRot, HitNormal);
			SetRotation(NewRot);
		}
		B227_SyncMovement();
	}

	simulated function Tick(float DeltaTime)
	{
		if (Level.NetMode != NM_DedicatedServer &&
			Level.bHighDetailMode &&
			Shadow == none)
		{
			Shadow = Spawn(class'Botpack.TargetShadow',self,,,rot(16384,0,0));
		}

		if (Level.NetMode == NM_Client)
			B227_ClientSyncMovement();
		else if (B227_SyncTimestamp > 0)
			B227_SyncMovement();

		if (Role != ROLE_Authority || B227_bOnlySyncInTick)
			return;

		if (DesiredTarget == none ||
			Master == none ||
			Instigator == none ||
			PlayerPawn(Instigator) != none)
		{
			//-Disable('Tick');
			B227_bOnlySyncInTick = true;
			if (Bot(Instigator) != none && Master != none && Instigator.Weapon == Master)
				Instigator.SwitchToBestWeapon();
			return;
		}

		if ( (Abs(Location.X - DesiredTarget.Location.X) < Instigator.CollisionRadius)
			&& (Abs(Location.Y - DesiredTarget.Location.Y) < Instigator.CollisionRadius) )
		{
			if ( !FastTrace(DesiredTarget.Location, Location) )
				return;

			Instigator.StopWaiting();
			Master.Translocate();
			if (Bot(Instigator) != none && Instigator.Weapon == Master)
				Instigator.SwitchToBestWeapon();
			//-Disable('Tick');
			B227_bOnlySyncInTick = true;
		}
	}

	simulated function BeginState()
	{
		SpawnTime = Level.TimeSeconds;
		TweenAnim('Open', 0.1);
	}

	function EndState()
	{
		DesiredTarget = None;
		if (Master != none && Bot(Instigator) != none && Instigator.Weapon == Master)
			Instigator.SwitchToBestWeapon();
	}
}

function B227_SyncMovement()
{
	super.B227_SyncMovement();
	B227_SyncRotation = Rotation;
}

simulated function B227_ClientAdjustMovement()
{
	SetRotation(B227_SyncRotation);

	if (B227_bIsMoving && Physics != PHYS_Falling)
		SetPhysics(PHYS_Falling);
	else if (!B227_bIsMoving && Physics != PHYS_None)
		SetPhysics(PHYS_None);
}

function B227_PlayImpactSound()
{
	PlaySound(ImpactSound, SLOT_Misc);  // hit wall sound
}

function bool B227_SameTeamAsOf(Pawn P)
{
	return
		Instigator != none &&
		P != none &&
		Instigator.PlayerReplicationInfo != none &&
		P.PlayerReplicationInfo != none &&
		Instigator.PlayerReplicationInfo.Team == P.PlayerReplicationInfo.Team;
}

defaultproperties
{
	DisruptionThreshold=65.000000
	GlowColor(0)=Class'Botpack.TranslocGlow'
	GlowColor(1)=Class'Botpack.TranslocBLue'
	GlowColor(2)=Class'Botpack.TranslocGreen'
	GlowColor(3)=Class'Botpack.TranslocGold'
	ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
	bNetTemporary=False
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.000000
	AmbientSound=Sound'Botpack.Translocator.targethum'
	Mesh=LodMesh'Botpack.Module'
	SoundRadius=20
	SoundVolume=100
	CollisionRadius=10.000000
	CollisionHeight=3.000000
	bProjTarget=True
	bBounce=True
	Mass=50.000000
}
