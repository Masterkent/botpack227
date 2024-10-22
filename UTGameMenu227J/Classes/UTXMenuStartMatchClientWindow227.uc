class UTXMenuStartMatchClientWindow227 expands UMenuStartMatchClientWindow
	config(UTGameMenu227);

#exec TEXTURE IMPORT NAME=UnrealLogo FILE=Textures\UnrealLogo.pcx GROUP="CampaignLogos" MIPS=OFF

const MAX_SP_DIFFICULTY_LEVELS = 7;

var config string LastMapSetMode;
var config string LastCampaign;
var config bool bFilterMaps;

var UWindowComboBoxControl MapSetModeCombo;
var localized string MapSetSingleText;
var localized string MapSetCampaignText;

var UWindowComboBoxControl CampaignCombo;
var localized string CampaignText;
var localized string CampaignHelp;

var UWindowComboBoxControl DifficultyCombo;
var UMenuLabelControl DifficultyLabel;

var UWindowCheckbox MutatorsCheck;

var UWindowCheckbox ClassicBalanceCheck;
var localized string ClassicBalanceText;
var localized string ClassicBalanceHelp;

var UWindowCheckbox FilterMapsCheck;
var localized string FilterMapsText;
var localized string FilterMapsHelp;

var localized string DefaultGameType;


var bool bCampaign;

struct CampaignInfo
{
	var string MapName; // map name in caps
	var string URL;
	var string Title;
	var string GameClass;
	var string Logo;
};

var array<CampaignInfo> Campaigns;
var CampaignInfo SelectedCampaign;

var bool bIgnoreChanges;

