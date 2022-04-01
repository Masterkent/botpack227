//=============================================================================
// ut_bosshead.
//=============================================================================
class UT_bosshead extends UTHeads;


#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	Mesh=LodMesh'Botpack.bossheadm'
	DrawScale=0.220000
	CollisionRadius=25.000000
	CollisionHeight=6.000000
	Mass=40.000000
}
