//=============================================================================
// ChallengeTeamHUD
//=============================================================================
class ChallengeTeamHUD extends ChallengeHUD;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var Texture TeamIcon[4];
var() color TeamColor[4];
var() color AltTeamColor[4];

var() name OrderNames[16];
var() int NumOrders;

simulated function HUDSetup(canvas canvas)
{
	Super.HUDSetup(canvas);
	if ( bUseTeamColor && (PawnOwner.PlayerReplicationInfo != None)
		&& (PawnOwner.PlayerReplicationInfo.Team < 4) )
	{
		HUDColor = TeamColor[PawnOwner.PlayerReplicationInfo.Team];
		SolidHUDColor = HUDColor;
		if ( Level.bHighDetailMode )
			HUDColor = B227_MultiplyColor(HUDColor, Opacity * 0.0625);
	}
}

simulated function DrawGameSynopsis(Canvas Canvas)
{
	local TournamentGameReplicationInfo GRI;
	local int i;

	GRI = TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	if ( GRI != None )
		for ( i=0 ;i<4; i++ )
			DrawTeam(Canvas, GRI.Teams[i]);
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	local float XL, YL;

	if ( (TI != None) && (TI.Size > 0) )
	{
		Canvas.Font = MyFonts.GetHugeFont(B227_ScaledFontScreenWidth(Canvas));
		Canvas.DrawColor = TeamColor[TI.TeamIndex];
		Canvas.SetPos(Canvas.ClipX - 64 * Scale, Canvas.ClipY - (336 + 128 * TI.TeamIndex) * Scale);
		Canvas.DrawIcon(TeamIcon[TI.TeamIndex], Scale);
		Canvas.StrLen(int(TI.Score), XL, YL);
		Canvas.SetPos(Canvas.ClipX - XL - 66 * Scale, Canvas.ClipY - (336 + 128 * TI.TeamIndex) * Scale + ((64 * Scale) - YL)/2 );
		Canvas.DrawText(int(TI.Score), false);
	}
}

// Entry point for string messages.
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	// TeamSay messages are handled in B227_HandleTeamSayMessage
	super.Message(PRI, Msg, MsgType);
}

simulated function SetIDColor( Canvas Canvas, int type )
{
	if (IdentifyTarget.Team == 255)
		Canvas.DrawColor = B227_MultiplyColor(WhiteColor, 0.333 * IdentifyFadeTime);
	else if ( type == 0 )
		Canvas.DrawColor = B227_MultiplyColor(AltTeamColor[IdentifyTarget.Team], 0.333 * IdentifyFadeTime);
	else
		Canvas.DrawColor = B227_MultiplyColor(TeamColor[IdentifyTarget.Team], 0.333 * IdentifyFadeTime);
}

simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local float XL, YL;
	local Pawn P;

	if ( !Super.DrawIdentifyInfo(Canvas) )
		return false;

	Canvas.StrLen("TEST", XL, YL);
	if( PawnOwner.PlayerReplicationInfo.Team == IdentifyTarget.Team )
	{
		P = Pawn(IdentifyTarget.Owner);
		Canvas.Font = MyFonts.GetSmallFont(B227_ScaledFontScreenWidth(Canvas));
		if ( P != None )
			DrawTwoColorID(Canvas,IdentifyHealth,string(P.Health), (Canvas.ClipY - 256 * Scale) + 1.5 * YL);
	}
	return true;
}

function DrawTalkFace(Canvas Canvas, int i, float YPos)
{
	if ( !bHideHUD && (PawnOwner.PlayerReplicationInfo != None) && !PawnOwner.PlayerReplicationInfo.bIsSpectator )
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(FaceAreaOffset, 0);
		Canvas.DrawColor = FaceTeam;
		Canvas.DrawTile(texture'Botpack.LadrStatic.Static.Static_a00', YPos + 7*Scale, YPos + 7*Scale, 0, 0, texture'FacePanel1'.USize, texture'FacePanel1'.VSize);
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(FaceAreaOffset + 4*Scale, 4*Scale);
		Canvas.DrawTile(FaceTexture, YPos - 1*Scale, YPos - 1*Scale, 0, 0, FaceTexture.USize, FaceTexture.VSize);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = FaceColor;
		Canvas.SetPos(FaceAreaOffset, 0);
		Canvas.DrawTile(texture'Botpack.LadrStatic.Static.Static_a00', YPos + 7*Scale, YPos + 7*Scale, 0, 0, texture'Botpack.LadrStatic.Static.Static_a00'.USize, texture'Botpack.LadrStatic.Static.Static_a00'.VSize);
		Canvas.DrawColor = WhiteColor;
	}
}

function B227_HandleTeamSayMessage(PlayerReplicationInfo PRI, out class<LocalMessage> MessageClass)
{
	MessageClass = class'TeamSayMessagePlus';
	if (PRI.Team < 4)
		FaceTeam = TeamColor[PRI.Team];
	else
		FaceTeam = FavoriteHUDColor;
}

defaultproperties
{
	TeamIcon(0)=Texture'Botpack.Icons.I_TeamR'
	TeamIcon(1)=Texture'Botpack.Icons.I_TeamB'
	TeamIcon(2)=Texture'Botpack.Icons.I_TeamG'
	TeamIcon(3)=Texture'Botpack.Icons.I_TeamY'
	TeamColor(0)=(R=255)
	TeamColor(1)=(G=128,B=255)
	TeamColor(2)=(G=255)
	TeamColor(3)=(R=255,G=255)
	AltTeamColor(0)=(R=200)
	AltTeamColor(1)=(G=94,B=187)
	AltTeamColor(2)=(G=128)
	AltTeamColor(3)=(R=255,G=255,B=128)
	OrderNames(0)=Defend
	OrderNames(1)=Hold
	OrderNames(2)=Attack
	OrderNames(3)=Follow
	OrderNames(4)=Freelance
	OrderNames(5)=Point
	OrderNames(10)=Attack
	OrderNames(11)=Freelance
	NumOrders=5
	ServerInfoClass=Class'Botpack.ServerInfoTeam'
}