function Created()
{
	local int CenterWidth, CenterPos, YOffset, YDist;

	Super(UMenuDialogClientWindow).Created();

	DesiredWidth = 270;
	DesiredHeight = 100;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;
	YOffset = 15;
	YDist = 25;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");

	MapSetModeCombo = UWindowComboBoxControl(CreateControl(class'UWindowComboBoxControl', CenterPos, YOffset, CenterWidth, 1));
	MapSetModeCombo.SetButtons(True);
	MapSetModeCombo.SetFont(F_Normal);

	IterateMapSetModes();

	CampaignCombo = UWindowComboBoxControl(CreateControl(class'UWindowComboBoxControl', CenterPos, YOffset, CenterWidth, 1));
	CampaignCombo.SetButtons(True);
	CampaignCombo.SetText(CampaignText);
	CampaignCombo.SetHelpText(CampaignHelp);
	CampaignCombo.SetFont(F_Normal);
	CampaignCombo.SetEditable(False);
	CampaignCombo.EnableQuickFilter(True);

	// Skill Level
	DifficultyCombo = UWindowComboBoxControl(CreateControl(class'UWindowComboBoxControl', CenterPos, YOffset, CenterWidth, 1));
	DifficultyCombo.SetButtons(True);
	DifficultyCombo.SetText(class'UMenuNewGameClientWindow'.default.SkillText);
	DifficultyCombo.SetHelpText(class'UMenuNewGameClientWindow'.default.SkillHelp);
	DifficultyCombo.SetFont(F_Normal);
	DifficultyCombo.SetEditable(False);
	DifficultyLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', 5, 45, WinWidth-10, 1));
	DifficultyLabel.Align = TA_Center;

	// Game Type
	GameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, YOffset, CenterWidth, 1));
	GameEdit.SetText(GameText);
	GameEdit.SetFont(F_Normal);
	GameEdit.EditBox.SetEditable(false);
	GameEdit.EditBox.TextColor.R = 128;
	GameEdit.EditBox.TextColor.G = 64;
	GameEdit.EditBox.TextColor.B = 0;

	// Game Classes
	GameCombo = UWindowComboBoxControl(CreateControl(class'UWindowComboBoxControl', CenterPos, YOffset, CenterWidth, 1));
	GameCombo.SetButtons(True);
	GameCombo.SetText(GameClassText);
	GameCombo.SetHelpText(GameHelp);
	GameCombo.SetFont(F_Normal);
	GameCombo.SetEditable(True);
	GameCombo.EnableQuickFilter(True);

	// Map
	MapCombo = UWindowComboBoxControl(CreateControl(class'UWindowComboBoxControl', CenterPos, YOffset, CenterWidth, 1));
	MapCombo.SetButtons(True);
	MapCombo.SetText(MapText);
	MapCombo.SetHelpText(MapHelp);
	MapCombo.SetFont(F_Normal);
	MapCombo.SetEditable(True);
	MapCombo.SetAutoSort(True);
	MapCombo.EnableQuickFilter(True);

	// Map List Button
	MapListButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, YOffset, 48, 16));
	MapListButton.SetText(MapListText);
	MapListButton.SetFont(F_Normal);
	MapListButton.SetHelpText(MapListHelp);

	// Mutator Button
	MutatorButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, YOffset, 48, 16));
	MutatorButton.SetText(MutatorText);
	MutatorButton.SetFont(F_Normal);
	MutatorButton.SetHelpText(MutatorHelp);

	// Classic Balance Checkbox
	MutatorsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, YOffset, CenterWidth, 1));
	MutatorsCheck.SetText(class'UMenuNewGameClientWindow'.default.UseMutText);
	MutatorsCheck.SetHelpText(class'UMenuNewGameClientWindow'.default.UseMutHelp);
	MutatorsCheck.SetFont(F_Normal);
	MutatorsCheck.Align = TA_Left;
	MutatorsCheck.bChecked = class'UMenuNewGameClientWindow'.default.bMutatorsSelected;

	ClassicBalanceCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, YOffset, CenterWidth, 1));
	ClassicBalanceCheck.SetText(ClassicBalanceText);
	ClassicBalanceCheck.SetHelpText(ClassicBalanceHelp);
	ClassicBalanceCheck.SetFont(F_Normal);
	ClassicBalanceCheck.Align = TA_Left;
	ClassicBalanceCheck.bChecked = class'GameInfo'.default.bUseClassicBalance;

	// Filter Invalid Game Classes Checkbox
	FilterInvalidGameClassesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, YOffset, CenterWidth, 1));
	FilterInvalidGameClassesCheck.SetText(FilterInvalidGameClassesText);
	FilterInvalidGameClassesCheck.SetHelpText(FilterInvalidGameClassesHelp);
	FilterInvalidGameClassesCheck.SetFont(F_Normal);
	FilterInvalidGameClassesCheck.Align = TA_Left;
	FilterInvalidGameClassesCheck.bChecked = BotmatchParent.bFilterInvalidGameClasses;

	FilterMapsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, YOffset, CenterWidth, 1));
	FilterMapsCheck.SetText(FilterMapsText);
	FilterMapsCheck.SetHelpText(FilterMapsHelp);
	FilterMapsCheck.SetFont(F_Normal);
	FilterMapsCheck.Align = TA_Left;
	FilterMapsCheck.bChecked = bFilterMaps;

	InitPageControls();
	Initialized = True;
}

function IterateMapSetModes()
{
	MapSetModeCombo.Clear();
	MapSetModeCombo.AddItem(MapSetSingleText, "SingleMap");
	MapSetModeCombo.AddItem(MapSetCampaignText, "Campaign");
	if (default.LastMapSetMode ~= "Campaign")
		MapSetModeCombo.SetSelectedIndex(1);
	else
		MapSetModeCombo.SetSelectedIndex(0);
}

