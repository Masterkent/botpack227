// NC game
// Code by Sergey 'Eater' Levin, 2001

class NCGameInfo extends UnrealGameInfo;

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	if (SpawnClass != class'NaliMage')
		SpawnClass=class'NaliMage';
	// make sure the difficulty level is set at medium
	// difficulty = 1;
	return Super.Login(Portal, Options, Error, SpawnClass);
}

/*event PostLogin( playerpawn NewPlayer )
{
	// Start player's music.
	if (NewPlayer.Song != none && NaliMage(NewPlayer) != none)
		NewPlayer.ClientSetMusic( NaliMage(NewPlayer).SavedSong, NewPlayer.SongSection, NewPlayer.CdTrack, NewPlayer.Transition );
	else
		Super.PostLogin(NewPlayer);
}*/

event InitGame(string Options, out string Error)
{
	MutatorClass = class<Mutator>(DynamicLoadObject("NCGameFix.NCGameFix", class'Class', true));
	if (MutatorClass == none)
		MutatorClass = default.MutatorClass;
	super.InitGame(Options, Error);
}

defaultproperties
{
     DefaultPlayerClass=Class'NaliChronicles.NaliMage'
     DefaultWeapon=None
     GameUMenuType="NaliChronicles.NCGameMenu"
     MultiplayerUMenuType=""
     GameOptionsMenuType="NaliChronicles.NCOptionsMenu"
     HUDType=Class'NaliChronicles.NCHUD'
}
