//=============================================================================
// TeamScoreBoard
//=============================================================================
class TeamScoreBoard extends TournamentScoreBoard;

var localized string TeamName[4];
var localized string OrdersString, InString;
var localized string PlayersNotShown;
var() color TeamColor[4];
var() color AltTeamColor[4];
var PlayerReplicationInfo OwnerInfo;
var TournamentGameReplicationInfo OwnerGame;

function ShowScores( canvas Canvas )
{
	local UTC_PlayerReplicationInfo PRI;
	local int PlayerCount, i;
	local float LoopCountTeam[4];
	local float XL, YL, XOffset, YOffset;
	local int PlayerCounts[4];
	local int LongLists[4];
	local int BottomSlot[4];
	local font CanvasFont;
	local bool bCompressed;
	local float r;

	OwnerInfo = Pawn(Owner).PlayerReplicationInfo;
	OwnerGame = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
	Canvas.Style = ERenderStyle.STY_Normal;
	CanvasFont = Canvas.Font;

	B227_InnerWidth = B227_ScaledScreenWidth(Canvas);
	B227_MarginLeft = (Canvas.SizeX - B227_InnerWidth) / 2;

	// Header
	DrawHeader(Canvas);

	for ( i=0; i<32; i++ )
		Ordered[i] = None;

	foreach AllActors(class'UTC_PlayerReplicationInfo', PRI)
		if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
		{
			Ordered[PlayerCount] = PRI;
			PlayerCount++;
			PlayerCounts[PRI.Team]++;
			if (PlayerCount == ArrayCount(Ordered))
				break;
		}

	SortScores(PlayerCount);
	Canvas.Font = MyFonts.GetMediumFont(B227_ScaledFontScreenWidth(Canvas));
	Canvas.StrLen("TEXT", XL, YL);
	ScoreStart = Canvas.CurY + YL*2;
	if ( ScoreStart + PlayerCount * YL + 2 > Canvas.ClipY )
	{
		bCompressed = true;
		CanvasFont = Canvas.Font;
		Canvas.Font = font'SmallFont';
		r = YL;
		Canvas.StrLen("TEXT", XL, YL);
		r = YL/r;
		Canvas.Font = CanvasFont;
	}
	for ( I=0; I<PlayerCount; I++ )
	{
		if ( Ordered[I].Team < 4 )
		{
			if ( Ordered[I].Team % 2 == 0 )
				XOffset = B227_MarginLeft + (B227_InnerWidth / 4) - (B227_InnerWidth / 8);
			else
				XOffset = B227_MarginLeft + ((B227_InnerWidth / 4) * 3) - (B227_InnerWidth / 8);

			Canvas.StrLen("TEXT", XL, YL);
			Canvas.DrawColor = AltTeamColor[Ordered[I].Team];
			YOffset = ScoreStart + (LoopCountTeam[Ordered[I].Team] * YL) + 2;
			if (( Ordered[I].Team > 1 ) && ( PlayerCounts[Ordered[I].Team-2] > 0 ))
			{
				BottomSlot[Ordered[I].Team] = 1;
				YOffset = ScoreStart + YL*11 + LoopCountTeam[Ordered[I].Team]*YL;
			}

			// Draw Name and Ping
			if ( (Ordered[I].Team < 2) && (BottomSlot[Ordered[I].Team] == 0) && (PlayerCounts[Ordered[I].Team+2] == 0))
			{
				LongLists[Ordered[I].Team] = 1;
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);
			}
			else if (LoopCountTeam[Ordered[I].Team] < 8)
				DrawNameAndPing( Canvas, Ordered[I], XOffset, YOffset, bCompressed);
			if ( bCompressed )
				LoopCountTeam[Ordered[I].Team] += 1;
			else
				LoopCountTeam[Ordered[I].Team] += 2;
		}
	}

	for ( i=0; i<4; i++ )
	{
		Canvas.Font = MyFonts.GetMediumFont(B227_ScaledFontScreenWidth(Canvas));
		if ( PlayerCounts[i] > 0 )
		{
			if ( i % 2 == 0 )
				XOffset = B227_MarginLeft + (B227_InnerWidth / 4) - (B227_InnerWidth / 8);
			else
				XOffset = B227_MarginLeft + ((B227_InnerWidth / 4) * 3) - (B227_InnerWidth / 8);
			YOffset = ScoreStart - YL + 2;

			if ( i > 1 )
				if (PlayerCounts[i-2] > 0)
					YOffset = ScoreStart + YL*10;

			Canvas.DrawColor = TeamColor[i];
			Canvas.SetPos(XOffset, YOffset);
			Canvas.StrLen(TeamName[i], XL, YL);
			Canvas.DrawText(TeamName[i], false);
			Canvas.StrLen(int(OwnerGame.Teams[i].Score), XL, YL);
			Canvas.SetPos(XOffset + (B227_InnerWidth/4) - XL, YOffset);
			Canvas.DrawText(int(OwnerGame.Teams[i].Score), false);

			if ( PlayerCounts[i] > 4 )
			{
				if ( i < 2 )
					YOffset = ScoreStart + YL*8;
				else
					YOffset = ScoreStart + YL*19;
				Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
				Canvas.SetPos(XOffset, YOffset);
				if (LongLists[i] == 0)
					Canvas.DrawText(PlayerCounts[i] - 4 @ PlayersNotShown, false);
			}
		}
	}

	// Trailer
	if (!B227_bLowRes(Canvas))
	{
		Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
		DrawTrailer(Canvas);
	}
	Canvas.Font = CanvasFont;
	Canvas.DrawColor = WhiteColor;
}

