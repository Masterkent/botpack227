class SBTeleporterTouch expands Trigger;

function Trigger(Actor A, Pawn EventInstigator)
{
	GotoState('TeleporterTouch');
	Instigator = EventInstigator;
}

state TeleporterTouch
{
Begin:
	TouchMatchingTeleporters();
}

function TouchMatchingTeleporters()
{
	local Teleporter Telep;

	if (Instigator != none)
	{
		foreach AllActors(class'Teleporter', Telep, Tag)
			Telep.Touch(Instigator);
	}
}
