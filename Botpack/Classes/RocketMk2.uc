//=============================================================================
// rocketmk2.
//=============================================================================
class RocketMk2 extends B227_SyncedProjectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var float SmokeRate;
var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;
var	RocketTrail Trail;
var B227_UTSmokeTrailEmitter B227_SmokeTrail;
var float B227_InitialSpeed;
var float B227_SmokeTrailOffset;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_InitialSpeed;
}

simulated event Destroyed()
{
	if (Trail != none)
		Trail.Destroy();
	B227_StopSmokeTrail();
	super.Destroyed();
}

simulated event PostBeginPlay()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

	Trail = Spawn(class'RocketTrail', self);

	if ( Level.bHighDetailMode )
	{
		SmokeRate = (200 + (0.5 + 2 * FRand()) * NumExtraRockets * 24)/Speed;
		if ( Level.bDropDetail )
		{
			SoundRadius = 6;
			LightRadius = 3;
		}

		B227_SetRocketTrail(Region.Zone);
		if (B227_SmokeTrail != none)
			B227_SmokeTrail.SetEmitterDelay(0.06);
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
	if (!Region.Zone.bWaterZone && VSize(Velocity) < B227_InitialSpeed)
		Velocity = Normal(Velocity) * FMin(B227_InitialSpeed, VSize(Velocity) + B227_InitialSpeed * DeltaTime);

	B227_ClientSyncMovement();

	if (VSize(Velocity) > 0)
		SetRotation(rotator(Velocity));
}

simulated event Timer()
{
	local ut_SpriteSmokePuff b;

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (Region.Zone.bWaterZone)
	{
		SetTimer(SmokeRate, false);
		return;
	}

	if (Level.bHighDetailMode)
	{
		B227_SetRocketTrail(Region.Zone);
		if (!class'UTSmokeTrail'.static.B227_ShouldReplaceWithEmitter())
		{
			if ( Level.bDropDetail || ((NumExtraRockets > 0) && (FRand() < 0.5)) )
				Spawn(class'LightSmokeTrail');
			else
				Spawn(class'UTSmokeTrail');
		}
		SmokeRate = 152/Speed;
	}
	else
	{
		B227_StopSmokeTrail();

		SmokeRate = 0.15 + FRand()*(0.01+NumExtraRockets);
		b = Spawn(class'ut_SpriteSmokePuff');
		if (b != none)
			b.RemoteRole = ROLE_None;
	}
	SetTimer(SmokeRate, false);
}

// Unreal 227 draws UTSmokeTrail differently and noticeably worse than UT (despite the same UScript code).
// This is why it was replaced with a more well-looking smoke generator here.
simulated function B227_SetRocketTrail(ZoneInfo Zone)
{
	if (!class'UTSmokeTrail'.static.B227_ShouldReplaceWithEmitter() || Zone.bWaterZone)
		B227_StopSmokeTrail();
	else if (Level.bHighDetailMode && (B227_SmokeTrail == none || B227_SmokeTrail.bDeleteMe))
	{
		B227_SmokeTrail = Spawn(class'B227_UTSmokeTrailEmitter', self);
		if (B227_SmokeTrail != none)
			B227_SmokeTrail.OffsetDistance = B227_SmokeTrailOffset;
	}
}

simulated function B227_StopSmokeTrail()
{
	if (B227_SmokeTrail != none)
	{
		B227_SmokeTrail.StopEmitting();
		B227_SmokeTrail = none;
	}
}

auto state Flying
{
	simulated function ZoneChange( ZoneInfo NewZone )
	{
		local waterring w;

		if (Level.NetMode != NM_DedicatedServer)
			B227_SetRocketTrail(NewZone);

		if (Region.Zone.bWaterZone != NewZone.bWaterZone)
		{
			if (Level.NetMode != NM_Client && NewZone.bWaterZone)
			{
				w = Spawn(class'WaterRing',,,,rot(16384,0,0));
				w.DrawScale = 0.2;
				PlayAnim( 'Still', 3.0 );
			}

			if (NewZone.bWaterZone)
			{
				bHitWater = True;
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
		HurtRadiusProj(Damage, 220.0, MyDamageType, MomentumTransfer, HitLocation );
		MakeNoise(1.0);
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		B227_SetupProjectileExplosion(Location, HitLocation, HitNormal);
		BlowUp(HitLocation);
		Destroy();
	}

	function BeginState()
	{
		local vector Dir;

		B227_InitialSpeed = Speed;
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
	local UT_SpriteBallExplosion s;

	if (Context.Level.NetMode == NM_DedicatedServer)
		return;

	s = Context.Spawn(class'UT_SpriteBallExplosion',,, HitLocation + HitNormal * 16);
	if (s != none)
		s.RemoteRole = ROLE_None; // Clients will still hear extra explosion sound when playing on a listen server.
								  // Fixing this issue would require modification of UT_SpriteBallExplosion that
								  // may affect a lot of classes that use it.

	B227_SpawnDecal(Context, default.ExplosionDecal, Location, HitNormal);
}

defaultproperties
{
	speed=900.000000
	MaxSpeed=1600.000000
	Damage=75.000000
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
	B227_SmokeTrailOffset=40
}
