class XidiaEventToEvent expands Info;

var() bool bTriggerOnceOnly;
var() bool bEnabled;

function Trigger(Actor A, Pawn EventInstigator)
{
	if (!bEnabled)
		return;

	TriggerEvent(Event, A, EventInstigator);
	if (bTriggerOnceOnly)
		bEnabled = false;
}

defaultproperties
{
	bEnabled=True
}