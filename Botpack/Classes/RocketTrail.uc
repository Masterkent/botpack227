//=============================================================================
// RocketTrail.
//=============================================================================
class RocketTrail extends Effects;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

defaultproperties
{
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	DrawType=DT_Sprite
	Style=STY_Translucent
	Sprite=Texture'Botpack.JRFlare'
	Texture=Texture'Botpack.JRFlare'
	Skin=Texture'Botpack.JRFlare'
	DrawScale=0.500000
	bUnlit=True
	Mass=8.000000
}
