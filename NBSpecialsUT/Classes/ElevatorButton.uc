//=============================================================================
// ElevatorButton.
//
// script by N.Bogenrieder (Beppo)
//
// use it with the classes under point 1. for a full
// working elevator with in- and outside buttons and
// outside doors !!
//
// ======================================
// !!! Building rules (best version): !!!
// ======================================
// A = 'elevator', B = two 'inside buttons',
// C = 'outside buttons' for each elevator keyframe
// D = TwoStateElevatorTriggers for each elevator keyframe
// E = elevator doors for each elevator keyframe
//
// 1. A = ElevatorMoverInsideButton in state 'ElevatorTriggerGradual'
//    B = ElevatorButtons in state 'ElevatorButton'
//    C = Movers in state 'BumpButton'
//    D = TwoStateElevatorTriggers
//    E = Movers in state 'TriggerToggle'
//    ( D is a subclass of 'Triggers' all others are subclasses of 'Brush.Mover')
//
// 2. B.Tag = B.Event = A.Tag = A.Event
//    B.bSlave = TRUE
//    B.AttachTag = A.Tag
//    B.bElevatorMover = TRUE
//    first  B.bMoveUp = TRUE   (BTN for moving up)
//    second B.bMoveUp = FALSE  (BTN for moving down)
//    (place them inside the elevator)
//
// 3. D.Tags = C.Events (for each elevator keyframe ie. Elev0 - Elev3)
//    D.Event = A.Event
//    D.TGotoKeyFrame = D.UTGotoKeyFrame = desired elevator keyframe (ie. 0 - 3)
//    (place Cs and Ds just outside of each elevator exit)
//
// 4. E.Tags = A.DoorTags (0-7 for each keyframe / submenu ElevatorDoors)
//    (don't forget to 'open' the doors, where the elevator starts)
//
// 5. if elevator doors are used or any other movers starting
//    with a KeyNum != 0:
//    place one Info.SetMoverInfo inside your map to correct a
//    bug from the original mover class (read its script for details)
//
// That's all :) !!
//=============================================================================
class ElevatorButton expands Mover;

var() bool bElevatorMover;
var() bool bMoveUp;

var vector       oKeyPos[8];
var rotator      oKeyRot[8];

function PostBeginPlay()
{
local int i;
	Super.PostBeginPlay();
// initialize all Keys and save them in oKey...
	for (i=1; i > 8; i++)
	{
		oKeyPos[i] = KeyPos[i];
		oKeyRot[i] = KeyRot[i];
		KeyPos[i]  = vect(0,0,0);
		KeyRot[i]  = rot(0,0,0);
	}
}

// Open the mover.
function DoOpen()
{
	bOpening = true;
	bDelaying = false;

// all interpolations done by changing the BasePos
	BasePos = Location + (oKeyPos[1] - oKeyPos[0]);

	InterpolateTo(1,MoveTime);

	PlaySound( OpeningSound, SLOT_None );
	AmbientSound = MoveAmbientSound;
}

// Close the mover.
function DoClose()
{
	local int k;

	bOpening = false;
	bDelaying = false;

	k = Max(0,KeyNum-1);

// all interpolations done by changing the BasePos
	BasePos = Location + (oKeyPos[k] - KeyPos[PrevKeyNum]);

	InterpolateTo(k,MoveTime);

	PlaySound( ClosingSound, SLOT_None );
	AmbientSound = MoveAmbientSound;
}

// Handle when the mover finishes opening.
function FinishedOpening()
{
	local actor A;
	local ElevatorMover EM;

	// Update sound effects.
	PlaySound( OpenedSound, SLOT_None );
	
	// Trigger any chained movers.
	if( Event != '' )
	{
		if( bElevatorMover)
		{
// move the ElevatorMover
			foreach AllActors( class 'ElevatorMover', EM, Event )
			{
				EM.SavedTrigger = Self;

// if EM is turned off set the proper state for moving
				EM.GotoState( 'ElevatorTriggerGradual' );

				if(bMoveUp)
					EM.MoveKeyframe( EM.KeyNum + 1, EM.MoveTime );
				else
					EM.MoveKeyframe( EM.KeyNum - 1, EM.MoveTime );
			}
		}
		else
		{
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( Self, Instigator );
		}
	}
	FinishNotify();
}

function TurnOFF()
{
// turn off all related ElevatorButtons
// and ElevatorMovers, cause else you
// can push the other in- and outside
// btns while this mover is moving
// unwanted result: shifting...
	local ElevatorMoverInsideButtons EM;
	local ElevatorButton EB;

	if( Event != '' )
		if( bElevatorMover)
		{
			foreach AllActors( class 'ElevatorButton', EB, Event )
				EB.Disable('Bump');
			foreach AllActors( class 'ElevatorMoverInsideButtons', EM, Event )
				EM.GotoState( 'DoNothing');
		}
}
function TurnON()
{
// turn all on again ...
	local ElevatorMoverInsideButtons EM;
	local ElevatorButton EB;

	if( Event != '' )
		if( bElevatorMover)
		{
			foreach AllActors( class 'ElevatorButton', EB, Event )
				EB.Enable('Bump');
			foreach AllActors( class 'ElevatorMoverInsideButtons', EM, Event )
				EM.GotoState( 'ElevatorTriggerGradual' );
		}
}

// All below just for the 'outside button' variant
// (see building rules on top of this script).
// Cause, if the outside button is pressed the inside
// button (this script itself) have to be disabled.
// This is done with the Trigger and UnTrigger
// functions below...

state() ElevatorButton
{
// if another 'button' triggers the elevator...
	function Trigger( actor Other, pawn EventInstigator )
	{
		Disable( 'Bump' );
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		Enable( 'Bump' );
	}

	function bool HandleDoor(pawn Other)
	{
		if ( (BumpType == BT_PlayerBump) && !Other.bIsPlayer )
			return false;

		Bump(Other);
		return false; //let pawn try to move around this button
	}

	function Bump( actor Other )
	{
		if ( (BumpType != BT_AnyBump) && (Pawn(Other) == None) )
			return;
		if ( (BumpType == BT_PlayerBump) && !Pawn(Other).bIsPlayer )
			return;
		if ( (BumpType == BT_PawnBump) && (Other.Mass < 10) )
			return;
		Global.Bump( Other );
		SavedTrigger = Other;
		Instigator = Pawn( Other );
		GotoState( 'ElevatorButton', 'Open' );
	}
	function BeginEvent()
	{
		bSlave     = true;
	}
	function EndEvent()
	{
		bSlave     = true;
		Instigator = None;
		GotoState( 'ElevatorButton', 'Close' );
	}
Open:
	Disable( 'Bump' );
	TurnOFF();
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	if( bTriggerOnceOnly )
		GotoState('');
	if( bSlave )
		Stop;
Close:
	Disable( 'Bump' );
	TurnOFF();
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	Enable( 'Bump' );
	TurnON();
}

defaultproperties
{
     bElevatorMover=True
     bMoveUp=True
     MoverEncroachType=ME_IgnoreWhenEncroach
     MoverGlideType=MV_MoveByTime
     BumpType=BT_PawnBump
     bSlave=True
     InitialState=ElevatorButton
}
