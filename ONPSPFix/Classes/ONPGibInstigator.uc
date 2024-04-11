class ONPGibInstigator expands Triggers;

var vector ThrowVelocity;

event Trigger(Actor A, Pawn EventInstigator)
{
	if (EventInstigator != none && (Instigator == none || Instigator == EventInstigator))
	{
		if (bool(ThrowVelocity))
		{
			if (EventInstigator.Physics == PHYS_Walking)
				EventInstigator.SetPhysics(PHYS_Falling);
			EventInstigator.Velocity = ThrowVelocity;
		}
		EventInstigator.gibbedBy(none);
	}
}
