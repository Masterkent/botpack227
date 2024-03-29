class UTAudioClientWindow expands UMenuAudioClientWindow;

var UWindowHSliderControl AnnouncerVolumeSlider;
var localized string AnnouncerVolumeText;
var localized string AnnouncerVolumeHelp;

var UWindowCheckbox AutoTauntCheck;
var localized string AutoTauntText;
var localized string AutoTauntHelp;

var UWindowCheckbox Use3DHardwareCheck;
var localized string Use3DHardwareText;
var localized string Use3DHardwareHelp;

var UWindowCheckbox UseSurroundSoundCheck;
var localized string UseSurroundSoundText;
var localized string UseSurroundSoundHelp;

var UWindowComboControl MessageSettingsCombo;
var localized string MessageSettingsText;
var localized string MessageSettingsHelp;
var localized string MessageSettings[4];

var UWindowMessageBox ConfirmHardware;
var localized string ConfirmHardwareTitle;
var localized string ConfirmHardwareText;

var UWindowMessageBox ConfirmSurround;
var localized string ConfirmSurroundTitle;
var localized string ConfirmSurroundText;

var UWindowCheckbox NoMatureLanguageCheck;
var localized string NoMatureLanguageText;
var localized string NoMatureLanguageHelp;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local TournamentPlayer P;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	P = TournamentPlayer(GetPlayerOwner());

	MessageSettingsCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	MessageSettingsCombo.SetText(MessageSettingsText);
	MessageSettingsCombo.SetHelpText(MessageSettingsHelp);
	MessageSettingsCombo.SetFont(F_Normal);
	MessageSettingsCombo.SetEditable(False);
	MessageSettingsCombo.AddItem(MessageSettings[0]);
	MessageSettingsCombo.AddItem(MessageSettings[1]);
	MessageSettingsCombo.AddItem(MessageSettings[2]);
	MessageSettingsCombo.AddItem(MessageSettings[3]);
	if (P != none)
	{
		if (P.bNoVoiceMessages)
			MessageSettingsCombo.SetSelectedIndex(3);
		else if (P.bNoVoiceTaunts)
			MessageSettingsCombo.SetSelectedIndex(2);
		else if (P.bNoAutoTaunts)
			MessageSettingsCombo.SetSelectedIndex(1);
		else
			MessageSettingsCombo.SetSelectedIndex(0);
	}
	else if (class'TournamentPlayer'.default.bNoVoiceMessages)
		MessageSettingsCombo.SetSelectedIndex(3);
	else if (class'TournamentPlayer'.default.bNoVoiceTaunts)
		MessageSettingsCombo.SetSelectedIndex(2);
	else if (class'TournamentPlayer'.default.bNoAutoTaunts)
		MessageSettingsCombo.SetSelectedIndex(1);
	else
		MessageSettingsCombo.SetSelectedIndex(0);
	ControlOffset += 25;

	NoMatureLanguageCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	NoMatureLanguageCheck.bChecked = class'TournamentPlayer'.default.bNoMatureLanguage;
	NoMatureLanguageCheck.SetText(NoMatureLanguageText);
	NoMatureLanguageCheck.SetHelpText(NoMatureLanguageHelp);
	NoMatureLanguageCheck.SetFont(F_Normal);
	NoMatureLanguageCheck.Align = TA_Left;
	ControlOffset += 25;

	// Announcer Volume
	AnnouncerVolumeSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	AnnouncerVolumeSlider.SetRange(0, 4, 1);
	if (P != none)
		AnnouncerVolumeSlider.SetValue(P.AnnouncerVolume);
	else
		AnnouncerVolumeSlider.SetValue(class'TournamentPlayer'.default.AnnouncerVolume);
	AnnouncerVolumeSlider.SetText(AnnouncerVolumeText);
	AnnouncerVolumeSlider.SetHelpText(AnnouncerVolumeHelp);
	AnnouncerVolumeSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// 3DHardware.
	Use3DHardwareCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	Use3DHardwareCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3dHardware"));
	Use3DHardwareCheck.SetText(Use3DHardwareText);
	Use3DHardwareCheck.SetHelpText(Use3DHardwareHelp);
	Use3DHardwareCheck.SetFont(F_Normal);
	Use3DHardwareCheck.Align = TA_Left;
	ControlOffset += 25;

	// Surround Sound.
	UseSurroundSoundCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	UseSurroundSoundCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.AudioDevice UseSurround"));
	UseSurroundSoundCheck.SetText(UseSurroundSoundText);
	UseSurroundSoundCheck.SetHelpText(UseSurroundSoundHelp);
	UseSurroundSoundCheck.SetFont(F_Normal);
	UseSurroundSoundCheck.Align = TA_Left;
	ControlOffset += 25;
}

function ExtraMessageOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.ExtraMessageOptions();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	VoiceMessagesCheck.HideWindow();

	AutoTauntCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, VoiceMessagesCheck.WinTop, CenterWidth, 1));
	if (TournamentPlayer(GetPlayerOwner()) != none)
		AutoTauntCheck.bChecked = TournamentPlayer(GetPlayerOwner()).bAutoTaunt;
	else
		AutoTauntCheck.bChecked = class'TournamentPlayer'.default.bAutoTaunt;
	AutoTauntCheck.SetText(AutoTauntText);
	AutoTauntCheck.SetHelpText(AutoTauntHelp);
	AutoTauntCheck.SetFont(F_Normal);
	AutoTauntCheck.Align = TA_Left;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	AutoTauntCheck.SetSize(MessageBeepCheck.WinWidth, 1);
	AutoTauntCheck.WinLeft = MessageBeepCheck.WinLeft;

	AnnouncerVolumeSlider.SetSize(SoundVolumeSlider.WinWidth, 1);
	AnnouncerVolumeSlider.SliderWidth = SoundVolumeSlider.SliderWidth;
	AnnouncerVolumeSlider.WinLeft = SoundVolumeSlider.WinLeft;

	MessageSettingsCombo.SetSize(SoundVolumeSlider.WinWidth, 1);
	MessageSettingsCombo.WinLeft = SoundVolumeSlider.WinLeft;
	MessageSettingsCombo.EditBoxWidth = SoundVolumeSlider.SliderWidth;

	Use3DHardwareCheck.SetSize(AutoTauntCheck.WinWidth, 1);
	Use3DHardwareCheck.WinLeft = AutoTauntCheck.WinLeft;

	UseSurroundSoundCheck.SetSize(AutoTauntCheck.WinWidth, 1);
	UseSurroundSoundCheck.WinLeft = AutoTauntCheck.WinLeft;

	NoMatureLanguageCheck.SetSize(AutoTauntCheck.WinWidth, 1);
	NoMatureLanguageCheck.WinLeft = AutoTauntCheck.WinLeft;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case AutoTauntCheck:
			AutoTauntChecked();
			break;
		case AnnouncerVolumeSlider:
			AnnouncerVolumeChanged();
			break;
		case MessageSettingsCombo:
			MessageSettingsChanged();
			break;
		case Use3DHardwareCheck:
			Hardware3DChecked();
			break;
		case UseSurroundSoundCheck:
			SurroundSoundChecked();
			break;
		case NoMatureLanguageCheck:
			NoMatureLanguageChanged();
			break;
		}
	}
}

function MessageSettingsChanged()
{
	local TournamentPlayer P;
	P = TournamentPlayer(GetPlayerOwner());

	switch(MessageSettingsCombo.GetSelectedIndex())
	{
	case 1:
		class'TournamentPlayer'.default.bNoVoiceMessages = false;
		class'TournamentPlayer'.default.bNoVoiceTaunts = false;
		class'TournamentPlayer'.default.bNoAutoTaunts = true;
		if (P != none)
		{
			P.bNoVoiceMessages = False;
			P.bNoVoiceTaunts = False;
			P.bNoAutoTaunts = True;
		}
		break;
	case 2:
		class'TournamentPlayer'.default.bNoVoiceMessages = false;
		class'TournamentPlayer'.default.bNoVoiceTaunts = true;
		class'TournamentPlayer'.default.bNoAutoTaunts = true;
		if (P != none)
		{
			P.bNoVoiceMessages = False;
			P.bNoVoiceTaunts = True;
			P.bNoAutoTaunts = True;
		}
		break;
	case 3:
		class'TournamentPlayer'.default.bNoVoiceMessages = true;
		class'TournamentPlayer'.default.bNoVoiceTaunts = true;
		class'TournamentPlayer'.default.bNoAutoTaunts = true;
		if (P != none)
		{
			P.bNoVoiceMessages = True;
			P.bNoVoiceTaunts = True;
			P.bNoAutoTaunts = True;
		}
		break;
	default:
		class'TournamentPlayer'.default.bNoVoiceMessages = false;
		class'TournamentPlayer'.default.bNoVoiceTaunts = false;
		class'TournamentPlayer'.default.bNoAutoTaunts = false;
		if (P != none)
		{
			P.bNoVoiceMessages = False;
			P.bNoVoiceTaunts = False;
			P.bNoAutoTaunts = False;
		}
		break;
	}
	SaveConfigs();
}

