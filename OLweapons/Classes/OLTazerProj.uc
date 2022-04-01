// ============================================================
// OLweapons.OLTazerProj: Decals, decals.....
// Psychic_313: unchanged
// ============================================================

class OLTazerProj expands TazerProj;
//allows decals...
function SuperExplosion()
{
  local RingExplosion2 r;

  HurtRadius(Damage*3.9, 240, 'jolted', MomentumTransfer*2, Location );

  r = Spawn(Class'OSRingExplosion2',,'',Location, Instigator.ViewRotation);
  r.PlaySound(r.ExploSound,,20.0,,1000,0.6);
  Destroy();
}
simulated function PostBeginPlay()      //decals or no decals?
  {
    Super.PostBeginPlay();
    if (class'olweapons.uiweapons'.default.busedecals)
    ExplosionDecal=Class'Botpack.EnergyImpact';
    else
    ExplosionDecal=None;
    }

defaultproperties
{
}
