//=============================================================================
// bin2.
//=============================================================================
class Bin2 extends ut_Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.bin2M'
	DrawScale=0.250000
	CollisionHeight=30.000000
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
}
