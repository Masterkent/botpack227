// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// NoWeaponSkaarjTrooper : Quick hack so no bisplayer crap... for weaponless skaarj
// ===============================================================

class NoWeaponSkaarjTrooper expands SkaarjTrooper;

auto state Startup
{
  function BeginState()
  {
    Super(ScriptedPawn).BeginState();
  }
}

defaultproperties
{
     WeaponType=None
     CombatStyle=1.000000
}
