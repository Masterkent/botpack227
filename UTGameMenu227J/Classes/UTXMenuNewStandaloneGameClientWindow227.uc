class UTXMenuNewStandaloneGameClientWindow227 extends UMenuBotmatchClientWindow
	config(UTGameMenu227);

function bool CheckGameClass(string PackageName, string FullGameClassName)
{
	return true;
}

function string MapPrefix()
{
	if (class'UTXMenuStartMatchClientWindow227'.default.bFilterMaps)
		return super.MapPrefix();
	return "";
}


function Created()
{
	bSetGameDifficulty = false;

	if( !Class'UMenuMutatorCW'.Default.bKeepMutators )
		Class'UMenuMutatorCW'.Default.MutatorList = "";

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
	Splitter.SplitPos = 280;
	Splitter.MaxSplitPos = 280;
	Splitter.bRightGrow = True;

	ScreenshotWindow = UMenuScreenshotCW(Splitter.CreateWindow(class'UTXMenuScreenshotCW227', 0, 0, WinWidth, WinHeight));

	CreatePages();

	Splitter.LeftClientWindow = Pages;
	Splitter.RightClientWindow = ScreenshotWindow;

	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
	StartButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16));
	StartButton.SetText(StartText);
	StartButton.bDisabled = false;

	Super(UWindowDialogClientWindow).Created();
}

function WindowShown()
{
	super.WindowShown();

	UpdateScreenshotWindow();
}

function CreatePages()
{
	local class<UWindowPageWindow> PageClass;

	Pages = UMenuPageControl(Splitter.CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);
	Pages.AddPage(StartMatchTab, class'UTXMenuStartMatchScrollClient227');

	if (GameClass)
	{
		if (Len(GameClass.Default.RulesMenuType) > 0)
		{
			PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
			if (PageClass != None)
				RulesPage = Pages.AddPage(RulesTab, PageClass);
		}

		if (Len(GameClass.Default.SettingsMenuType) > 0)
		{
			PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
			if (PageClass != None)
				SettingsPage = Pages.AddPage(SettingsTab, PageClass);
		}

		if (Len(GameClass.Default.BotMenuType) > 0)
		{
			PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
			if (PageClass != None)
				BotConfigPage = Pages.AddPage(BotConfigTab, PageClass);
		}
	}
	else if (GameType ~= "default")
		SettingsPage = Pages.AddPage(SettingsTab, class'UTXMenuSinglePlayerSettingsSClient');
}

function GameChanged()
{
	local class<UWindowPageWindow> PageClass;

	bSetGameDifficulty = false;

	if (Pages.GetPage(RulesTab) != none)
		Pages.DeletePage(Pages.GetPage(RulesTab));
	if (Pages.GetPage(SettingsTab) != none)
		Pages.DeletePage(Pages.GetPage(SettingsTab));
	if (Pages.GetPage(BotConfigTab) != none)
		Pages.DeletePage(Pages.GetPage(BotConfigTab));

	if (GameClass == none)
	{
		if (GameType ~= "default")
			SettingsPage = Pages.AddPage(SettingsTab, class'UTXMenuSinglePlayerSettingsSClient');
		return;
	}

	// Change out the rules page...
	if (Len(GameClass.Default.RulesMenuType) > 0)
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
		if (PageClass != None)
			RulesPage = Pages.AddPage(RulesTab, PageClass);
	}

	// Change out the settings page...
	if (Len(GameClass.Default.SettingsMenuType) > 0)
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
		if (PageClass != None)
			SettingsPage = Pages.AddPage(SettingsTab, PageClass);
	}

	// Change out the bots page...
	if (Len(GameClass.Default.BotMenuType) > 0)
	{
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
		if (PageClass != None)
			BotConfigPage = Pages.AddPage(BotConfigTab, PageClass);
	}
}

