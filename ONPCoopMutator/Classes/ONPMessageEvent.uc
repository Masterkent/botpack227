class ONPMessageEvent expands Triggers;

var SpecialEvent SpecialEvent;

static function WrapSpecialEvent(SpecialEvent SpecialEvent)
{
	local ONPMessageEvent MessageEvent;

	if (SpecialEvent != none)
		MessageEvent = SpecialEvent.Spawn(class'ONPMessageEvent',, SpecialEvent.Tag);
	if (MessageEvent == none)
		return;

	MessageEvent.SpecialEvent = SpecialEvent;
	SpecialEvent.Tag = '';
}

function Trigger(Actor A, Pawn EventInstigator)
{
	if (SpecialEvent == none)
		return;

	SpecialEvent.Trigger(A, EventInstigator);
	SpecialEvent.bBroadcast = false;
}
