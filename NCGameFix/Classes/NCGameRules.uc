class NCGameRules expands GameRules;

event BeginPlay()
{
	if (Level.Game.GameRules == none)
		Level.Game.GameRules = self;
	else
		Level.Game.GameRules.AddRules(self);
}

function ModifyDamage(Pawn Injured, Pawn EventInstigator, out int Damage, vector HitLocation, name DamageType, out vector Momentum)
{
	local NCSafeFall NCSafeFall;

	if (DamageType != 'fell')
		return;
	foreach Injured.TouchingActors(class'NCSafeFall', NCSafeFall)
	{
		Damage = 0;
		return;
	}
}

defaultproperties
{
	bModifyDamage=True
}
