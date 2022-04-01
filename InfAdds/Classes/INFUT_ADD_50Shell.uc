//=============================================================================
// INFUT_ADD_50Shell.
//=============================================================================
class INFUT_ADD_50Shell expands INFUT_ADD_ShellCase;

#exec OBJ LOAD FILE="InfAddsResources.u" PACKAGE=InfAdds

function Eject(Vector Vel)
{
	Velocity = Vel;
	RandSpin(100000);
	if (Instigator != None)
	{
		Velocity += Instigator.Velocity * 0.5;
		if (Instigator.HeadRegion.Zone.bWaterZone)
		{
			Velocity = Velocity * (0.1+FRand()*0.2);
			bHasBounced=True;
		}
	}
}

defaultproperties
{
     Mesh=LodMesh'InfAdds.Add50Shell'
     DrawScale=0.060000
}
