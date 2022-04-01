class B227_MutatorGR expands GameRules;

static function bool WrapMutator(UTC_Mutator M)
{
	local B227_MutatorGR GR;

	if (M == none || M.bDeleteMe)
		return false;

	foreach M.AllActors(class'B227_MutatorGR', GR)
		break;
	return GR != none || M.Spawn(class'B227_MutatorGR') != none;
}

event BeginPlay()
{
	if (Level.Game.GameRules == none)
		Level.Game.GameRules = self;
	else
		Level.Game.GameRules.AddRules(self);
}


function ModifyPlayer(Pawn P)
{
	if (Level.Game.BaseMutator != none)
		class'UTC_Mutator'.static.UTSF_ModifyPlayer(Level.Game.BaseMutator, P);
}

function NotifyKilled(Pawn Victim, Pawn Killer, name DamageType)
{
	if (Level.Game.BaseMutator != none)
		class'UTC_Mutator'.static.UTSF_ScoreKill(Level.Game.BaseMutator, Killer, Victim);
}

function bool CanPickupInventory(Pawn P, Inventory Inv)
{
	local byte bAllowPickup;

	return
		Level.Game.BaseMutator == none ||
		!class'UTC_Mutator'.static.UTSF_HandlePickupQuery(Level.Game.BaseMutator, P, Inv, bAllowPickup) ||
		bAllowPickup == 1;
}

function bool PreventDeath(Pawn Dying, Pawn Killer, name DamageType)
{
	return
		Level.Game.BaseMutator != none &&
		class'UTC_Mutator'.static.UTSF_PreventDeath(
			Level.Game.BaseMutator, Dying, Killer, DamageType, class'UTC_Pawn'.static.B227_DamageHitLocation(Dying));
}

defaultproperties
{
	bNotifySpawnPoint=True
	bHandleDeaths=True
	bHandleInventory=True
}
