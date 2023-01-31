//=============================================================================
// brick.
//=============================================================================
class Brick extends ut_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.brickM'
	DrawScale=0.150000
	CollisionRadius=17.000000
	CollisionHeight=7.000000
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
}
