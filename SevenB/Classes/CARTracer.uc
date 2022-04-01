//=============================================================================
// CARTracer.
//=============================================================================
class CARTracer expands Projectile;

#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

function PostBeginPlay()
{
  Super.PostBeginPlay();
  Velocity = Vector(Rotation) * speed;
  if ( Level.bDropDetail )
    LightType = LT_None;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
  Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
  If ( Other!=Instigator )
    Destroy();
}

defaultproperties
{
     speed=4000.000000
     MaxSpeed=4000.000000
     bNetOptional=True
     bReplicateInstigator=False
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     Style=STY_Translucent
     Skin=Texture'SevenB.Skins.JTR0501'
     DrawScale=2.000000
     ScaleGlow=10.000000
     AmbientGlow=187
     Fatness=90
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=30
     LightSaturation=69
     LightRadius=3
}
