//=============================================================================
// ArenaCam.
//=============================================================================
class ArenaCam expands Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() Sound ArmDown;
var() Sound ArmLoop;

Auto State Camarm
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (AnimSequence=='sit')
			GotoState( 'Camarm','down');
		else
			GotoState( 'Camarm','sit');
	}

Down:
	Disable('Trigger');
	PlayAnim('down',1.2);
	PlaySound(ArmDown,SLOT_Misc,1.0);
	FinishAnim();
	LoopAnim('loop',1.2);
	PlaySound(ArmLoop,SLOT_Misc,1.0);

//	Enable('Trigger');
	Stop;


Loop:
	Disable('Trigger');
	LoopAnim('loop',1.2);
	PlaySound(ArmLoop,SLOT_Misc,1.0);

Begin:
	PlayAnim('sit',1.2);
}

defaultproperties
{
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.ArenaCam'
	DrawScale=9.500000
}
