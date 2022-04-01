//=============================================================================
// icbm.
//=============================================================================
class ICBM extends UT_Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.icbmM'
	bCollideActors=True
}
