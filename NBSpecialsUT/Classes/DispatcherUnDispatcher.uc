//=============================================================================
// DispatcherUnDispatcher.
//
// script by N.Bogenrieder (Beppo)
//
// just a combination of the Dispatcher AND the UnDispatcher
// + variable 'triggering' Trigger or UnTrigger combinations
//=============================================================================
class DispatcherUnDispatcher expands Triggers;

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutEvents[8]; // Events to generate.
var() float OutDelays[8]; // Relative delays before generating events.
var() int	OutTrigger[8]; // if not 0 Trigger , if 0 UnTrigger

// UnDispatcher variables.

var() name  UnOutEvents[8]; // Events to generate.
var() float UnOutDelays[8]; // Relative delays before generating events.
var() int	UnOutTrigger[8]; // if not 0 Trigger , if 0 UnTrigger

var int i;                // Internal counter.

//=============================================================================
// Dispatcher logic.

//
// When dispatcher is Triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('Dispatch');
}

//
// Dispatch events.
//
state Dispatch
{
Begin:
	disable('Trigger');
	for( i=0; i<ArrayCount(OutEvents); i++ )
	{
		if( OutEvents[i] != '' )
		{
			Sleep( OutDelays[i] );
			foreach AllActors( class 'Actor', Target, OutEvents[i] )
				if(OutTrigger[i] == 0)
					Target.UnTrigger( Self, Instigator );
				else
					Target.Trigger( Self, Instigator );
		}
	}
	enable('Trigger');
}


//=============================================================================
// UnDispatcher logic.

//
// When dispatcher is UnTriggered...
//
function UnTrigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('UnDispatch');
}

//
// Dispatch events.
//
state UnDispatch
{
Begin:
	disable('UnTrigger');
	for( i=0; i<ArrayCount(UnOutEvents); i++ )
	{
		if( UnOutEvents[i] != '' )
		{
			Sleep( UnOutDelays[i] );
			foreach AllActors( class 'Actor', Target, UnOutEvents[i] )
				if(UnOutTrigger[i] == 0)
					Target.UnTrigger( Self, Instigator );
				else
					Target.Trigger( Self, Instigator );
		}
	}
	enable('UnTrigger');
}

defaultproperties
{
     OutTrigger(0)=1
     OutTrigger(1)=1
     OutTrigger(2)=1
     OutTrigger(3)=1
     OutTrigger(4)=1
     OutTrigger(5)=1
     OutTrigger(6)=1
     OutTrigger(7)=1
     Texture=Texture'Engine.S_Dispatcher'
}
