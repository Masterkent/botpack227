// NC movie
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCMovie extends NCGameInfo;

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	NewPlayer.bHidden = true;
	NewPlayer.ghost();
	NewPlayer.god();
	return NewPlayer;
}

defaultproperties
{
}
