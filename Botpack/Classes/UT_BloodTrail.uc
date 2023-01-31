//=============================================================================
// ut_BloodTrail.
//=============================================================================
class UT_BloodTrail extends ut_Blood2;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();	
	LoopAnim('Trail');
	bRandomFrame = !Level.bDropDetail;
}

function AnimEnd()
{
}

defaultproperties
{
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	LifeSpan=5.000000
	AnimSequence=trail
	Texture=Texture'Botpack.Blood.BD6'
	Mesh=LodMesh'Botpack.UTBloodTrl'
	DrawScale=0.200000
	AmbientGlow=0
}
