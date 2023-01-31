//=============================================================================
// MTracer.
//=============================================================================
class MTracer extends Projectile;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function PostBeginPlay()
{
	//log("Spawn"@self@"with role"@Role@"and netmode"@Level.netmode);
	Super.PostBeginPlay();
	Velocity = Speed * vector(Rotation);
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
	bReplicateInstigator=False
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=2.000000
	Style=STY_Translucent
	Texture=FireTexture'UnrealShare.Effect1.FireEffect1u'
	Mesh=LodMesh'Botpack.MiniTrace'
	DrawScale=0.800000
	AmbientGlow=187
	bUnlit=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=30
	LightSaturation=69
	LightRadius=3
}
