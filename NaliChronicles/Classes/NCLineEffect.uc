// The base of all line effects
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCLineEffect extends NCSpellEffect;

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		if (Level.NetMode == NM_DedicatedServer)
		{
			Disable('Tick');
			return;
		}
		if ((Lifespan/Default.LifeSpan) >= 0.5) {
			Style=STY_Normal;
		}
		else {
			Style=STY_Translucent;
			ScaleGlow = ((Lifespan/2)/Default.Lifespan);
			LightBrightness = ScaleGlow*210.0;
		}
	}
}

defaultproperties
{
     LifeSpan=1.200000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Skin=Texture'NaliChronicles.Skins.EarthLineSkin'
     Mesh=LodMesh'NaliChronicles.LineEffect'
     DrawScale=0.700000
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightSaturation=48
     LightRadius=12
}
