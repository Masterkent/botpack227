class ONPPawnDestructionEvent expands Info;

// Issue Event when the observed pawn is destroyed for any reason

function AssignPawn(Pawn P)
{
	if (P == none)
		return;
	Instigator = P;
	Event = Instigator.Event;
	Instigator.Event = '';
}

event Tick(float DeltaTime)
{
	if (Instigator == none || Instigator.bDeleteMe)
	{
		TriggerEvent(Event, self, Instigator);
		Destroy();
	}
}
