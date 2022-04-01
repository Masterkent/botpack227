//=============================================================================
// INFUT_ADD_50Spoon.
//=============================================================================
class INFUT_ADD_50Spoon expands INFUT_ADD_50Shell;

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
     Mesh=LodMesh'InfAdds.INFIL_UTM2_50Spoon'
}
