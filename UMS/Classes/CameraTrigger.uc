//=============================================================================
// CameraTrigger.
// Written by Yoda.
//=============================================================================
class CameraTrigger expands UMSTriggers;

var() name TargetCameraTag;
var() bool bTriggerOnlyOnce;


function Trigger( actor Other, pawn EventInstigator )
{

	Touch (Other);

}

function Touch( actor Other )
{


	if ( PlayerPawn(Other) != None )
	{
		Log (Self$": I have been touched, Setting viewtarget for Pawn "$Other$"to "$PlayerPawn(Other).ViewTarget);
		PlayerPawn(Other).ViewTarget = FindMovieCamera(TargetCameraTag);

		if ( bTriggerOnlyOnce )
			Destroy();

	}


}


function MovieCamera FindMovieCamera (name MovieCTag) 
{

	local MovieCamera C;
	log ("Finding MovieCamera...");
	foreach AllActors(class 'MovieCamera', C, MovieCTag) 
	{
		Log(C);
		return C;
		
	}
}

defaultproperties
{
				Texture=Texture'Engine.S_Trigger'
}
