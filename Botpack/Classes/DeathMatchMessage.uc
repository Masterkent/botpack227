//
// Messages common to DeathMatchPlus derivatives.
//
// Switch 0: OverTime
//
// Switch 1: Entered game.
//	RelatedPRI_1 is the player.
//
// Switch 2: Name change.
//	RelatedPRI_1 is the player.
//
// Switch 3: Team change.
//	RelatedPRI_1 is the player.
//	OptionalObject is a TeamInfo.
//
// Switch 4: Left game.
//	RelatedPRI_1 is the player.


class DeathMatchMessage expands CriticalEventPlus;

var localized string OvertimeMessage;
var localized string GlobalNameChange;
var localized string NewTeamMessage;
var localized string NewTeamMessageTrailer;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (default.B227_bHasRelatedContext)
		return B227_GetString(Switch);

	switch (Switch)
	{
		case 0:
			return Default.OverTimeMessage;
			break;
		case 1:
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.PlayerName$class'GameInfo'.Default.EnteredMessage;
			break;
		case 2:
			if (UTC_PlayerReplicationInfo(RelatedPRI_1) == none)
				return "";

			return UTC_PlayerReplicationInfo(RelatedPRI_1).OldName @ default.GlobalNameChange @ RelatedPRI_1.PlayerName;
			break;
		case 3:
			if (RelatedPRI_1 == None)
				return "";
			if (OptionalObject == None)
				return "";

			return RelatedPRI_1.PlayerName@Default.NewTeamMessage@TeamInfo(OptionalObject).TeamName$Default.NewTeamMessageTrailer;
			break;
		case 4:
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.PlayerName$class'GameInfo'.Default.LeftMessage;
			break;
	}
	return "";
}

static function string B227_GetString(optional int Switch)
{
	switch (Switch)
	{
		case 0:
			return default.OverTimeMessage;
		case 1:
			if (Len(default.B227_RelatedPawnInfo_1) == 0)
				return "";
			return default.B227_RelatedPawnInfo_1 $ class'GameInfo'.default.EnteredMessage;
		case 2:
			if (Len(default.B227_RelatedPawnInfo_1) == 0 || Len(default.B227_RelatedPawnInfo_2) == 0)
				return "";
			return default.B227_RelatedPawnInfo_1 @ default.GlobalNameChange @ default.B227_RelatedPawnInfo_2;
		case 3:
			if (Len(default.B227_RelatedPawnInfo_1) == 0 || Len(default.B227_RelatedInfo) == 0)
				return "";
			return default.B227_RelatedPawnInfo_1 @ default.NewTeamMessage @ default.B227_RelatedInfo $ default.NewTeamMessageTrailer;
		case 4:
			if (Len(default.B227_RelatedPawnInfo_1) == 0)
				return "";
			return default.B227_RelatedPawnInfo_1 $ class'GameInfo'.default.LeftMessage;
	}
	return "";
}

defaultproperties
{
	OvertimeMessage="Score tied at the end of regulation. Sudden Death Overtime!!!"
	GlobalNameChange="changed name to"
	NewTeamMessage="is now on"
}
