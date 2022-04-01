//=============================================================================
// IntroBoss.
//=============================================================================
class IntroBoss expands Decoration;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

Auto State IntroBoss
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (AnimSequence=='stand')
			GotoState( 'IntroBoss','wave');
		else
			GotoState( 'IntroBoss','stand');
	}

wave: 
	Disable('Trigger');
	PlayAnim('wave',0.5);
	FinishAnim();
	Enable('Trigger');	
	Stop;

stand:
	Disable('Trigger');
	PlayAnim('stand',1);
	FinishAnim();
	Sleep(1.0);
	Enable('Trigger');
	Stop;
	
Begin:
	PlayAnim('stand',0.4);
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.IntroBoss'
}
