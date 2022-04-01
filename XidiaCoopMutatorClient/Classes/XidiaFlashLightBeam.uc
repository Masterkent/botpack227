class XidiaFlashLightBeam expands FlashLightBeam;

var vector RepLocation;
var vector HitLocation, HitNormal, EndTrace;

replication
{
	reliable if (Role == ROLE_Authority && !bNetOwner)
		RepLocation;
}

simulated function Tick(float DeltaTime)
{
	if (Level.NetMode != NM_Client)
		RepLocation = Location;

	if ((Level.NetMode != NM_Client || bNetOwner) && Pawn(Owner) != none)
	{
		EndTrace = Pawn(Owner).Location + 10000* Vector(Pawn(Owner).ViewRotation);
		Trace(HitLocation, HitNormal, EndTrace, Owner.Location, true);
		SetLocation(HitLocation - vector(Pawn(Owner).ViewRotation) * 64);
	}
	else
		SetLocation(RepLocation);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
