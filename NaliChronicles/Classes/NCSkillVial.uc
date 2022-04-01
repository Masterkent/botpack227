// Adds to a player's casting skill
// Code by Sergey 'Eater' Levin, 2001

// leaf - 20%, magic - 35%, dark - 30%, power - 15%
// for vial: 3 leaf, 2 power, 5 dark, 5 magic

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSkillVial extends NCPotion;

state Activated
{
	function Timer()
	{
		local NCSkillBooster booster;
		local inventory Inv;
		if (Pawn(Owner) != none) {
			for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
				if (NCSkillBooster(Inv) != none) booster = NCSkillBooster(Inv);
			}
			if ((booster != none) && (booster.charge >= 120)) {
				GotoState('DeActivated');
			}
			else {
				count += 0.2;
				if (count >= 1.0) {
					count = 0;
					Owner.PlaySound(ActivateSound);
				}
				Charge -= 1;
				if (booster != none) {
					booster.charge++;
					booster.calcIncrease();
				}
				else {
					booster = Spawn(Class'NaliChronicles.NCSkillBooster',,,owner.location,owner.rotation);
					booster.charge = 2;
					booster.bHeldItem = true;
					booster.GiveTo(Pawn(Owner));
					booster.Timer();
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
     powershigh(0)=0.230000
     powershigh(1)=0.230000
     powershigh(2)=0.450000
     powershigh(5)=0.400000
     powerslow(0)=0.100000
     powerslow(1)=0.100000
     powerslow(2)=0.250000
     powerslow(3)=-0.200000
     powerslow(4)=-0.200000
     powerslow(5)=0.250000
     infotex=Texture'NaliChronicles.Icons.SkillVialInfo'
     PickupMessage="You got a spell casting potion vial"
     ItemName="spell casting potion vial"
     Icon=Texture'NaliChronicles.Icons.SkillVial'
     Skin=Texture'NaliChronicles.Skins.JSkillvial'
}
