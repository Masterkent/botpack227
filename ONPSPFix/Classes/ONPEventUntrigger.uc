class ONPEventUntrigger expands Info;

event Trigger(Actor A, Pawn EventInstigator)
{
	UnTriggerEvent(Event, A, EventInstigator);
}
