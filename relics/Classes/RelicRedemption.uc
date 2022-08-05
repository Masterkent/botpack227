class RelicRedemption expands Relic;

event PostBeginPlay()
{
	if (Initialized)
		return;
	Spawn(class'B227_RelicGameRules');
	super.PostBeginPlay();
}

defaultproperties
{
     RelicClass=Class'relics.RelicRedemptionInventory'
}
