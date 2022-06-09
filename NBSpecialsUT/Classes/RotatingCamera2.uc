//=============================================================================
// RotatingCamera2.
//
// script by N.Bogenrieder (Beppo)
//
// same as the RotatingCamera but doesn't set the
// viewtarget
// attach an Info.ViewSpot to it to get the view...
//=============================================================================
class RotatingCamera2 expands RotatingCamera;

auto state Camera
{
function Tick( float DeltaTime )
{
	tmprot.Yaw = RotateYaw;
	if (bChkYaw)
	{
		if ( Rotation.Yaw > maxYaw )
			bRotClockwise = False;
		if ( Rotation.Yaw < minYaw )
			bRotClockwise = True;
		if ( !bRotClockwise )
			tmprot.Yaw *= -1;
	}
	SetRotation( Rotation + (tmprot*DeltaTime) );
}

function Trigger( Actor other, Pawn EventInstigator )
{
	if (!bActive)
	{
		oInst = PlayerPawn(other);
		if ( oInst != None )
		{
//			SetViewOfPlayer();
			Enable('Tick');
			bActive = True;
		}
	}
}

function UnTrigger( Actor other, Pawn EventInstigator )
{
	if (bActive && oInst == PlayerPawn(Other))
	{
//		ResetViewOfPlayer();
		Disable('Tick');
		bActive = False;
	}
}

Begin:
	Disable('Tick');
	bActive = False;
	oInst = None;
}

defaultproperties
{
}
