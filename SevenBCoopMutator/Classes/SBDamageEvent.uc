class SBDamageEvent expands Triggers;

var SpecialEvent SpecialEvent;

static function WrapSpecialEvent(SpecialEvent SpecialEvent)
{
	local SBDamageEvent DamageEvent;

	if (SpecialEvent != none)
		DamageEvent = SpecialEvent.Spawn(class'SBDamageEvent',, SpecialEvent.Tag);
	if (DamageEvent == none)
		return;

	DamageEvent.SpecialEvent = SpecialEvent;
	SpecialEvent.Tag = '';
}

function Trigger(Actor A, Pawn EventInstigator)
{
	if (SpecialEvent != none)
		SpecialEvent.Trigger(EventInstigator, EventInstigator);
}
