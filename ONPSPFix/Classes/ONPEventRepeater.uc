class ONPEventRepeater expands Info;

var float RepeatTriggerTime;

struct EventInstigatorData
{
	var Pawn Instigator;
	var int Count;
	var float TimePassed;
};

var array<EventInstigatorData> EventInstigators;
var int EventInstigatorsCount;
var bool bNoTrigger;

event Trigger(Actor A, Pawn EventInstigator)
{
	if (!bNoTrigger && EventInstigator != none && RepeatTriggerTime > 0)
		AddEventInstigator(EventInstigator);
}

event Untrigger(Actor A, Pawn EventInstigator)
{
	if (EventInstigator != none)
		SubtractEventInstigator(EventInstigator);
}

event Tick(float DeltaTime)
{
	local int i;

	if (RepeatTriggerTime > 0)
	{
		bNoTrigger = true;

		for (i = 0; i < EventInstigatorsCount; ++i)
			if (EventInstigators[i].Instigator != none &&
				!EventInstigators[i].Instigator.bDeleteMe)
			{
				EventInstigators[i].TimePassed += DeltaTime;
				if (EventInstigators[i].TimePassed >= RepeatTriggerTime)
				{
					EventInstigators[i].TimePassed = FMin(EventInstigators[i].TimePassed - RepeatTriggerTime, RepeatTriggerTime);
					TriggerEvent(Event, EventInstigators[i].Instigator, EventInstigators[i].Instigator);
				}
			}

		bNoTrigger = false;
	}
}

function AddEventInstigator(Pawn EventInstigator)
{
	local int i;

	for (i = 0; i < EventInstigatorsCount; ++i)
		if (EventInstigators[i].Instigator == EventInstigator)
		{
			EventInstigators[i].Count++;
			EventInstigators[i].TimePassed = 0;
			return;
		}

	for (i = 0; i < EventInstigatorsCount; ++i)
		if (EventInstigators[i].Instigator == none)
			break;

	EventInstigators[i].Instigator = EventInstigator;
	EventInstigators[i].Count = 1;
	EventInstigators[i].TimePassed = 0;
	if (i == EventInstigatorsCount)
		EventInstigatorsCount++;
}

function SubtractEventInstigator(Pawn EventInstigator)
{
	local int i;

	for (i = 0; i < EventInstigatorsCount; ++i)
		if (EventInstigators[i].Instigator == EventInstigator)
		{
			if (--EventInstigators[i].Count <= 0)
				EventInstigators[i].Instigator = none;
			return;
		}
}
