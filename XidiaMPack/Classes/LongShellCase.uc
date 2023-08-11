// ===============================================================
// XidiaMPack.LongShellCase: umm..lasts longer
// ===============================================================

class LongShellCase expands ShellCase;

function Eject(Vector Vel)
{
	Velocity = Vel;
	RandSpin(100000);

	if (Instigator == none)
		Instigator = Pawn(Owner);
	if (Instigator != none)
	{
		Velocity += Instigator.Velocity*0.5;
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			Velocity = Velocity * (0.2+FRand()*0.2);
			bHasBounced=True;
		}
	}
}

defaultproperties
{
     LifeSpan=11.000000
}
