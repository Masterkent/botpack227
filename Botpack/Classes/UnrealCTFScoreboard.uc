// UnrealCTFScoreBoard
//=============================================================================
class UnrealCTFScoreBoard extends TeamScoreBoard;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() texture FlagIcon[4];

function DrawNameAndPing(Canvas Canvas, UTC_PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
	Super.DrawNameAndPing(Canvas, PRI, XOffset, YOffset, bCompressed);
	if ( PRI.HasFlag == None )
		return;

	// Flag icon
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(XOffset - 32, YOffset);
	Canvas.DrawIcon(FlagIcon[CTFFlag(PRI.HasFlag).Team], 1.0);
}

defaultproperties
{
	FlagIcon(0)=Texture'Botpack.Icons.RedFlag'
	FlagIcon(1)=Texture'Botpack.Icons.BlueFlag'
	FlagIcon(2)=Texture'Botpack.Icons.GreenFlag'
	FlagIcon(3)=Texture'Botpack.Icons.YellowFlag'
	FragGoal="Capture Limit:"
}
