//=============================================================================
// brazier.
//=============================================================================
class Brazier extends ut_Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

function beginPlay()
{

		loopanim('sway',0.2);
}

defaultproperties
{
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.brazierM'
	DrawScale=0.500000
	CollisionRadius=12.000000
	CollisionHeight=60.000000
	bBlockActors=True
	bBlockPlayers=True
}
