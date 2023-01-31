//=============================================================================
// fighter2.
//=============================================================================
class Fighter2 extends UT_Decoration;


#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

function beginPlay()
{
		loopanim('sway',0.4);
		animframe = FRand();
}

defaultproperties
{
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.fighter2M'
}
