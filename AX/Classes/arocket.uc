//=============================================================================
// arocket 1 slower more damage.
//=============================================================================
class arocket extends B227_SyncedProjectile;

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

simulated event Tick(float DeltaTime)
{
	if (Level.NetMode == NM_Client)
		B227_ClientSyncMovement();
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

		if (Region.Zone.bWaterZone != NewZone.bWaterZone)
		{
			if ( Level.NetMode != NM_DedicatedServer )
			{
				w = Spawn(class'WaterRing',,,,rot(16384,0,0));
				w.DrawScale = 0.2;
				w.RemoteRole = ROLE_None;
				PlayAnim( 'Still', 3.0 );
			}
			if (Region.Zone.bWaterZone)
			{
				bHitWater = true;
				Velocity = 0.6 * Velocity;
			}
		}
		if (VSize(NewZone.ZoneVelocity) != 0)
			B227_SyncMovement();
	}

	function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && !Other.IsA('Projectile') )
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function BlowUp(vector HitLocation)
	{
		HurtRadiusProj(Damage,220.0, MyDamageType, MomentumTransfer, HitLocation );
		MakeNoise(1.0);
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		spawn(class'axshockwave',,,HitLocation + HitNormal*16);
		B227_SetupProjectileExplosion(Location,, HitNormal);

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

static function B227_Explode(Actor Context, vector Location, vector HitLocation, vector HitNormal, rotator Direction)
{
	if (Context.Level.NetMode != NM_DedicatedServer)
		B227_SpawnDecal(Context, default.ExplosionDecal, Location, HitNormal);
}

defaultproperties
{
     speed=600.000000
     MaxSpeed=1600.000000
     Damage=100.000000
     MomentumTransfer=80000
     MyDamageType=RocketDeath
     SpawnSound=Sound'UnrealShare.Eightball.Ignite'
     ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
     ExplosionDecal=Class'Botpack.BlastMark'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     AnimSequence=Wing
     AmbientSound=Sound'Botpack.RocketLauncher.RocketFly1'
     Mesh=LodMesh'Botpack.UTRocket'
     DrawScale=0.020000
     AmbientGlow=96
     bUnlit=True
     SoundRadius=14
     SoundVolume=255
     SoundPitch=100
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightRadius=6
     bBounce=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     B227_bReplicateExplosion=True
     bNetTemporary=False
}
