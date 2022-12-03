class UnrealitySafeFall expands Triggers;

event BeginPlay()
{
	AddGameRules();
}

function AddGameRules()
{
	local GameRules GR;

	for (GR = Level.Game.GameRules; GR != none; GR = GR.NextRules)
		if (UnrealityGameRules(GR) != none)
			return;
	Spawn(class'UnrealityGameRules');
}
