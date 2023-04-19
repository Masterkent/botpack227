class ONPInterpolateSpecialEvent expands Triggers;

var SpecialEvent SpecialEvent;

static function WrapSpecialEvent(SpecialEvent SpecialEvent)
{
	local ONPInterpolateSpecialEvent MessageEvent;

	if (SpecialEvent != none)
		MessageEvent = SpecialEvent.Spawn(class'ONPInterpolateSpecialEvent',, SpecialEvent.Tag);
	if (MessageEvent == none)
		return;

	MessageEvent.SpecialEvent = SpecialEvent;
	SpecialEvent.Tag = '';
}

function Trigger(Actor A, Pawn EventInstigator)
{
	local string Message;

	if (SpecialEvent == none ||
		EventInstigator == none ||
		InStr(SpecialEvent.Message, "%k") >= 0 && Len(EventInstigator.GetHumanName()) == 0)
	{
		return;
	}

	Message = SpecialEvent.Message;
	SpecialEvent.Message = ReplaceStr(SpecialEvent.Message, "%k", EventInstigator.GetHumanName());
	SpecialEvent.Trigger(A, EventInstigator);
	SpecialEvent.Message = Message;
}
