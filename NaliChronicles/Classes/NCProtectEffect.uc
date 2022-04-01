// Magic armor created by spells
// Code by Sergey 'Eater' Levin

class NCProtectEffect extends Pickup;

var() travel float timeBeforeDecay;
var() float decayTimePerArmor;
var() texture newHandSkin;
var() texture newSkin;
var travel float decayStart;
var travel int book;
var travel bool bNicked;
var travel float lastlvltime;
var float lastlvl;
var travel bool bLevelChanged;

function Tick(float DeltaTime) {
	super.Tick(DeltaTime);
	if (bLevelChanged) {
		decayStart -= lastlvl;
		if (timeBeforeDecay>0)
			setTimer(timeBeforeDecay+decayStart,false);
		else
			Timer();
		bLevelChanged = false;
	}
	lastlvltime = Level.TimeSeconds;
	//Pawn(Owner).ClientMessage(decayStart);
}

event TravelPreAccept() {
	lastlvl = lastlvltime;
	lastlvltime = 0;
	bLevelChanged = true;
	Super.TravelPreAccept();
}

function PostBeginPlay() {
	Super.PostBeginPlay();
	if (NCMovie(level.game) != none) {
		Pawn(Owner).DeleteInventory(Self);
		destroy(); // can't exist in a movie
	}
}

function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	local int ArmorDamage;

	if (!bNicked) {
		bNicked = true;
		timeBeforeDecay = default.timeBeforeDecay;
	}
	if ( DamageType != 'Drowned' )
		ArmorImpactEffect(HitLocation);
	if( (DamageType!='None') && ((ProtectionType1==DamageType) || (ProtectionType2==DamageType)) )
		return 0;

	if (DamageType=='Drowned') Return Damage;

	ArmorDamage = (Damage * ArmorAbsorption) / 100;
	if( ArmorDamage >= Charge )
	{
		ArmorDamage = Charge;
		GiveExp(ArmorDamage);
		Pawn(Owner).DeleteInventory(Self);
		Destroy();
	}
	else
		Charge -= ArmorDamage;
	//Pawn(Owner).ClientMessage("We Absorb: " $ ArmorAbsorption);
	GiveExp(ArmorDamage);
	return (Damage - ArmorDamage);
}

function GiveExp(int toAdd) {
	toAdd *= 2;
	if (NaliMage(Owner) != none) {
		NaliMage(Owner).GainExp(book,toAdd);
	}
}

function StartDecayCount() {
	decayStart = Level.TimeSeconds;
	setTimer(timeBeforeDecay,false);
}

function UsedUp()
{
	clearSkin();
	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
	}
	Owner.PlaySound(DeactivateSound);
	Pawn(Owner).DeleteInventory(Self);
	Destroy();
}

function Timer() {
	if (timeBeforeDecay <= 0) {
		charge -= 1;
		if (charge <= 0) {
			UsedUp();
		}
		setTimer(decayTimePerArmor,false);
	}
	else {
		timeBeforeDecay = 0;
		setTimer(decayTimePerArmor,false);
	}
}

function clearSkin() {
	local Inventory Inv;
	local int highest;
	local NCProtectEffect high;

	if ((Owner != none) && (newHandSkin != none)) { // modify this to go to next skin instead
		for ( Inv=pawn(Owner).Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if ((NCProtectEffect(Inv) != none) && (NCProtectEffect(Inv).newHandSkin != none) && (Inv != self)) {
				if (high == none) {
					high = NCProtectEffect(Inv);
					highest = Inv.AbsorptionPriority;
				}
				else {
					if (Inv.AbsorptionPriority > highest) {
						high = NCProtectEffect(Inv);
						highest = Inv.AbsorptionPriority;
					}
				}
			}
		}
		if (high != none) {
			Owner.Skin = high.newSkin;
			if ((NCWeapon(pawn(Owner).weapon) != none) && (NCWeapon(pawn(Owner).weapon).bHasHand))
				pawn(Owner).weapon.skin = high.newHandSkin;
		}
		else {
			Owner.skin = owner.default.skin;
			if ((NCWeapon(pawn(owner).weapon) != none) && (NCWeapon(pawn(owner).weapon).bHasHand))
				pawn(owner).weapon.skin = pawn(owner).weapon.default.skin;
		}
	}
}

function Destroyed() {
	clearSkin();
	Super.Destroyed();
}

function GiveTo(Pawn Other) {
	local NCProtectEffect high;

	if (newHandSkin != none) {
		high = findBestPEffect(other);
		if (high != none) {
			Other.Skin = high.newSkin;
			if ((NCWeapon(Other.weapon) != none) && (NCWeapon(Other.weapon).bHasHand))
				Other.weapon.skin = high.newHandSkin;
		}
		else {
			Other.skin = newSkin;
			if ((NCWeapon(Other.weapon) != none) && (NCWeapon(Other.weapon).bHasHand))
				Other.weapon.skin = newHandSkin;
		}
	}
	Super.GiveTo(Other);
}

function newWeaponDrawn() {
	local NCProtectEffect high;

	if ((NCWeapon(pawn(owner).weapon) != none) && (NCWeapon(pawn(owner).weapon).bHasHand) && (newHandSkin != none)) {
		high = findBestPEffect(Pawn(owner));
		if (high == none) {
			pawn(Owner).weapon.skin = newHandSkin;
		}
	}
}

function NCProtectEffect findBestPEffect(pawn other) {
	local Inventory Inv;
	local int highest;
	local NCProtectEffect high;

	highest = AbsorptionPriority;
	for ( Inv=other.Inventory; Inv!=None; Inv=Inv.Inventory ) {
		if ((NCProtectEffect(Inv) != none) && (NCProtectEffect(Inv).newHandSkin != none)) {
			if (Inv.AbsorptionPriority > highest) {
				high = NCProtectEffect(Inv);
				highest = Inv.AbsorptionPriority;
			}
		}
	}
	return high;
}

defaultproperties
{
     bDisplayableInv=True
     bIsAnArmor=True
     AbsorptionPriority=10
}
