//=============================================================================
// AXkevlar.
//=============================================================================
class AXkevlar expands Tournamentpickup;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

function bool HandlePickupQuery( inventory Item )
{
	local inventory S;

	if ( item.class == class )
	{
		S = Pawn(Owner).FindInventoryType(class'UT_Shieldbelt');
		if (  S==None )
		{
			if ( Charge<Item.Charge )
				Charge = Item.Charge;
		}
		else
			Charge = Clamp(S.Default.Charge - S.Charge, Charge, Item.Charge );
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if ( PickupMessageClass == None )
			Pawn(Owner).ClientMessage(PickupMessage, 'Pickup');
		else
			class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), PickupMessageClass, 0, None, None, Self.Class);
		Item.PlaySound (PickupSound,,2.0);
		Item.SetReSpawn();
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy, S;

	Copy = Super.SpawnCopy(Other);
	S = Other.FindInventoryType(class'UT_Shieldbelt');
	if ( S != None )
	{
		Copy.Charge = Min(Copy.Charge, S.Default.Charge - S.Charge);
		if ( Copy.Charge <= 0 )
		{
			S.Charge -= 1;
			Copy.Charge = 1;
		}
	}
	return Copy;
}

defaultproperties
{
     bDisplayableInv=True
     PickupMessage="You got the Kevlar Vest."
     ItemName="Kevlar vest"
     RespawnTime=30.000000
     PickupViewMesh=LodMesh'AX.AXkevlar'
     PickupViewScale=0.650000
     Charge=150
     ArmorAbsorption=75
     bIsAnArmor=True
     AbsorptionPriority=7
     MaxDesireability=2.000000
     PickupSound=Sound'AX.Sounds.kev'
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.AXkevlar'
     DrawScale=0.120000
     AmbientGlow=32
     CollisionHeight=11.000000
}
