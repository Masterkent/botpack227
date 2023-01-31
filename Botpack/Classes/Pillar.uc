//=============================================================================
// pillar.
//=============================================================================
class Pillar extends UT_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.pillarM'
	DrawScale=0.500000
	CollisionRadius=12.000000
	CollisionHeight=60.000000
	bBlockActors=True
	bBlockPlayers=True
}
