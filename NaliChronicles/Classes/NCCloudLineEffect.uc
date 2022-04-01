// A line used by lightning
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCCloudLineEffect extends NCLineEffect;

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
     DrawType=DT_Sprite
     Texture=Texture'NaliChronicles.Skins.CloudSprite'
     DrawScale=0.200000
     bUnlit=True
     LightBrightness=32
     LightSaturation=255
     LightRadius=16
}
