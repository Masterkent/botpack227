//=============================================================================
// PKrocketmk2.
//=============================================================================
class PKRocketMk2 extends Projectile;

var float SmokeRate;
var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;
var	rockettrail trail;

simulated function Destroyed()
{
	if ( Trail != None )
		Trail.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	Trail = Spawn(class'RocketTrail',self);
	if ( Level.bHighDetailMode )
	{
		SmokeRate = (200 + (0.5 + 2 * FRand()) * NumExtraRockets * 24)/Speed;
		if ( Level.bDropDetail )
		{
			SoundRadius = 6;
			LightRadius = 3;
		}
	}
	else
	{
		SmokeRate = 0.15 + FRand()*(0.02+NumExtraRockets);
		LightRadius = 3;
	}
	SetTimer(SmokeRate, true);
}

simulated function Timer()
{
	local ut_SpriteSmokePuff b;

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( Level.bHighDetailMode )
	{
		if ( Level.bDropDetail || ((NumExtraRockets > 0) && (FRand() < 0.5)) )
			Spawn(class'LightSmokeTrail');
		else
			Spawn(class'UTSmokeTrail');
		SmokeRate = 152/Speed;
	}
	else
	{
		SmokeRate = 0.15 + FRand()*(0.01+NumExtraRockets);
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
	SetTimer(SmokeRate, false);
}

auto state Flying
{

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;

		if (!NewZone.bWaterZone || bHitWater) Return;

		bHitWater = True;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
			w.RemoteRole = ROLE_None;
			PlayAnim( 'Still', 3.0 );
		}
		Velocity=0.6*Velocity;
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && !Other.IsA('Projectile') )
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function BlowUp(vector HitLocation)
	{
		HurtRadius(Damage,220.0, MyDamageType, MomentumTransfer, HitLocation );
		MakeNoise(1.0);
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local PKSpriteBallExplosion s;

		s = spawn(class'PKSpriteBallExplosion',,,HitLocation + HitNormal*16);
 		s.RemoteRole = ROLE_None;

		BlowUp(HitLocation);

 		Destroy();
	}

	function BeginState()
	{
		local vector Dir;

		Dir = vector(Rotation);
		Velocity = speed * Dir;
		Acceleration = Dir * 50;
		PlayAnim( 'Wing', 0.2 );
		if (Region.Zone.bWaterZone)
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
	}
}

defaultproperties
{
     speed=700.000000
     MaxSpeed=1600.000000
     Damage=75.000000
     MomentumTransfer=80000
     MyDamageType=RocketDeath
     SpawnSound=Sound'PerUnreal.Eightball.PKrocket'
     ExplosionDecal=Class'Botpack.BlastMark'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=12.000000
     AnimSequence=Wing
     AmbientSound=Sound'PerUnreal.Eightball.PKrockfly'
     Mesh=LodMesh'Botpack.UTRocket'
     DrawScale=0.020000
     AmbientGlow=96
     bUnlit=True
     SoundVolume=255
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightRadius=6
     bBounce=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
}
