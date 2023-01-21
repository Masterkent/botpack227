//=============================================================================
// flakslug.
//=============================================================================
class flakslug extends B227_Projectile;

#exec MESH IMPORT MESH=flakslugm ANIVFILE=MODELS\flakslug_a.3D DATAFILE=MODELS\flakslug_d.3D
#exec MESH LODPARAMS MESH=flakslugm STRENGTH=0.3
#exec MESH ORIGIN MESH=flakslugm X=0 Y=0 Z=0 YAW=128 PITCH=64
#exec MESH SEQUENCE MESH=flakslugm SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=flakslugm SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jflakslugel1 FILE=MODELS\flakslug.PCX
#exec MESHMAP SCALE MESHMAP=flakslugm X=0.019 Y=0.019 Z=0.038
#exec MESHMAP SETTEXTURE MESHMAP=flakslugm NUM=1 TEXTURE=Jflakslugel1 TLOD=50

var	chunktrail trail;
var vector initialDir;

simulated function PostBeginPlay()
{
	if ( !Region.Zone.bWaterZone && (Level.NetMode != NM_DedicatedServer) )
		Trail = Spawn(class'ChunkTrail',self);

	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * Speed;
	initialDir = Velocity;
	Velocity.z += 200; 
	initialDir = Velocity;
	if ( Level.bHighDetailMode  && !Level.bDropDetail ) 
		SetTimer(0.04,True);
	else 
		SetTimer(0.25,True);
}

function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( Other != instigator ) 
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

event Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

event HitWall(vector HitNormal, Actor Wall)
{
	super.HitWall(HitNormal, Wall);
}

simulated function Timer()
{
	local ut_SpriteSmokePuff s;

	initialDir = Velocity;
	if (Level.NetMode!=NM_DedicatedServer) 
	{
		s = Spawn(class'ut_SpriteSmokePuff');
		s.RemoteRole = ROLE_None;
	}
	if ( Level.bDropDetail )
		SetTimer(0.25,True);
	else if ( Level.bHighDetailMode )
		SetTimer(0.04,True);
}

function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;

	MakeNoise(1.0);
	B227_SetupProjectileExplosion(Location,, HitNormal, rotator(Velocity));

	HurtRadiusProj(damage, 150, 'FlakDeath', MomentumTransfer, HitLocation);
	start = Location + 10 * HitNormal;
 	Spawn( class'ut_FlameExplosion',,,Start);
	Spawn( class 'UTChunk2',, '', Start);
	Spawn( class 'UTChunk3',, '', Start);
	Spawn( class 'UTChunk4',, '', Start);
	Spawn( class 'UTChunk1',, '', Start);
	Spawn( class 'UTChunk2',, '', Start);
	Destroy();
}

static function B227_Explode(
	Actor Context,
	vector Location,
	vector HitLocation,
	vector HitNormal,
	rotator Direction)
{
	local DirectionalBlast D;

	D = Context.Spawn(class'UnrealShare.DirectionalBlast',,, Location, Direction);
	if (D != none)
		D.DirectionalAttach(vector(Direction), HitNormal);
}

defaultproperties
{
	speed=1200.000000
	Damage=70.000000
	MomentumTransfer=75000
	bNetTemporary=False
	Physics=PHYS_Falling
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=6.000000
	Mesh=LodMesh'Botpack.flakslugm'
	AmbientGlow=67
	bUnlit=True
	B227_bReplicateExplosion=True
}
