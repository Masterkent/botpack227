class SBSpawnableTeleporter expands B227_SpawnableTeleporter;

var() bool bDrawWhenEnabled;

// Overrides the base class implementation
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
