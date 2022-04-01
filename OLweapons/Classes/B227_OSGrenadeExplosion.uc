class B227_OSGrenadeExplosion expands B227_ProjectileExplosion;

simulated function Explosion()
{
	local SpriteBallExplosion ExplosionEffect;

	ExplosionEffect = Spawn(class'SpriteBallExplosion',,, GetHitLocation());
	if (ExplosionEffect != none)
		ExplosionEffect.RemoteRole = ROLE_None;

	if (class'olweapons.uiweapons'.default.busedecals)
		Spawn(class'odBlastMark',,, GetProjLocation(), rot(16384,0,0));
}
