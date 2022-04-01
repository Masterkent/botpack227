//=============================================================================
// ShockBeam.
//=============================================================================
class ShockBeam extends Effects
	config(Botpack);

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var vector MoveAmount;
var int NumPuffs;

var config bool B227_bModifyLighting;

var float B227_Pitch, B227_Yaw, B227_Roll;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		MoveAmount, NumPuffs;

	reliable if (Role == Role_Authority)
		B227_Pitch, B227_Yaw, B227_Roll;
}

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode  != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan)*1.0;
		AmbientGlow = ScaleGlow * 210;
		if (B227_ShouldModifyLighting())
			B227_ModifyLighting();
	}
}


simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		SetTimer(0.05, false);
		if (B227_ShouldModifyLighting())
			B227_ModifyLighting();
	}
	if (Level.NetMode != NM_Client)
	{
		B227_Pitch = Rotation.Pitch;
		B227_Yaw = Rotation.Yaw;
		B227_Roll = Rotation.Roll;
	}
}

simulated function Timer()
{
	local ShockBeam r;
	
	if (NumPuffs>0)
	{
		r = Spawn(class'Shockbeam',,,Location+MoveAmount);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MoveAmount = MoveAmount;
	}
}

simulated event PostNetBeginPlay()
{
	local rotator R;

	R.Pitch = B227_Pitch;
	R.Yaw = B227_Yaw;
	R.Roll = B227_Roll;
	SetRotation(R); // override imprecisely replicated rotation with precise value
}

static function bool B227_ShouldModifyLighting()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bModifyProjectilesLighting &&
		default.B227_bModifyLighting;
}

simulated function B227_ModifyLighting()
{
	LightType = LT_Steady;
	LightEffect = LE_None;
	LightRadius = 15;
	LightBrightness = 64 * FClamp(Lifespan / default.Lifespan, 0, 1);
	LightHue = 165; // same as for ShockProj
	LightSaturation = 72; // // same as for ShockProj
}

defaultproperties
{
	Physics=PHYS_Rotating
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.270000
	Rotation=(Roll=20000)
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'Botpack.Effects.jenergy2'
	Mesh=LodMesh'Botpack.Shockbm'
	DrawScale=0.440000
	bUnlit=True
	bParticles=True
	bFixedRotationDir=True
	RotationRate=(Roll=1000000)
	DesiredRotation=(Roll=20000)
	B227_bModifyLighting=True
}