function Hardware3DChecked()
{
	Hardware3DSet();

	if(Use3DHardwareCheck.bChecked)
		ConfirmHardware = MessageBox(ConfirmHardwareTitle, ConfirmHardwareText, MB_YesNo, MR_No, MR_None);
}

function Hardware3DSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice Use3dHardware "$Use3DHardwareCheck.bChecked);
}

function SurroundSoundChecked()
{
	SurroundSoundSet();
	if(UseSurroundSoundCheck.bChecked)
		ConfirmSurround = MessageBox(ConfirmSurroundTitle, ConfirmSurroundText, MB_YesNo, MR_No, MR_None);
}

function SurroundSoundSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.AudioDevice UseSurround "$UseSurroundSoundCheck.bChecked);
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(Result != MR_Yes)
	{
		switch(W)
		{
		case ConfirmHardware:
			Use3DHardwareCheck.bChecked = False;
			Hardware3DSet();
			ConfirmHardware = None;
			break;
		case ConfirmSurround:
			UseSurroundSoundCheck.bChecked = False;
			SurroundSoundSet();
			ConfirmSurround = None;
			break;
		}
	}
}

function VoiceMessagesChecked()
{
}

function AutoTauntChecked()
{
	if (TournamentPlayer(GetPlayerOwner()) != none)
		TournamentPlayer(GetPlayerOwner()).SetAutoTaunt(AutoTauntCheck.bChecked);
	class'TournamentPlayer'.default.bAutoTaunt = AutoTauntCheck.bChecked;
	SaveConfigs();
}

function AnnouncerVolumeChanged()
{
	if (TournamentPlayer(GetPlayerOwner()) != none)
		TournamentPlayer(GetPlayerOwner()).AnnouncerVolume = AnnouncerVolumeSlider.GetValue();
	class'TournamentPlayer'.default.AnnouncerVolume = AnnouncerVolumeSlider.GetValue();
	SaveConfigs();
}

function NoMatureLanguageChanged()
{
	if (TournamentPlayer(GetPlayerOwner()) != none)
		TournamentPlayer(GetPlayerOwner()).bNoMatureLanguage = NoMatureLanguageCheck.bChecked;
	class'TournamentPlayer'.default.bNoMatureLanguage = NoMatureLanguageCheck.bChecked;
	SaveConfigs();
}

function SaveConfigs()
{
	class'TournamentPlayer'.static.StaticSaveConfig();
	Super.SaveConfigs();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
     AnnouncerVolumeText="Announcer Volume"
     AnnouncerVolumeHelp="Adjusts the volume of the in-game announcer."
     AutoTauntText="Auto Taunt"
     AutoTauntHelp="If checked, your player will send automatic taunts to your victims, whenever you score a frag."
     Use3DHardwareText="Use Hardware 3D Sound"
     Use3DHardwareHelp="If checked, UT will use your 3D audio hardware for richer environmental effects."
     UseSurroundSoundText="Use Surround Sound"
     UseSurroundSoundHelp="If checked, UT will use your digital receiver for better surround sound."
     MessageSettingsText="Play Voice Messages"
     MessageSettingsHelp="This setting controls which voice messages sent from other players will be heard."
     MessageSettings(0)="All"
     MessageSettings(1)="No Auto-Taunts"
     MessageSettings(2)="No Taunts"
     MessageSettings(3)="None"
     ConfirmHardwareTitle="Confirm Use 3D Sound Hardware"
     ConfirmHardwareText="The hardware 3D sound feature requires you have a 3D sound card supporting A3D or EAX.  Enabling this option can also cause your performance to degrade severely in some cases.\n\nAre you sure you want to enable this feature?"
     ConfirmSurroundTitle="Confirm Use Surround Sound"
     ConfirmSurroundText="The surround sound feature requires you have a compatible surround sound receiver connected to your sound card.  Enabling this option without the appropriate receiver can cause anomalies in sound performance.\n\nAre you sure you want to enable this feature?"
     NoMatureLanguageText="No Mature Taunts"
     NoMatureLanguageHelp="If checked, voice taunts with mature language will not be played."
}
