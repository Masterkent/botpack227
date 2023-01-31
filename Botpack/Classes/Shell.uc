//=============================================================================
// shell.
//=============================================================================
class Shell extends UT_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.shellM'
	DrawScale=0.300000
	CollisionRadius=10.000000
	CollisionHeight=36.000000
	bCollideActors=True
}
