class LadderLoadGame extends UTIntro;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	local SpectatorCam Cam;

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	NewPlayer.bHidden = True;

	foreach AllActors(class'SpectatorCam', Cam) 
		NewPlayer.ViewTarget = Cam;

	return NewPlayer;
}

function AcceptInventory(pawn PlayerPawn)
{
	local inventory Inv, Next;

	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Next )
	{
		Inv.Destroy();
	}

	class'TournamentConsole'.static.UTSF_LoadGame(PlayerPawn(PlayerPawn).Player.Console);
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}

defaultproperties
{
}
