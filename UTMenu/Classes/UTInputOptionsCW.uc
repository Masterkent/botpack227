class UTInputOptionsCW expands UMenuInputOptionsClientWindow;

// Instant Rocket
var UWindowCheckbox	InstantRocketCheck;
var localized string InstantRocketText;
var localized string InstantRocketHelp;

// Speech Binder Button
var UWindowSmallButton SpeechBinderButton;
var localized string SpeechBinderText;
var localized string SpeechBinderHelp;
var localized string B227_NoVoicePackText;

var bool B227_bModernLayout;

function Created()
{
	local int ControlWidth, ControlLeft;
	local bool bInstantRocket;

	Super.Created();

	DesiredWidth = 220;
	DesiredHeight = 180;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlOffset += 25;

	if (TournamentPlayer(GetPlayerOwner()) != none)
		bInstantRocket = TournamentPlayer(GetPlayerOwner()).bInstantRocket;
	else
		bInstantRocket = class'TournamentPlayer'.default.bInstantRocket;
	InstantRocketCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	InstantRocketCheck.bChecked = TournamentPlayer(GetPlayerOwner()).bInstantRocket;
	InstantRocketCheck.SetText(InstantRocketText);
	InstantRocketCheck.SetHelpText(InstantRocketHelp);
	InstantRocketCheck.SetFont(F_Normal);
	InstantRocketCheck.Align = TA_Right;

	ControlOffset += 25;
	SpeechBinderButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ControlLeft, ControlOffset, 48, 16));
	SpeechBinderButton.SetText(SpeechBinderText);
	SpeechBinderButton.SetHelpText(SpeechBinderHelp);

	B227_bModernLayout = DynamicLoadObject("UMenu.UMenuInputOptionsClientWindow.DodgeClickTimeEdit", class'Object', true) != none;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if (B227_bModernLayout)
		B227_SetCheckBoxAutoWidth(InstantRocketCheck, C, 20);
	else
		InstantRocketCheck.SetSize(ControlWidth, 1);
	InstantRocketCheck.WinLeft = ControlLeft;

	SpeechBinderButton.AutoWidth(C);
	SpeechBinderButton.WinLeft = (WinWidth - SpeechBinderButton.WinWidth) / 2;

	Super.BeforePaint(C, X, Y);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			case InstantRocketCheck:
				InstantRocketChanged();
				break;
		}
		break;
	case DE_Click:
		switch (C)
		{
			case SpeechBinderButton:
				if (class<ChallengeVoicePack>(GetPlayerOwner().PlayerReplicationInfo.VoiceType) != none)
					Root.CreateWindow(class'SpeechBinderWindow', 100, 100, 100, 100);
				else
					MessageBox(SpeechBinderText, B227_NoVoicePackText, MB_OK, MR_OK);
				break;
		}
		break;
	}
}

function InstantRocketChanged()
{
	if (TournamentPlayer(GetPlayerOwner()) != none)
	{
		TournamentPlayer(GetPlayerOwner()).SetInstantRocket(InstantRocketCheck.bChecked);
		GetPlayerOwner().SaveConfig();
	}
	else
	{
		class'TournamentPlayer'.default.bInstantRocket = InstantRocketCheck.bChecked;
		class'TournamentPlayer'.static.StaticSaveConfig();
	}
}

function B227_SetCheckBoxAutoWidth(UWindowCheckbox CheckBox, Canvas C, float DesiredTextOffset)
{
	local float TextWidth, TextHeight;

	C.Font = CheckBox.Root.Fonts[CheckBox.Font];
	CheckBox.TextSize(C, CheckBox.Text, TextWidth, TextHeight);
	CheckBox.WinWidth = DesiredTextOffset + TextWidth;
}

defaultproperties
{
	InstantRocketText="Instant Rocket Fire"
	InstantRocketHelp="Make the Rocket Launcher fire rockets instantly, rather than charging up multiple rockets."
	SpeechBinderText="Speech Binder"
	SpeechBinderHelp="Use this special window to bind taunts and orders to keys."
	B227_NoVoicePackText="You don't have a voice pack in the current game."
}
