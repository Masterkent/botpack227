// An effect played when spell starts being cast
// Code by Sergey 'Eater' Levin, 2001

class NCStartEffect extends NCSpellEffect;

function PostBeginPlay() {
	Super.PostBeginPlay();
	PlayAnim( 'Explo', 0.35, 0.0 );
}

defaultproperties
{
     LifeSpan=0.600000
     AnimSequence=Explo
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'UnrealShare.Effects.T_PawnT'
     Skin=Texture'UnrealShare.Effects.T_PawnT'
     Mesh=LodMesh'Botpack.UTRingex'
     DrawScale=0.250000
     bUnlit=True
     bParticles=True
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightSaturation=96
     LightRadius=12
}
