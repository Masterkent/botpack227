class XidiaSafeFall expands Triggers;

static function CreateAtActor(
	LevelInfo Level,
	string ActorName,
	float CollisionRadius,
	float CollisionHeight)
{
	local Actor A;

	A = Actor(DynamicLoadObject(Level.Outer.Name $ "." $ ActorName, class'Actor'));
	if (A != none)
		A = Level.Spawn(class'XidiaSafeFall',,, A.Location);
	if (A != none)
		A.SetCollisionSize(CollisionRadius, CollisionHeight);
}
