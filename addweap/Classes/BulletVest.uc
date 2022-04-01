//=============================================================================
// Armor2 powerup.
//=============================================================================
class BulletVest extends TournamentPickup;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

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
     PickupMessage="You got the Bulletproof vest."
     ItemName="Bulletproof vest"
     RespawnTime=30.000000
     PickupViewMesh=LodMesh'addweap.BulletVest'
     Charge=100
     ArmorAbsorption=75
     bIsAnArmor=True
     AbsorptionPriority=7
     MaxDesireability=2.000000
     PickupSound=Sound'addweap.Items.BulletVest'
     Mesh=LodMesh'addweap.BulletVest'
     AmbientGlow=64
     CollisionHeight=9.000000
}
