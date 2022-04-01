// ============================================================
// OLweapons.OSDAmmo3: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// Psychic_313: unchanged
// ============================================================

class OSDAmmo3 expands DAmmo3;
 simulated function PostBeginPlay()      //decals or no decals?
  {
    Super.PostBeginPlay();
    if (class'olweapons.uiweapons'.default.busedecals)
    ExplosionDecal=Class'olweapons.odenergyimpact';
    else
    ExplosionDecal=None;
    }

defaultproperties
{
}
