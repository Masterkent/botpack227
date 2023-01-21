//=============================================================================
// ThighPads.
//=============================================================================
class ThighPads extends TournamentPickup;

#exec MESH IMPORT MESH=ThighPads ANIVFILE=MODELS\ThighPads_a.3d DATAFILE=MODELS\ThighPads_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ThighPads X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=ThighPads SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ThighPads SEQ=sit                      STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=ThighPads MESH=ThighPads
#exec MESHMAP SCALE MESHMAP=ThighPads X=0.04 Y=0.04 Z=0.08
#exec TEXTURE IMPORT NAME=JThighPads_01 FILE=MODELS\ThighPads1.PCX GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ThighPads NUM=1 TEXTURE=JThighPads_01
#exec MESHMAP SETTEXTURE MESHMAP=ThighPads NUM=2 TEXTURE=JThighPads_01
#exec TEXTURE IMPORT NAME=B227_I_ThighPads FILE=Textures\Hud\B227_i_ThighPads.pcx GROUP="Icons" MIPS=OFF

function bool HandlePickupQuery(Inventory Item)
{
	if (Item.Class == Class) 
	{
		Charge = Max(Charge, B227_HandleUTArmors(Pawn(Owner), 0, 0, Item.Charge));
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
	local inventory Copy;

	Copy = super.SpawnCopy(Other);
	Copy.Charge = B227_HandleUTArmors(Other, 0, 0, Copy.Charge, Copy);
	if (Copy.Charge <= 0)
		Copy.Destroy();
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
