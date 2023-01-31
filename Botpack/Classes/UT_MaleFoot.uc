//=============================================================================
// ut_malefoot.
//=============================================================================
class UT_MaleFoot extends UTPlayerChunks;


#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	Mesh=LodMesh'Botpack.malefootm'
	CollisionRadius=25.000000
	CollisionHeight=6.000000
	Mass=40.000000
}
