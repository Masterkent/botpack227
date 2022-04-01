//=============================================================================
// utbanner.
//=============================================================================
class UTBanner extends UT_Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

function beginPlay()
{
		loopanim('sway',0.2);
		animframe = FRand();		
}

defaultproperties
{
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.utbannerM'
	DrawScale=0.500000
}
