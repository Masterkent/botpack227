//=============================================================================
// InstantRockets.
// rocket launchers always instant fire
//=============================================================================

class InstantRockets expands UTC_Mutator;

function bool AlwaysKeep(Actor Other)
{
	if (UT_Eightball(Other) != none)
		UT_Eightball(Other).bAlwaysInstant = true;
	if (NextMutator != none)
		return class'UTC_Mutator'.static.UTSF_AlwaysKeep(NextMutator, Other);
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (UT_Eightball(Other) != none)
		UT_Eightball(Other).bAlwaysInstant = true;
	return true;
}

defaultproperties
{
}
