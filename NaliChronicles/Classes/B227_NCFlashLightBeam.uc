class B227_NCFlashLightBeam expands FlashLightBeam;

var vector RepLocation;

replication
{
	reliable if (Role == ROLE_Authority && !bNetOwner)
		RepLocation;
}

simulated event Tick(float DeltaTime)
{
	local vector HitLocation, HitNormal, EndTrace;

	if (Level.NetMode == NM_Client)
	{
		if (bNetOwner && Pawn(Owner) != none)
		{
			EndTrace = Pawn(Owner).Location + 10000 * vector(Pawn(Owner).ViewRotation);
			Trace(HitLocation, HitNormal, EndTrace, Owner.Location, true);
			SetLocation(HitLocation - vector(Pawn(Owner).ViewRotation) * 64);
		}
		else
			SetLocation(RepLocation);
	}
	else
		RepLocation = Location;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
