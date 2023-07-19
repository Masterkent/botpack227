//=============================================================================
// flakslug.
//=============================================================================
class flakslug extends B227_Projectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

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

	class'UTC_GameInfo'.static.B227_SetDamageWeaponClass(Level, B227_DamageWeaponClass);
	HurtRadiusProj(damage, 150, 'FlakDeath', MomentumTransfer, HitLocation);
	class'UTC_GameInfo'.static.B227_ResetDamageWeaponClass(Level);

	start = Location + 10 * HitNormal;
	Spawn( class'ut_FlameExplosion',,,Start);

	class'B227_Projectile'.default.B227_DamageWeaponClass = B227_DamageWeaponClass;

	Spawn( class 'UTChunk2',, '', Start);
	Spawn( class 'UTChunk3',, '', Start);
	Spawn( class 'UTChunk4',, '', Start);
	Spawn( class 'UTChunk1',, '', Start);
	Spawn( class 'UTChunk2',, '', Start);

	class'B227_Projectile'.default.B227_DamageWeaponClass = none;

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
