//=============================================================================
// ceilinggunbase.
//=============================================================================
class CeilingGunBase extends UT_Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	bStatic=False
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.cdbaseM'
}
