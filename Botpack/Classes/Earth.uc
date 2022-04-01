//=============================================================================
// earth.
//=============================================================================
class Earth extends UT_Decoration;


#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	bStatic=False
	Physics=PHYS_Rotating
	DrawType=DT_Mesh
	Skin=Texture'Botpack.Skins.Jearth1'
	Mesh=LodMesh'Botpack.earth1'
	DrawScale=2.000000
	bFixedRotationDir=True
	RotationRate=(Yaw=1500)
	DesiredRotation=(Yaw=500)
}
