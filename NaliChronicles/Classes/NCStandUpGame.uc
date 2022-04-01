// The player starts out down on the ground
// Code by Sergey 'Eater' Levin, 2001

class NCStandUpGame extends NCGameInfo;

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
	if ( NewPlayer != None )	{
		NewPlayer.PlayerRestartState = 'PlayerWaking';
		NewPlayer.ViewRotation.Pitch = 16384;
	}
	return NewPlayer;
}

defaultproperties
{
}
