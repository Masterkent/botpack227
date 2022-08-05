class B227_RelicGameRules expands GameRules;

event BeginPlay()
{
	if (Level.Game.GameRules == none)
		Level.Game.GameRules = self;
	else
		Level.Game.GameRules.AddRules(self);
}

function bool PreventDeath(Pawn Dying, Pawn Killer, name DamageType)
{
	local Inventory Inv;

	if (!class'RelicRedemptionInventory'.default.B227_bPreventDeath || Dying == none)
		return false;
	for (Inv = Dying.Inventory; Inv != none; Inv = Inv.Inventory)
		if (RelicRedemptionInventory(Inv) != none && Inv.bActive)
		{
			RelicRedemptionInventory(Inv).B227_RecoverPawn(Dying);
			RemoveAllArmors(Dying);
			return true;
		}
	return false;
}

static function RemoveAllArmors(Pawn P)
{
	local Inventory Inv;

	for (Inv = P.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.bIsAnArmor)
			Inv.Destroy();
}

defaultproperties
{
	bHandleDeaths=True
}
