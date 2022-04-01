//=============================================================================
// BulletImpact.
//=============================================================================
class BulletImpact expands Effects;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim('Hit',0.5);
}

simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
	AnimSequence=Hit
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'UnrealShare.BulletImpact'
	DrawScale=0.280000
	AmbientGlow=255
	bUnlit=True
}
