class NCPhysWalkingToNone expands Info;

event Tick(float DeltaTime)
{
	if (Owner != none && Owner.Physics == PHYS_Walking)
	{
		Owner.SetPhysics(PHYS_None);
		Owner.SetCollision(false);
	}
}
