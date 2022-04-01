// ============================================================
// OLweapons.OSRazorBladeAlt: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// Psychic_313: unchanged
// ============================================================

class OSRazorBladeAlt expands RazorBladeAlt;
auto state Flying
{
simulated function HitWall (vector HitNormal, actor Wall)
  {
  super.Hitwall(hitnormal,wall);
  If (class'olweapons.uiweapons'.default.bUseDecals)
  Spawn(class'odWallCrack',,,Location, rotator(HitNormal)); } }

defaultproperties
{
}
