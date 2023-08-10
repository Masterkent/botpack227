//=============================================================================
// TournamentScoreBoard
//=============================================================================
class TournamentScoreBoard extends ScoreBoard;

var localized string MapTitle, Author, Restart, Continue, Ended, ElapsedTime, RemainingTime, FragGoal, TimeLimit;
var localized string PlayerString, FragsString, DeathsString, PingString;
var localized string TimeString, LossString, FPHString;
var color GreenColor, WhiteColor, GoldColor, BlueColor, LightCyanColor, SilverColor, BronzeColor, CyanColor, RedColor;
var UTC_PlayerReplicationInfo Ordered[32];
var float ScoreStart;	// top allowed score start
var bool bTimeDown;
var FontInfo MyFonts;
var localized string MapTitleQuote;

var float B227_MarginLeft, B227_InnerWidth; // margin and width of the area that contains the score table

function Destroyed()
{
	Super.Destroyed();
	if ( MyFonts != None )
		MyFonts.Destroy();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	MyFonts = FontInfo(spawn(Class<Actor>(DynamicLoadObject(class'ChallengeHUD'.default.FontInfoClass, class'Class'))));
}

function DrawHeader( canvas Canvas )
{
	local GameReplicationInfo GRI;
	local float XL, YL;
	local font CanvasFont;

	Canvas.DrawColor = WhiteColor;
	GRI = PlayerPawn(Owner).GameReplicationInfo;

	Canvas.Font = MyFonts.GetHugeFont(B227_ScaledFontScreenWidth(Canvas));

	Canvas.bCenter = True;
	Canvas.StrLen("Test", XL, YL);
	ScoreStart = 58.0/768.0 * Canvas.ClipY;
	CanvasFont = Canvas.Font;
	if ( GRI.GameEndedComments != "" )
	{
		Canvas.DrawColor = GoldColor;
		Canvas.SetPos(0, ScoreStart);
		Canvas.DrawText(GRI.GameEndedComments, True);
	}
	else
	{
		Canvas.SetPos(0, ScoreStart);
		DrawVictoryConditions(Canvas);
	}
	Canvas.bCenter = False;
	Canvas.Font = CanvasFont;
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

	if ( TGRI.FragLimit > 0 )
	{
		Canvas.DrawText(FragGoal@TGRI.FragLimit);
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.CurY - YL);
	}

	if ( TGRI.TimeLimit > 0 )
		Canvas.DrawText(TimeLimit@TGRI.TimeLimit$":00");
}

function string TwoDigitString(int Num)
{
	if ( Num < 10 )
		return "0"$Num;
	else
		return string(Num);
}

function DrawTrailer( canvas Canvas )
{
	local int Hours, Minutes, Seconds;
	local float XL, YL;
	local PlayerPawn PlayerOwner;
	local string LevelTitle;

	Canvas.bCenter = true;
	Canvas.StrLen("Test", XL, YL);
	Canvas.DrawColor = WhiteColor;
	PlayerOwner = PlayerPawn(Owner);
	Canvas.SetPos(0, Canvas.ClipY - 2 * YL);

	if (Level.Title ~= class'LevelInfo'.default.Title)
		LevelTitle = string(Level.Outer.Name);
	else
		LevelTitle = Level.Title;

	if ( (Level.NetMode == NM_Standalone) && Level.Game.IsA('DeathMatchPlus') )
	{
		if ( DeathMatchPlus(Level.Game).bRatedGame )
			Canvas.DrawText(DeathMatchPlus(Level.Game).RatedGameLadderObj.SkillText@PlayerOwner.GameReplicationInfo.GameName@MapTitle@MapTitleQuote$LevelTitle$MapTitleQuote, true);
		else if ( DeathMatchPlus(Level.Game).bNoviceMode )
			Canvas.DrawText(class'ChallengeBotInfo'.static.B227_SkillString(Level.Game.Difficulty)@PlayerOwner.GameReplicationInfo.GameName@MapTitle@MapTitleQuote$LevelTitle$MapTitleQuote, true);
		else
			Canvas.DrawText(class'ChallengeBotInfo'.static.B227_SkillString(Level.Game.Difficulty + 4)@PlayerOwner.GameReplicationInfo.GameName@MapTitle@MapTitleQuote$LevelTitle$MapTitleQuote, true);
	}
	else
		Canvas.DrawText(PlayerOwner.GameReplicationInfo.GameName@MapTitle@LevelTitle, true);

	Canvas.SetPos(0, Canvas.ClipY - YL);

	if (UTC_GameReplicationInfo(PlayerOwner.GameReplicationInfo) != none &&
		UTC_GameReplicationInfo(PlayerOwner.GameReplicationInfo).B227_bSyncTime)
	{
		bTimeDown = UTC_GameReplicationInfo(PlayerOwner.GameReplicationInfo).B227_RemainingTime >= 0;
	}
	else if (!bTimeDown)
		bTimeDown = PlayerOwner.GameReplicationInfo.RemainingTime > 0;

	if (bTimeDown)
	{
		if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
			Canvas.DrawText(RemainingTime@"00:00", true);
		else
		{
			Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
			Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
			Canvas.DrawText(RemainingTime@TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
		}
	}
	else
	{
		Seconds = PlayerOwner.GameReplicationInfo.ElapsedTime;
		Minutes = Seconds / 60;
		Hours   = Minutes / 60;
		Seconds = Seconds - (Minutes * 60);
		Minutes = Minutes - (Hours * 60);
		Canvas.StrLen(ElapsedTime @ TwoDigitString(Hours) $ ":00:00", XL, YL);
		Canvas.bCenter = false;
		Canvas.SetPos((Canvas.SizeX - XL) / 2, Canvas.ClipY - YL);
		Canvas.DrawText(ElapsedTime @ TwoDigitString(Hours) $ ":" $ TwoDigitString(Minutes) $ ":" $ TwoDigitString(Seconds), true);
	}

	if ( PlayerOwner.GameReplicationInfo.GameEndedComments != "" )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		if ( Level.NetMode == NM_Standalone )
			Canvas.DrawText(Ended@Continue, true);
		else
			Canvas.DrawText(Ended, true);
	}
	else if ( (PlayerOwner != None) && (PlayerOwner.Health <= 0) )
	{
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL*6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		Canvas.DrawText(Restart, true);
	}
	Canvas.bCenter = false;
}

