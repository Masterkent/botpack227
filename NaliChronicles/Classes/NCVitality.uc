// Allows player to regain health
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCVitality extends Pickup;

function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	return (Damage); // doesn't absorb anything
}

function UsedUp()
{
	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		Pawn(Owner).NextItem();
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
	if ((Owner != none) && (charge > 0) && (Pawn(Owner).health < 100)) {
		Pawn(Owner).health += fMax(1,charge/20);
		if (Pawn(Owner).health > 100) Pawn(Owner).health = 100;
		charge -= 1;
		if (charge <= 0)
			UsedUp();
	}
	SetTimer(0.4,false);
}

defaultproperties
{
     bDisplayableInv=True
     Charge=100
     bIsAnArmor=True
     AbsorptionPriority=1
     Icon=Texture'NaliChronicles.Icons.VitalityBarIcon'
}
