//=============================================================================
// ut_Blood2.
//=============================================================================
class UT_Blood2 extends Effects;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var bool bGreenBlood;

simulated function GreenBlood()
{
	bGreenBlood = true;
	bHidden = true;
}

simulated function PreBeginPlay()
{
	if( class'GameInfo'.Default.bVeryLowGore )
		GreenBlood();
}

simulated function AnimEnd()
{
  	Destroy();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Masked
	Texture=Texture'Botpack.Blood.BD3'
	Mesh=Mesh'Botpack.BloodUTm'
	DrawScale=0.250000
	AmbientGlow=56
	bUnlit=True
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'Botpack.Blood.BD3'
	MultiSkins(1)=Texture'Botpack.Blood.BD4'
	MultiSkins(2)=Texture'Botpack.Blood.BD6'
	MultiSkins(3)=Texture'Botpack.Blood.BD9'
	MultiSkins(4)=Texture'Botpack.Blood.BD10'
	MultiSkins(5)=Texture'Botpack.Blood.BD3'
	MultiSkins(6)=Texture'Botpack.Blood.BD4'
	MultiSkins(7)=Texture'Botpack.Blood.BD6'
}
