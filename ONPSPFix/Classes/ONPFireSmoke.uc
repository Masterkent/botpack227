class ONPFireSmoke expands ONPParticleFireSpawner;

var float tsize;

function BeginPlay()
{
	tsize = Drawscale * 0.1;
	Enable('Timer');
	SetTimer(0.1,True);
}

function Timer()
{
	Scaleglow -= 0.1;
	DrawScale += tsize;
	if (Scaleglow <= 0.0)
		Destroy();
}


function HitWall(vector HitNormal, actor Wall) 
{
	Destroy();
}


defaultproperties
{
	vAcceleration=0
	vAccelerationVariance=0
	FireTexture=None
	FireBaseSize=0.000000
	FireSizeVariance=0.000000
	hAcceleration=0
	SmokeBaseSize=0.000000
	SmokeSizeVariance=0.000000
	SmokeTexture=None
	FireRadius=0
	bSpawnSmoke=False
	SpawnDelay=0.000000
	bStasis=False
	bNetTemporary=True
	Physics=PHYS_Projectile
	RemoteRole=ROLE_None
	LifeSpan=5.000000
	Velocity=(X=0.000000,Y=0.000000,Z=100.000000)
	Style=STY_Translucent
	Texture=FireTexture'UnrealShare.Effect16.fireeffect16'
	bUnlit=True
	CollisionRadius=1.000000
	CollisionHeight=1.000000
	bCollideWorld=True
}
