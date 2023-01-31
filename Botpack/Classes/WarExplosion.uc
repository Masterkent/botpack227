//=============================================================================
// WarExplosion.
//=============================================================================
class WarExplosion extends AnimSpriteEffect;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( !Level.bHighDetailMode ) 
		Drawscale = 1.9;
	PlaySound (EffectSound1,,12.0,,3000);	
    Texture = Default.Texture;
}

defaultproperties
{
	NumFrames=18
	Pause=0.050000
	EffectSound1=Sound'Botpack.Redeemer.WarExplo'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=1.000000
	DrawType=DT_SpriteAnimOnce
	Style=STY_Translucent
	Texture=Texture'Botpack.WarExplosionS.we_a00'
	DrawScale=2.800000
	LightEffect=LE_NonIncidence
	LightRadius=12
	bCorona=False
}
