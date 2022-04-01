// ===============================================================
// SevenB.USMBodyArmor: Blocks Bullets completely
// ===============================================================

class USMBodyArmor extends armor2;

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

  if( (DamageType!='None') && ((ProtectionType1==DamageType) || (ProtectionType2==DamageType))
	  && (HitLocation.Z-owner.Location.Z) < 0.72*Owner.CollisionHeight && (HitLocation.Z-owner.Location.Z) > 0.18*Owner.CollisionHeight){
  	ArmorImpactEffect(HitLocation);
  	if (charge>damage){
			charge -= Damage;
    	return 0;
    }
    else{ //destroyed
    	Damage-=Charge;
    	Charge=0;
    	destroy();
    	return Damage;
    }
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
     PickupMessage="You got the USM Body Armor."
     ItemName="USM Body Armor"
     ProtectionType1=shot
}