function DrawCategoryHeaders(Canvas Canvas)
{
	local float Offset, XL, YL, XL2;

	Offset = Canvas.CurY;
	Canvas.DrawColor = WhiteColor;

	Canvas.StrLen( "0000", XL, YL );

	Canvas.SetPos(B227_MarginLeft + B227_InnerWidth * 0.1875, Offset);
	Canvas.DrawText(PlayerString);

	Canvas.StrLen(FragsString, XL2, YL);
	Canvas.SetPos(B227_MarginLeft + B227_InnerWidth * 0.625 + XL * 0.5 - XL2, Offset);
	Canvas.DrawText(FragsString);

	Canvas.StrLen(DeathsString, XL2, YL);
	Canvas.SetPos(B227_MarginLeft + B227_InnerWidth * 0.75 + XL * 0.5 - XL2, Offset);
	Canvas.DrawText(DeathsString);
}

function DrawNameAndPing(Canvas Canvas, UTC_PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed)
{
	local float XL, YL, XL2, YL2, XL3, YL3;
	local bool bLocalPlayer;
	local int Time;

	if (B227_OwnerPRI() == none)
		return;

	bLocalPlayer = (PRI == B227_OwnerPRI());
	Canvas.Font = MyFonts.GetBigFont(B227_ScaledFontScreenWidth(Canvas));

	// Draw Name
	if ( PRI.bAdmin )
		Canvas.DrawColor = WhiteColor;
	else if ( bLocalPlayer )
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = CyanColor;

	Canvas.SetPos(B227_MarginLeft + B227_InnerWidth * 0.1875, YOffset);
	Canvas.DrawText(PRI.PlayerName, False);

	Canvas.StrLen( "0000", XL, YL );

	// Draw Score
	if ( !bLocalPlayer )
		Canvas.DrawColor = LightCyanColor;

	Canvas.StrLen( int(PRI.Score), XL2, YL );
	Canvas.SetPos( B227_MarginLeft + B227_InnerWidth * 0.625 + XL * 0.5 - XL2, YOffset );
	Canvas.DrawText( int(PRI.Score), false );

	// Draw Deaths
	Canvas.StrLen( int(PRI.Deaths), XL2, YL );
	Canvas.SetPos( B227_MarginLeft + B227_InnerWidth * 0.75 + XL * 0.5 - XL2, YOffset );
	Canvas.DrawText( int(PRI.Deaths), false );

	if ( (B227_InnerWidth > 512) && (Level.NetMode != NM_Standalone) )
	{
		Canvas.DrawColor = WhiteColor;
		Canvas.Font = MyFonts.GetSmallestFont(B227_ScaledFontScreenWidth(Canvas));

		// Draw Time
		Time = Max(1, (Level.TimeSeconds + B227_OwnerPRI().StartTime - PRI.StartTime)/60);
		Canvas.TextSize( TimeString$": 999", XL3, YL3 );
		Canvas.SetPos( B227_MarginLeft + B227_InnerWidth * 0.75 + XL, YOffset );
		Canvas.DrawText( TimeString$":"@Time, false );

		// Draw FPH
		Canvas.TextSize( FPHString$": 999", XL2, YL2 );
		Canvas.SetPos( B227_MarginLeft + B227_InnerWidth * 0.75 + XL, YOffset + 0.5 * YL );
		Canvas.DrawText( FPHString$": "@int(60 * PRI.Score/Time), false );

		XL3 = FMax(XL3, XL2);
		// Draw Ping
		Canvas.SetPos( B227_MarginLeft + B227_InnerWidth * 0.75 + XL + XL3 + 16, YOffset );
		Canvas.DrawText( PingString$":"@PRI.Ping, false );
	}
}

