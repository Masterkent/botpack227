// Quickly regenerates health but causes bloodlust
// Code by Sergey 'Eater' Levin, 2002

// leaf - 20%, health - 30%, dark - 30%, power - 20%
// 3 leaf, 3 heart, 4 health, 5 dark

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCBloodlustVial extends NCPotion;

state Activated
{
	function Timer()
	{
		local NCBloodlust bloodlust;
		local inventory Inv;
		if (Pawn(Owner) != none) {
			for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
				if (NCBloodlust(Inv) != none) bloodlust = NCBloodlust(Inv);
			}
			if ((bloodlust != none) && (bloodlust.charge >= 100)) {
				GotoState('DeActivated');
			}
			else {
				count += 0.2;
				if (count >= 1.0) {
					count = 0;
					Owner.PlaySound(ActivateSound);
				}
				Charge -= 1;
				if (bloodlust != none) {
					bloodlust.charge++;
					bloodlust.addFog();
				}
				else {
					bloodlust = Spawn(Class'NaliChronicles.NCBloodlust',,,owner.location,owner.rotation);
					bloodlust.charge = 2;
					bloodlust.bHeldItem = true;
					bloodlust.GiveTo(Pawn(Owner));
					bloodlust.Timer();
					bloodlust.addFog();
				}
			}
		}
		if (Charge<=0) {
			UsedUp();
			GotoState('DeActivated');
		}
	}
}

defaultproperties
{
     powershigh(0)=0.270000
     powershigh(1)=0.300000
     powershigh(3)=0.340000
     powershigh(5)=0.340000
     powerslow(0)=0.130000
     powerslow(1)=0.100000
     powerslow(2)=-0.200000
     powerslow(3)=0.200000
     powerslow(4)=-0.200000
     powerslow(5)=0.200000
     infotex=Texture'NaliChronicles.Icons.BloodlustVialInfo'
     PickupMessage="You got a bloodlust potion vial"
     ItemName="bloodlust potion vial"
     Icon=Texture'NaliChronicles.Icons.BloodlustVial'
     Skin=Texture'NaliChronicles.Skins.JBloodlustvial'
}
