//=============================================================================
// PKflakslug.
//=============================================================================
class PKflakslug extends Projectile;

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

simulated function Landed( vector HitNormal )
{
	local DirectionalBlast D;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		D = Spawn(class'UnrealShare.DirectionalBlast',self);
		if ( D != None )
			D.DirectionalAttach(initialDir, HitNormal);
	}
	Explode(Location,HitNormal);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	local DirectionalBlast D;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		D = Spawn(class'UnrealShare.DirectionalBlast',self);
		if ( D != None )
			D.DirectionalAttach(initialDir, HitNormal);
	}
	Super.HitWall(HitNormal, Wall);
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

	HurtRadius(damage, 150, 'FlakDeath', MomentumTransfer, HitLocation);
	start = Location + 10 * HitNormal;
 	Spawn( class'PKFlakExplosion',,,Start);
	Spawn( class 'UTChunk2',, '', Start);
	Spawn( class 'UTChunk3',, '', Start);
	Spawn( class 'UTChunk4',, '', Start);
	Spawn( class 'UTChunk1',, '', Start);
	Spawn( class 'UTChunk2',, '', Start);
 	Destroy();
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
}
