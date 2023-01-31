//=============================================================================
// redeemertrail.
//=============================================================================
class RedeemerTrail extends Effects;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function PreBeginPlay()
{
	loopanim('all',2.0);
}

defaultproperties
{
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	LifeSpan=35.000000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Sprite=Texture'Botpack.Skins.MuzzyFlak'
	Texture=Texture'Botpack.Skins.MuzzyFlak'
	Skin=Texture'Botpack.Skins.MuzzyFlak'
	Mesh=LodMesh'Botpack.muzzRFF3'
	DrawScale=0.600000
	ScaleGlow=0.700000
	bUnlit=True
	bParticles=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=30
	LightRadius=8
	Mass=30.000000
}
