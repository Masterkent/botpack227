//=============================================================================
// ut_maletorso.
//=============================================================================
class UT_MaleTorso extends UTPlayerChunks;


#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	Mesh=LodMesh'Botpack.maletorsom'
	CollisionRadius=25.000000
	CollisionHeight=6.000000
	Mass=50.000000
}
