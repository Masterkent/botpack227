//=============================================================================
// Chainsaw hit.
//=============================================================================
class PKSawHit expands Effects;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim('Hit',0.5);
	spawn(class'PKSpark',,,Location + 8 * Vector(Rotation));
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
     Mesh=LodMesh'Botpack.BulletImpact'
     DrawScale=0.280000
     AmbientGlow=255
     bUnlit=True
}
