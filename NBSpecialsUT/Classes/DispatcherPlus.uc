//=============================================================================
// DispatcherPlus.
//
// script by N.Bogenrieder (Beppo)
//
// same as Dispatcher so only works if Triggered
// + can do Trigger AND UnTrigger events
// like the UnDispatcher
//=============================================================================
class DispatcherPlus expands Triggers;

//-----------------------------------------------------------------------------
// DispatcherPlus variables.

var() name  OutEvents[8]; // Events to generate.
var() float OutDelays[8]; // Relative delays before generating events.
var() int	OutTrigger[8]; // if not 0 Trigger , if 0 UnTrigger
var() bool  bUseActor;

var int i;                // Internal counter.
var actor oActor;

//=============================================================================
// DispatcherPlus logic.

//
// When dispatcher is Triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	oActor = Other;
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
				if (bUseActor)
				{
					if(OutTrigger[i] == 0)
						Target.UnTrigger( oActor, Instigator );
					else
						Target.Trigger( oActor, Instigator );
				}
				else
				{
					if(OutTrigger[i] == 0)
						Target.UnTrigger( Self, Instigator );
					else
						Target.Trigger( Self, Instigator );
				}
		}
	}
	enable('Trigger');
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
     bUseActor=True
     Texture=Texture'Engine.S_Dispatcher'
}
