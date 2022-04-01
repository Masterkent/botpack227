class B227_SpeechMiniDisplay expands UWindowWindow;

var B227_Speech_UTFadeTextArea DisplayArea;

var string ArrowString;
var localized string NameString;
var localized string OrdersString;
var localized string LocationString;
var localized string HumanString;

var int TeamID;
var string Callsign;
var string LocationName;
var string OrderStr;

function Created()
{
	Super.Created();

	DisplayArea = B227_Speech_UTFadeTextArea(CreateWindow(class'B227_Speech_UTFadeTextArea', 100, 100, 100, 100));
	DisplayArea.MyFont = class'B227_SpeechMenuWindow'.static.GetSmallFont(Root);
	DisplayArea.TextColor.R = 255;
	DisplayArea.TextColor.G = 255;
	DisplayArea.TextColor.B = 255;
	DisplayArea.FadeFactor = 6;
	DisplayArea.bMousePassThrough = True;

	TeamID = -1;
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	DisplayArea.WinWidth = WinWidth;
	DisplayArea.WinHeight = WinHeight;
	DisplayArea.WinLeft = 0;
	DisplayArea.WinTop = 0;
}

function Reset()
{
	if (TeamID >= 0)
		DisplayArea.Clear();
	TeamID = -1;
}

function bool UpdateInfo(int TeamID, string Callsign)
{
	local TournamentGameReplicationInfo TRI;
	local UTC_PlayerReplicationInfo PRI;
	local string S;
	local bool bResult;

	bResult = self.TeamID != TeamID;
	self.TeamID = TeamID;

	foreach GetPlayerOwner().AllActors(class'UTC_PlayerReplicationInfo', PRI)
	{
		if (PRI.TeamID == TeamID &&
			PRI.Team == GetPlayerOwner().PlayerReplicationInfo.Team)
		{
			bResult = bResult || self.Callsign != Callsign;
			self.Callsign = Callsign;

			if ( PRI.PlayerLocation != None )
				S = PRI.PlayerLocation.LocationName;
			else if ( PRI.PlayerZone != None )
				S = PRI.PlayerZone.ZoneName;
			else
				S = "";

			bResult = bResult || LocationName != S;
			LocationName = S;

			TRI = TournamentGameReplicationInfo(GetPlayerOwner().GameReplicationInfo);
			if (TRI != None)
			{
				if ( PRI.IsA('BotReplicationInfo') )
					S = TRI.GetOrderString(PRI);
				else
					S = HumanString;
			}
			else
				S = "";

			bResult = bResult || OrderStr != S;
			OrderStr = S;

			return bResult;
		}
	}
	return false;
}

function UpdateDisplayedInfo()
{
	DisplayArea.Clear();

	DisplayArea.AddText(ArrowString @ Callsign);
	if (Len(LocationName) > 0)
		DisplayArea.AddText(LocationString @ LocationName);
	if (Len(OrderStr) > 0)
		DisplayArea.AddText(OrdersString @ OrderStr);
}

defaultproperties
{
     ArrowString="<<<"
     NameString="Name:"
     OrdersString="Orders:"
     LocationString="Location:"
     HumanString="None <Human>"
}
