//=============================================================================
// earth2.
//=============================================================================
class Earth2 extends UT_Decoration;


#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	bStatic=False
	Physics=PHYS_Rotating
	DrawType=DT_Mesh
	Style=STY_Translucent
	Skin=Texture'Botpack.Skins.Jearth21'
	Mesh=LodMesh'Botpack.earth21'
	DrawScale=2.050000
	ScaleGlow=0.700000
	bFixedRotationDir=True
	RotationRate=(Yaw=800)
	DesiredRotation=(Yaw=500)
}
