class UTC_Pickup expands Pickup
	abstract;

var() class<LocalMessage> PickupMessageClass;
var() class<LocalMessage> ItemMessageClass;

function bool HandlePickupQuery(Inventory Item)
{
	if (item.class == class) 
	{
		if (bCanHaveMultipleCopies) 
		{   // for items like Artifact
			NumCopies++;
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
			if (UTC_Pickup(Item).PickupMessageClass == None)
				Pawn(Owner).ClientMessage(item.PickupMessage, 'Pickup');
			else
				class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), UTC_Pickup(Item).PickupMessageClass, 0, none, none, item.Class);
			Item.PlaySound (Item.PickupSound,,2.0);
			Item.SetRespawn();
		}
		else if ( bDisplayableInv ) 
		{
			if ( Charge<Item.Charge )
				Charge= Item.Charge;
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
			if (UTC_Pickup(Item).PickupMessageClass == None)
				Pawn(Owner).ClientMessage(item.PickupMessage, 'Pickup');
			else
				class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), UTC_Pickup(Item).PickupMessageClass, 0, none, none, item.Class);
			Item.PlaySound (item.PickupSound,,2.0);
			Item.SetReSpawn();
		}
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

auto state Pickup
{	
	function Touch( actor Other )
	{
		local Inventory Copy;
		if ( ValidTouch(Other) ) 
		{
			Copy = SpawnCopy(Pawn(Other));
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			if (bActivatable && Pawn(Other).SelectedItem==None) 
				Pawn(Other).SelectedItem=Copy;
			if (bActivatable && bAutoActivate && Pawn(Other).bAutoActivate) Copy.Activate();
			if (PickupMessageClass == none)
				Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
			else
				class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Other), PickupMessageClass, 0, none, none, self.Class);
			if (bDeleteMe)
				Other.PlaySound(PickupSound,,2.0);
			else
				PlaySound(PickupSound,,2.0);
			Pickup(Copy).PickupFunction(Pawn(Other));
		}
	}
}

function UsedUp()
{
	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		Pawn(Owner).NextItem();
		if (Pawn(Owner).SelectedItem == Self) {
			Pawn(Owner).NextItem();
			if (Pawn(Owner).SelectedItem == Self) Pawn(Owner).SelectedItem=None;
		}
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
		if (ItemMessageClass != None)
			class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), ItemMessageClass, 0, none, none, self.Class);
		else
			Pawn(Owner).ClientMessage(ExpireMessage);
	}
	Owner.PlaySound(DeactivateSound);
	Destroy();
}
