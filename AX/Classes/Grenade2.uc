//=============================================================================
// grenade2.
//=============================================================================
class Grenade2 extends B227_Projectile;

var chunktrail trail;
var vector initialDir;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		Velocity = Vector(Rotation) * Speed;
		Velocity.z += 200;
	}

	InitialDir = Velocity;

	if (Level.NetMode != NM_DedicatedServer)
	{
		if ( Level.bHighDetailMode  && !Level.bDropDetail )
			SetTimer(0.04,True);
		else
			SetTimer(0.25,True);
	}
}

function ProcessTouch(Actor Other, vector HitLocation)
{
	if ( Other != instigator )
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

function Landed( vector HitNormal )
{
	/*-local DirectionalBlast D;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		D = Spawn(class'DirectionalBlast', self);
		if ( D != None )
			D.DirectionalAttach(initialDir, HitNormal);
	}*/
	Explode(Location, HitNormal);
}

/*-simulated function HitWall (vector HitNormal, actor Wall)
{
	local DirectionalBlast D;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		D = Spawn(class'DirectionalBlast', self);
		if ( D != None )
			D.DirectionalAttach(initialDir, HitNormal);
	}
	Super.HitWall(HitNormal, Wall);
}
*/

simulated function Timer()
{
	local ut_SpriteSmokePuff s;

	initialDir = Velocity;
	if (Level.NetMode!=NM_DedicatedServer)
	{
		s = Spawn(class'UT_BlackSmoke');
		s.RemoteRole = ROLE_None;
	}
	if ( Level.bDropDetail )
		SetTimer(0.25,True);
	else if ( Level.bHighDetailMode )
		SetTimer(0.04,True);
}

function Explode(vector HitLocation, vector HitNormal)
{
	HurtRadiusProj(damage, 250, 'FlakDeath', MomentumTransfer, HitLocation);
	B227_SetupProjectileExplosion(Location,, HitNormal, rotator(Velocity));
	Destroy();
}

static function B227_Explode(
	Actor Context,
	vector Location,
	vector HitLocation,
	vector HitNormal,
	rotator Direction)
{
	local vector start;
	local UT_SpriteBallExplosion s;
	local DirectionalBlast D;

	if (Context.Level.NetMode != NM_DedicatedServer)
	{
		start = Location + 10 * HitNormal;
		s = Context.Spawn(class'UT_SpriteBallExplosion',,, start);
		if (s != none)
			s.RemoteRole = ROLE_None;

		D = Context.Spawn(class'DirectionalBlast',,, Location);
		if (D != none)
			D.DirectionalAttach(vector(Direction), HitNormal);
	}
}

defaultproperties
{
     speed=1200.000000
     Damage=100.000000
     MomentumTransfer=75000
     bNetTemporary=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     Mesh=LodMesh'AX.Grenade'
     DrawScale=0.200000
     AmbientGlow=67
     bUnlit=True
     B227_bReplicateExplosion=True
}
