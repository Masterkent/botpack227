class JumpMatch expands Mutator;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (DeathMatchPlus(Level.Game) != none)
		DeathMatchPlus(Level.Game).bJumpMatch = true;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('UT_JumpBoots') )
		return false;

	return true;
}

defaultproperties
{
}
