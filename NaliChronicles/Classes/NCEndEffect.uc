// An effect played when spell starts is done casting
// Code by Sergey 'Eater' Levin, 2001

class NCEndEffect extends NCSpellEffect;

function PostBeginPlay() {
	Super.PostBeginPlay();
	PlayAnim( 'Explo', 0.35, 0.0 );
}

defaultproperties
{
     LifeSpan=0.600000
     AnimSequence=Explo
     DrawType=DT_Mesh
     Style=STY_None
     Mesh=LodMesh'Botpack.UTRingex'
     DrawScale=0.700000
     ScaleGlow=1.100000
     AmbientGlow=255
     bUnlit=True
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightSaturation=96
     LightRadius=12
}
