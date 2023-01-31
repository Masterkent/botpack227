//=============================================================================
// IntroDude.
//=============================================================================
class IntroDude expands decoration;
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

Auto State IntroDude
{

function Trigger( actor Other, pawn EventInstigator )
{
	if (AnimSequence=='stand')
		GotoState( 'IntroDude','shake');
	else
		GotoState( 'IntroDude','stand');
}

shake: 
	Disable('Trigger');
	PlayAnim('shake',1);
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
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'Botpack.IntroDude'
}
