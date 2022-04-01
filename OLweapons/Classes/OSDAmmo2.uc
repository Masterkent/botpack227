// ============================================================
// OLweapons.OSDAmmo2: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// Psychic_313: unchanged
// ============================================================

class OSDAmmo2 expands DAmmo2;
simulated function PostBeginPlay()      //decals or no decals?
  {
    Super.PostBeginPlay();
    if (class'olweapons.uiweapons'.default.busedecals)
    ExplosionDecal=Class'odenergyimpact';
    else
    ExplosionDecal=None;
    }

defaultproperties
{
}
