//=============================================================================
// ChallengeCTFHUD.
//=============================================================================
class ChallengeCTFHUD extends ChallengeTeamHUD;

// Blue
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var CTFFlag MyFlag;

function Timer()
{
	Super.Timer();

	if (PlayerOwner == none || PawnOwner == none)
		return;
	if (PawnOwner.PlayerReplicationInfo.HasFlag != none)
		class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(PlayerOwner, class'CTFMessage2', 0);
	if (MyFlag != none && !MyFlag.bHome)
		class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(PlayerOwner, class'CTFMessage2', 1);
}

simulated function PostRender( canvas Canvas )
{
	local int X, Y, i;
	local CTFFlag Flag;

	Super.PostRender( Canvas );

	B227_InitUpscale(Canvas);

	if ( (PlayerOwner == None) || (PawnOwner == None) || (PlayerOwner.GameReplicationInfo == None)
		|| (PawnOwner.PlayerReplicationInfo == None)
		|| ((PlayerOwner.bShowMenu || PlayerOwner.bShowScores) && (Canvas.ClipX < 640)) )
	{
		B227_ResetUpscale(Canvas);
		return;
	}

	Canvas.Style = Style;
	if( !bHideHUD && !bHideTeamInfo )
	{
		X = Canvas.ClipX - 70 * Scale;
		Y = Canvas.ClipY - 350 * Scale;

		for ( i=0; i<4; i++ )
		{
			Flag = CTFReplicationInfo(PlayerOwner.GameReplicationInfo).FlagList[i];
			if ( Flag != None )
			{
				Canvas.DrawColor = TeamColor[Flag.Team];
				Canvas.SetPos(X,Y);

				if (Flag.Team == PawnOwner.PlayerReplicationInfo.Team)
					MyFlag = Flag;
				if ( Flag.bHome ) 
					Canvas.DrawIcon(texture'I_Home', Scale * 2);
				else if ( Flag.bHeld )
					Canvas.DrawIcon(texture'I_Capt', Scale * 2);
				else
					Canvas.DrawIcon(texture'I_Down', Scale * 2);
			}
			Y -= 150 * Scale;
		}
	}

	B227_ResetUpscale(Canvas);
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	if ( (TI != None) && (TI.Size > 0) )
	{
		Canvas.DrawColor = TeamColor[TI.TeamIndex];
		DrawBigNum(Canvas, int(TI.Score), Canvas.ClipX - 144 * Scale, Canvas.ClipY - 336 * Scale - (150 * Scale * TI.TeamIndex), 1);
	}
}

defaultproperties
{
	ServerInfoClass=Class'Botpack.ServerInfoCTF'
}