function IterateCampaigns()
{
	local string Description, S;
	local CampaignInfo CampaignInfo;
	local int i;
	local int SelectedIndex;

	Campaigns.Empty();
	CampaignCombo.Clear();

	foreach GetPlayerOwner().IntDescIterator("UnrealShare.SinglePlayer", CampaignInfo.GameClass, Description)
	{
		if (!Divide(Description, ";", CampaignInfo.URL, CampaignInfo.Title))
			continue;

		if (!Divide(CampaignInfo.URL, "?", CampaignInfo.MapName, S))
			CampaignInfo.MapName = Caps(CampaignInfo.URL);
		if (Divide(CampaignInfo.Title, ";", CampaignInfo.Logo, CampaignInfo.Title))
		{
			if (CampaignInfo.MapName ~= "Vortex2" && (Len(CampaignInfo.Logo) == 0 || CampaignInfo.Logo ~= "UnrealShare.Logo2"))
				CampaignInfo.Logo = Class.Outer.Name $ ".CampaignLogos.UnrealLogo";
		}
		else
			CampaignInfo.Logo = "";
		if (Len(CampaignInfo.URL) > 0 && Len(CampaignInfo.Title) > 0)
		{
			if (Len(CampaignInfo.GameClass) > 0 && !(CampaignInfo.GameClass ~= "Game.Game"))
				CampaignInfo.URL $= "?Game=" $ CampaignInfo.GameClass;
			Campaigns.Add(CampaignInfo);
		}
	}

	SortCampaigns();

	for (i = 0; i < Campaigns.Size(); ++i)
	{
		CampaignCombo.AddItem(Campaigns[i].Title, String(i));
		if (Campaigns[i].URL ~= LastCampaign)
			SelectedIndex = i;
	}

	if (i > 0)
		CampaignCombo.SetSelectedIndex(SelectedIndex);
}

function SortCampaigns()
{
	local int i, n, size;
	local int idx1, idx2, end1, end2;
	local int merged_idx;
	local array<CampaignInfo> merged;

	size = Campaigns.Size();
	if (size < 2)
		return;

	merged.SetSize(size);

	for (n = 1; true; n *= 2)
	{
		for (i = 0; i < size; i += n * 2)
		{
			merged_idx = i;

			idx1 = i;
			if (size - idx1 > n)
				end1 = idx1 + n;
			else
				end1 = size;

			idx2 = end1;
			if (size - idx2 > n)
				end2 = idx2 + n;
			else
				end2 = size;

			while (idx1 < end1 && idx2 < end2)
			{
				if (CompareCampaignInfo(Campaigns[idx1], Campaigns[idx2]))
					merged[merged_idx++] = Campaigns[idx1++];
				else
					merged[merged_idx++] = Campaigns[idx2++];
			}
			while (idx1 < end1)
				merged[merged_idx++] = Campaigns[idx1++];
			while (idx2 < end2)
				merged[merged_idx++] = Campaigns[idx2++];

			for (merged_idx = i; merged_idx < end2; ++merged_idx)
				Campaigns[merged_idx] = merged[merged_idx];
		}

		if (size - n <= n)
			return;
	}
}

static final function bool CompareCampaignInfo(out CampaignInfo X1, out CampaignInfo X2)
{
	if (X2.MapName ~= "Vortex2")
		return false;
	if (X1.MapName ~= "Vortex2")
		return true;
	if (X2.MapName ~= "Intro1")
		return false;
	if (X1.MapName ~= "Intro1")
		return true;
	if (Caps(X1.Title) < Caps(X2.Title))
		return true;
	return false;
}

function IterateDifficulties()
{
	local int i;

	DifficultyCombo.Clear();

	for (i = 0; i < MAX_SP_DIFFICULTY_LEVELS; ++i)
		DifficultyCombo.AddItem(class'UMenuNewGameClientWindow'.default.Skills[i]);
	DifficultyCombo.SetSelectedIndex(GetSelectedDifficultyLevel());
	DifficultyLabel.SetText(class'UMenuNewGameClientWindow'.default.SkillStrings[GetSelectedDifficultyLevel()]);
	UpdateDifficultyComboTextColor();
}

