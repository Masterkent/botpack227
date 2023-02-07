//=============================================================================
// Armor2 powerup.
//=============================================================================
class Armor2 extends TournamentPickup;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec TEXTURE IMPORT NAME=B227_I_Armor2 FILE=Textures\Hud\B227_i_Armor2.pcx GROUP="Icons" MIPS=OFF

function bool HandlePickupQuery(Inventory Item)
{
	local Inventory S;

	if (Item.Class == Class)
	{
		if (class'B227_Config'.static.ShouldModifyArmorBalance())
			Charge = Max(Charge, B227_HandleUTArmors(Pawn(Owner), 0, Item.Charge, 0));
		else
		{
			S = Pawn(Owner).FindInventoryType(class'UT_Shieldbelt');
			if (S == none)
			{
				if (Charge < Item.Charge)
					Charge = Item.Charge;
			}
			else
				Charge = Clamp(S.default.Charge - S.Charge, Charge, Item.Charge);
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

function Inventory SpawnCopy(Pawn Other)
{
	local Inventory Copy, S;

	Copy = super.SpawnCopy(Other);

	if (class'B227_Config'.static.ShouldModifyArmorBalance())
	{
		Copy.Charge = B227_HandleUTArmors(Other, 0, Copy.Charge, 0, Copy);
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
	PickupMessage="You got the Body Armor."
	RespawnTime=30.000000
	PickupViewMesh=Mesh'Botpack.Armor2M'
	Charge=100
	ArmorAbsorption=75
	bIsAnArmor=True
	AbsorptionPriority=7
	MaxDesireability=2.000000
	PickupSound=Sound'Botpack.Pickups.ArmorUT'
	Mesh=Mesh'Botpack.Armor2M'
	AmbientGlow=64
	CollisionHeight=11.000000
	ItemName="Body Armor"
	Icon=Texture'Botpack.Icons.B227_I_Armor2'
}
