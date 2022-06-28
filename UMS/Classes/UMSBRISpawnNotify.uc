//=============================================================================
//
// UMSBRISpawnNotify.uc
//
// by Hugh Macdonald
//
//=============================================================================

class UMSBRISpawnNotify expands SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
	local actor O;

	log("Before the SpawnNotify, the BRI is a"@BotReplicationInfo(A));
	if (BotReplicationInfo(A) != None)
	{
		O = A.Owner;
		A.Destroy();
		log("Spawning a UMSBRI to replace a normal BRI");
		return Spawn(class'UMSBotReplicationInfo', O);
	}
	return A;
}

defaultproperties
{
				ActorClass=Class'Botpack.BotReplicationInfo'
				RemoteRole=ROLE_None
}
