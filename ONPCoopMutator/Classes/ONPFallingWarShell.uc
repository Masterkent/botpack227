class ONPFallingWarShell expands WarShell;

auto state Flying
{
	event Landed(vector HitNormal)
	{
		HitWall(HitNormal, none);
	}
}

defaultproperties
{
	Physics=PHYS_Falling
}
