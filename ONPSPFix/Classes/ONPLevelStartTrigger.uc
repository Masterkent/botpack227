class ONPLevelStartTrigger expands Triggers;

event Tick(float DeltaTime)
{
	TriggerEvent(Event, self, none);
	Disable('Tick');
}
