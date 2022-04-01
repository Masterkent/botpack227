//=============================================================================
// UTSmokeTrail.
//=============================================================================
class UTSmokeTrail extends Effects
	config(Botpack);

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var int Curr;
var bool bRandomize, bEven;
var int Vert[8];

var config bool B227_bReplaceWithEmitter;    // Use B227_UTSmokeTrailEmitter for projectiles that support such replacement
var config bool B227_bReplaceWithSmokePuffs; // Simulate particles using ut_SpriteSmokePuff actors

var int B227_NumSmokePuffs;

function PostBeginPlay()
{
	if (B227_bReplaceWithSmokePuffs)
		B227_SpawnSmokePuffs();
	else
	{
		Super.PostBeginPlay();
		SetTimer(1.4, false);
		if ( bRandomize && (FRand() < 0.4) )
			MultiSkins[5 + Rand(2)] = Texture'Botpack.utsmoke.us3_a00';
	}
}

function B227_SpawnSmokePuffs()
{
	local int i;
	local ut_SpriteSmokePuff Particle;

	bHidden = true;
	for (i = 0; i < B227_NumSmokePuffs; ++i)
	{
		Particle = Spawn(class'ut_SpriteSmokePuff', self,, Location - vector(Rotation) * i * 22.5);
		if (Particle != none)
			Particle.RemoteRole = ROLE_None;
	}
}

function Timer()
{
	if ( Curr >= 0 )
	{
		MultiSkins[Vert[Curr]] = None;
		Curr--;
		if ( Curr >= 0 )
			SetTimer(0.025, false);
	}
}

defaultproperties
{
	Curr=7
	bRandomize=True
	Vert(0)=1
	Vert(1)=7
	Vert(2)=3
	Vert(3)=6
	Vert(4)=2
	Vert(5)=5
	Vert(7)=4
	Physics=PHYS_Projectile
	RemoteRole=ROLE_None
	LifeSpan=1.600000
	Velocity=(Z=50.000000)
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'Botpack.utsmoke.us1_a00'
	Mesh=LodMesh'Botpack.Smokebm'
	DrawScale=2.000000
	ScaleGlow=0.800000
	bUnlit=True
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'Botpack.utsmoke.us8_a00'
	MultiSkins(1)=Texture'Botpack.utsmoke.US3_A00'
	MultiSkins(2)=Texture'Botpack.utsmoke.us8_a00'
	MultiSkins(3)=Texture'Botpack.utsmoke.us2_a00'
	MultiSkins(4)=Texture'Botpack.utsmoke.us1_a00'
	MultiSkins(5)=Texture'Botpack.utsmoke.us2_a00'
	MultiSkins(6)=Texture'Botpack.utsmoke.us1_a00'
	MultiSkins(7)=Texture'Botpack.utsmoke.us8_a00'
	B227_NumSmokePuffs=8
	B227_bReplaceWithEmitter=True
	B227_bReplaceWithSmokePuffs=True
}
