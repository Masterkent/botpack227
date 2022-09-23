class SBInstigatorSoundEvent expands Triggers;

var SpecialEvent SpecialEvent;

static function WrapSpecialEvents(Actor Context, name SpecialEventTag)
{
	local SpecialEvent SpecialEvent, FirstSpecialEvent;
	local SBInstigatorSoundEvent SBInstigatorSoundEvent;

	foreach Context.AllActors(class'SpecialEvent', SpecialEvent, SpecialEventTag)
		if (SpecialEvent.InitialState == 'PlaySoundEffect' ||
			SpecialEvent.InitialState == 'PlayersPlaySoundEffect')
		{
			if (FirstSpecialEvent == none)
				FirstSpecialEvent = SpecialEvent;
			SpecialEvent.Tag = '';
		}

	if (FirstSpecialEvent != none)
		SBInstigatorSoundEvent = FirstSpecialEvent.Spawn(class'SBInstigatorSoundEvent',, SpecialEventTag);

	if (SBInstigatorSoundEvent != none)
		SBInstigatorSoundEvent.SpecialEvent = FirstSpecialEvent;
}

function Trigger(Actor A, Pawn EventInstigator)
{
	if (SpecialEvent != none && EventInstigator != none)
	{
		if (SpecialEvent.IsInState('PlaySoundEffect'))
			EventInstigator.PlaySound(SpecialEvent.Sound, SLOT_None, SpecialEvent.TransientSoundVolume);
		else
			EventInstigator.PlaySound(SpecialEvent.Sound, SLOT_None, EventInstigator.default.TransientSoundVolume);
	}
}
