class ONPEventToEvent expands Triggers;

var bool bTriggerOnceOnly;

auto state Active
{
	event Trigger(Actor A, Pawn EventInstigator)
	{
		if (bTriggerOnceOnly)
		{
			CauseEvent(A, EventInstigator);
			GotoState('');
		}
		else
			CauseEvent(A, EventInstigator);
	}

	singular function CauseEvent(Actor A, Pawn EventInstigator)
	{
		TriggerEvent(Event, A, EventInstigator);
	}
}