function IterateGameClasses()
{
	local string GameClassName, GameTitle;
	local string PackageName, ClassName;
	local int i, GamesCount;

	GameEdit.Clear();
	GameCombo.Clear();

	if ( !BotmatchParent )
		return;

	foreach GetPlayerOwner().IntDescIterator("Engine.GameInfo", GameClassName,, true)
	{
		if (!Divide(GameClassName, ".", PackageName, ClassName)) // ClassName may include names of groups
			continue;
		if (!BotmatchParent.CheckGameClass(PackageName, GameClassName) ||
			BotmatchParent.bFilterInvalidGameClasses && class<GameInfo>(DynamicLoadObject(GameClassName, class'class', true)) == none)
		{
			continue;
		}

		GameTitle = ClassName @ "[" $ PackageName $ "]";
		GameCombo.AddItem(GameTitle, GameClassName);
	}

	GameCombo.Sort();
	GameCombo.InsertItem(DefaultGameType, "default");

	GamesCount = GameCombo.ItemsCount();
	for (i = 0; i < GamesCount; ++i)
		if (GameCombo.GetItemValue2(i) ~= BotmatchParent.GameType)
		{
			GameCombo.SetSelectedIndex(i);
			break;
		}
	if (i == GamesCount)
		GameCombo.SetSelectedIndex(0);

	BotmatchParent.GameType = GameCombo.GetValue2();
	ProcessSelectedGameClass();
}

function InitPageControls()
{
	MapSetModeChanged();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int CenterWidth;
	local float LabelWidth;
	local float YOffset, YDist, YBottomDist;

	YOffset = 15;
	YDist = 25;
	YBottomDist = 20;

	CenterWidth = WinWidth - 2 * ControlHOffset;

	if (bCampaign)
	{
		CampaignCombo.GetMinTextAreaWidth(C, LabelWidth);
		DifficultyCombo.GetMinTextAreaWidth(C, LabelWidth);
		LabelWidth += EditAreaOffset;

		CampaignCombo.SetSize(CenterWidth, 1);
		CampaignCombo.WinLeft = ControlHOffset;
		CampaignCombo.WinTop = YOffset += YDist;
		CampaignCombo.EditBoxWidth = CenterWidth - LabelWidth;

		DifficultyCombo.SetSize(CenterWidth, 1);
		DifficultyCombo.WinLeft = ControlHOffset;
		DifficultyCombo.WinTop = YOffset += YDist;
		DifficultyCombo.EditBoxWidth = CenterWidth - LabelWidth;

		DifficultyLabel.SetSize(CenterWidth, 1);
		DifficultyLabel.WinLeft = ControlHOffset;
		DifficultyLabel.WinTop = YOffset += YDist;
	}
	else
	{
		GameCombo.GetMinTextAreaWidth(C, LabelWidth);
		MapCombo.GetMinTextAreaWidth(C, LabelWidth);
		LabelWidth += EditAreaOffset;

		GameEdit.SetSize(CenterWidth, 1);
		GameEdit.WinLeft = ControlHOffset;
		GameEdit.WinTop = YOffset += YDist;
		GameEdit.EditBoxWidth = CenterWidth - LabelWidth;

		GameCombo.SetSize(CenterWidth, 1);
		GameCombo.WinLeft = ControlHOffset;
		GameCombo.WinTop = YOffset += YDist;
		GameCombo.EditBoxWidth = CenterWidth - LabelWidth;

		MapCombo.SetSize(CenterWidth, 1);
		MapCombo.WinLeft = ControlHOffset;
		MapCombo.WinTop = YOffset += YDist;
		MapCombo.EditBoxWidth = CenterWidth - LabelWidth;
	}

	MapSetModeCombo.SetSize(CenterWidth, 1);
	MapsetModeCombo.WinLeft = ControlHOffset;
	MapsetModeCombo.EditBoxWidth = CenterWidth - LabelWidth;

	MapListButton.AutoWidth(C);
	MutatorButton.AutoWidth(C);

	MapListButton.WinWidth = Max(MapListButton.WinWidth, MutatorButton.WinWidth);
	MutatorButton.WinWidth = MapListButton.WinWidth;

	if (bCampaign)
	{
		MutatorButton.WinLeft = (WinWidth - MapListButton.WinWidth) / 2;
		MutatorButton.WinTop = YOffset += YDist;
	}
	else
	{
		MapListButton.WinLeft = (WinWidth - (MapListButton.WinWidth + MutatorButton.WinWidth + ControlHOffset)) / 2;
		MapListButton.WinTop = YOffset += YDist;
		MutatorButton.WinLeft = (WinWidth - (MapListButton.WinWidth - MutatorButton.WinWidth - ControlHOffset)) / 2;
		MutatorButton.WinTop = MapListButton.WinTop;
	}

	YOffset = WinHeight - BottomControlOffset;

	if (!bCampaign)
	{
		FilterMapsCheck.AutoWidth(C);
		FilterMapsCheck.WinLeft = WinWidth - ControlHOffset - FilterMapsCheck.WinWidth;
		FilterMapsCheck.WinTop = YOffset;
		YOffset -= YBottomDist;

		FilterInvalidGameClassesCheck.AutoWidth(C);
		FilterInvalidGameClassesCheck.WinLeft = WinWidth - ControlHOffset - FilterInvalidGameClassesCheck.WinWidth;
		FilterInvalidGameClassesCheck.WinTop = YOffset;
		YOffset -= YBottomDist;
	}

	ClassicBalanceCheck.AutoWidth(C);
	ClassicBalanceCheck.WinLeft = WinWidth - ControlHOffset - ClassicBalanceCheck.WinWidth;
	ClassicBalanceCheck.WinTop = YOffset;
	YOffset -= YBottomDist;

	MutatorsCheck.AutoWidth(C);
	MutatorsCheck.WinLeft = WinWidth - ControlHOffset - MutatorsCheck.WinWidth;
	MutatorsCheck.WinTop = YOffset;
	YOffset -= YBottomDist;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if (!Initialized || bIgnoreChanges)
		return;

	if (E == DE_Change)
		switch (C)
		{
			case MapSetModeCombo:
				MapSetModeChanged();
				break;
			case CampaignCombo:
				CampaignChanged();
				break;
			case DifficultyCombo:
				DifficultyChanged();
				break;
			case MutatorsCheck:
				MutatorsChanged();
				break;
			case ClassicBalanceCheck:
				ClassicBalanceChanged();
				break;
			case FilterMapsCheck:
				FilterMapsChanged();
				break;
		}
}

