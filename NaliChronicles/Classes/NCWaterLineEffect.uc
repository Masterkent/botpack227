// A watery line effect
// Code by Sergey 'Eater' Levin, 2001

class NCWaterLineEffect extends NCLineEffect;

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
     Texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newblue'
     bUnlit=True
     bMeshEnviroMap=True
     LightBrightness=32
     LightHue=180
     LightSaturation=64
     LightRadius=16
}
