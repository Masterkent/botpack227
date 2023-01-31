//=============================================================================
// rim.
//=============================================================================
class Rim extends UT_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.rimM'
	DrawScale=0.150000
	CollisionRadius=18.000000
	CollisionHeight=7.000000
	bCollideActors=True
}
