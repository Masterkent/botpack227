class UTXMenuSinglePlayerSettingsCWindow extends UMenuPageWindow
	config(UTGameMenu227);

var globalconfig bool bUseDifficulty;

var bool Initialized;
var float ControlOffset;

// Skill Level
var UWindowComboControl DifficultyCombo;
var UWindowCheckbox UseDifficultyCheck;
var localized string UseDifficultyText;
var localized string UseDifficultyHelp;

function Created()
{
	local int i;

	Super.Created();

	// Skill Level
	DifficultyCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', WinWidth / 2, ControlOffset, 100, 1));
	DifficultyCombo.SetText(class'UMenuSinglePlayerSettingsCWindow'.default.SkillText);
	DifficultyCombo.SetHelpText(class'UMenuSinglePlayerSettingsCWindow'.default.SkillHelp);
	DifficultyCombo.SetFont(F_Normal);
	DifficultyCombo.SetEditable(false);
	for (i = 0; i < ArrayCount(class'UMenuNewGameClientWindow'.default.Skills); ++i)
		DifficultyCombo.AddItem(class'UMenuNewGameClientWindow'.default.Skills[i]);
	DifficultyCombo.SetSelectedIndex(Clamp(class'UMenuNewGameClientWindow'.default.LastSelectedSkill,0,ArrayCount(class'UMenuNewGameClientWindow'.default.Skills)));
	ControlOffset += 25;

	UseDifficultyCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', WinWidth / 2, ControlOffset, 100, 1));
	UseDifficultyCheck.SetText(UseDifficultyText);
	UseDifficultyCheck.SetHelpText(UseDifficultyHelp);
	UseDifficultyCheck.SetFont(F_Normal);
	UseDifficultyCheck.Align = TA_Left;
	UseDifficultyCheck.bChecked = default.bUseDifficulty;
	ControlOffset += 25;

	SetUseOfGameDifficulty();
}

function SetUseOfGameDifficulty()
{
	if (UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow')) != none)
		UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow')).bSetGameDifficulty = default.bUseDifficulty;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, CheckboxWidth;
	local int LabelHSpacing, LabelAreaWidth;
	local float LabelTextAreaWidth, EditAreaWidth;

	Super.BeforePaint(C, X, Y);

	LabelTextAreaWidth = 0;
	DifficultyCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	UseDifficultyCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);

	EditAreaWidth = class'UMenuSinglePlayerSettingsCWindow'.default.EditAreaWidth;
	LabelHSpacing = 8;
	LabelAreaWidth = LabelTextAreaWidth + LabelHSpacing;
	ControlWidth = LabelAreaWidth + EditAreaWidth;
	CheckboxWidth = ControlWidth - EditAreaWidth + 16;
	ControlLeft = (WinWidth - ControlWidth) / 2;

	DifficultyCombo.SetSize(ControlWidth, 1);
	DifficultyCombo.WinLeft = ControlLeft;
	DifficultyCombo.EditBoxWidth = EditAreaWidth;

	UseDifficultyCheck.SetSize(CheckboxWidth, 1);
	UseDifficultyCheck.WinLeft = ControlLeft;
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset;

	Initialized = true;
}

function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
			case DifficultyCombo:
				SkillChanged();
				break;
			case UseDifficultyCheck:
				UseDifficultyChanged();
				break;
		}
	}
}

function SkillChanged()
{
	class'UMenuNewGameClientWindow'.default.LastSelectedSkill = DifficultyCombo.GetSelectedIndex();
	class'UMenuNewGameClientWindow'.static.StaticSaveConfig();
}

function UseDifficultyChanged()
{
	default.bUseDifficulty = UseDifficultyCheck.bChecked;
	SetUseOfGameDifficulty();
	StaticSaveConfig();
}

defaultproperties
{
	ControlOffset=20.0
	UseDifficultyText="Use Difficulty:"
	UseDifficultyHelp="Whether the specified difficulty should be used (or else ignored)"
}
