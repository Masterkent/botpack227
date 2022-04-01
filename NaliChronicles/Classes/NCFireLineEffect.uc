// A fire line effect
// Code by Sergey 'Eater' Levin, 2002

class NCFireLineEffect extends NCLineEffect;

var texture myTexes[3];

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

function PostBeginPlay() {
	Super.PostBeginPlay();
	Texture = myTexes[Rand(3)];
}

defaultproperties
{
     myTexes(0)=Texture'Botpack.ChunkGlow.Chunk_a02'
     myTexes(1)=Texture'Botpack.ChunkGlow.Chunk_a03'
     myTexes(2)=Texture'Botpack.ChunkGlow.Chunk_a04'
     Texture=Texture'Botpack.ChunkGlow.Chunk_a02'
     bUnlit=True
     bMeshEnviroMap=True
     LightBrightness=32
     LightHue=32
     LightSaturation=64
     LightRadius=16
}
