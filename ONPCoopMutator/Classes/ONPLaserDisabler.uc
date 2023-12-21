class ONPLaserDisabler expands Trigger;

var() float Delay;

event Touch(Actor A)
{
	if (IsRelevant(A))
		GotoState('Active');
}

state Active
{
	ignores Touch;

	function ModifyLasers()
	{
		local Trigger Trigger;
		local Mover Mover;

		foreach AllActors(class'Trigger', Trigger)
			if (InStr(Locs(string(Trigger.Tag)), "laser") == 0)
				Trigger.GotoState('OtherTriggerTurnsOff');

		foreach AllActors(class'Mover', Mover)
			if (InStr(Locs(string(Mover.Tag)), "laser") == 0)
				class'ONPMoverOpener'.static.CreateInstance(Mover);
	}

Begin:
	Sleep(Delay);
	ModifyLasers();
}
