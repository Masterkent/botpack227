//=============================================================================
// EnhancedRespawn.
//=============================================================================
class EnhancedRespawn expands Effects;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

simulated function BeginPlay()
{
	Super.BeginPlay();
	Playsound(EffectSound1);
	PlayAnim('All',0.8);
}

simulated function PostBeginPlay()
{
	local inventory Inv;

	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
	Playsound(EffectSound1);
	if ( Owner != None )
	{
		Inv = Inventory(Owner);
 		if ( Inv != None )
		{
			if ( Inv.PickupViewScale == 1.0 )
				Mesh = Inv.PickUpViewMesh;
			else
				Mesh = Owner.Mesh;
			if ( Inv.RespawnTime < 15 )
				LifeSpan = 0.5;
		}
		else
			Mesh = Owner.Mesh;
		Animframe = Owner.Animframe;
		Animsequence = Owner.Animsequence;
	}
}

auto state Explode
{
	simulated function Tick( float DeltaTime )
	{
		if ( Owner != None )
		{
			if ( Owner.LatentFloat > 1 ) //got picked up and put back to sleep
			{
				Destroy();
				Return;
			}
			SetRotation(Owner.Rotation);
		}
		if ( Level.bDropDetail )
			LifeSpan -= DeltaTime;
		ScaleGlow = (Lifespan/Default.Lifespan);
		LightBrightness = ScaleGlow*210.0;
		DrawScale = 0.03 + 0.77 * ScaleGlow;
	}

	simulated function AnimEnd()
	{
		RemoteRole = ROLE_None;
		Destroy();
	}
}

defaultproperties
{
	EffectSound1=Sound'Botpack.Generic.RespawnSound2'
	bNetOptional=True
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=1.500000
	AnimSequence=All
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'UnrealShare.DBEffect.de_A00'
	Skin=Texture'UnrealShare.DBEffect.de_A00'
	Mesh=LodMesh'UnrealShare.TeleEffect2'
	DrawScale=1.100000
	AmbientGlow=255
	bUnlit=True
	bParticles=True
	bMeshEnviroMap=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=210
	LightHue=30
	LightSaturation=224
	LightRadius=6
}
