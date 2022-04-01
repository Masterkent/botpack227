class XidiaTriggerStoppedMover expands Triggers;

static function XidiaTriggerStoppedMover CreateFor(LevelInfo Level, string MoverName, optional name Event)
{
	local XidiaTriggerStoppedMover Result;
	local Mover Mover;

	Mover = Mover(DynamicLoadObject(Level.Outer.Name $ "." $ MoverName, class'Mover'));
	if (Mover == none || Mover.Tag == '')
		return none;
	Result = Level.Spawn(class'XidiaTriggerStoppedMover', Mover, Mover.Tag);
	if (Result == none)
		return none;

	Result.Event = Event;
	Mover.Tag = '';

	return Result;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	if (Mover(Owner) == none || Mover(Owner).bInterpolating || Mover(Owner).bDelaying)
		return;

	Owner.Trigger(Other, EventInstigator);

	if (Event != '')
		TriggerEvent(Event, Other, EventInstigator);
}
