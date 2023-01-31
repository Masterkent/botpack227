//=============================================================================
// barrel3.
//=============================================================================
class Barrel3 extends ut_Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.barrel3M'
	DrawScale=0.250000
	CollisionHeight=30.000000
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
}
