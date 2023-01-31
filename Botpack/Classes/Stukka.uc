//=============================================================================
// Stukka
//=============================================================================
class Stukka expands Decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var bool bDiveBomber;

defaultproperties
{
	Mesh=LodMesh'Botpack.stukkam'
	AmbientGlow=10
	SoundRadius=9
	SoundVolume=255
	CollisionRadius=0.000000
	CollisionHeight=0.000000
}
