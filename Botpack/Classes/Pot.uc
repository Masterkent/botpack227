//=============================================================================
// pot.
//=============================================================================
class Pot extends UT_Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.potM'
	DrawScale=0.200000
	bCollideActors=True
	bBlockActors=True
	bBlockPlayers=True
}
