class B227_UnrealityFlareEffect expands Effects;

var vector RepLocation;

replication
{
	reliable if (Role == ROLE_Authority)
		RepLocation;
}

simulated event Tick(float DeltaTime)
{
	if (Level.NetMode == NM_Client)
		ClientUpdateLocation();
	else
		RepLocation = Location;
}

simulated function ClientUpdateLocation()
{
	if (Owner == none)
		SetLocation(RepLocation);
}

defaultproperties
{
	bNetTemporary=False
	bHidden=False
	bCarriedItem=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_None
	AmbientSound=Sound'UnrealShare.Pickups.flarel1'
	SoundRadius=9
	SoundVolume=240
	LightType=LT_SubtlePulse
	LightRadius=33
	LightEffect=LE_TorchWaver
	LightSaturation=89
	LightHue=0
	LightBrightness=250
	RepLocation=(X=0,Y=0,Z=-1000000)
}
