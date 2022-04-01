class SBMoverEventHandler expands Info;

var name ControllerTag;
var name MoverPosChange;
var bool bPermanentChange;
var name OpenPosEvent;
var name ClosePosEvent;

function Trigger(Actor A, Pawn EventInstigator)
{
	local SBMoverStateController Controller;

	foreach AllActors(class'SBMoverStateController', Controller, ControllerTag)
	{
		if (MoverPosChange != '')
			Controller.SetCurrentChange(MoverPosChange, bPermanentChange, A, EventInstigator);
		if (OpenPosEvent != '')
			Controller.OpenPosEvent = OpenPosEvent;
		if (ClosePosEvent != '')
			Controller.ClosePosEvent = ClosePosEvent;
		OpenPosEvent = '';
		ClosePosEvent = '';
	}
}
