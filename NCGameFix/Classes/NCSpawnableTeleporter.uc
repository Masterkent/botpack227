class NCSpawnableTeleporter expands B227_SpawnableTeleporter;

var() bool bDrawWhenEnabled;

// intentionally overridden to be empty
function PostBeginPlay() {}

function Trigger(Actor Other, Pawn EventInstigator)
{
	local Actor A;

	bEnabled = !bEnabled;
	if (bEnabled)
		foreach TouchingActors(Class'Actor',A)
			Touch(A);

	if (bDrawWhenEnabled)
		bHidden = !bEnabled;
}

defaultproperties
{
	bStatic=False
	bCollideWhenPlacing=False
}
