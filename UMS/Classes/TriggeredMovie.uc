//=============================================================================
// TriggeredMovie. -- One massive hack to make UMS work in realtime.
// Written by Yoda.
//=============================================================================

class TriggeredMovie expands UMS;

var() name TargetMovieSpotTag;
var() name DirectorTag;
var() bool bDontChangeHUD;
var() bool bDontResetView;
var bool bRolling;
var MoviePlayer MP;
var Hud PlayerHUD[50];
var int PlayerNum;
var Director TriggeredDirector;
var bool bKeptView;

function Trigger(actor Other, Pawn instigator) {

	if (bRolling == false) {
		Log ("Triggered!");
		ConvertPlayers();
		BeginMovie();
		bRolling = true;
	}

}

function Tick(float DeltaTime) 
{
	local PlayerPawn P;


	if (bRolling && TriggeredDirector != None) 
	{

		if (TriggeredDirector.bDoneWithMovie == true) 
		{
			log ("I have detected the director is done.. resetting.");	
			foreach AllActors(class'PlayerPawn', P) 
			{
				if (!P.IsA('MoviePlayer')) 
				{
					Log ("Restoring... "$P);
					if (bDontChangeHud == false) 
					{
						P.MyHud.Destroy();
						P.MyHud = none;
						P.HudType = Level.Game.HUDType;
						
					}
					if (bDontResetView == false) 
					{
						P.ViewTarget = none;
					}
				}
			}
   
			if (bDontResetView == false) 
			{
				MP.Destroy();
				bRolling = false;
				TriggeredDirector.bDoneWithMovie = false;
				TriggeredDirector = None;
				Log ("Destroyed camera!");
			}			
			else 
			{
				Log ("Keeping camera...");
				bRolling = true;
				TriggeredDirector.bDoneWithMovie = false;
				TriggeredDirector = None;
			}
		}
	}
}

function ConvertPlayers() {

	local PlayerPawn P;

	local TriggeredMovieSpot MS;

	PlayerNum = 0;
	foreach AllActors(class'TriggeredMovieSpot', MS, TargetMovieSpotTag) {
		Log ("Found MovieSpot spot!");
		if (bRolling == false)	{
			MP = spawn(class'MoviePlayer',,,MS.Location,MS.Rotation);
			Log ("No camera found.. spawning new one");
		}
	}

	foreach AllActors(class'PlayerPawn', P) {
		if (!P.IsA('MoviePlayer')) {
			Log ("Converting... "$P);

			if (bDontChangeHUD == false) {
				P.MyHud.Destroy();
				P.MyHud = none;
				P.HudType = class'MovieHUD';

			}
			P.ViewTarget = MP;
			P.bBehindView = false;

		}
	}


}


function BeginMovie() {
	
	local Director MyDirector;
	Log ("Finding director to begin movie!");
	foreach AllActors(class'Director', MyDirector, DirectorTag) {

		Log ("Director found..."$MyDirector);
		MyDirector.bRolling = true;
		TriggeredDirector = MyDirector;
	}


}

defaultproperties
{
}
