//=============================================================================
// RotatingMover2.
//
// script by N.Bogenrieder (Beppo)
//
// Its just a RotatingMover that doesn't start to rotate by
// itself... only if triggerd... and the controler pressed
// Fire or AltFire
//=============================================================================
class RotatingMover2 expands Mover;

var() rotator RotateRate;
var() rotator AltRotateRate;
var() bool bRotateFire;
var() bool bRotateAltFire;

var actor tActor;
var bool bActive;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	tActor = None;
	Disable('Tick');
}

function BeginPlay()
{
	Disable( 'Tick' );
}

auto state RotateFireAltFire
{
	function Tick( float DeltaTime )
	{
		if (tActor != None)
		{
			if ((Pawn(tActor).bFire == 1) && (bRotateFire))
				SetRotation( Rotation + (RotateRate*DeltaTime) );
			else if ((Pawn(tActor).bAltFire == 1) && (bRotateAltFire))
				SetRotation( Rotation + (AltRotateRate*DeltaTime) );
		}
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		if (!bActive && other.IsA('Pawn'))
		{
			tActor = Other; Enable('Tick');
			bActive = True;
		}
	}

	function UnTrigger( Actor other, Pawn EventInstigator )
	{
		if (bActive && tActor == Other)
		{
			tActor = None;  Disable('Tick');
			bActive = False;
		}
	}
Begin:
	Disable('Tick');
	tActor = None;
	bActive = False;
}

defaultproperties
{
     RotateRate=(Roll=10000)
     AltRotateRate=(Roll=8000)
     bRotateFire=True
     MoverEncroachType=ME_IgnoreWhenEncroach
     bDynamicLightMover=True
     InitialState=None
     bDirectional=True
}
