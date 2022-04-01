class B227_DamageMutatorGR expands GameRules;

var private UTC_Mutator DamageMutator;

static function bool WrapMutator(UTC_Mutator M)
{
	local B227_DamageMutatorGR GR;

	if (M == none || M.bDeleteMe)
		return false;

	foreach M.AllActors(class'B227_DamageMutatorGR', GR)
		break;
	if (GR == none)
	{
		GR = M.Spawn(class'B227_DamageMutatorGR');
		if (GR == none)
			return false;
	}

	if (UTC_GameInfo(M.Level.Game) != none)
	{
		M.NextDamageMutator = UTC_GameInfo(M.Level.Game).DamageMutator;
		UTC_GameInfo(M.Level.Game).DamageMutator = M;
	}
	else
		M.NextDamageMutator = GR.DamageMutator;
	GR.DamageMutator = M;
	return true;
}

event BeginPlay()
{
	if (Level.Game.GameRules == none)
		Level.Game.GameRules = self;
	else
		Level.Game.GameRules.AddRules(self);
}

function ModifyDamage(Pawn Victim, Pawn DamageInstigator, out int Damage, vector HitLocation, name DamageType, out vector Momentum)
{
	if (DamageMutator != none)
		DamageMutator.MutatorTakeDamage(Damage, Victim, DamageInstigator, HitLocation, Momentum, DamageType);
}

defaultproperties
{
	bModifyDamage=True
}
