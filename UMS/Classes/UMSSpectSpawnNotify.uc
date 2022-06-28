//=============================================================================
//
// UMSSpectSpawnNotify.uc
//
// by Hugh Macdonald
//
//=============================================================================

class UMSSpectSpawnNotify expands SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
	local actor O;
	
	log("Before the SpawnNotify, the Spectator is a"@A);
	if ((CHSpectator(A) != None))
	{
		O = A.Owner;
		A.Destroy();
		log("Spawning a UMSSpectator to replace a CHSpectator");
		return Spawn(class'UMSSpectator', O);
	}
	return A;
}

defaultproperties
{
				ActorClass=Class'Botpack.CHSpectator'
				RemoteRole=ROLE_None
}
