//=============================================================================
// PlasmaCap.
//=============================================================================
class PlasmaCap extends Effects;

function B227_SetAdvancedLighting(PBolt Beam)
{
	bHidden = true;
	AmbientGlow = 0;
	LightEffect = LE_None;
	LightBrightness = Beam.LightBrightness;
	LightRadius = Beam.LightRadius;
	LightHue = Beam.LightHue;
	LightSaturation = Beam.LightSaturation;
}

defaultproperties
{
	RemoteRole=ROLE_None
	LifeSpan=8.000000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'Botpack.BoltHit.phit_a00'
	DrawScale=0.650000
	AmbientGlow=187
	bUnlit=True
	SoundRadius=10
	SoundVolume=218
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=83
	LightRadius=4
}
