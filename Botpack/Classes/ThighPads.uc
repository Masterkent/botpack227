//=============================================================================
// ThighPads.
//=============================================================================
class ThighPads extends TournamentPickup;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_ThighPads FILE=Textures\Hud\B227_i_ThighPads.pcx GROUP="Icons" MIPS=OFF

function bool HandlePickupQuery(Inventory Item)
{
	local Inventory S;

	if (Item.Class == Class)
	{
		if (class'B227_Config'.static.ShouldModifyArmorBalance())
			Charge = Max(Charge, B227_HandleUTArmors(Pawn(Owner), 0, 0, Item.Charge));
		else
		{
			S = Pawn(Owner).FindInventoryType(class'UT_Shieldbelt');
			if (S == none)
			{
				if (Charge < Item.Charge)
					Charge = Item.Charge;
			}
			else
				Charge = Clamp(S.default.Charge - S.Charge, Charge, Item.Charge );
		}
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if (UTC_Pickup(Item).PickupMessageClass == None)
			Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
		else
			class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Owner), UTC_Pickup(Item).PickupMessageClass, 0, None, None, Self.Class);
		Item.PlaySound (PickupSound,,2.0);
		Item.SetReSpawn();
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function inventory SpawnCopy(Pawn Other)
{
	local Inventory Copy, S;

	Copy = super.SpawnCopy(Other);

	if (class'B227_Config'.static.ShouldModifyArmorBalance())
	{
		Copy.Charge = B227_HandleUTArmors(Other, 0, 0, Copy.Charge, Copy);
		if (Copy.Charge <= 0)
			Copy.Destroy();
	}
	else
	{
		S = Other.FindInventoryType(class'UT_Shieldbelt');
		if (S != none)
		{
			Copy.Charge = Min(Copy.Charge, S.default.Charge - S.Charge);
			if (Copy.Charge <= 0)
			{ 
				S.Charge -= 1;
				Copy.Charge = 1;
			}
		}
	}
	return Copy;
}

defaultproperties
{
	bDisplayableInv=True
	bRotatingPickup=True
	PickupMessage="You got the Thigh Pads."
	ItemName="Thigh Pads"
	RespawnTime=30.000000
	PickupViewMesh=LodMesh'Botpack.ThighPads'
	Charge=50
	ArmorAbsorption=50
	bIsAnArmor=True
	AbsorptionPriority=7
	MaxDesireability=1.800000
	PickupSound=Sound'Botpack.Pickups.ArmorUT'
	Icon=Texture'Botpack.Icons.B227_I_ThighPads'
	Mesh=LodMesh'Botpack.ThighPads'
	AmbientGlow=64
}
