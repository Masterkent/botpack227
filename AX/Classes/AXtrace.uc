//=============================================================================
// AXtrace.
//=============================================================================
class AXtrace expands Projectile;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

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
     speed=4500.000000
     MaxSpeed=5750.000000
     bReplicateInstigator=False
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     Style=STY_Translucent
     Skin=Texture'AX.Icons.a5hdc'
     Mesh=LodMesh'AX.AXtrace'
     DrawScale=0.700000
     AmbientGlow=187
     bUnlit=True
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=30
     LightSaturation=69
     LightRadius=3
}
