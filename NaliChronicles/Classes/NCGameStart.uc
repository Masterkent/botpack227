// NC game, to be used on first level
// Code by Sergey 'Eater' Levin, 2001

class NCGameStart extends NCGameInfo;

function AddDefaultInventory( pawn PlayerPawn )
{
	local inventory newItem;

	Super.AddDefaultInventory(playerpawn);
	if (PlayerPawn.FindInventoryType(Class'NaliChronicles.NCDiary') == none) {
		newItem = Spawn(Class'NaliChronicles.NCDiary',,,PlayerPawn.Location);
		newItem.RespawnTime = 0.0;
		newItem.GiveTo(PlayerPawn);
		PlayerPawn(PlayerPawn).PrevItem();
	}
	if (PlayerPawn.FindInventoryType(Class'NaliChronicles.NCLogbook') == none) {
		newItem = Spawn(Class'NaliChronicles.NCLogbook',,,PlayerPawn.Location);
		newItem.RespawnTime = 0.0;
		newItem.GiveTo(PlayerPawn);
		PlayerPawn(PlayerPawn).PrevItem();
	}
}

defaultproperties
{
}
