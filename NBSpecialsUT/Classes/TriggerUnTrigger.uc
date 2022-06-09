//=============================================================================
// TriggerUnTrigger.
//
// script by N.Bogenrieder (Beppo)
//
// Trigger-Event turns on
// UnTrigger-Event turns off
//=============================================================================
class TriggerUnTrigger expands Trigger;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bInitiallyActive = False;
}

state() TriggerUnTrigger
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = True;
		if ( bInitiallyActive )
			CheckTouchList();
	}

	function UnTrigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = False;
	}
}

defaultproperties
{
     bInitiallyActive=False
     InitialState=TriggerUnTrigger
}
