class ONPPlayerTriggeringActor expands Triggers;

event Touch(Actor A)
{
	local Trigger.ETriggerType TriggerType;

	if (Trigger(A) != none)
	{
		TriggerType = Trigger(A).TriggerType;
		if (TriggerType == TT_PlayerProximity ||
			TriggerType == TT_PawnProximity ||
			TriggerType == TT_ClassProximity && ClassIsChildOf(class'PlayerPawn', Trigger(A).ClassProximityType))
		{
			Trigger(A).TriggerType = TT_AnyProximity;
			A.Touch(self);
			A.UnTouch(self);
			Trigger(A).TriggerType = TriggerType;
		}
	}
}

function Trigger(Actor A, Pawn EventInstigator)
{
	Instigator = EventInstigator;
}

defaultproperties
{
	CollisionRadius=17
	CollisionHeight=39
}
