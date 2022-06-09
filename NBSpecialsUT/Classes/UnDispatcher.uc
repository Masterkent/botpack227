//=============================================================================
// UnDispatcher.
//
// script by N.Bogenrieder (Beppo)
//
// same as Dispatcher but only works if UnTriggered
// + can do Trigger AND UnTrigger events
//=============================================================================
class UnDispatcher expands Triggers;

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutEvents[8]; // Events to generate.
var() float OutDelays[8]; // Relative delays before generating events.
var() int	OutTrigger[8]; // if not 0 Trigger , if 0 UnTrigger

var int i;                // Internal counter.

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
	enable('UnTrigger');
}

defaultproperties
{
     Texture=Texture'Engine.S_Dispatcher'
}
