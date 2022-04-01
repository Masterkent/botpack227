// The base of all health sources that can be carried around
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCHealthVial extends NCPotion;

state Activated
{
	function Timer()
	{
		if (Pawn(Owner) != none) {
			if (Pawn(Owner).health >= 100) {
				GotoState('DeActivated');
			}
			else {
				count += 0.2;
				if (count >= 1.0) {
					count = 0;
					Owner.PlaySound(ActivateSound);
				}
				Charge -= 1;
				if ((Pawn(Owner).health+1) <= 100)
					Pawn(Owner).health += 1;
				else
					Pawn(Owner).health = 100;
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
     powershigh(0)=0.250000
     powershigh(1)=0.025000
     powershigh(2)=0.100000
     powershigh(3)=0.800000
     powershigh(4)=0.150000
     powershigh(5)=0.100000
     powerslow(0)=0.100000
     powerslow(1)=-0.050000
     powerslow(2)=-0.100000
     powerslow(3)=0.700000
     powerslow(5)=-0.100000
     infotex=Texture'NaliChronicles.Icons.healthVialInfo'
     PickupMessage="You got a healing potion vial"
     ItemName="healing potion vial"
     Icon=Texture'NaliChronicles.Icons.HealthVial'
     Skin=Texture'NaliChronicles.Skins.Jhealthvial'
}
