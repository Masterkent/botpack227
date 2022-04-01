//=============================================================================
//
//=============================================================================
class smokeproj extends UT_Grenade;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

var() float  SmokeSpeed;
var() float  SmokeRate;
var() Vector SmokeAccel;
var() float  SmokeDelay;
var() float  SmokeDelayVariance;
var() float  SpeedVariance;
var() float  BasePuffSize; // Size of cloud
var() float  SizeVariance;
var() float SmokeDamageRadius;
var() Int SmokeDamage;
var() float SmokeRefresh,SmokeStartTime;
var() int SmokeLife;
var Bool bSteam;
var int countX;


simulated function PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator RandRot;

	Super.PostBeginPlay();
	bSteam=False;
	if ( Level.NetMode != NM_DedicatedServer )
		PlayAnim('WingIn');
	Enable('Timer');
	SetTimer(SmokeStartTime,false);


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

local ADSpriteSmokePuff b;




  b = Spawn(class'ADSpriteSmokePuff');
  HurtRadius(SmokeDamage, SmokeDamageRadius, MyDamageType, MomentumTransfer,Location);
  b.DrawScale = BasePuffSize+FRand()*SizeVariance*5;
  b.Acceleration = SmokeAccel;
  countX++;
  If (CountX >= SmokeLife)
	{
	Disable('Timer');
	Explosion(Location+Vect(0,0,1)*16);
	Return;
	}
  SetTimer(SmokeRefresh,false);


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
	if (bSteam==False)
	{
	Enable('Timer');
	SetTimer(0.01,false);
	bSteam=True;
	}

	HitWall( HitNormal, None );
}

//simulated function ProcessTouch( actor Other, vector HitLocation )
//{
//
//
//
//}

simulated function HitWall( vector HitNormal, actor Wall )
{
	bCanHitOwner = True;
	Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	RandSpin(100000);
	speed = VSize(Velocity);
	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, 1.5 );
	if ( Velocity.Z > 400 )
		Velocity.Z = 0.5 * (400 + Velocity.Z);
	else if ( speed < 30 )
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
	local UT_SpriteBallExplosion s;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
  		s = spawn(class'UT_SpriteBallExplosion',,,HitLocation);
		s.DrawScale=0.3;
		s.RemoteRole = ROLE_None;
	}
 	//AmbientSound = none;
	Destroy();
}

defaultproperties
{
     SmokeSpeed=5.000000
     SmokeRate=5.000000
     SmokeAccel=(X=10.000000,Y=10.000000,Z=10.000000)
     SmokeDelay=0.120000
     SmokeDelayVariance=0.500000
     SpeedVariance=1.000000
     BasePuffSize=15.000000
     SizeVariance=1.000000
     SmokeDamageRadius=250.000000
     SmokeDamage=12
     SmokeRefresh=0.450000
     SmokeStartTime=1.500000
     SmokeLife=22
     speed=500.000000
     MaxSpeed=500.000000
     Damage=10.000000
     MomentumTransfer=50
     MyDamageType=Corroded
     ImpactSound=Sound'addweap.Smoke.smokebump'
     AmbientSound=Sound'addweap.Smoke.smokesound'
     Mesh=LodMesh'addweap.smokegasgrenade'
     SoundVolume=128
}
