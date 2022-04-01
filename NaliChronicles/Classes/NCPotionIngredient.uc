// The base of all potion ingredients
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPotionIngredient extends NCPickup
	abstract;

var() color IngredientColor;
var() float powers[10]; // 0 - activator, 1 - power, 2 - magic, 3 - health, 4 - holy, 5 - dark, 6 - 9 - unused
var float count;

function UsedUp()
{
	if ( Pawn(Owner) != None )
	{
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
		if ( ItemMessageClass != None )
			class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), ItemMessageClass, 0, None, None, Self.Class);
		else
			Pawn(Owner).ClientMessage(ExpireMessage);
		NumCopies -= 1;
		if (NumCopies < 0) {
			bActivatable = false;
			Pawn(Owner).NextItem();
			if (Pawn(Owner).SelectedItem == Self) {
				Pawn(Owner).NextItem();
				if (Pawn(Owner).SelectedItem == Self) Pawn(Owner).SelectedItem=None;
			}
			Pawn(Owner).DeleteInventory(Self);
		}
		else {
			charge = default.charge;
		}
	}
	if (NumCopies < 0)
		Destroy();
}

state Activated
{
	function BeginState() {
		if (NaliMage(Owner) == None || NaliMage(Owner).CurrentVial == None)
			Activate();
		Super.BeginState();
	}

	function Timer()
	{
		if (NaliMage(Owner).CurrentVial != none) {
			if (NaliMage(Owner).CurrentVial.AddIngredient(class,1)) {
				count += 0.2;
				if (count >= 1.0) {
					count = 0;
					Owner.PlaySound(ActivateSound);
				}
				Charge -= 1;
			}
			else {
				Activate();
			}
		}
		else {
			Activate();
		}
		if (Charge<=0) {
			UsedUp();
			Activate();
		}
	}

Begin:
	count = 0.8;
	SetTimer(0.2,True);
}

defaultproperties
{
     infotex=Texture'NaliChronicles.Icons.ingredientInfo'
     bShowCharge=True
     pickupGroup=1
     bCanHaveMultipleCopies=True
     ExpireMessage="This ingredient has been used up"
     bActivatable=True
     bDisplayableInv=True
     bAmbientGlow=False
     PickupMessage="You got a potion ingredient"
     ItemName="Potion ingredient"
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     AmbientGlow=0
}
