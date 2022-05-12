class NCTriggerClosedMover expands Triggers;

function Trigger(Actor Other, Pawn EventInstigator)
{
	if (Mover(Owner) == none || Mover(Owner).bInterpolating || Mover(Owner).bDelaying || Mover(Owner).KeyNum > 0)
		return;

	Owner.Trigger(Other, EventInstigator);
}
