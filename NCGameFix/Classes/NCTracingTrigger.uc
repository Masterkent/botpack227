class NCTracingTrigger expands Trigger;

var Actor TracedActor;

function Trigger(Actor A, Pawn EventInstigator)
{
	if (TracedActor != none && !TracedActor.bDeleteMe)
		SetTimer(0.1, true);
}

function SetTracedActor(Actor A)
{
	TracedActor = A;
}

function Timer()
{
	TraceActor();
}

function TraceActor()
{
	local Actor A;

	if (TracedActor == none || TracedActor.bDeleteMe)
	{
		DisableTracing();
		return;
	}

	if (!FastTrace(Location, TracedActor.Location))
	{
		if (Event != '')
		{
			foreach AllActors(class 'Actor', A, Event)
				A.Trigger(TracedActor, TracedActor.Instigator);
		}

		if (bTriggerOnceOnly)
			DisableTracing();
	}
}

function DisableTracing()
{
	TracedActor = none;
	SetTimer(0, false);
}

defaultproperties
{
}
