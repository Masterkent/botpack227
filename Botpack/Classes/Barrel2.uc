//=============================================================================
// barrel2.
//=============================================================================
class Barrel2 extends ut_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.barrel2M'
	DrawScale=0.250000
	CollisionHeight=30.000000
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
}
