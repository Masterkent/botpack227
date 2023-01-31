//=============================================================================
// boulder1.
//=============================================================================
class Boulder1 extends ut_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.boulder1M'
	CollisionRadius=40.000000
	bBlockActors=True
	bBlockPlayers=True
}
