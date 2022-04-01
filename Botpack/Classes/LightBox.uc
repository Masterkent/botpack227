//=============================================================================
// lightbox.
//=============================================================================
class LightBox extends UT_Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'Botpack.lightboxM'
	bUnlit=True
}
