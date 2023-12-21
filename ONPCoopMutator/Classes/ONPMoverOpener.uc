class ONPMoverOpener expands Triggers;

var Mover ControlledMover;

static function ONPMoverOpener CreateInstance(Mover Mover)
{
	local ONPMoverOpener A;

	A = Mover.Spawn(class'ONPMoverOpener', Mover, Mover.Tag);
	if (A == none)
		return none;

	Mover.Tag = '';
	return A;
}

event BeginPlay()
{
	ControlledMover = Mover(Owner);
}

function Trigger(Actor A, Pawn EventInstigator)
{
	if (ControlledMover == none)
		return;

	if (ControlledMover.bInterpolating)
	{
		if (ControlledMover.bOpening)
			return;
	}
	else if (ControlledMover.bDelaying || !MoverIsClosingOrClosed(ControlledMover))
		return;

	ControlledMover.Trigger(A, EventInstigator);
}

static function bool MoverIsClosingOrClosed(Mover Mover)
{
	return Mover.KeyNum == 0 || Mover.KeyNum < Mover.PrevKeyNum;
}
