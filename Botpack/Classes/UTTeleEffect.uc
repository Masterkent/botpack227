//=============================================================================
// UTTeleEffect.
//=============================================================================
class UTTeleEffect extends Effects;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Teleport', 2.0, 0.0);
}

defaultproperties
{
	RemoteRole=ROLE_None
	LifeSpan=1.000000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'Botpack.Tele2'
	bUnlit=True
}
