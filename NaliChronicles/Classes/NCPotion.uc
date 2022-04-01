// The base of all potions that can be mixed
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

//#exec MESHMAP SETTEXTURE MESHMAP=manavial NUM=1 TEXTURE=Jmanavial

class NCPotion extends NCPickup
	abstract;

var float count;
var() int maxcount;
var() float powershigh[10];
var() float powerslow[10];

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
	function Timer()
	{
		// this should be replaced in later classes
		if (Charge<=0) {
			UsedUp();
			GotoState('DeActivated');
		}
	}
	function EndState()
	{
		bActive = false;
	}
Begin:
	count = 0.8;
	SetTimer(0.2,True);
}

function bool HandlePickupQuery( inventory Item )
{
	if (Item.class == class)
	{
		if (NumCopies <= (maxcount-2))
		{
			NumCopies++;
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
			if ( UTC_Pickup(Item).PickupMessageClass == None )
				Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
			else
				class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), UTC_Pickup(Item).PickupMessageClass, 0, None, None, Item.Class);
			Item.PlaySound (Item.PickupSound,,2.0);
			Item.SetRespawn();
		}
		else {
			Pawn(Owner).ClientMessage("You can't carry any more " $ ItemName $ "s",'Pickup');
		}
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

defaultproperties
{
     maxcount=10
     infotex=Texture'NaliChronicles.Icons.ManaVialInfo'
     bShowCharge=True
     bCanHaveMultipleCopies=True
     ExpireMessage="This vial is empty"
     bActivatable=True
     bDisplayableInv=True
     bAmbientGlow=False
     PickupMessage="You got a vial"
     ItemName="Vial"
     PickupViewMesh=LodMesh'NaliChronicles.manavial'
     PickupViewScale=0.300000
     Charge=15
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     ActivateSound=Sound'NaliChronicles.PickupSounds.Drink'
     Icon=Texture'NaliChronicles.Icons.manavial'
     Skin=Texture'NaliChronicles.Skins.Jmanavial'
     Mesh=LodMesh'NaliChronicles.manavial'
     DrawScale=0.300000
     AmbientGlow=0
     CollisionRadius=6.000000
     CollisionHeight=10.000000
}
