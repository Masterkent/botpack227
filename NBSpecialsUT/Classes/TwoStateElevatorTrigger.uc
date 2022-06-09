//=============================================================================
// TwoStateElevatorTrigger.
//
// script by N.Bogenrieder (Beppo)
//
// like the ElevatorTrigger but used for a Trigger
// AND an UnTrigger event...
// so, no touching !
//=============================================================================
class TwoStateElevatorTrigger expands Triggers;

var() int	TGotoKeyframe;
var() float	TMoveTime;
var() int	UTGotoKeyframe;
var() float	UTMoveTime;
var() bool	bTriggerOnceOnly;

//The two MoveTimes are ignored by the ElevatorMover

function Touch( actor Other ) {}

function Trigger( actor Other, pawn EventInstigator )
{
	local ElevatorMover EM;
	// Call the ElevatorMover's Move function
	if( Event != '' )
		foreach AllActors( class 'ElevatorMover', EM, Event )
			EM.MoveKeyframe( TGotoKeyFrame, TMoveTime );
	if( bTriggerOnceOnly )
		// Ignore future touches.
		SetCollision(False);
}

function UnTrigger( actor Other, pawn EventInstigator )
{
	local ElevatorMover EM;
	// Call the ElevatorMover's Move function
	if( Event != '' )
		foreach AllActors( class 'ElevatorMover', EM, Event )
			EM.MoveKeyframe( UTGotoKeyFrame, UTMoveTime );
	if( bTriggerOnceOnly )
		// Ignore future touches.
		SetCollision(False);
}

defaultproperties
{
     TGotoKeyframe=1
     TMoveTime=4.000000
     UTMoveTime=4.000000
}
