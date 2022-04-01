//=============================================================================
// Dispatcher: receives one trigger (corresponding to its name) as input,
// then triggers a set of specifid events with optional delays.
//=============================================================================
class KKDispatcher extends Triggers;

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutEvents[8]; // Events to generate.
var() float OutDelays[8]; // Relative delays before generating events.
var int i;                // Internal counter.

//=============================================================================
// Dispatcher logic.

//
// When dispatcher is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('Dispatch');
}

function bool ActorExists(int num )
{
	local actor a;
        if( num < 0 )
		return false;
	if( OutEvents[num-1] == '' )
		return false;

	foreach AllActors( class 'Actor', A, OutEvents[num-1] )
        {
		break;
        }
        return (A != none);
}

//
// Dispatch events.
//
state Dispatch
{
Begin:
	disable('Trigger');

        if( i<ArrayCount(OutEvents) )
        {
Sleepy:
                if( ActorExists(i) )
                {
                          Sleep(0.01);
                          GoTo('Sleepy');
                }
                if( OutEvents[i] != '' )
		{
			Sleep( OutDelays[i] );
			foreach AllActors( class 'Actor', Target, OutEvents[i] )
				Target.Trigger( Self, Instigator );
		}
		i++;
	}
	enable('Trigger');
}

defaultproperties
{
     Texture=Texture'Engine.S_Dispatcher'
}