function SortScores(int N)
{
	local int I, J, Max;
	local UTC_PlayerReplicationInfo TempPRI;

	for ( I=0; I<N-1; I++ )
	{
		Max = I;
		for ( J=I+1; J<N; J++ )
		{
			if ( Ordered[J].Score > Ordered[Max].Score )
				Max = J;
			else if ((Ordered[J].Score == Ordered[Max].Score) && (Ordered[J].Deaths < Ordered[Max].Deaths))
				Max = J;
			else if ((Ordered[J].Score == Ordered[Max].Score) && (Ordered[J].Deaths == Ordered[Max].Deaths) &&
					 (Ordered[J].PlayerID < Ordered[Max].PlayerID))
				Max = J;
		}

		TempPRI = Ordered[Max];
		Ordered[Max] = Ordered[I];
		Ordered[I] = TempPRI;
	}
}

function ShowScores( canvas Canvas )
{
	local UTC_PlayerReplicationInfo PRI;
	local int PlayerCount, i;
	local float XL, YL;
	local float YOffset, YStart;
	local font CanvasFont;

	Canvas.Style = ERenderStyle.STY_Normal;

	// Header
	Canvas.SetPos(0, 0);
	DrawHeader(Canvas);

	// Wipe everything.
	for ( i=0; i<ArrayCount(Ordered); i++ )
		Ordered[i] = None;
	foreach AllActors(class'UTC_PlayerReplicationInfo', PRI)
		if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
		{
			Ordered[PlayerCount] = PRI;
			PlayerCount++;
			if (PlayerCount == ArrayCount(Ordered))
				break;
		}

	SortScores(PlayerCount);

	CanvasFont = Canvas.Font;
	Canvas.Font = MyFonts.GetBigFont(B227_ScaledFontScreenWidth(Canvas));

	B227_InnerWidth = B227_ScaledScreenWidth(Canvas);
	B227_MarginLeft = (Canvas.SizeX - B227_InnerWidth) / 2;

	Canvas.SetPos(0, 160.0/768.0 * Canvas.ClipY);
	DrawCategoryHeaders(Canvas);

	Canvas.StrLen( "TEST", XL, YL );
	YStart = Canvas.CurY;
	YOffset = YStart;
	if ( PlayerCount > 15 )
		PlayerCount = FMin(PlayerCount, (Canvas.ClipY - YStart)/YL - 1);

	Canvas.SetPos(0, 0);
	for ( I=0; I<PlayerCount; I++ )
	{
		YOffset = YStart + I * YL;
		DrawNameAndPing( Canvas, Ordered[I], 0, YOffset, false );
	}
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = CanvasFont;

	// Trailer
	if (!B227_bLowRes(Canvas))
	{
		Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
		DrawTrailer(Canvas);
	}
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = CanvasFont;
}

// Auxiliary
function UTC_PlayerReplicationInfo B227_OwnerPRI()
{
	return UTC_PlayerReplicationInfo(Pawn(Owner).PlayerReplicationInfo);
}

function TournamentGameReplicationInfo B227_GRI()
{
	return TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
}

function bool B227_bLowRes(Canvas Canvas)
{
	return Canvas.ClipX < 400 || Canvas.ClipY < 300;
}

static function float B227_ScaledScreenWidth(Canvas Canvas)
{
	return class'ChallengeHUD'.static.B227_ScaledScreenWidth(Canvas);
}

static function float B227_ScaledFontScreenWidth(Canvas Canvas)
{
	return class'UTC_HUD'.static.B227_ScaledFontScreenWidth(Canvas);
}

defaultproperties
{
	MapTitle="in"
	Author="by"
	Restart="You are dead.  Hit [Fire] to respawn!"
	Continue=" Hit [Fire] to continue!"
	Ended="The match has ended."
	ElapsedTime="Elapsed Time: "
	RemainingTime="Remaining Time: "
	FragGoal="Frag Limit:"
	TimeLimit="Time Limit:"
	PlayerString="Player"
	FragsString="Frags"
	DeathsString="Deaths"
	PingString="Ping"
	TimeString="Time"
	LossString="Loss"
	FPHString="FPH"
	GreenColor=(G=255)
	WhiteColor=(R=255,G=255,B=255)
	GoldColor=(R=255,G=255)
	BlueColor=(B=255)
	LightCyanColor=(R=128,G=255,B=255)
	SilverColor=(R=138,G=164,B=166)
	BronzeColor=(R=203,G=147,B=52)
	CyanColor=(G=128,B=255)
	RedColor=(R=255)
}
