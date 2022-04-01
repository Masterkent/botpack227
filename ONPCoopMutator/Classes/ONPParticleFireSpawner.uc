// This is replacement for NP32Strogg.ParticleFireSpawner.
// ParticleFireSpawner produces a lot of script warnings client-side, because it doesn't
// check the result of call to Spawn and sometimes attempts to access None after
// spawned objects have been destroyed.

class ONPParticleFireSpawner expands Effects;

#exec obj load file="..\Sounds\Ambancient.uax"

var() int vAcceleration;
var() int vAccelerationVariance;
var() texture FireTexture;
var() float FireBaseSize;
var() float FireSizeVariance;
var() int hAcceleration;
var() float SmokeBaseSize;
var() float SmokeSizeVariance;
var() texture SmokeTexture;
var() int FireRadius;
var() bool bSpawnSmoke;
var() float SpawnDelay;


var vector newloc;
var effects e;

replication
{
	reliable if (Role == Role_Authority && bNetInitial)
		FireRadius,
		vAcceleration,
		vAccelerationVariance,
		hAcceleration,
		FireBaseSize,
		FireSizeVariance,
		SmokeBaseSize,
		SmokeSizeVariance,
		SmokeTexture,
		bSpawnSmoke,
		SpawnDelay,
		FireTexture;
}

simulated function BeginPlay()
{
	Texture = None;
	if(Level.NetMode != NM_DedicatedServer)
		settimer(SpawnDelay, True);
	else
		Disable('Timer');
}


simulated function Timer()
{	
	Newloc = Vrand() * FireRadius + Location;
	Newloc.z = Location.z + 1;
	
	e = Spawn(class'ONPFireBall',,,newloc);
	if (e != none)
	{
		e.RemoteRole = ROLE_None;
		e.Texture = FireTexture;
		e.DrawScale = FireBaseSize + Frand() * FireSizeVariance;
		e.Acceleration = Vrand() * hAcceleration;
		e.Acceleration.z = vAcceleration + Rand(vAccelerationVariance);
	}
	
	if (Frand() < 0.4 && bSpawnSmoke)
	{
		newloc.z = Location.z + 20;
		e = Spawn(class'ONPFireSmoke',,,newloc);
		if (e != none)
		{
			e.RemoteRole = ROLE_None;
			e.Texture = SmokeTexture;
			e.DrawScale = SmokeBaseSize + Frand() * SmokeSizeVariance;
			e.Acceleration.z = vAcceleration + Rand(vAccelerationVariance);
			e.Velocity.z = vAcceleration;
		}
	}
}

function ReplaceOriginalSpawner(Effects e)
{
	vAcceleration = int(e.GetPropertyText("vAcceleration"));
	vAccelerationVariance = int(e.GetPropertyText("vAccelerationVariance"));
	FireTexture = FireTexture'UnrealShare.Effect1.FireEffect1pb';
	FireBaseSize = float(e.GetPropertyText("FireBaseSize"));
	FireSizeVariance = float(e.GetPropertyText("FireSizeVariance"));
	hAcceleration = int(e.GetPropertyText("hAcceleration"));
	SmokeBaseSize = float(e.GetPropertyText("SmokeBaseSize"));
	SmokeSizeVariance = float(e.GetPropertyText("SmokeSizeVariance"));
	SmokeTexture = FireTexture'UnrealShare.Effect16.fireeffect16';
	FireRadius = int(e.GetPropertyText("FireRadius"));
	bSpawnSmoke = bool(e.GetPropertyText("bSpawnSmoke"));
	SpawnDelay = float(e.GetPropertyText("SpawnDelay"));

	e.Destroy();
}


defaultproperties
{
	vAcceleration=100
	vAccelerationVariance=50
	FireTexture=FireTexture'UnrealShare.Effect1.FireEffect1pb'
	FireBaseSize=0.500000
	FireSizeVariance=0.250000
	hAcceleration=10
	SmokeBaseSize=0.750000
	SmokeSizeVariance=1.000000
	SmokeTexture=FireTexture'UnrealShare.Effect16.fireeffect16'
	FireRadius=4
	bSpawnSmoke=True
	SpawnDelay=0.200000
	bStasis=True
	bNetTemporary=False
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Sprite
	SoundRadius=12
	SoundVolume=192
	AmbientSound=Sound'Ambancient.Looping.afire4'
}
