// The base of all protection spells the player casts on himself
// Code by Sergey 'Eater' Levin, 2001

class NCProtectSpell extends NCSpell
	abstract;

var() float armorpersecond;
var() float faildamage; // damage dealt in case of failure per each second spell was held
var() class<NCProtectEffect> Enchantment;
var() float mintime;

function bool ScanForAccidents(float timeheld) { // depending on stress, this function can cause freak accidents
	local float f;
	local rotator newrotation;

	f = (stress/9) - GetMySkill()/10;
	if (FRand() < f) {
		newrotation = Pawn(Owner).viewrotation;
		newrotation.yaw += 32768;
		newrotation.pitch += 32768;
		Owner.TakeDamage(faildamage*timeheld,pawn(owner),owner.location,vect(0,0,0),'zapped');
		return false;
	}

	return true;
}

function FinishCasting(float timeheld) {
	local NCProtectEffect ProtectEffect;
	local float addedArmor;
	local float decayTime;
	local bool newDecayTime;
	local Inventory inv;

	Super.FinishCasting(timeheld);
	if (timeheld >= casttime*0.1) { // don't use min time, instead require that each spell be charged to 10%
		for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if ( Inv.Class == Enchantment ) {
				addedArmor = Inv.charge;
				if (Inv.charge > (timeheld*armorpersecond*5)) {
					if (NCProtectEffect(Inv).timeBeforeDecay <= 0)
						decayTime = 0.01;
					else
						decayTime = NCProtectEffect(Inv).timeBeforeDecay-(Level.TimeSeconds-NCProtectEffect(Inv).decayStart);
					newDecayTime = true;
				}
				if (((armorpersecond*timeheld) + addedArmor) > Inv.default.charge)
					addedArmor = Inv.default.charge - (armorpersecond*timeheld);
				if (addedArmor < 0)
					addedArmor = 0;
				Inv.destroy();
			}
		}
		ProtectEffect = Spawn(Enchantment,,,owner.location,owner.rotation);
		ProtectEffect.charge = int((armorpersecond*timeheld) + addedArmor);
		if (newDecayTime)
			ProtectEffect.timeBeforeDecay = decayTime;
		else
			ProtectEffect.timeBeforeDecay = ProtectEffect.default.timeBeforeDecay*(timeheld/casttime);
		ProtectEffect.bHeldItem = true;
		ProtectEffect.GiveTo(Pawn(Owner));
		ProtectEffect.StartDecayCount();
		ProtectEffect.book = book;
		ProtectEffect.ArmorAbsorption *= 1 + (NaliMage(Owner).SpellSkills[book]/15);
		if (ProtectEffect.ArmorAbsorption > 100)
			ProtectEffect.ArmorAbsorption = 100;
	}
}

function Cast() {
	local Inventory Inv;
	local int i;

	for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
		if (NCProtectEffect(Inv) != none && Inv.Class != Enchantment) {
			i++;
		}
	}
	if (i >= 3)
		Pawn(Owner).ClientMessage("You cannot posses more than four magical shields.",'Pickup');
	else
		Super.Cast();
}

defaultproperties
{
     armorpersecond=50.000000
     faildamage=10.000000
     mintime=0.500000
     bHarmless=True
     PickupMessage="You found protection pell"
}
