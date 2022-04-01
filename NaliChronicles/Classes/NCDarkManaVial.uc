// A mana source that damages the player while restoring mana
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDarkManaVial extends NCPotion;

state Activated
{
	function Timer()
	{
		local float tempskill;

		if (NaliMage(Owner) != none) {
			if (NaliMage(Owner).mana >= NaliMage(Owner).maxmana) {
				GotoState('DeActivated');
			}
			else {
				count += 0.2;
				if (count >= 1.0) {
					count = 0;
					Owner.PlaySound(ActivateSound);
					tempskill = Pawn(Owner).skill;
					Pawn(Owner).skill = 3;
					Owner.TakeDamage(3,Pawn(Owner),Owner.location,vect(0,0,0),'Slimed');
					Pawn(Owner).skill = tempskill;
				}
				Charge -= 1;
				if ((NaliMage(Owner).mana+1) <= NaliMage(Owner).maxmana)
					NaliMage(Owner).mana += 1;
				else
					NaliMage(Owner).mana = NaliMage(Owner).maxmana;
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
     powershigh(2)=0.800000
     powershigh(5)=0.150000
     powerslow(0)=0.100000
     powerslow(1)=-0.050000
     powerslow(2)=0.700000
     powerslow(3)=-0.150000
     powerslow(4)=-0.150000
     infotex=Texture'NaliChronicles.Icons.DManaVialInfo'
     PickupMessage="You got a dark mana vial"
     ItemName="dark mana vial"
     Icon=Texture'NaliChronicles.Icons.DManaVial'
     Skin=Texture'NaliChronicles.Skins.Jdrkmanavial'
}
