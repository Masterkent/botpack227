class NCSafeFall expands Triggers;

static function CreateAtLocation(
	LevelInfo Level,
	vector Location,
	float CollisionRadius,
	float CollisionHeight)
{
	local NCSafeFall NCSafeFall;

	NCSafeFall = Level.Spawn(class'NCSafeFall',,, Location);
	if (NCSafeFall != none)
		NCSafeFall.SetCollisionSize(CollisionRadius, CollisionHeight);
}
