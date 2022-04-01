//=============================================================================
// boulder2.
//=============================================================================
class Boulder2 extends ut_Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.boulder2M'
	DrawScale=0.250000
	bBlockActors=True
	bBlockPlayers=True
}
