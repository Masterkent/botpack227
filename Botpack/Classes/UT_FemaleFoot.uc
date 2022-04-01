//=============================================================================
// ut_femalefoot.
//=============================================================================
class UT_FemaleFoot extends UTPlayerChunks;


#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	Mesh=LodMesh'Botpack.femalefootm'
	CollisionRadius=25.000000
	CollisionHeight=6.000000
	Mass=40.000000
}
