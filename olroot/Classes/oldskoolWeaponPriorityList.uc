// ============================================================
// olweapons.oldskoolWeaponPriorityList: lets us fine olweapons. stuff......
// ============================================================

class oldskoolWeaponPriorityList expands UMenuWeaponPriorityList;
function bool ShowThisItem()
{
  return bFound;        //always show......
}
// oldstuff:
// && (Left(WeaponClassName, 8) ~= "Botpack." || Left(WeaponClassName, 10) ~= "OLweapons." || Left(WeaponClassName, 7) ~= "legacy.")

defaultproperties
{
}
