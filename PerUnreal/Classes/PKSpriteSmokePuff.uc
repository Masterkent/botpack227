//=============================================================================
// pkspritesmokepuff.
//=============================================================================
class PKSpriteSmokePuff extends AnimSpriteEffect;

var() Texture SSprites[4];
var() float RisingRate;
var() int NumSets;

simulated function BeginPlay()
{
	Velocity = Vect(0,0,1)*RisingRate;
	if ( !Level.bDropDetail )
		Texture = SSPrites[Rand(NumSets)];
}

defaultproperties
{
     SSprites(0)=Texture'Botpack.utsmoke.us1_a00'
     SSprites(1)=Texture'Botpack.utsmoke.us2_a00'
     SSprites(2)=Texture'Botpack.utsmoke.US3_A00'
     SSprites(3)=Texture'Botpack.utsmoke.us8_a00'
     RisingRate=20.000000
     NumSets=4
     NumFrames=8
     Pause=0.050000
     bNetOptional=True
     Physics=PHYS_Projectile
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.750000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Texture=Texture'Botpack.utsmoke.us1_a00'
     DrawScale=1.000000
     ScaleGlow=0.300000
     LightType=LT_None
     LightBrightness=10
     LightHue=0
     LightSaturation=255
     LightRadius=7
     bCorona=False
}
