// ===============================================================
// SevenB.USMThighPads: blocks bullets completely
// ===============================================================

class USMThighPads extends ThighPads;

function ArmorImpactEffect(vector HitLocation)
{
  if ( Owner.IsA('PlayerPawn') )
  {
    PlayerPawn(Owner).PlaySound(sound'unreali.bulletr2', SLOT_None, 3.5*PlayerPawn(Owner).SoundDampening);
  }
	Spawn(class'osHeavyWallHitEffect',,, HitLocation+normal(hitlocation-owner.location), Rotator(hitlocation-owner.location));
}
function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
  local int ArmorDamage;

  if( (DamageType!='None') && ((ProtectionType1==DamageType) || (ProtectionType2==DamageType)) && (HitLocation.Z-owner.Location.Z) < 0.18*Owner.CollisionHeight){
  	ArmorImpactEffect(HitLocation);
    return 0;
	}
  if (DamageType=='Drowned') Return Damage;

  ArmorDamage = (Damage * ArmorAbsorption) / 100;
  if( ArmorDamage >= Charge )
  {
    ArmorDamage = Charge;
    Destroy();
  }
  else
    Charge -= ArmorDamage;
  return (Damage - ArmorDamage);
}

defaultproperties
{
     PickupMessage="You got the USM Thigh Pads."
     ItemName="USM Thigh Pads"
     ProtectionType1=shot
}
