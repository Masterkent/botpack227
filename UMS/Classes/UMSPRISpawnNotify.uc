//=============================================================================
//
// UMSPRISpawnNotify.uc
//
// by Hugh Macdonald
//
//=============================================================================

class UMSPRISpawnNotify expands SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
	local actor O;

	log("Before the SpawnNotify, the PRI is a"@PlayerReplicationInfo(A));
	if ((PlayerReplicationInfo(A) != None) && (BotReplicationInfo(A) == None))
	{
		O = A.Owner;
		A.Destroy();
		log("Spawning a UMSPRI to replace a normal PRI");
		return Spawn(class'UMSPlayerReplicationInfo', O);
	}
	return A;
}

defaultproperties
{
				ActorClass=Class'Engine.PlayerReplicationInfo'
				RemoteRole=ROLE_None
}
