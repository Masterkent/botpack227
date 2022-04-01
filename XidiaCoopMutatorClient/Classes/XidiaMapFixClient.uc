class XidiaMapFixClient expands XidiaMapFixBase;

simulated event PostNetBeginPlay()
{
	if (Level.NetMode != NM_Client)
		return;
	AdjustBubbleGenerators();
	AdjustExplosionChains();
	Client_FixCurrentMap();
}

simulated function AdjustBubbleGenerators()
{
	local BubbleGenerator BubbleGenerator;

	foreach AllActors(class'BubbleGenerator', BubbleGenerator)
		BubbleGenerator.bHidden = true;
}

simulated function AdjustExplosionChains()
{
	local ExplosionChain ExplosionChain;

	foreach AllActors(class'ExplosionChain', ExplosionChain)
		ExplosionChain.bHidden = true;
}

simulated function Client_FixCurrentMap()
{
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
