class B227_Projectile expands Projectile;

var bool B227_bReplicateExplosion;
var class<Weapon> B227_DamageWeaponClass;

event PreBeginPlay()
{
	super.PreBeginPlay();
	B227_DamageWeaponClass = class'B227_Projectile'.default.B227_DamageWeaponClass;
}

function B227_SetupProjectileExplosion(
	optional vector ProjLocation,
	optional vector HitLocation,
	optional vector HitNormal,
	optional rotator Direction)
{
	local B227_ProjectileExplosion PE;

	if (Level.NetMode != NM_Client || !B227_bReplicateExplosion)
		B227_Explode(self, Location, HitLocation, HitNormal, Direction);

	if (B227_bReplicateExplosion &&
		(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer))
	{
		PE = Spawn(class'B227_ProjectileExplosion');
		if (PE != none)
			PE.SetExplosionInfo(Class, ProjLocation, HitLocation, HitNormal, Direction);
	}
}

static function B227_Explode(
	Actor Context,
	vector Location,
	vector HitLocation,
	vector HitNormal,
	rotator Direction);

static function B227_SpawnDecal(
	Actor Context,
	class<Decal> ExplosionDecal,
	vector Location,
	vector HitNormal)
{
	if (Context.Level.NetMode != NM_DedicatedServer)
		Context.Spawn(ExplosionDecal, Context,, Location, rotator(HitNormal));
}

simulated event HitWall(vector HitNormal, Actor Wall)
{
	if (Role == ROLE_Authority)
	{
		if (Mover(Wall) != none && Mover(Wall).bDamageTriggered)
			Wall.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');

		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if (!B227_bReplicateExplosion && ExplosionDecal != none)
		B227_SpawnDecal(self, ExplosionDecal, Location, HitNormal);
}

defaultproperties
{
	B227_bReplicateExplosion=False
	bNetTemporary=False
}
