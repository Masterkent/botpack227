class ONPTriggerIfMoverIsStopped expands Triggers;

static function ONPTriggerIfMoverIsStopped CreateFor(LevelInfo Level, string MoverName, name Tag, name Event)
{
	local ONPTriggerIfMoverIsStopped Result;
	local Mover Mover;

	Mover = Mover(DynamicLoadObject(Level.Outer.Name $ "." $ MoverName, class'Mover'));
	if (Mover == none)
		return none;
	Result = Level.Spawn(class'ONPTriggerIfMoverIsStopped', Mover, Tag);
	if (Result == none)
		return none;

	Result.Event = Event;

	return Result;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	if (Mover(Owner) == none || Mover(Owner).bInterpolating || Mover(Owner).bDelaying)
		return;

	if (Event != '')
		TriggerEvent(Event, Other, EventInstigator);
}
