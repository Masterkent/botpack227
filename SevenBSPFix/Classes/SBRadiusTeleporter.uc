class SBRadiusTeleporter expands SBSpawnableTeleporter;

var() bool bPlayersOnly;

event Tick(float DeltaTime)
{
	local Actor A;
	foreach RadiusActors(class'Actor', A, CollisionRadius)
		if (A.bCollideActors)
			Touch(A);
}

function Touch(Actor A)
{
	if (!bPlayersOnly || Pawn(A) != none && Pawn(A).PlayerReplicationInfo != none)
		super.Touch(A);
}