function MapSetModeChanged()
{
	if (MapSetModeCombo.GetValue2() ~= "Campaign")
		SetCampaignMode();
	else
		SetSingleMapMode();
}

function SetSingleMapMode()
{
	bCampaign = false;
	default.bCampaign = bCampaign;
	LastMapSetMode = "SingleMap";
	BotmatchParent.bSetGameDifficulty = false;

	HideChildWindow(CampaignCombo);
	HideChildWindow(DifficultyCombo);
	HideChildWindow(DifficultyLabel);
	ShowChildWindow(GameEdit);
	ShowChildWindow(GameCombo);
	ShowChildWindow(MapCombo);
	ShowChildWindow(MapListButton);
	ShowChildWindow(FilterInvalidGameClassesCheck);
	ShowChildWindow(FilterMapsCheck);

	IterateGameClasses();
	IterateMaps(BotmatchParent.Map);

	SaveConfig();
}

function SetCampaignMode()
{
	bCampaign = true;
	default.bCampaign = bCampaign;
	LastMapSetMode = "Campaign";
	BotmatchParent.bSetGameDifficulty = true;

	ShowChildWindow(CampaignCombo);
	ShowChildWindow(DifficultyCombo);
	ShowChildWindow(DifficultyLabel);
	HideChildWindow(GameEdit);
	HideChildWindow(GameCombo);
	HideChildWindow(MapCombo);
	HideChildWindow(MapListButton);
	HideChildWindow(FilterInvalidGameClassesCheck);
	HideChildWindow(FilterMapsCheck);

	bIgnoreChanges = true;
	IterateCampaigns();
	IterateDifficulties();
	bIgnoreChanges = false;

	BotmatchParent.PreGameChanged();
	BotmatchParent.GameClass = none;

	CampaignChanged();
}

function AfterCreate()
{
	if (default.bCampaign)
		UpdateLogo();
	else
		super.AfterCreate();
}

