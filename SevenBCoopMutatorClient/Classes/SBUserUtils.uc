class SBUserUtils expands Inventory;

var transient B227_SpeechMenu B227_SpeechMenu;

function GiveTo(Pawn P)
{
	Instigator = P;
	BecomeItem();
	RemoteRole = ROLE_SimulatedProxy;
	P.AddInventory(self);
}

simulated exec function ShowSpeech()
{
	class'Botpack.B227_SpeechMenu'.static.ShowMenu(PlayerPawn(Owner), B227_SpeechMenu);
}

defaultproperties
{
	bTravel=False
}