function DrawScore(Canvas Canvas, float Score, float XOffset, float YOffset)
{
	local float XL, YL;

	Canvas.StrLen(string(int(Score)), XL, YL);
	Canvas.SetPos(XOffset + (B227_InnerWidth/4) - XL, YOffset);
	Canvas.DrawText(int(Score), False);
}

function DrawNameAndPing(Canvas Canvas, UTC_PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
	local float XL, YL, XL2, YL2, YB;
	local string O, L;
	local Font CanvasFont;
	local bool bAdminPlayer;
	local int Time;

	if (B227_OwnerPRI() == none)
		return;

	bAdminPlayer = PRI.bAdmin;

	// Draw Name
	if (PRI.PlayerName == B227_OwnerPRI().PlayerName)
		Canvas.DrawColor = GoldColor;

	if ( bAdminPlayer )
		Canvas.DrawColor = WhiteColor;

	Canvas.SetPos(XOffset, YOffset);
	Canvas.DrawText(PRI.PlayerName, False);
	Canvas.StrLen(PRI.PlayerName, XL, YB);

	if ( B227_InnerWidth > 512 )
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';
		Canvas.DrawColor = WhiteColor;

		if (Level.NetMode != NM_Standalone)
		{
			if ( !bCompressed || (B227_InnerWidth > 640) )
			{
				// Draw Time
				Time = Max(1, (Level.TimeSeconds + B227_OwnerPRI().StartTime - PRI.StartTime)/60);
				Canvas.StrLen(TimeString$":     ", XL, YL);
				Canvas.SetPos(XOffset - XL - 6, YOffset);
				Canvas.DrawText(TimeString$":"@Time, false);
			}

			// Draw Ping
			Canvas.StrLen(PingString$":     ", XL2, YL2);
			Canvas.SetPos(XOffset - XL2 - 6, YOffset + (YL+1));
			Canvas.DrawText(PingString$":"@PRI.Ping, false);
		}
		Canvas.Font = CanvasFont;
	}

	// Draw Score
	if (PRI.PlayerName == B227_OwnerPRI().PlayerName)
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = TeamColor[PRI.Team];
	DrawScore(Canvas, PRI.Score, XOffset, YOffset);

	if (B227_InnerWidth < 512)
		return;

	// Draw location, Order
	if ( !bCompressed && (PRI.Team == OwnerInfo.Team) )
	{
		CanvasFont = Canvas.Font;
		Canvas.Font = Font'SmallFont';

		if ( PRI.PlayerLocation != None )
			L = PRI.PlayerLocation.LocationName;
		else if ( PRI.PlayerZone != None )
			L = PRI.PlayerZone.ZoneName;
		else
			L = "";
		if ( L != "" )
		{
			L = InString@L;
			Canvas.SetPos(XOffset, YOffset + YB);
			Canvas.DrawText(L, False);
		}
		O = OwnerGame.GetOrderString(PRI);
		if (O != "")
		{
			O = OrdersString@O;
			Canvas.StrLen(O, XL2, YL2);
			Canvas.SetPos(XOffset, YOffset + YB + YL2);
			Canvas.DrawText(O, False);
		}
		Canvas.Font = CanvasFont;
	}
}

function DrawVictoryConditions(Canvas Canvas)
{
	local TournamentGameReplicationInfo TGRI;
	local float XL, YL;

	TGRI = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
	if ( TGRI == None )
		return;

	Canvas.DrawText(TGRI.GameName);
	Canvas.StrLen("Test", XL, YL);
	Canvas.SetPos(0, Canvas.CurY - YL);

	if ( TGRI.GoalTeamScore > 0 )
	{
		Canvas.DrawText(FragGoal@TGRI.GoalTeamScore);
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.CurY - YL);
	}

	if ( TGRI.TimeLimit > 0 )
		Canvas.DrawText(TimeLimit@TGRI.TimeLimit$":00");
}

defaultproperties
{
	TeamName(0)="Red Team"
	TeamName(1)="Blue Team"
	TeamName(2)="Green Team"
	TeamName(3)="Gold Team"
	OrdersString="Orders:"
	InString="Location:"
	PlayersNotShown="Player[s] not shown."
	TeamColor(0)=(R=255)
	TeamColor(1)=(G=128,B=255)
	TeamColor(2)=(G=255)
	TeamColor(3)=(R=255,G=255)
	AltTeamColor(0)=(R=200)
	AltTeamColor(1)=(G=94,B=187)
	AltTeamColor(2)=(G=128)
	AltTeamColor(3)=(R=255,G=255,B=128)
}
