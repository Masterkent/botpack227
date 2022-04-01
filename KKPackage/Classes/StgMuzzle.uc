class StgMuzzle extends CannonMuzzle;

#exec OBJ LOAD FILE="..\Textures\KKSkins.utx"

#exec OBJ LOAD FILE="KKPackageResources.u" PACKAGE=KKPackage

function PostBeginPlay()
{
//		Super.PostBeginPlay();
//		LoopAnim('Shoot');
}

defaultproperties
{
     bDynamicLight=True
     LODBias=22.000000
     Texture=Texture'KKSkins.Skins.StMuzzleStin'
     Mesh=Mesh'KKPackage.stingermuzz'
     DrawScale=1.000000
     bParticles=False
}
