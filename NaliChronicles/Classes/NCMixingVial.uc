// A vial ready to be used for mixing a potion
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCMixingVial extends NCPickup;

var travel class<NCPotionIngredient> ingredientIndex[10];
var class<NCPotion> possiblePotions[20];
var travel float ingredientAmount[10];
var travel float powers[10];
var() texture emptyIcon;
var() texture filledIcon;
var() texture borderIcon;
var() texture markIcon;
var travel bool bBoiling;
var sound finishedSounds[3];

function FinishBoil() {
	local int i;
	local int candidates[10];
	local int j;
      local int ccount;
	local bool notGood;
	local NCPotion p;
	local pawn po;

	//Pawn(Owner).ClientMessage("Activator: "$(NaliMage(Owner).CurrentVial.powers[0]/charge)$
	//				  " Power: "$(NaliMage(Owner).CurrentVial.powers[1]/charge)$
	//				  " Magic: "$(NaliMage(Owner).CurrentVial.powers[2]/charge)$
	//				  " Health: "$(NaliMage(Owner).CurrentVial.powers[3]/charge)$
	//				  " Holy: "$(NaliMage(Owner).CurrentVial.powers[4]/charge)$
	//				  " Dark: "$(NaliMage(Owner).CurrentVial.powers[5]/charge));
	while (i < 10) {
		candidates[i] = 255;
		i++;
	}
	i = 0;
	while (possiblePotions[i] != none) {
		notGood = false;
		j = 0;
		while (j < 10) {
			if ((powers[j]/charge < possiblePotions[i].default.powerslow[j]) ||
		    	(powers[j]/charge > possiblePotions[i].default.powershigh[j])) {
				notGood = true;
			}
			j++;
		}
		if (!notGood) {
			//Pawn(Owner).ClientMessage("Accepted by potion "$possiblePotions[i].default.ItemName);
			if (ccount < 10) {
				candidates[ccount] = i;
				ccount++;
			}
		}
		i++;
	}
	if (ccount > 0) {
		i = Rand(ccount);
		//Pawn(Owner).ClientMessage("Random number selected: "$i$" with a count of "$ccount);
		NaliMage(Owner).pickupGroup = 0;
		NaliMage(Owner).CurrentVial = none;
		bActive = false;
		//Pawn(Owner).ClientMessage(possiblePotions[candidates[i]].default.PickupMessage);
		p = NCPotion(Pawn(Owner).FindInventoryType(possiblePotions[candidates[i]]));
		if (p != none) {
			p.NumCopies += 1;
		}
		else {
			p = spawn(possiblePotions[candidates[i]],Owner,,,rot(0,0,0));
			p.RespawnTime = 0.0;
			p.bHeldItem = true;
			p.GiveTo(Pawn(Owner));
		}
		p.charge = charge;
		Owner.PlaySound(FinishedSounds[int(frand()*3)]);
		Pawn(Owner).ClientMessage(p.PickupMessage,'Pickup');
		bActivatable = false;
		po = Pawn(Owner);
		Pawn(Owner).DeleteInventory(Self);
		po.SelectedItem = p;
		NaliMage(Owner).pickupGroup = 0;
		destroy();
	}
	else {
		Pawn(Owner).ClientMessage("You failed to mix a potion");
		bBoiling = False;
		charge = 0;
		Activate();
	}
}

function bool AddIngredient(class<NCPotionIngredient> ingredient, int amount) {
	local int i;
	local int actamount;

	if (charge < default.charge) {
		actamount = amount;
		if (actamount+charge > default.charge) actamount = default.charge-charge;
		while (i < 10) {
			powers[i] += ingredient.default.powers[i]*actamount;
			i++;
		}
		i = 0;
		while (i < 10) {
			if ((ingredientIndex[i] == ingredient) || (ingredientIndex[i] == none)) {
				ingredientIndex[i] = ingredient;
				charge += amount;
				if (charge > default.charge) {
					amount -= charge-default.charge;
					charge = default.charge;
				}
				ingredientAmount[i] += amount;
				i = 10;
			}
			i++;
		}
		return true;
	}
	return false;
}

function destroyed() {
	if (Owner != none && NaliMage(Owner).CurrentVial == self) {
		NaliMage(Owner).pickupGroup = 0;
	}
}

state Activated
{
	function BeginState() {
		Super.BeginState();
		if ((NaliMage(Owner).CurrentVial != none) && (NaliMage(Owner).CurrentVial.bBoiling)) {
			Activate();
		}
		else {
			if (NaliMage(Owner).CurrentVial != none) {
				NaliMage(Owner).CurrentVial.Activate();
			}
			NaliMage(Owner).CurrentVial = self;
			NaliMage(Owner).pickupGroup = 1;
		}
	}

	function Activate() {
		local NCEmptyVial ev;
		local pawn p;

		if (!bBoiling) {
			NaliMage(Owner).CurrentVial = none;
			NaliMage(Owner).pickupGroup = 0;
			if (charge <= 0) {
				bActive = false;
				ev = NCEmptyVial(Pawn(Owner).FindInventoryType(Class'NCEmptyVial'));
				if (ev != none) {
					ev.NumCopies += 1;
				}
				else {
					ev = spawn(Class'NCEmptyVial',Owner,,,rot(0,0,0));
					ev.RespawnTime = 0.0;
					ev.bHeldItem = true;
					ev.GiveTo(Pawn(Owner));
				}
				bActivatable = false;
				p = pawn(owner);
				Pawn(Owner).DeleteInventory(Self);
				p.SelectedItem = ev;
				destroy();
			}
			else {
				Super.Activate();
			}
		}
	}
}

defaultproperties
{
     possiblePotions(0)=Class'NaliChronicles.NCHealthVial'
     possiblePotions(1)=Class'NaliChronicles.NCDarkManaVial'
     possiblePotions(2)=Class'NaliChronicles.NCManaVial'
     possiblePotions(3)=Class'NaliChronicles.NCSpeedVial'
     possiblePotions(4)=Class'NaliChronicles.NCVitalityVial'
     possiblePotions(5)=Class'NaliChronicles.NCSkillVial'
     possiblePotions(6)=Class'NaliChronicles.NCBloodlustVial'
     emptyIcon=Texture'NaliChronicles.Icons.VialFillUpIcon'
     filledIcon=Texture'NaliChronicles.Icons.VialFill'
     borderIcon=Texture'NaliChronicles.Icons.VialFillUpBorders'
     markIcon=Texture'NaliChronicles.Icons.VialMarks'
     finishedSounds(0)=Sound'NaliChronicles.PickupSounds.bottle1'
     finishedSounds(1)=Sound'NaliChronicles.PickupSounds.bottle2'
     finishedSounds(2)=Sound'NaliChronicles.PickupSounds.bottle3'
     infotex=Texture'NaliChronicles.Icons.MixingVialInfo'
     bShowCharge=True
     interGroup=True
     ExpireMessage="This vial is empty"
     bActivatable=True
     bDisplayableInv=True
     bAmbientGlow=False
     PickupMessage="You got a mixing vial"
     ItemName="Mixing vial"
     PickupViewMesh=LodMesh'NaliChronicles.EmptyVial'
     PickupViewScale=0.300000
     Charge=15
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     Icon=Texture'NaliChronicles.Icons.MixingVial'
     Skin=Texture'NaliChronicles.Skins.Jemptyvial'
     Mesh=LodMesh'NaliChronicles.EmptyVial'
     DrawScale=0.300000
     AmbientGlow=0
     CollisionRadius=6.000000
     CollisionHeight=10.000000
}
