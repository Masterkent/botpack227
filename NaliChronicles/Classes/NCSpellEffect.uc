// The base of all spell effects
// Code by Sergey 'Eater' Levin, 2001

class NCSpellEffect extends Effects;

auto state Explode
{
	simulated function Tick(float DeltaTime)
	{
		if (Level.NetMode == NM_DedicatedServer)
		{
			Disable('Tick');
			return;
		}
		ScaleGlow = (Lifespan/Default.Lifespan);
		LightBrightness = ScaleGlow*210.0;
	}

	simulated function BeginState()
	{
		if (EffectSound1!=none)
			PlaySound(EffectSound1,,0.5,,500);
		if (DrawType==DT_Mesh)
			PlayAnim('All',0.6);
	}
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.000000
}
