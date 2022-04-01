//=============================================================================
// Grenade.
//=============================================================================
class Grenade expands B227_SyncedProjectile;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

var bool bCanHitOwner, bHitWater;
var float Count, SmokeRate;
var int NumExtraGrenades;

var bool B227_bCanCrossWaterSurface;
var bool B227_bStop;

replication
{
	reliable if (Role == ROLE_Authority && !bNetInitial)
		B227_bStop;
}

simulated event PostBeginPlay()
{
	local vector X,Y,Z;

	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
		PlayAnim('still');

	RandSpin(50000);
	B227_bCanCrossWaterSurface = true;

	if ( Role == ROLE_Authority )
	{
		SetTimer(2.9+FRand()*0.5,false);                  //Grenade begins unarmed
		GetAxes(Instigator.ViewRotation,X,Y,Z);
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed +
			FRand() * 100);
		Velocity.z += 210;
		MaxSpeed = 1000;
		bCanHitOwner = False;
		if (Region.Zone.bWaterZone)
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
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

	if (VSize(NewZone.ZoneVelocity) != 0)
		B227_SyncMovement();

	if (!B227_bCanCrossWaterSurface || Region.Zone.bWaterZone == NewZone.bWaterZone)
		return;

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

simulated function Timer()
{
	Explosion(Location+Vect(0,0,1)*16);
}

simulated function Tick(float DeltaTime)
{
	local UT_BlackSmoke b;

	if (Level.NetMode == NM_DedicatedServer)
	{
		Disable('Tick');
		return;
	}

	if (Level.NetMode == NM_Client)
		B227_ClientSyncMovement();

	Count += DeltaTime;
	if ( (Count>Frand()*SmokeRate+SmokeRate+NumExtraGrenades*0.03) && (Level.NetMode!=NM_DedicatedServer) )
	{
		b = Spawn(class'UT_BlackSmoke');
		b.RemoteRole = ROLE_None;
		Count=0;
	}
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
		bBounce = False;
		SetPhysics(PHYS_None);
		B227_bStop = true;
	}

	B227_SyncMovement();
}

///////////////////////////////////////////////////////
function BlowUp(vector HitLocation)
{
	HurtRadiusProj(damage, 300, MyDamageType, MomentumTransfer, HitLocation);
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
	local WarExplosion s;

	if (Context.Level.NetMode != NM_DedicatedServer)
	{
		Context.Spawn(class'Botpack.BlastMark',,, Location, rot(16384,0,0));
		s = Context.Spawn(class'WarExplosion',,, HitLocation);
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

function B227_PlayImpactSound()
{
	PlaySound(ImpactSound, SLOT_Misc, 1.5);
}

defaultproperties
{
     speed=1200.000000
     MaxSpeed=1300.000000
     Damage=120.000000
     MomentumTransfer=55000
     MyDamageType=GrenadeDeath
     ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
     ExplosionDecal=Class'Botpack.BlastMark'
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     AnimSequence=Still
     Mesh=LodMesh'AX.Grenade'
     DrawScale=0.200000
     AmbientGlow=64
     bUnlit=True
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=11500,Yaw=5600,Roll=2300)
     B227_bReplicateExplosion=True
}
