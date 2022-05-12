class NCTriggerTypeModifier expands Triggers;

var Trigger.ETriggerType TriggerType;

function Trigger(Actor A, Pawn EventInstigator)
{
	if (Trigger(Owner) != none)
		Trigger(Owner).TriggerType = TriggerType;
}

event PostBeginPlay();
event Touch(Actor A);
event UnTouch(Actor A);

static function NCTriggerTypeModifier MakeInstance(Actor Context, string OwnerName, name Tag, Trigger.ETriggerType TriggerType)
{
	local Trigger Trigger;
	local NCTriggerTypeModifier Modifier;

	Trigger = Trigger(DynamicLoadObject(Context.Outer.Name $ "." $ OwnerName, class'Actor'));
	Modifier = Trigger.Spawn(class'NCTriggerTypeModifier', Trigger, Tag);
	Modifier.TriggerType = TriggerType;
	return Modifier;
}

defaultproperties
{
	bCollideActors=False
}
