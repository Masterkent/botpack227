//=============================================================================
// fighter.
//=============================================================================
class Fighter extends UT_Decoration;


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
	Mesh=LodMesh'Botpack.fighterM'
}
