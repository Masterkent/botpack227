//=============================================================================
// PKFlakExplosion.
//=============================================================================
class PKFlakExplosion expands AnimSpriteEffect;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (!Level.bHighDetailMode)
			Drawscale = 1.4;
		else
			Spawn(class'UT_ShortSmokeGen');
	}
	PlaySound(sound'PKflakexplo',, 2.0,, 8192, Level.TimeDilation- 0.4*FRand());

	Spawn(class'PKExploSpark',Self, '', Location + (20 + 20 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKExploSpark',Self, '', Location + (20 + 20 * FRand()) * (VRand() + Vect(0,0,0.5)) );
	Spawn(class'PKExploSpark',Self, '', Location + (20 + 20 * FRand()) * (VRand() + Vect(0,0,0.5)) );
}

defaultproperties
{
     NumFrames=8
     Pause=0.050000
     EffectSound1=Sound'UnrealShare.General.Expl04'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.500000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'Botpack.UT_Explosions.Exp2_a00'
     Skin=Texture'UnrealShare.Effects.ExplosionPal2'
     DrawScale=2.000000
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightBrightness=159
     LightHue=32
     LightSaturation=79
     LightRadius=8
     bCorona=False
}
