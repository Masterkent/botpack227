class UTRulesCWindow extends UMenuGameRulesBase;

// Tourney
var UWindowCheckbox TourneyCheck;
var localized string TourneyText;
var localized string TourneyHelp;

var UWindowCheckbox ForceRespawnCheck;
var localized string ForceRespawnText;
var localized string ForceRespawnHelp;

// 227i's UMenuGameRulesBase.Created()
function B227_Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");

	// Frag Limit
	FragEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	FragEdit.SetText(FragText);
	FragEdit.SetHelpText(FragHelp);
	FragEdit.SetFont(F_Normal);
	FragEdit.SetNumericOnly(True);
	FragEdit.SetMaxLength(3);
	FragEdit.Align = TA_Right;

	// Time Limit
	TimeEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	TimeEdit.SetText(TimeText);
	TimeEdit.SetHelpText(TimeHelp);
	TimeEdit.SetFont(F_Normal);
	TimeEdit.SetNumericOnly(True);
	TimeEdit.SetMaxLength(3);
	TimeEdit.Align = TA_Right;
	ControlOffset += 25;

	// WeaponsStay
	WeaponsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	WeaponsCheck.SetText(WeaponsText);
	WeaponsCheck.SetHelpText(WeaponsHelp);
	WeaponsCheck.SetFont(F_Normal);
	WeaponsCheck.bChecked = BotmatchParent.GameClass.Default.bCoopWeaponMode;
	WeaponsCheck.Align = TA_Right;
	ControlOffset += 25;

	SetupNetworkOptions();
}

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	B227_Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	// Tourney
	TourneyCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, WeaponsCheck.WinTop, ControlWidth, 1));
	TourneyCheck.SetText(TourneyText);
	TourneyCheck.SetHelpText(TourneyHelp);
	TourneyCheck.SetFont(F_Normal);
	TourneyCheck.Align = TA_Right;
}

function SetupNetworkOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;

	Super.SetupNetworkOptions();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	if(BotmatchParent.bNetworkGame && !ClassIsChildOf( BotmatchParent.GameClass, class'LastManStanding'))
	{
		ForceRespawnCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		ForceRespawnCheck.SetText(ForceRespawnText);
		ForceRespawnCheck.SetHelpText(ForceRespawnHelp);
		ForceRespawnCheck.SetFont(F_Normal);
		ForceRespawnCheck.Align = TA_Right;
		ControlOffset += 25;
	}
}


// replaces UMenuGameRulesCWindow's version
function LoadCurrentValues()
{
	FragEdit.SetValue(string(Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.FragLimit));

	TimeEdit.SetValue(string(Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.TimeLimit));

	if(MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue(string(Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxPlayers));

	if(MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.SetValue(string(Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxSpectators));

	if(BotmatchParent.bNetworkGame)
		WeaponsCheck.bChecked = Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bMultiWeaponStay;
	else
		WeaponsCheck.bChecked = Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bCoopWeaponMode;

	TourneyCheck.bChecked = Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bTournament;

	if(ForceRespawnCheck != None)
		ForceRespawnCheck.bChecked = Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bForceRespawn;
}

// 227i's UMenuGameRulesBase.BeforePaint
function B227_BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	FragEdit.SetSize(ControlWidth, 1);
	FragEdit.WinLeft = ControlLeft;
	FragEdit.EditBoxWidth = 25;

	TimeEdit.SetSize(ControlWidth, 1);
	TimeEdit.WinLeft = ControlRight;
	TimeEdit.EditBoxWidth = 25;

	if (MaxPlayersEdit != None)
	{
		MaxPlayersEdit.SetSize(ControlWidth, 1);
		MaxPlayersEdit.WinLeft = ControlLeft;
		MaxPlayersEdit.EditBoxWidth = 25;
	}

	if (MaxSpectatorsEdit != None)
	{
		MaxSpectatorsEdit.SetSize(ControlWidth, 1);
		MaxSpectatorsEdit.WinLeft = ControlRight;
		MaxSpectatorsEdit.EditBoxWidth = 25;
	}

	WeaponsCheck.SetSize(ControlWidth, 1);
	WeaponsCheck.WinLeft = ControlLeft;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;

	B227_BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	TourneyCheck.SetSize(ControlWidth, 1);
	TourneyCheck.WinLeft = ControlRight;

	if(ForceRespawnCheck != None)
	{
		ForceRespawnCheck.SetSize(ControlWidth, 1);
		ForceRespawnCheck.WinLeft = ControlLeft;
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case TourneyCheck:
			TourneyChanged();
			break;
		case ForceRespawnCheck:
			ForceRespawnChanged();
			break;
		}
	}
}

function TourneyChanged()
{
	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bTournament = TourneyCheck.bChecked;
}

function ForceRespawnChanged()
{
	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bForceRespawn = ForceRespawnCheck.bChecked;
}

// replaces UMenuGameRulesCWindow's version
function FragChanged()
{
	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.FragLimit = int(FragEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function TimeChanged()
{
	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.TimeLimit = int(TimeEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function MaxPlayersChanged()
{
	if(int(MaxPlayersEdit.GetValue()) > 16)
		MaxPlayersEdit.SetValue("16");
	if(int(MaxPlayersEdit.GetValue()) < 1)
		MaxPlayersEdit.SetValue("1");

	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
}

function MaxSpectatorsChanged()
{
	if(int(MaxSpectatorsEdit.GetValue()) > 16)
		MaxSpectatorsEdit.SetValue("16");

	if(int(MaxSpectatorsEdit.GetValue()) < 0)
		MaxSpectatorsEdit.SetValue("0");

	Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.MaxSpectators = int(MaxSpectatorsEdit.GetValue());
}

// replaces UMenuGameRulesCWindow's version
function WeaponsChecked()
{
	if(BotmatchParent.bNetworkGame)
		Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bMultiWeaponStay = WeaponsCheck.bChecked;
	else
		Class<DeathMatchPlus>(BotmatchParent.GameClass).Default.bCoopWeaponMode = WeaponsCheck.bChecked;
}

function SaveConfigs()
{
	Super.SaveConfigs();
	BotmatchParent.GameClass.static.StaticSaveConfig();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
     TourneyText="Tournament"
     TourneyHelp="If checked, each player must indicate they are ready by clicking their fire button before the match begins."
     ForceRespawnText="Force Respawn"
     ForceRespawnHelp="If checked, players will be automatically respawned when they die, without waiting for the user to press Fire."
}
