//=============================================================================
// PKMiniShellCase.
//=============================================================================
class PKMiniShellCase extends PKShellCase;

simulated function HitWall( vector HitNormal, actor Wall )
{
	Super.HitWall(HitNormal, Wall);
	GotoState('Ending');
}

State Ending
{
Begin:
	Sleep(0.7);
	Destroy();
}

defaultproperties
{
     bOnlyOwnerSee=True
     RemoteRole=ROLE_None
     LightType=LT_None
}
