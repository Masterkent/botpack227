//=============================================================================
// Translocator.
//=============================================================================
class Translocator extends TournamentWeapon
	config(Botpack);

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

// Right handed version

var TranslocatorTarget TTarget;
var float TossForce, FireDelay;
var Weapon PreviousWeapon;
var Actor DesiredTarget;
var float MaxTossForce;
var bool bBotMoveFire, bTTargetOut;

var globalconfig bool B227_bCanRecoverDisruptedModule;

replication
{
	reliable if ( bNetOwner && (Role == ROLE_Authority) )
		bTTargetOut;
}

function setHand(float Hand)
{
	if ( Hand != 2 )
	{
		if ( Hand == 0 )
			Hand = 1;
		else
			Hand *= -1;

		if ( Hand == -1 )
			Mesh = mesh(DynamicLoadObject("Botpack.TranslocR", class'Mesh'));
		else
			Mesh = mesh'Botpack.Transloc';
	}
	Super.SetHand(Hand);
}

function float RateSelf( out int bUseAltMode )
{
	return -2; 
}

function BringUp()
{
	PreviousWeapon = None;
	Super.BringUp();
}

function RaiseUp(Weapon OldWeapon)
{
	if ( OldWeapon == self )
		PreviousWeapon = None;
	else
		PreviousWeapon = OldWeapon;
	Super.BringUp();
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local float EnemyDist;

	if ( bTTargetOut )
		return -0.6;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 700 )
		return 1.0;
	else
		return -0.2;
}

function float SuggestDefenseStyle()
{
	if ( bTTargetOut )
		return 0;

	return -0.6;
}

function bool HandlePickupQuery( inventory Item )
{
	if ( Item.IsA('TranslocatorTarget') && (item == TTarget) )
	{
		TTarget.Destroy();
		TTarget = None;
		bTTargetOut = false;
		return true;
	}
	else
		return Super.HandlePickupQuery(Item);
}

function Destroyed()
{
	Super.Destroyed();
	if ( TTarget != None )
		TTarget.Destroy();
}

function SetSwitchPriority(pawn Other)
{
	AutoSwitchPriority = 0;
}

simulated function ClientWeaponEvent(name EventType)
{
	//-if ( EventType == 'TouchTarget' )
	//-	PlayIdleAnim();
}

function Fire( float Value )
{
	local bool bDisrupted;

	if ( bBotMoveFire )
		return;
	if (  TTarget == None )
	{
		if ( Level.TimeSeconds - 0.5 > FireDelay )
		{
			bPointing=True;
			bCanClientFire = true;
			ClientFire(value);
			Pawn(Owner).PlayRecoil(FiringSpeed);
			ThrowTarget();
			FireDelay = Level.TimeSeconds + 0.1;
		}
	}
	else if ( TTarget.SpawnTime < Level.TimeSeconds - 0.8 )
	{
		if (TTarget.Disrupted() &&
			!B227_bCanRecoverDisruptedModule &&
			!TTarget.B227_bIsRecoverable)
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_None, 4.0);
			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_Misc, 4.0);
			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_Interact, 4.0);
			Pawn(Owner).gibbedBy(TTarget.disruptor);
			bDisrupted = true;
		}
		else
			Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
		FireDelay = Level.TimeSeconds;
		if (bDisrupted)
			return;
	}

	GotoState('NormalFire');
}

function bool ClientFire(float Value)
{
	if ( !bTTargetOut && bCanClientFire && (Level.TimeSeconds - 0.5 > FireDelay) )
	{
		PlayFiring();
		FireDelay = Level.TimeSeconds + 0.1;
		return true;
	}
	return false;
}

function bool ClientAltFire( float Value )
{
	return true;
}

function SpawnEffect(vector Start, vector Dest)
{
	local actor e;

	e = Spawn(class'TranslocOutEffect',,,start, Owner.Rotation);
	e.Mesh = Owner.Mesh;
	e.Animframe = Owner.Animframe;
	e.Animsequence = Owner.Animsequence;
	e.Velocity = 900 * Normal(Dest - Start);
}

function Translocate()
{
	local vector Dest, Start;
	local Bot B;
	local Pawn P;

	bBotMoveFire = false;
	PlayAnim('Thrown', 1.2,0.1);
	Dest = TTarget.Location;
	if ( TTarget.Physics == PHYS_None )
		Dest += vect(0,0,40);

	if ( Level.Game.IsA('DeathMatchPlus') 
		&& !DeathMatchPlus(Level.Game).AllowTranslocation(Pawn(Owner), Dest) )
		return;

	Start = Pawn(Owner).Location;
	TTarget.SetCollision(false,false,false);
	if ( Pawn(Owner).SetLocation(Dest) )
	{
		if ( !Owner.Region.Zone.bWaterZone )
			Owner.SetPhysics(PHYS_Falling);
		if ( TTarget.Disrupted() )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			SpawnEffect(Start, Dest);
			Pawn(Owner).gibbedBy(TTarget.disruptor);

			bTTargetOut = false;
			TTarget.Destroy();
			TTarget = none;

			return;
		}

		if ( !FastTrace(Pawn(Owner).Location, TTarget.Location) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Pawn(Owner).SetLocation(Start);
			Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		}
		else 
		{ 
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Owner.Velocity.X = 0;
			Owner.Velocity.Y = 0;
			B = Bot(Owner);
			if ( B != None )
			{
				if ( TTarget.DesiredTarget.IsA('NavigationPoint') )
					B.MoveTarget = TTarget.DesiredTarget;
				B.bJumpOffPawn = true;
				if ( !Owner.Region.Zone.bWaterZone )
					B.SetFall();
			}
			else
			{
				// bots must re-acquire this player
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( (P.Enemy == Owner) && P.IsA('Bot') )
						Bot(P).LastAcquireTime = Level.TimeSeconds;
			}

			Level.Game.PlayTeleportEffect(Owner, true, true);
			SpawnEffect(Start, Dest);
		}
	} 
	else 
	{
		Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	}

	if ( TTarget != None )
	{
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
	}
	bPointing=True;
}

