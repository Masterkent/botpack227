//=============================================================================
// ResetTriggeredMovers.
//
// script by N.Bogenrieder (Beppo)
//
//=============================================================================
class ResetTriggeredMovers expands Triggers;

var() name  MoverTags[8]; // Movers to reset
var() int	TriggerUnTrigger[8]; // if not 0 Trigger , if 0 UnTrigger

var int i;                // Internal counter.
var mover tMover;

function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('ResetMovers');
}

state ResetMovers
{
Begin:
	disable('Trigger');
	for( i=0; i<ArrayCount(MoverTags); i++ )
	{
		if( MoverTags[i] != '' )
		{
			foreach AllActors( class 'Mover', tMover, MoverTags[i] )
			{
				tMover.numTriggerEvents = 0;
				if(TriggerUnTrigger[i] == 0)
					tMover.UnTrigger( Self, Instigator );
				else
					tMover.Trigger( Self, Instigator );
			}
		}
	}
	enable('Trigger');
}

defaultproperties
{
     Texture=Texture'Engine.S_SpecialEvent'
}
