//=============================================================================
// ut_femaletorso.
//=============================================================================
class UT_FemaleTorso extends UTPlayerChunks;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	Mesh=LodMesh'Botpack.femaletorsom'
	CollisionRadius=25.000000
	CollisionHeight=6.000000
	Mass=50.000000
}
