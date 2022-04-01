// A line used by lightning
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCLightningLineEffect extends NCLineEffect;

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		if (Level.NetMode == NM_DedicatedServer)
		{
			Disable('Tick');
			return;
		}
		if ((Lifespan/Default.LifeSpan) < 0.5) {
			ScaleGlow = ((Lifespan/2)/Default.Lifespan);
			LightBrightness = ScaleGlow*210.0;
		}
	}
}

defaultproperties
{
     Skin=Texture'NaliChronicles.Skins.LightningLineSkin'
     bUnlit=True
     LightBrightness=32
     LightSaturation=255
     LightRadius=16
}
