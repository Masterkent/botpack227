//=============================================================================
// ElevatorMoverInsideButtons.
//
// script by N.Bogenrieder (Beppo)
//
// details see ElevatorButton !!
//=============================================================================
class ElevatorMoverInsideButtons expands ElevatorMover;

var(ElevatorDoors) name DoorTag[8];
var(ElevatorInfo) name ElevatorInfoTag;

var ElevatorBotInfo EInfo;

function PostBeginPlay()
{
	Super.PostBeginPlay();
// if KeyNum != 0 the function 'BeginPlay' moves the
// mover to its initial location (KeyNum) but it doesn't
// set up all needed vars correctly...
	InterpolateTo(KeyNum,0.01);
// this fixes it!

	foreach allactors (class'ElevatorBotInfo', EInfo, ElevatorInfoTag)
		break;		
}

function StartMovement()
{
	local ElevatorButton EB;

	if( EInfo != None)
		EInfo.TurnOffElev();

// disable all related ElevatorBtns
	if( Event != '' )
		foreach AllActors( class 'ElevatorButton', EB, Event )
			EB.Disable( 'Bump' );
}

function EndMovement()
{
	local ElevatorButton EB;

// Notify our triggering actor that we have completed.
	if( SavedTrigger != None )
		SavedTrigger.EndEvent();
	
// enable all related ElevatorBtns
	if( Event != '' )
		foreach AllActors( class 'ElevatorButton', EB, Event )
			EB.Enable( 'Bump' );

	FinishNotify(); 

	if( EInfo != None)
	{
// if reached one of the 'end'-keyframes
		if	(	(KeyNum <= 0)
			||	(KeyNum >= NumKeys-1) )
		{
			EInfo.bUseUpDown = True;

// turn off the down button
			if(KeyNum <= 0)
			{
				EInfo.TurnOffIn(False);
			}
// turn off the up button
			else
			{
				EInfo.TurnOffIn(True);
			}
		}
		else
		{
			EInfo.bUseUpDown = False;
		}
		
		EInfo.TurnOnElev(KeyNum);
	}

	SavedTrigger = None;
	Instigator = None;
}

function FinishedClosing()
{
	PlaySound( ClosedSound, SLOT_None );
//	EndMovement();
}

function FinishedOpening()
{
	PlaySound( OpenedSound, SLOT_None );
//	EndMovement();
}

function MoveKeyframe( int newKeyNum, float newMoveTime)
{
	if(!bMoveKey) {	return;	}

	StartMovement();

	if	(	(newKeyNum >= NumKeys)
		||	(newKeyNum < 0) 
		||	(newKeyNum == KeyNum) )
	{
		EndMovement();
		return;
	}

// Close the Doors
	OpenCloseDoor();

	NextKeyNum = newKeyNum;
	if( NextKeyNum < KeyNum )
	{
		MoveDirection = -1;
		MoveTimeInterval = newMoveTime/(KeyNum-NextKeyNum);
		GotoState('ElevatorTriggerGradual','ChangeFrame');
	}
	
	if( NextKeyNum > KeyNum )
	{
		MoveDirection = 1;
		MoveTimeInterval = newMoveTime/(NextKeyNum-KeyNum);
		GotoState('ElevatorTriggerGradual','ChangeFrame');
	}
}

function OpenCloseDoor()
{
local mover Door;
	if( DoorTag[KeyNum] != '' )
		foreach AllActors( class 'Mover', Door, DoorTag[KeyNum] )
			Door.Trigger( self, instigator);
}

state() ElevatorTriggerGradual 
{
	function InterpolateEnd(actor Other) 
	{	
		AmbientSound = None;
	}

	function BeginState()
	{
		bOpening = false;
	}

ChangeFrame:
	bMoveKey = false;

	// Move the mover
	if( MoveDirection > 0	){
		DoOpen();
		FinishInterpolation();
		FinishedClosing();
	}
	else {
		DoClose();
		FinishInterpolation();
		FinishedOpening();
	}

	// Check if there are more frames to go
	//
	if( KeyNum != NextKeyNum )
		GotoState('ElevatorTriggerGradual','ChangeFrame');
	else
	{
		EndMovement();
// Open the Doors
		OpenCloseDoor();
	}

	bMoveKey = true;
	Stop;
Begin:
}

// Called from the ElevatorButtons
state DoNothing
{
ignores MoveKeyFrame;
Begin:
}

defaultproperties
{
     MoverEncroachType=ME_IgnoreWhenEncroach
     MoveTime=2.000000
     InitialState=ElevatorTriggerGradual
}
