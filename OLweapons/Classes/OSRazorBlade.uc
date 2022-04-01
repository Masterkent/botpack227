// ============================================================
// OLweapons.OSRazorBlade: makes use of decals and nothing more....
// Psychic_313: unchanged
// ============================================================

class OSRazorBlade expands RazorBlade;
auto state Flying
{
simulated function HitWall (vector HitNormal, actor Wall)
  {
  super.Hitwall(hitnormal,wall);
  If (class'olweapons.uiweapons'.default.bUseDecals)
  Spawn(class'odWallCrack',,,Location, rotator(HitNormal));    }
  }

defaultproperties
{
}
