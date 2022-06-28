//=============================================================================
//
// MPCameraMaster.uc
//
// by Hugh Macdonald
//
//=============================================================================

class MPCameraMaster expands UMS;

simulated function PreBeginPlay()
{
	log("About to spawn the three SpawnNotify's from the MPCameraMaster");
	Spawn(class'UMSPRISpawnNotify');
	Spawn(class'UMSBRISpawnNotify');
	Spawn(class'UMSSpectSpawnNotify');
}

defaultproperties
{
}