function CampaignChanged()
{
	local int CampaignIndex;

	CampaignIndex = int(CampaignCombo.GetValue2());
	if (0 <= CampaignIndex && CampaignIndex < Campaigns.Size())
	{
		default.SelectedCampaign = Campaigns[CampaignIndex];
		LastCampaign = default.SelectedCampaign.URL;
	}

	BotmatchParent.EnableStart(Len(default.SelectedCampaign.URL) > 0);
	UpdateLogo();

	if (Initialized)
		SaveConfig();
}

function UpdateLogo()
{
	if (InStr(default.SelectedCampaign.Logo, ".") > 0)
		BotmatchParent.ScreenshotWindow.Screenshot = Texture(DynamicLoadObject(default.SelectedCampaign.Logo, class'Texture', true));
	else
		BotmatchParent.ScreenshotWindow.Screenshot = none;
	BotmatchParent.ScreenshotWindow.MapTitle = "";
	BotmatchParent.ScreenshotWindow.MapAuthor = "";
	BotmatchParent.ScreenshotWindow.IdealPlayerCount = "";
}

function DifficultyChanged()
{
	class'UMenuNewGameClientWindow'.default.LastSelectedSkill = DifficultyCombo.GetSelectedIndex();
	class'UMenuNewGameClientWindow'.static.StaticSaveConfig();
	DifficultyLabel.SetText(class'UMenuNewGameClientWindow'.default.SkillStrings[class'UMenuNewGameClientWindow'.default.LastSelectedSkill]);
	UpdateDifficultyComboTextColor();
}

function MutatorsChanged()
{
	class'UMenuNewGameClientWindow'.default.bMutatorsSelected = MutatorsCheck.bChecked;
	class'UMenuNewGameClientWindow'.static.StaticSaveConfig();
}

function ClassicBalanceChanged()
{
	class'GameInfo'.default.bUseClassicBalance = ClassicBalanceCheck.bChecked;
	class'GameInfo'.static.StaticSaveConfig();
}

function FilterMapsChanged()
{
	bFilterMaps = FilterMapsCheck.bChecked;
	default.bFilterMaps = bFilterMaps;
	GameChanged();
	SaveConfig();
}

function int GetSelectedDifficultyLevel()
{
	return Clamp(class'UMenuNewGameClientWindow'.default.LastSelectedSkill, 0, MAX_SP_DIFFICULTY_LEVELS - 1);
}

function UpdateDifficultyComboTextColor()
{
	if (class'UMenuNewGameClientWindow'.default.LastSelectedSkill > 3)
		DifficultyCombo.EditBox.TextColor = MakeColor(255, 96, 0);
	else
		DifficultyCombo.EditBox.TextColor = MakeColor(0, 0, 0);
}

function ProcessSelectedGameClass()
{
	if (Len(BotmatchParent.GameType) > 0)
	{
		if (BotmatchParent.GameType ~= "default")
		{
			BotmatchParent.GameClass = none;
			GameEdit.SetValue(DefaultGameType);
		}
		else
		{
			BotmatchParent.GameClass = class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType, class'class', true));
			if (BotmatchParent.GameClass != none)
				GameEdit.SetValue(BotmatchParent.GameClass.default.GameName);
			else
				GameEdit.SetValue(InvalidGameClass);
		}
	}
	else
	{
		BotmatchParent.GameClass = none;
		GameEdit.SetValue("");
	}

	BotmatchParent.EnableStart(BotmatchParent.GameClass != none || BotmatchParent.GameType ~= "default");
	MapListButton.bDisabled = BotmatchParent.GameClass == none || BotmatchParent.GameClass.Default.MapListType == none;
}

defaultproperties
{
	MapSetSingleText="Open Single Map"
	MapSetCampaignText="Start New Campaign"
	CampaignText="Campaign:"
	CampaignHelp="Select the campaign to play"
	ClassicBalanceText="Classic Balance"
	ClassicBalanceHelp="Preserve the original gameplay as close as possible"
	FilterMapsText="Filter Maps"
	FilterMapsHelp="When checked, maps are filtered by game prefix"
	DefaultGameType="Default"
}
