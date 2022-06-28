//=============================================================================
// MovieInfo.
//
// MovieInfo is a game with no rules, no way to win or loose.  It lets
// you just run your movie in a given level.
//=============================================================================
class MovieInfo expands GameInfo;

event playerpawn Login (string Portal, string Options, out string Error, class<playerpawn> SpawnClass)
{
	local PlayerPawn P;
	
	SpawnClass = class'MoviePlayer';
	P = super.Login(Portal, Options, Error, SpawnClass);
	P.HUDType = HUDType;
	P.myHUD = spawn(P.HUDType, P);

	return P;
}

defaultproperties
{
				HUDType=Class'UMS.MovieHUD'
}
