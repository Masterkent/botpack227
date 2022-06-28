//=============================================================================
//
// MPCameraTrigger.uc
//
// by Hugh Macdonald
//
//=============================================================================
class MPCameraTrigger expands UMSTriggers;

var() name TargetCameraTag;

function Trigger( actor Other, pawn EventInstigator )
{
	Touch (Other);
}

function Touch( actor Other )
{
	local Pawn P;
	
	if ( Pawn(Other) != None )
	{
		if (UMSPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo) != None)
		{
			UMSPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).CurrentCamera = FindMovieCamera(TargetCameraTag);
		}
		if (UMSBotReplicationInfo(Pawn(Other).PlayerReplicationInfo) != None)
		{
			UMSBotReplicationInfo(Pawn(Other).PlayerReplicationInfo).CurrentCamera = FindMovieCamera(TargetCameraTag);
		}
	}
	
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if(UMSSpectator(P) != None)
		{
			UMSSpectator(P).ChangeUMSView();
		}
	}
}


function MovieCamera FindMovieCamera (name MovieCTag) 
{

	local MovieCamera C;
	foreach AllActors(class 'MovieCamera', C, MovieCTag) 
	{
		return C;
	}
}

defaultproperties
{
				RemoteRole=ROLE_None
				Texture=Texture'Engine.S_Trigger'
}
