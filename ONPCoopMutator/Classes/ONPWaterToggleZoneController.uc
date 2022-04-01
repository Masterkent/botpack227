class ONPWaterToggleZoneController expands Info;

var WaterToggleZone ControlledZone;
var bool RepWater;

replication
{
	reliable if (Role == ROLE_Authority)
		ControlledZone;
}

function SetControlledZone(WaterToggleZone Zone)
{
	ControlledZone = Zone;
	Tag = Zone.Tag;
	Zone.Tag = '';
}

simulated function Trigger(Actor A, Pawn EventInstigator)
{
	if (ControlledZone == none)
		return;

	ControlledZone.Trigger(A, EventInstigator);
}

simulated function Tick(float DeltaTime)
{
	if (Level.NetMode != NM_Client)
		Disable('Tick');
	if (ControlledZone.RepWater != ControlledZone.bWaterZone)
		Trigger(self, none);
}

defaultproperties
{
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}
