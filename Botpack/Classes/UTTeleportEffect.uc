//=============================================================================
// UTTeleportEffect.
//=============================================================================
class UTTeleportEffect extends PawnTeleportEffect;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var bool bSpawnEffects;
var UTTeleEffect T1, T2;

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		local rotator newrot;

		if ( !Level.bHighDetailMode )
		{
			bOwnerNoSee = true;
			Disable('Tick');
			return;
		}

		if ( Level.NetMode == NM_DedicatedServer )
		{
			Disable('Tick');
			return;
		}

		ScaleGlow = (Lifespan/Default.Lifespan);	
		LightBrightness = ScaleGlow*210.0;

		if ( !Level.bHighDetailMode )
		{
			LightRadius = 6;
			return;
		}

		if ( !bSpawnEffects )
		{
			bSpawnEffects = true;
			T1 = spawn(class'UTTeleeffect');
			newrot = Rotation;
			newRot.Yaw = Rand(65535);
			T2 = spawn(class'UTTeleeffect',,,location - vect(0,0,10), newRot);
		}
		else
		{
			if ( T1 != None )
				T1.ScaleGlow = ScaleGlow;
			if ( T2 != None )
				T2.ScaleGlow = ScaleGlow;
		}
	}
}

defaultproperties
{
	Texture=Texture'Botpack.FlareFX.utflare1'
	bRandomFrame=True
	MultiSkins(0)=Texture'Botpack.FlareFX.utflare1'
	MultiSkins(1)=Texture'Botpack.FlareFX.utflare2'
	MultiSkins(2)=Texture'Botpack.FlareFX.utflare3'
	MultiSkins(3)=Texture'Botpack.FlareFX.utflare4'
	MultiSkins(4)=Texture'Botpack.FlareFX.utflare5'
	MultiSkins(5)=Texture'Botpack.FlareFX.utflare6'
	MultiSkins(6)=Texture'Botpack.FlareFX.utflare7'
	MultiSkins(7)=Texture'Botpack.FlareFX.utflare8'
	LightRadius=9
}