function AltFire( float Value )
{
	if ( bBotMoveFire )
		return;

	GotoState('NormalFire');

	if ( TTarget != None )
		Translocate();
}

function ReturnToPreviousWeapon()
{
	if ( (PreviousWeapon == None)
		|| ((PreviousWeapon.AmmoType != None) && (PreviousWeapon.AmmoType.AmmoAmount <=0)) )
		Pawn(Owner).SwitchToBestWeapon();
	else
	{
		Pawn(Owner).PendingWeapon = PreviousWeapon;
		PutDown();
	}
}

function PlayFiring()
{
	PlaySound(FireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
	PlayAnim('Throw',1.0,0.1);
}

function ThrowTarget()
{
	local Vector Start, X,Y,Z;

	if (Level.Game.LocalLog != None)
		Level.Game.LocalLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	if (Level.Game.WorldLog != None)
		Level.Game.WorldLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);

	if ( Owner.IsA('Bot') )
		bBotMoveFire = true;
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	Pawn(Owner).ViewRotation = Pawn(Owner).AdjustToss(TossForce, Start, 0, true, true); 
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	TTarget = Spawn(class'TranslocatorTarget',,, Start);
	if (TTarget!=None)
	{
		bTTargetOut = true;
		TTarget.Master = self;
		if ( Owner.IsA('Bot') )
			TTarget.SetCollisionSize(0,0); 
		TTarget.Throw(Pawn(Owner), MaxTossForce, Start);
	}
	else GotoState('Idle');
}

state NormalFire
{
	ignores fire, altfire, AnimEnd;

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	if ( Owner.IsA('Bot') )
		Bot(Owner).SwitchToBestWeapon();
	Sleep(0.1);
	if ( (Pawn(Owner).bFire != 0) && (Pawn(Owner).bAltFire != 0) )
	 	ReturnToPreviousWeapon();
	GotoState('Idle');
}

state Idle
{
	function AnimEnd()
	{
		PlayIdleAnim();
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);
	Disable('AnimEnd');
	FinishAnim();
	PlayIdleAnim();
}


///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if ( bTTargetOut )
		LoopAnim('Idle', 0.4);
	else  
		LoopAnim('Idle2',0.2,0.1);
	Enable('AnimEnd');
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	if ( bTTargetOut )
		TweenAnim('ThrownFrame', 0.27);
	else
		PlayAnim('Select',1.1, 0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc,Pawn(Owner).SoundDampening);
}


function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.36 );
	else
	{
		if ( bTTargetOut ) PlayAnim('Down2', 1.1, 0.05);
		else PlayAnim('Down', 1.1, 0.05);
	}
}

function PlayPostSelect()
{
	local actor RealTarget;

	// If Bot is wanting a specific target fired at, do it
	if ( DesiredTarget != None )
	{
		TossForce = MaxTossForce;
		RealTarget = Owner.Target;
		Owner.Target = DesiredTarget;
		ThrowTarget();
		PlayFiring();
		Owner.Target = RealTarget;
		TTarget.DesiredTarget = DesiredTarget;
		DesiredTarget = None;
	}
}

defaultproperties
{
	MaxTossForce=830.000000
	WeaponDescription="Classification: Personal Teleportation Device\n\nPrimary Fire: Launches the destination module.  Throw the module to the location you would like to teleport to.\n\nSecondary Fire: Activates the translocator and teleports the user to the destination module.\n\nTechniques: Throw your destination module at another player and then activate the secondary fire, and you will telefrag your opponent!  If you press your primary fire button when activating your translocator with the secondary fire, the last weapon you had selected will automatically return once you have translocated."
	PickupAmmoCount=1
	bCanThrow=False
	FiringSpeed=1.000000
	FireOffset=(X=15.000000,Y=-13.000000,Z=-7.000000)
	AIRating=-1.000000
	FireSound=Sound'Botpack.Translocator.ThrowTarget'
	AltFireSound=Sound'Botpack.Translocator.ReturnTarget'
	DeathMessage="%k telefragged %o!"
	AutoSwitchPriority=0
	PickupMessage="You got the Translocator Source Module."
	ItemName="Translocator"
	RespawnTime=0.000000
	PlayerViewOffset=(X=5.000000,Y=-4.200000,Z=-7.000000)
	PlayerViewMesh=LodMesh'Botpack.Transloc'
	PickupViewMesh=LodMesh'Botpack.Trans3loc'
	ThirdPersonMesh=LodMesh'Botpack.Trans3loc'
	StatusIcon=Texture'Botpack.Icons.UseTrans'
	Icon=Texture'Botpack.Icons.UseTrans'
	Mesh=LodMesh'Botpack.Trans3loc'
	bNoSmooth=False
	CollisionRadius=8.000000
	CollisionHeight=3.000000
	Mass=10.000000
}
