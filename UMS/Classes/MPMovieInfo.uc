//=============================================================================
// MPMovieInfo.
//
// MovieInfo is a game with no rules, no way to win or loose.  It lets
// you just run your movie in a given level.
//=============================================================================
class MPMovieInfo expands DeathMatchPlus;

event playerpawn Login (string Portal, string Options, out string Error, class<playerpawn> SpawnClass)
{
	local PlayerPawn P;
	
	P = super.Login(Portal, Options, Error, SpawnClass);
	
	if(P.IsA('Spectator'))
	{
		SpawnClass = class'UMSSpectator';
		P.HUDType = HUDType;
		P.myHUD = spawn(P.HUDType, P);
	}

	return P;
}

defaultproperties
{
				HUDType=Class'UMS.MovieHUD'
				MapPrefix="UMS"
				BeaconName="UMS"
				GameName="Movie"
}
