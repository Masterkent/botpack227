//=============================================================================
// InventoryZone.
//
// script by N.Bogenrieder (Beppo)
//
// Use this for predefined Inventory when
// entering / leaving this Zone
//
// ======================
// ZoneInfo.bNoInventory:
//
// use this ZoneInfo with bNoInventory for StartupZones
// like a RestRoom or ChatRoom... and use the ExitZone-
// Inventory entries to setup any inventory!
//
// !!! this variant is working with every game type !!!
//
// ====================
// EnterZone inventory:
//
// the EnterZone Inventory is only functining with bots
// in every game type...
// players are working fine only in singleplayer games
// cause no 'real' entering occurs ie. if players are
// respawned in DeathMatch games...
//
// ie. DeathMatch is setting up all DefaultInventory
// AFTER the player enters a zone... so all inventory items
// get killed, cause DeathMatch only allows a DefaultWeapon!
//
//=============================================================================
class InventoryZone expands ZoneInfo;

struct Inv20
{
	var() class<inventory> inv[20];
};

var(EnterZone) Inv20 AddInv;
var(EnterZone) Inv20 DeleteInv;
var(EnterZone) bool bDeleteALLInventory;

var(ExitZone) Inv20 AddInvE;
var(ExitZone) Inv20 DeleteInvE;
var(ExitZone) bool bDeleteALLInventoryE;

var int i;

replication
{
	reliable if( Role==ROLE_Authority )
		AddInv, DeleteInv, bDeleteALLInventory,
		AddInvE, DeleteInvE, bDeleteALLInventoryE;
}

event ActorEntered( actor Other )
{
// just like the original only much faster (original 1.5 secs)
	if ( bNoInventory && Other.IsA('Inventory') && (Other.Owner == None) )
	{
		Other.LifeSpan = 0.01;
		return;
	}
	Super.ActorEntered( Other );

	if	(Other.IsA('PlayerPawn') || Other.IsA('Bots') )
		EnterZone( Pawn(Other) );
}

function EnterZone(pawn Other)
{
local inventory inv, inv2;

	if (Other == None)
		return;

	if (bDeleteALLInventory)
	{
		inv = Other.Inventory;
		while( inv!=None )
		{
		 	inv2 = inv.Inventory;
			inv.DropFrom(Other.Location);
			inv.Destroy();
			inv = inv2;
		}
		inv2 = None;
		inv = None;
	}
	
	for (i=0; i<20; i++)
		if ( DeleteInv.inv[i] != None )
		{
			inv = None;
			inv = Other.FindInventoryType(DeleteInv.inv[i]);
			if (inv != None)
			{
				inv.DropFrom(Other.Location);
				inv.Destroy();
			}
		}

	for (i=0; i<20; i++)
		if ( AddInv.inv[i] != None )
		{
			inv = None;
			inv = Other.FindInventoryType(AddInv.inv[i]);
			if (inv == None || Pickup(inv).bCanHaveMultipleCopies)
			{
				inv = spawn(AddInv.inv[i],,,Other.Location);
				inv.RespawnTime = 0;
				inv.Touch(Other);
// could not pick it up - destroy it
				if( inv.IsInState( 'Pickup' )) inv.destroy();
			}
// if item is already in inventory list...
// if it's an Ammo add the AmmoAmount...
			else if (inv.IsA( 'Ammo' ))
			{
				Ammo(inv).AddAmmo(Ammo(inv).default.AmmoAmount);
			}
		}
}

event ActorLeaving( actor Other )
{
	Super.ActorLeaving( Other );

	if	(Other.IsA('PlayerPawn') || Other.IsA('Bots') )
		ExitZone( Pawn(Other) );
}

function ExitZone(pawn Other)
{
local inventory inv, inv2;

	if (Other == None)
		return;

	if (bDeleteALLInventoryE)
	{
		inv = Other.Inventory;
		while( inv!=None )
		{
		 	inv2 = inv.Inventory;
			inv.DropFrom(Other.Location);
			inv.Destroy();
			inv = inv2;
		}
		inv2 = None;
		inv = None;
	}
	
	for (i=0; i<20; i++)
		if ( DeleteInvE.inv[i] != None )
		{
			inv = None;
			inv = Other.FindInventoryType(DeleteInvE.inv[i]);
			if (inv != None)
			{
				inv.DropFrom(Other.Location);
				inv.Destroy();
			}
		}

	for (i=0; i<20; i++)
		if ( AddInvE.inv[i] != None )
		{
			inv = None;
			inv = Other.FindInventoryType(AddInvE.inv[i]);
			if (inv == None || Pickup(inv).bCanHaveMultipleCopies)
			{
				inv = spawn(AddInvE.inv[i],,,Other.Location);
				inv.RespawnTime = 0;
				inv.Touch(Other);
// could not pick it up - destroy it
				if( inv.IsInState( 'Pickup' )) inv.destroy();
			}
// if item is already in inventory list...
// if it's an Ammo add the AmmoAmount...
			else if (inv.IsA( 'Ammo' ))
			{
				Ammo(inv).AddAmmo(Ammo(inv).default.AmmoAmount);
			}
		}
}

defaultproperties
{
}
