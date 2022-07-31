class B227_PlayerShipEffects expands Info;

var PlayerPawn PlayerOwner;
var B227_PlayerShipSmokeEmitter SmokeEmitter1, SmokeEmitter2;

simulated event Tick(float DeltaTime)
{
	local vector X, Y, Z;

	if (Level.NetMode == NM_DedicatedServer)
	{
		Disable('Tick');
		return;
	}

	PlayerOwner = PlayerPawn(Owner);
	if (PlayerOwner == none || PlayerOwner.Region.Zone.bWaterZone)
	{
		StopSmokeEmitter(SmokeEmitter1);
		StopSmokeEmitter(SmokeEmitter2);
		return;
	}
	GetAxes(PlayerOwner.Rotation, X, Y, Z);
	X = PlayerOwner.Location - X * PlayerOwner.CollisionRadius;
	Y *= PlayerOwner.CollisionRadius / 7; //offset of engines.
	Z *= PlayerOwner.CollisionHeight / 7;

	UpdateSmokeEmitter(SmokeEmitter1, X + Y - Z);
	UpdateSmokeEmitter(SmokeEmitter2, X - Y - Z);
}

simulated event Destroyed()
{
	StopSmokeEmitter(SmokeEmitter1);
	StopSmokeEmitter(SmokeEmitter2);
}

simulated function UpdateSmokeEmitter(out B227_PlayerShipSmokeEmitter SmokeEmitter, vector NewLocation)
{
	if (SmokeEmitter == none)
		SmokeEmitter = Spawn(class'B227_PlayerShipSmokeEmitter',,, NewLocation);
	else
		SmokeEmitter.SetLocation(NewLocation);
}

simulated function StopSmokeEmitter(out B227_PlayerShipSmokeEmitter SmokeEmitter)
{
	if (SmokeEmitter != none)
	{
		SmokeEmitter.StopEmitting();
		SmokeEmitter = none;
	}
}

defaultproperties
{
	bHidden=False
	DrawType=DT_None
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
}
