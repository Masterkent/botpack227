//=============================================================================
// PKSuperShockBeam.
//=============================================================================
class PKSuperShockBeam extends Effects;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var vector MoveAmount;
var int NumPuffs;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		MoveAmount, NumPuffs;
}

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode  != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan)*1.0;
		AmbientGlow = ScaleGlow * 210;
	}
}


simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
		SetTimer(0.05, false);

                if ( FRand() < 0.1) Texture=Texture'PKenergy1';
                else if ( FRand() < 0.2) Texture=Texture'PKenergy2';
                else if ( FRand() < 0.3) Texture=Texture'PKenergy3';
                else if ( FRand() < 0.4) Texture=Texture'PKenergy4';
                else if ( FRand() < 0.5) Texture=Texture'PKenergy5';
                else if ( FRand() < 0.6) Texture=Texture'PKenergy6';
                else if ( FRand() < 0.7) Texture=Texture'PKenergy7';
                else if ( FRand() < 0.8) Texture=Texture'PKenergy8';
                else if ( FRand() < 0.9) Texture=Texture'PKenergy9';
                else Texture=Texture'botpack.Effects.jenergy3';
}

simulated function Timer()
{
	local PKSuperShockBeam r;

	if (NumPuffs>0)
	{
		r = Spawn(class'PKSuperShockbeam',,,Location+MoveAmount);
		r.RemoteRole = ROLE_None;
		r.NumPuffs = NumPuffs -1;
		r.MoveAmount = MoveAmount;
	}
}

defaultproperties
{
     Physics=PHYS_Rotating
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.270000
     Rotation=(Roll=20000)
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=Texture'Botpack.Effects.jenergy3'
     Mesh=LodMesh'Botpack.SShockbm'
     DrawScale=0.440000
     bUnlit=True
     bParticles=True
     bFixedRotationDir=True
     RotationRate=(Roll=1000000)
     DesiredRotation=(Roll=20000)
}
