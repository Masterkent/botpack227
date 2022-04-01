//=============================================================================
// Grenade.
//=============================================================================
class UT_Grenade extends B227_SyncedProjectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var bool bCanHitOwner, bHitWater;
var float Count, SmokeRate;
var int NumExtraGrenades;

var bool B227_bHandleZoneChange;
var bool B227_bStop;

replication
{
	reliable if (Role == ROLE_Authority && !bNetInitial)
		B227_bStop;
}

simulated event PostBeginPlay()
{
	local vector X,Y,Z;

	super.PostBeginPlay();
	if (Level.NetMode != NM_DedicatedServer)
		PlayAnim('WingIn');

	RandSpin(50000);

	if (Role == ROLE_Authority)
	{
		SetTimer(2.5 + FRand() * 0.5, false); // Grenade begins unarmed
		if (Instigator != none)
		{
			GetAxes(Instigator.ViewRotation, X, Y, Z);
			Velocity = X * (Instigator.Velocity dot X) * 0.4 + vector(Rotation) * (Speed + FRand() * 100);
		}
		else
			Velocity = vector(Rotation) * (Speed + FRand() * 100);
		Velocity.z += 210;
		MaxSpeed = 1000;
		bCanHitOwner = false;
		B227_bHandleZoneChange = true;
		if (Region.Zone.bWaterZone)
		{
			bHitWater = true;
			Velocity = 0.6 * Velocity;
		}
	}
}

simulated function BeginPlay()
{
	if ( Level.bHighDetailMode && !Level.bDropDetail ) 
		SmokeRate = 0.03;
	else 
		SmokeRate = 0.15;
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	local waterring w;

	if (!B227_bHandleZoneChange)
		return;

	if (Region.Zone.bWaterZone != NewZone.bWaterZone)
	{
		if (Level.NetMode != NM_Client)
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
		}

		if (NewZone.bWaterZone)
		{
			bHitWater = true;
			Velocity = 0.6 * Velocity;
		}
	}
	if (VSize(NewZone.ZoneVelocity) != 0)
		B227_SyncMovement();
}

function Timer()
{
	Explosion(Location+Vect(0,0,1)*16);
}

simulated function Tick(float DeltaTime)
{
	if (Level.NetMode != NM_DedicatedServer)
		B227_MakeGrenadeTrail(DeltaTime);
	if (Level.NetMode == NM_Client)
		B227_ClientSyncMovement();
}

simulated function Landed( vector HitNormal )
{
	HitWall( HitNormal, None );
}

function ProcessTouch( actor Other, vector HitLocation )
{
	if ( (Other!=instigator) || bCanHitOwner )
		Explosion(HitLocation);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	bCanHitOwner = True;
	Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	RandSpin(100000);
	speed = VSize(Velocity);
	B227_PlayImpactSound();
	if ( Velocity.Z > 400 )
		Velocity.Z = 0.5 * (400 + Velocity.Z);
	else if (speed < 20 && Level.NetMode != NM_Client)
	{
		bBounce = false;
		SetPhysics(PHYS_None);
		B227_bStop = true;
	}

	B227_SyncMovement();
}

///////////////////////////////////////////////////////
function BlowUp(vector HitLocation)
{
	HurtRadiusProj(damage, 200, MyDamageType, MomentumTransfer, HitLocation);
	MakeNoise(1.0);
}

function Explosion(vector HitLocation)
{
	BlowUp(HitLocation);
	B227_SetupProjectileExplosion(Location, HitLocation);
	Destroy();
}

static function B227_Explode(Actor Context, vector Location, vector HitLocation, vector HitNormal, rotator Direction)
{
	local UT_SpriteBallExplosion s;

	if (Context.Level.NetMode != NM_DedicatedServer)
	{
		Context.Spawn(class'Botpack.BlastMark',,, Location, rot(16384, 0, 0));
		s = Context.Spawn(class'UT_SpriteBallExplosion',,, HitLocation);
		if (s != none)
			s.RemoteRole = ROLE_None;
	}
}

simulated function B227_ClientAdjustMovement()
{
	if (B227_bStop)
	{
		bBounce = false;
		SetPhysics(PHYS_None);
	}
}

simulated function B227_MakeGrenadeTrail(float DeltaTime)
{
	local UT_BlackSmoke b;

	if (Region.Zone.bWaterZone || Level.bDropDetail) 
		return;

	Count += DeltaTime;
	if (Count > Frand() * SmokeRate + SmokeRate + NumExtraGrenades * 0.03)
	{
		b = Spawn(class'UT_BlackSmoke');
		b.RemoteRole = ROLE_None;
		Count = 0;
	}
}

function B227_PlayImpactSound()
{
	PlaySound(ImpactSound, SLOT_Misc, 1.5);
}

defaultproperties
{
	speed=600.000000
	MaxSpeed=1000.000000
	Damage=80.000000
	MomentumTransfer=50000
	MyDamageType=GrenadeDeath
	ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
	ExplosionDecal=Class'Botpack.BlastMark'
	Physics=PHYS_Falling
	RemoteRole=ROLE_SimulatedProxy
	AnimSequence=WingIn
	Mesh=LodMesh'Botpack.UTGrenade'
	DrawScale=0.020000
	AmbientGlow=64
	bUnlit=True
	bBounce=True
	bFixedRotationDir=True
	DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
	B227_bReplicateExplosion=True
	bNetTemporary=False
}
