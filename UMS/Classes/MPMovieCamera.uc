//=============================================================================
//
// MPMovieCamera.uc
//
// by Hugh Macdonald
//
//=============================================================================

class MPMovieCamera expands MovieCamera;

var() bool bTrackingMP;
var() bool bMovingMP;
var() struct MoveCamPoint
{
	var() name PawnPoint;
	var() name CameraPoint;
	var SimplePoint PawnSP;
	var MovieCamera PosMC;
} Start, End;

var vector MCDist, MCTotDist;

var rotator MCRot, MCTotRot;

var Pawn CurrentPawn;

function PostBeginPlay()
{
	if(bMovingMP)
	{
		Start.PawnSP = FindSimplePoint(Start.PawnPoint);
		Start.PosMC = FindMovieCamera(Start.CameraPoint);
		End.PawnSP = FindSimplePoint(End.PawnPoint);
		End.PosMC = FindMovieCamera(End.CameraPoint);
		
		MCTotDist = End.PosMC.Location - Start.PosMC.Location;
		MCTotRot = End.PosMC.Rotation - Start.PosMC.Rotation;
	}
}

function SimplePoint FindSimplePoint(name SPName)
{
	local SimplePoint S;
	
	foreach AllActors(class 'SimplePoint', S)

		if (SPName == S.Tag)
			return S;
	//If there is no matching SimplePoint, return none.
	return NONE;
}

function MovieCamera FindMovieCamera(name MCName)
{
	local MovieCamera C;
	
	foreach AllActors(class 'MovieCamera', C)
		if (MCName == C.Tag)
			return C;
	//If there is no matching MovieCamera, return none.
	return NONE;
}


event Tick(float DeltaTime)
{
	local float PawnDist, PawnTotDist, PawnPct;
	local vector TempVec;
	local rotator TempRot;

	if(CurrentPawn != None)
	{
		if(bMovingMP)
		{
			// Find out what percentage of the distance between the two points the pawn is
			PawnDist = vsize(CurrentPawn.Location - Start.PawnSP.Location);
			PawnTotDist = PawnDist + vsize(End.PawnSP.Location - CurrentPawn.Location);
			PawnPct = PawnDist / PawnTotDist;
			
			// Set the position of the camera
			TempVec = PawnPct * MCTotDist;
			SetLocation(Start.PosMC.Location + TempVec);
			
			// Set the rotation of the camera
			TempRot = PawnPct * MCTotRot;
			SetRotation(Start.PosMC.Rotation + TempRot);
		}
	
	
		if(bTrackingMP)
		{
			TempVec = (CurrentPawn.Location) - Location;
			TempRot = rotator(TempVec);
			SetRotation(TempRot);
		}
	}
}

defaultproperties
{
}
