class SBInstantDispatcher expands Dispatcher;

var bool bDiscardInstigator;
var bool bTriggerOnceOnly;
var Trigger ConditionTrigger;

function Trigger(Actor A, Pawn EventInstigator)
{
	if (ConditionTrigger != none && !ConditionTrigger.bInitiallyActive)
		return;

	if (bDiscardInstigator)
		EventInstigator = none;

	Disable('Trigger');
	for (i = 0; i < ArrayCount(OutEvents); ++i)
		TriggerEvent(OutEvents[i], self, EventInstigator);
	if (!bTriggerOnceOnly)
		Enable('Trigger');
	else
		Disable('UnTrigger');
}

function UnTrigger(Actor A, Pawn EventInstigator)
{
	if (ConditionTrigger != none && !ConditionTrigger.bInitiallyActive)
		return;

	if (bDiscardInstigator)
		EventInstigator = none;

	Disable('UnTrigger');
	for (i = 0; i < ArrayCount(OutEvents); ++i)
		UnTriggerEvent(OutEvents[i], self, EventInstigator);
	Enable('UnTrigger');
}
