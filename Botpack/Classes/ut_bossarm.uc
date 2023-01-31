//=============================================================================
// ut_bossarm.
//=============================================================================
class UT_bossarm extends UTPlayerChunks;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	Mesh=LodMesh'Botpack.bossarmm'
	DrawScale=0.500000
	Fatness=140
	CollisionRadius=25.000000
	Mass=40.000000
}
