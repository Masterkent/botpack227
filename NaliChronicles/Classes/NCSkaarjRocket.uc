// Skaarj rocket
// Code by Sergey 'Eater' Levin, 2002

class NCSkaarjRocket extends Projectile;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

var float SmokeRate;
var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;
var	rockettrail trail;

simulated function Destroyed()
{
	if (trail != none)
		trail.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

	trail = Spawn(class'RocketTrail',self);
	if ( Level.bHighDetailMode )
	{
		SmokeRate = 200/Speed;
		if ( Level.bDropDetail )
		{
			SoundRadius = 6;
			LightRadius = 3;
		}
	}
	else
	{
		SmokeRate = 0.15 + FRand()*0.02;
		LightRadius = 3;
	}
	SetTimer(SmokeRate, true);
}

simulated function Timer() // same as UT rocket... almost
{
	local ut_SpriteSmokePuff b;

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( Level.bHighDetailMode )
	{
		if (Level.bDropDetail)
			Spawn(class'LightSmokeTrail');
		else
			Spawn(class'UTSmokeTrail');
		SmokeRate = 152/Speed;
	}
	else
	{
		SmokeRate = 0.15 + FRand()*0.01;
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
	Spawn(class'GreenBloodPuff');
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
		}
		Velocity=0.75*Velocity;
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && !Other.IsA('Projectile') ) {
			Other.TakeDamage(35, instigator,HitLocation,(MomentumTransfer * Normal(Velocity)), 'shredded' );
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	function BlowUp(vector HitLocation)
	{
		HurtRadiusProj(Damage,170.0, MyDamageType, MomentumTransfer, HitLocation );
		MakeNoise(1.0);
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local FlameExplosion s;

		s = spawn(class'FlameExplosion',,,HitLocation + HitNormal*16);
 		s.RemoteRole = ROLE_None;

		BlowUp(HitLocation);

 		Destroy();
	}

	function BeginState()
	{
		local vector Dir;
		local rotator newrot;

		Dir = vector(Rotation);
		Velocity = speed * Dir;
		Acceleration = Dir * 50;
		if (Region.Zone.bWaterZone)
		{
			bHitWater = True;
			Velocity=0.75*Velocity;
		}
	}
}

defaultproperties
{
     speed=850.000000
     MaxSpeed=1400.000000
     Damage=90.000000
     MomentumTransfer=70000
     MyDamageType=RocketDeath
     SpawnSound=Sound'UnrealShare.Eightball.Ignite'
     ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
     ExplosionDecal=Class'Botpack.BlastMark'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     AnimSequence=Wing
     AmbientSound=Sound'Botpack.PulseGun.PulseFly'
     Mesh=LodMesh'NaliChronicles.skaarjrock'
     DrawScale=1.100000
     AmbientGlow=96
     bUnlit=True
     SoundRadius=14
     SoundVolume=255
     SoundPitch=100
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=140
     LightRadius=6
     bBounce=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
}
