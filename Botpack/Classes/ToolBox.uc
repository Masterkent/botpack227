//=============================================================================
// toolbox.
//=============================================================================
class ToolBox extends ut_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.toolboxM'
	DrawScale=0.250000
	CollisionHeight=30.000000
	bBlockActors=True
	bBlockPlayers=True
}
