class SBMapFixClient expands SBMapFixBase;

var bool bModifiedClientSide;

simulated function Tick(float DeltaTime)
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (!bModifiedClientSide)
		{
			bModifiedClientSide = true;
			Client_FixCurrentMap();
		}
	}
	Disable('Tick');
}

simulated function Client_FixCurrentMap()
{
	if (CurrentMap ~= "Jones-05-TemplePart2")
		Client_FixCurrentMap_Jones_05_TemplePart2();
	else if (CurrentMap ~= "Jones-08-Pirate3")
		Client_FixCurrentMap_Jones_08_Pirate3();
}

simulated function Client_FixCurrentMap_Jones_05_TemplePart2()
{
	// Is also changed by SBMapFixServer
	LoadLevelZone("ZoneInfo0").ZoneVelocity = vect(0, 0, 0);
}

simulated function Client_FixCurrentMap_Jones_08_Pirate3()
{
	SetDynamicLightMover("Mover13");
}


simulated function ZoneInfo LoadLevelZone(string ZoneName)
{
	return ZoneInfo(DynamicLoadObject(outer.name $ "." $ ZoneName, class'ZoneInfo'));
}

simulated function SetDynamicLightMover(string MoverName)
{
	LoadLevelMover(MoverName).bDynamicLightMover = true;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
}
