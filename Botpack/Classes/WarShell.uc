//=============================================================================
// WarShell.
//=============================================================================
class WarShell extends B227_Projectile;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var float CannonTimer, SmokeRate;
var	RedeemerTrail Trail;

simulated event Timer()
{
	local ut_SpriteSmokePuff b;

	if (bDeleteMe) // fix for 227j bug that allows calling Timer after destruction
		return;

	if (Level.NetMode != NM_DedicatedServer && (Trail == none || Trail.bDeleteMe))
	{
		Trail = Spawn(class'RedeemerTrail', self);
		if (Trail != none)
			Trail.LifeSpan = 0;
	}

	CannonTimer += SmokeRate;
	if ( CannonTimer > 0.6 )
	{
		WarnCannons();
		CannonTimer -= 0.6;
	}

	if ( Region.Zone.bWaterZone || (Level.NetMode == NM_DedicatedServer) )
	{
		SetTimer(SmokeRate, false);
		Return;
	}

	if (Level.bHighDetailMode)
	{
		if (Level.bDropDetail)
			Spawn(class'LightSmokeTrail');
		else
			Spawn(class'UTSmokeTrail');
		SmokeRate = 152/Speed;
	}
	else
	{
		SmokeRate = 0.15;
		b = Spawn(class'ut_SpriteSmokePuff');
		if (b != none)
			b.RemoteRole = ROLE_None;
	}
	SetTimer(SmokeRate, false);
}

simulated event Destroyed()
{
	if (Trail != none)
		Trail.Destroy();
	super.Destroyed();
}

simulated event PostBeginPlay()
{
	SmokeRate = 0.3;
	SetTimer(0.3, false);
}

function WarnCannons()
{
	local TeamCannon TeamCannon;

	foreach AllActors(class'TeamCannon', TeamCannon)
		TeamCannon.B227_WarnAboutWarShell(self);
}

singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, name damageType )
{
	if ( NDamage > 5 )
	{
		PlaySound(Sound'Expl03',,6.0);
		spawn(class'WarExplosion',,,Location);
		HurtRadiusProj(Damage, 350.0, MyDamageType, MomentumTransfer, HitLocation );
		RemoteRole = ROLE_SimulatedProxy;
		Destroy();
	}
}

auto state Flying
{
	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local WaterRing w;

		if (Level.NetMode == NM_DedicatedServer)
			return;

		if ( NewZone.bWaterZone != Region.Zone.bWaterZone )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = 0.2;
			w.RemoteRole = ROLE_None;
		}
	}

	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( Other != instigator )
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		if ( Role < ROLE_Authority )
			return;

		HurtRadius(Damage, 300.0, MyDamageType, MomentumTransfer, HitLocation );
		Spawn(class'ShockWave',,, HitLocation + HitNormal*16);
		B227_SetupProjectileExplosion(Location,, HitNormal);
		RemoteRole = ROLE_SimulatedProxy;
		Destroy();
	}

	function BeginState()
	{
		local vector InitialDir;

		initialDir = vector(Rotation);
		if ( Role == ROLE_Authority )
			Velocity = speed*initialDir;
		Acceleration = initialDir*50;
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
	Damage=1000.000000
	MomentumTransfer=100000
	MyDamageType=RedeemerDeath
	ExplosionDecal=Class'Botpack.NuclearMark'
	bNetTemporary=False
	RemoteRole=ROLE_SimulatedProxy
	AmbientSound=Sound'Botpack.Redeemer.WarFly'
	Mesh=LodMesh'Botpack.missile'
	AmbientGlow=78
	bUnlit=True
	SoundRadius=100
	SoundVolume=255
	CollisionRadius=15.000000
	CollisionHeight=8.000000
	bProjTarget=True
	B227_bReplicateExplosion=True
}
