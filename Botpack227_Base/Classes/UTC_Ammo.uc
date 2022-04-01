class UTC_Ammo expands Ammo
	abstract;

var() class<LocalMessage> PickupMessageClass;

function bool HandlePickupQuery(Inventory Item)
{
	if ( (class == item.class) || 
		(ClassIsChildOf(item.class, class'Ammo') && (class == Ammo(item).parentammo)) ) 
	{
		if (AmmoAmount==MaxAmmo) return true;
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if (UTC_Ammo(Item) == none || UTC_Ammo(Item).PickupMessageClass == none)
			Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
		else
			class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), UTC_Ammo(Item).PickupMessageClass, 0, none, none, Item.Class);
		Item.PlaySound(Item.PickupSound);
		AddAmmo(Ammo(item).AmmoAmount);
		item.SetRespawn();
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
			PlaySound (PickupSound,,2.0);
			Pickup(Copy).PickupFunction(Pawn(Other));
		}
	}
}
