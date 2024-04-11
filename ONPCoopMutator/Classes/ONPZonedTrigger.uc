class ONPZonedTrigger expands Trigger;
// Causes Event only when the instigator is in the same zone as the trigger actor.

function bool IsRelevant(Actor A)
{
	return A.Region.ZoneNumber == Region.ZoneNumber && super.IsRelevant(A);
}

function ReplaceTrigger(Trigger Trigger)
{
	if (Trigger.InitialState != '')
		GotoState(Trigger.InitialState);
	SetLocation(Trigger.Location);
	SetCollisionSize(Trigger.CollisionRadius, Trigger.CollisionHeight);
	bTriggerOnceOnly = Trigger.bTriggerOnceOnly;
	Event = Trigger.Event;
	Tag = Trigger.Tag;
	TriggerType = Trigger.TriggerType;
	ClassProximityType = Trigger.ClassProximityType;
	ReTriggerDelay = Trigger.ReTriggerDelay;

	Trigger.SetCollision(false);
	Trigger.Event = '';
}
