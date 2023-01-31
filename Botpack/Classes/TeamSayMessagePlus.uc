class TeamSayMessagePlus expands StringMessagePlus;

var Color B227_YellowColor;

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return;

	if (class'B227_Config'.default.bEnableExtensions && class'B227_Config'.default.bYellowTeamSayMessages)
		Canvas.DrawColor = default.B227_YellowColor;
	else
		Canvas.DrawColor = default.GreenColor;
	Canvas.DrawText(RelatedPRI_1.PlayerName $ " ", false);
	Canvas.SetPos(Canvas.CurX, Canvas.CurY - YL);
	if (UTC_PlayerReplicationInfo(RelatedPRI_1) != none && UTC_PlayerReplicationInfo(RelatedPRI_1).PlayerLocation != none)
		LocationName = UTC_PlayerReplicationInfo(RelatedPRI_1).PlayerLocation.LocationName;
	else if (RelatedPRI_1.PlayerZone != none)
		Locationname = RelatedPRI_1.PlayerZone.ZoneName;

	if (LocationName != "")
	{
		Canvas.DrawColor = default.CyanColor;
		Canvas.DrawText(" ("$LocationName$"): ", false);
	}
	else
		Canvas.DrawText(": ", false);
	Canvas.SetPos(Canvas.CurX, Canvas.CurY - YL);
	Canvas.DrawColor = default.LightGreenColor;
	Canvas.DrawText(MessageString, false);
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	local string LocationName;

	if (RelatedPRI_1 == none)
		return "";
	if (UTC_PlayerReplicationInfo(RelatedPRI_1) != none && UTC_PlayerReplicationInfo(RelatedPRI_1).PlayerLocation != none)
		LocationName = UTC_PlayerReplicationInfo(RelatedPRI_1).PlayerLocation.LocationName;
	else if (RelatedPRI_1.PlayerZone != none)
		LocationName = RelatedPRI_1.PlayerZone.ZoneName;
	if (Locationname == "")
		return RelatedPRI_1.PlayerName @ ": " $ MessageString;
	else
		return RelatedPRI_1.PlayerName $ "  (" $ LocationName $ "): " $ MessageString;
}

defaultproperties
{
	bComplexString=True
	DrawColor=(B=0)
	B227_YellowColor=(R=255,G=255)
}
