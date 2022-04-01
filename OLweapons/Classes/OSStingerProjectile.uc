// ============================================================
// OLweapons.OSStingerProjectile
// Psychic_313: unchanged
// ============================================================

class OSStingerProjectile expands StingerProjectile;

simulated function PostBeginPlay()      //decals or no decals?
  {
    Super.PostBeginPlay();
    if (class'olweapons.uiweapons'.default.busedecals)
    ExplosionDecal=Class'odpock';
    else
    ExplosionDecal=None;
    }

defaultproperties
{
}
