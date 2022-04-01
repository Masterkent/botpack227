// The flaming trail of a fireball
// Code by Sergey 'Eater' Levin, 2001

class NCFirePuff extends AnimSpriteEffect;

var() float MainScale;

function Tick(float DeltaTime) {
	DrawScale = MainScale + ((1-(Lifespan/Default.Lifespan))*MainScale);
	ScaleGlow = (Lifespan/Default.Lifespan);
	LightBrightness = 64*(Lifespan/Default.Lifespan);
}

function PostBeginPlay() {
	Super.PostBeginPlay();
	Velocity = Vect(0,0,1)*10;
}

defaultproperties
{
     MainScale=1.000000
     LifeSpan=2.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UnrealShare.s_Exp004'
     DrawScale=1.000000
     AmbientGlow=215
     Fatness=0
     LightEffect=LE_NonIncidence
     LightBrightness=64
     LightHue=32
     LightSaturation=8
     LightRadius=4
     LightPeriod=50
     bCorona=False
}
