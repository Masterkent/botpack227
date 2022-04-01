// A larger container for mixing potions
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCMixingBottle extends NCMixingVial;

state Activated
{
	function Activate() {
		local NCEmptyBottle eb;
		local pawn p;

		if (!bBoiling) {
			NaliMage(Owner).CurrentVial = none;
			NaliMage(Owner).pickupGroup = 0;
			if (charge <= 0) {
				bActive = false;
				eb = NCEmptyBottle(Pawn(Owner).FindInventoryType(Class'NCEmptyBottle'));
				if (eb != none) {
					eb.NumCopies += 1;
				}
				else {
					eb = spawn(Class'NCEmptyBottle',Owner,,,rot(0,0,0));
					eb.RespawnTime = 0.0;
					eb.bHeldItem = true;
					eb.GiveTo(Pawn(Owner));
				}
				bActivatable = false;
				p = pawn(owner);
				Pawn(Owner).DeleteInventory(Self);
				p.SelectedItem = eb;
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
     possiblePotions(0)=Class'NaliChronicles.NCHealthBottle'
     possiblePotions(1)=Class'NaliChronicles.NCDarkManaBottle'
     possiblePotions(2)=Class'NaliChronicles.NCManaBottle'
     possiblePotions(3)=Class'NaliChronicles.NCSpeedBottle'
     possiblePotions(4)=Class'NaliChronicles.NCVitalityBottle'
     possiblePotions(5)=Class'NaliChronicles.NCSkillBottle'
     possiblePotions(6)=Class'NaliChronicles.NCBloodlustBottle'
     emptyIcon=Texture'NaliChronicles.Icons.BottleFillUpIcon'
     filledIcon=Texture'NaliChronicles.Icons.BottleFill'
     borderIcon=Texture'NaliChronicles.Icons.BottleFillUpBorders'
     markIcon=Texture'NaliChronicles.Icons.BottleMarks'
     infotex=Texture'NaliChronicles.Icons.MixingBottleInfo'
     ExpireMessage="This bottle is empty"
     PickupMessage="You got a mixing bottle"
     ItemName="Mixing bottle"
     PickupViewMesh=LodMesh'NaliChronicles.EmptyBottle'
     Charge=25
     Icon=Texture'NaliChronicles.Icons.MixingBottle'
     Skin=Texture'NaliChronicles.Skins.JemptyBottle'
     Mesh=LodMesh'NaliChronicles.EmptyBottle'
}
