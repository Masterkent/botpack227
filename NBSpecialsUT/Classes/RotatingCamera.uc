//=============================================================================
// RotatingCamera.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class RotatingCamera expands Mover;

var() float RotateYaw;
var() float maxYaw;
var() float minYaw;
var() float CameraFOV;

var bool bChkYaw;
var rotator tmprot;
var playerpawn oInst;
var float oFOV;
var bool bRotClockwise;
var bool bActive;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bChkYaw = False;
	if	(	(maxYaw != 0)
		&&	(minYaw != 0) )
	{
		tmprot = Rotation;
		tmprot.Yaw = minYaw;
		SetRotation(tmprot);
		bChkYaw = True;
	}
	if(RotateYaw < 0) RotateYaw *= -1;
	bRotClockwise = True;
	tmprot.Pitch = 0;
	tmprot.Roll = 0;
	oInst = None;
	Disable('Tick');
}

function SetViewOfPlayer()
{
	if (oInst.ViewTarget != Self)
	{
		if (oInst.ViewTarget != none)
			oInst.EndZoom();
		oInst.ViewTarget = Self;
		oFOV = oInst.DesiredFOV;
		oInst.DesiredFOV = class'ViewSpot'.static.B227_ScaleFOV(CameraFOV, oInst.DefaultFOV, class'ViewSpot'.static.B227_GetAspectRatio(oInst));
		oInst.bBehindView = False;
	}
}

function ResetViewOfPlayer()
{
	if (oInst.ViewTarget == Self)
	{
		oInst.DesiredFOV = oFOV;
		oInst.bBehindView = False;
		oInst.ViewTarget = None;
	}
	oInst = None;
}

function BeginPlay()
{
	Disable( 'Tick' );
}

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
		if ( oInst != None && other.IsA('PlayerPawn'))
		{
			ResetViewOfPlayer();
		}
		oInst = PlayerPawn(other);
		if ( oInst != None )
		{
			SetViewOfPlayer();
			Enable('Tick');
			bActive = True;
		}
	}
}

function UnTrigger( Actor other, Pawn EventInstigator )
{
	if (bActive && oInst == PlayerPawn(Other))
	{
		ResetViewOfPlayer();
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
     RotateYaw=4000.000000
     maxYaw=32768.000000
     minYaw=0.100000
     CameraFOV=100.000000
     MoverEncroachType=ME_IgnoreWhenEncroach
     bDynamicLightMover=True
     InitialState=None
     bDirectional=True
}
