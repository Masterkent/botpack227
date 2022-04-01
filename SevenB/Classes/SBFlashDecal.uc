// ===============================================================
// SevenB.SBFlashDecal: Flashlight decal
/// By some guy
// Note: co-op replication doesn't work so well, but whatever
// ===============================================================

class SBFlashDecal extends pock;

#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

simulated function Timer();

simulated function PostBeginPlay()
{
	super(Scorch).PostBeginPlay();
}

defaultproperties
{
     PockTex(0)=Texture'SevenB.svbm'
     PockTex(1)=Texture'SevenB.svbm'
     PockTex(2)=Texture'SevenB.svbm'
     MultiDecalLevel=4
     bHighDetail=False
     bNetTemporary=False
     Style=STY_Modulated
     Texture=Texture'SevenB.svbm'
     DrawScale=1.000000
}
