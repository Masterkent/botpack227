class ONPSpawnableTeleporter expands Teleporter;

var Teleporter PrototypeTeleporter;

// intentionally overridden to be empty
function PostBeginPlay() {}

defaultproperties
{
	bStatic=False
	bCollideWhenPlacing=False
}
