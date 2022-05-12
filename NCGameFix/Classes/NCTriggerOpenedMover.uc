class NCTriggerOpenedMover expands Triggers;

function Trigger(Actor Other, Pawn EventInstigator)
{
	if (Mover(Owner) == none || Mover(Owner).bInterpolating || Mover(Owner).bDelaying || Mover(Owner).KeyNum < Mover(Owner).NumKeys - 1)
		return;

	Owner.Trigger(Other, EventInstigator);
}