function StartPressed()
{
	local string URL;
	local string Difficulty;
	local string Mutators;

	if (Len(Map) == 0)
		return;

	if (ShouldUseSpecifiedGameType() && (Len(GameType) == 0 || class<GameInfo>(DynamicLoadObject(GameType, class'class', true)) == none))
	{
		Log("Rejected an attempt to start new game with an invalid game class '" $ GameType $ "'");
		return;
	}

	// Reset the game class.
	if( GameClass )
		GameClass.Static.ResetGame();

	if (bSetGameDifficulty)
	{
		Difficulty = "?Difficulty=" $ class'UMenuNewGameClientWindow'.default.LastSelectedSkill;
		class'UMenuNewGameClientWindow'.static.StaticSaveConfig();
	}

	if (class'UMenuNewGameClientWindow'.default.bMutatorsSelected)
		Mutators = class'UMenuMutatorCW'.default.MutatorList;

	if (class'UTXMenuStartMatchClientWindow227'.default.bCampaign)
		URL = ExtractMutators(class'UTXMenuStartMatchClientWindow227'.default.SelectedCampaign.URL, Mutators);
	else
		URL = Map;
	if (ShouldUseSpecifiedGameType())
		URL $= "?Game=" $ GameType;
	URL $= Difficulty;
	if (Len(Mutators) > 0)
		URL $= "?Mutator=" $ Mutators;

	ParentWindow.Close();
	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}

function bool ShouldUseSpecifiedGameType()
{
	return !class'UTXMenuStartMatchClientWindow227'.default.bCampaign && !(GameType ~= "default");
}

static function string ExtractMutators(string URL, out string Mutators)
{
	local int MutatorsStart, MutatorsEnd;
	local string URLMutators;
	local array<string> UniqueMutators;

	MutatorsStart = InStr(Locs(URL), "?mutator=");
	if (MutatorsStart >= 0)
	{
		URLMutators = Mid(URL, MutatorsStart + Len("?mutator="));
		MutatorsEnd = InStr(URLMutators, "?");
		if (MutatorsEnd >= 0)
		{
			URL = Left(URL, MutatorsStart) $ Mid(URLMutators, MutatorsEnd);
			URLMutators = Left(URLMutators, MutatorsEnd);
		}
		else
			URL = Left(URL, MutatorsStart);

		ParseUniqueMutators(UniqueMutators, URLMutators);
		ParseUniqueMutators(UniqueMutators, Mutators);
	}
	else
		ParseUniqueMutators(UniqueMutators, Mutators);

	Mutators = MutatorArrayToString(UniqueMutators);
	return URL;
}

static function ParseUniqueMutators(out array<string> UniqueMutators, string MutatorList)
{
	local string Mutator;

	if (Len(MutatorList) == 0)
		return;
	while (Divide(MutatorList, ",", Mutator, MutatorList))
		AddUniqueMutatorToArray(UniqueMutators, Mutator);
	AddUniqueMutatorToArray(UniqueMutators, MutatorList);
}

static function AddUniqueMutatorToArray(out array<string> UniqueMutators, string Mutator)
{
	local int i;

	if (Len(Mutator) == 0)
		return;

	for (i = 0; i < UniqueMutators.Size(); ++i)
		if (UniqueMutators[i] ~= Mutator)
			return;
	UniqueMutators.Add(Mutator);
}

static function string MutatorArrayToString(out array<string> UniqueMutators)
{
	local int i;
	local string Result;

	if (UniqueMutators.Size() > 0)
		Result $= UniqueMutators[0];
	for (i = 1; i < UniqueMutators.Size(); ++i)
		Result $= "," $ UniqueMutators[i];
	return Result;
}

function UpdateScreenshotWindow()
{
	if (class'UTXMenuStartMatchClientWindow227'.default.bCampaign)
	{
		if (InStr(class'UTXMenuStartMatchClientWindow227'.default.SelectedCampaign.Logo, ".") > 0)
			ScreenshotWindow.Screenshot =
				Texture(DynamicLoadObject(class'UTXMenuStartMatchClientWindow227'.default.SelectedCampaign.Logo, class'Texture', true));
		else
			ScreenshotWindow.Screenshot = none;
	}
	else
		ScreenshotWindow.SetMap(Map);
}
