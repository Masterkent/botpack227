// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvFlashLightBeam : A hack to be sure it isn't visible for owner in co-op
// ===============================================================

class TvFlashLightBeam expands FlashLightBeam;

var vector RepLocation;

var bool bHideMe; // [U227] this var is unused

/*-
replication{
  reliable if (Role==Role_authority&&bNetOwner&&!bDemoRecording)
    bHideMe;
}
simulated function PostNetBeginPlay(){ //yes, it is unsafe.. but I must do this for location updates
  if (bHideMe)
    LightType=LT_None;
}
*/

replication
{
	reliable if (Role == ROLE_Authority && !bNetOwner)
		RepLocation;
}

function Timer() //don't scare creatures when in cutscene
{
  if (tvplayer(Owner)==none||TvPlayer(Owner).PlayerMod!=1)
    MakeNoise(0.3);
}

simulated event Tick(float DeltaTime)
{
	local vector HitLocation, HitNormal, EndTrace;

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
