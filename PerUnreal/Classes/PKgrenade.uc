//=============================================================================
// PKgrenade.
//=============================================================================
class PKgrenade extends Projectile;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var bool bCanHitOwner, bHitWater;
var float Count, SmokeRate;
var int NumExtraGrenades;

simulated function PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator RandRot;

	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
		PlayAnim('WingIn');
	SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed

	if ( Role == ROLE_Authority )
	{
		GetAxes(Instigator.ViewRotation,X,Y,Z);
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed +
			FRand() * 100);
		Velocity.z += 210;
		MaxSpeed = 1000;
		RandSpin(50000);
		bCanHitOwner = False;
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			bHitWater = True;
			Disable('Tick');
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

	if (!NewZone.bWaterZone || bHitWater) Return;

	bHitWater = True;
	w = Spawn(class'WaterRing',,,,rot(16384,0,0));
	w.DrawScale = 0.2;
	w.RemoteRole = ROLE_None;
	Velocity=0.6*Velocity;
}

simulated function Timer()
{
	Explosion(Location+Vect(0,0,1)*16);
}

simulated function Tick(float DeltaTime)
{
	local UT_BlackSmoke b;

	if ( bHitWater || Level.bDropDetail )
	{
		Disable('Tick');
		Return;
	}
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

simulated function ProcessTouch( actor Other, vector HitLocation )
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
	B227_MakeImpactSound();
	if ( Velocity.Z > 400 )
		Velocity.Z = 0.5 * (400 + Velocity.Z);
	else if ( speed < 20 )
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

///////////////////////////////////////////////////////
function BlowUp(vector HitLocation)
{
	HurtRadius(damage, 200, MyDamageType, MomentumTransfer, HitLocation);
	MakeNoise(1.0);
}

simulated function Explosion(vector HitLocation)
{
	local PKSpriteBallExplosion s;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
  		s = spawn(class'PKSpriteBallExplosion',,,HitLocation);
		s.RemoteRole = ROLE_None;
	}
 	Destroy();
}

function B227_MakeImpactSound()
{
	PlaySound(ImpactSound, SLOT_Misc, 1,, 1200, 0.9 + 0.2 * FRand());
}


defaultproperties
{
     speed=600.000000
     MaxSpeed=1000.000000
     Damage=80.000000
     MomentumTransfer=50000
     MyDamageType=GrenadeDeath
     ImpactSound=Sound'PerUnreal.Eightball.PKbounce'
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
}
