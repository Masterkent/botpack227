//=============================================================================
// pock.
//=============================================================================
class Pock expands UnrealShare.Scorch;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() texture PockTex[3];

simulated function PostBeginPlay()
{
	if ( Level.bDropDetail )
		Texture = PockTex[0];
	else
		Texture = PockTex[Rand(3)];

	Super.PostBeginPlay();
}

simulated function AttachToSurface()
{
	bAttached = AttachDecal(100, vect(0,0,1)) != None;
}

defaultproperties
{
	PockTex(0)=Texture'Botpack.pock0_t'
	PockTex(1)=Texture'Botpack.pock2_t'
	PockTex(2)=Texture'Botpack.pock4_t'
	bImportant=False
	MultiDecalLevel=0
	DrawScale=0.190000
}
