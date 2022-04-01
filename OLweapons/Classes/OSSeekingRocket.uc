// ============================================================
// OLweapons.OSSeekingRocket: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// Psychic_313: unchanged
// ============================================================

class OSSeekingRocket expands SeekingRocket;
simulated function PostBeginPlay()      //decals or no decals?
  {
    Super.PostBeginPlay();
    if (class'olweapons.uiweapons'.default.busedecals)
    ExplosionDecal=Class'odBlastMark';
    else
    ExplosionDecal=None;
    }

defaultproperties
{
}
