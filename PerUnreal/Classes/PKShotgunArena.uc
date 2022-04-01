//=============================================================================
// ShotgunArena.
// replaces all weapons and ammo with Shotguns and shells
//=============================================================================

class PKShotgunArena expands Arena;

defaultproperties
{
     WeaponName=Shotgun
     AmmoName=PKSGAmmo
     WeaponString="PerUnreal.Shotgun"
     AmmoString="PerUnreal.PKSGAmmo"
     DefaultWeapon=Class'PerUnreal.Shotgun'
}
