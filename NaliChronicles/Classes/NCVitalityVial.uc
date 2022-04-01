// Adds to a player's vitality
// Code by Sergey 'Eater' Levin, 2001

// leaf - 20%, health - 30%, holy - 30%, power - 10%

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCVitalityVial extends NCPotion;

state Activated
{
	function Timer()
	{
		local NCVitality vitality;
		local inventory Inv;
		if (Pawn(Owner) != none) {
			for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
				if (NCVitality(Inv) != none) vitality = NCVitality(Inv);
			}
			if ((vitality != none) && (vitality.charge >= 100)) {
				GotoState('DeActivated');
			}
			else {
				count += 0.2;
				if (count >= 1.0) {
					count = 0;
					Owner.PlaySound(ActivateSound);
				}
				Charge -= 1;
				if (vitality != none) {
					vitality.charge++;
				}
				else {
					vitality = Spawn(Class'NaliChronicles.NCVitality',,,owner.location,owner.rotation);
					vitality.charge = 1;
					vitality.bHeldItem = true;
					vitality.GiveTo(Pawn(Owner));
					vitality.Timer();
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
     powershigh(0)=0.200000
     powershigh(1)=0.200000
     powershigh(3)=0.400000
     powershigh(4)=0.400000
     powerslow(0)=0.080000
     powerslow(1)=0.040000
     powerslow(2)=-0.050000
     powerslow(3)=0.200000
     powerslow(4)=0.200000
     powerslow(5)=-0.100000
     infotex=Texture'NaliChronicles.Icons.VitalityVialInfo'
     PickupMessage="You got a vitality potion vial"
     ItemName="vitality potion vial"
     Icon=Texture'NaliChronicles.Icons.VitalityVial'
     Skin=Texture'NaliChronicles.Skins.JVitalityvial'
}
