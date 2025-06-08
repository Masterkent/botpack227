// ============================================================
// Oldskool.OldskoolUTMenuBotmatchCW: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class oldskoolUTMenuBotmatchCW expands UMenuBotmatchClientWindow;

var UWindowPageControlPage B227_StartMatchPage, B227_RulesPage, B227_SettingsPage, B227_BotConfigPage;

function CreatePages()
{
	local class<UWindowPageWindow> PageClass;

	log ("botmatchstep 1 done");
	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(True);

	B227_StartMatchPage = Pages.AddPage(StartMatchTab, class'UMenuStartMatchScrollClient');

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class'));
	if (PageClass != None)
		B227_RulesPage = Pages.AddPage(RulesTab, PageClass);

	PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class'));
	if (PageClass != None)
		B227_SettingsPage = Pages.AddPage(SettingsTab, PageClass);

	if (GameClass.Default.BotMenuType ~= "UTMenu.UTBotConfigSClient")
		PageClass = class<UWindowPageWindow>(DynamicLoadObject("olroot.oldskoolutbotconfigsclient", class'Class'));
	else
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
	if (PageClass != None)
		B227_BotConfigPage = Pages.AddPage(BotConfigTab, PageClass);
}

function WindowShown()
{
	local UMenuStartMatchScrollClient UMenuStartMatchScrollClient;
	local UMenuStartMatchClientWindow UMenuStartMatchClientWindow;

	if (B227_StartMatchPage == none || ScreenshotWindow == none)
		return;
	UMenuStartMatchScrollClient = UMenuStartMatchScrollClient(B227_StartMatchPage.Page);
	if (UMenuStartMatchScrollClient == none)
		return;
	UMenuStartMatchClientWindow = UMenuStartMatchClientWindow(UMenuStartMatchScrollClient.ClientArea);
	if (UMenuStartMatchClientWindow == none)
		return;

	ScreenshotWindow.SetMap(Map); // Fix for disappearing screenshot bug
}

function GameChanged()
{
	local class<UWindowPageWindow> PageClass;

	B227_PreGameChanged();

	SetPropertyText("bSetGameDifficulty", "false");

	if (GameClass != none)
	{
		// Change out the rules page...
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.RulesMenuType, class'Class', true));
		if (PageClass != none)
			B227_RulesPage = Pages.AddPage(RulesTab, PageClass);

		// Change out the settings page...
		PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.SettingsMenuType, class'Class', true));
		if (PageClass != none)
			B227_SettingsPage = Pages.AddPage(SettingsTab, PageClass);

		// Change out the bots page...
		if (Len(GameClass.default.BotMenuType) > 0)
		{
			if (GameClass.default.BotMenuType ~= "UTMenu.UTBotConfigSClient")
				PageClass = class<UWindowPageWindow>(DynamicLoadObject("olroot.oldskoolutbotconfigsclient", class'Class'));
			else
				PageClass = class<UWindowPageWindow>(DynamicLoadObject(GameClass.Default.BotMenuType, class'Class'));
			if (PageClass != none)
				B227_BotConfigPage = Pages.AddPage(BotConfigTab, PageClass);
		}
	}
}

function B227_PreGameChanged()
{
	if (B227_RulesPage != none)
		B227_DeletePage(B227_RulesPage);
	if (B227_SettingsPage != none)
		B227_DeletePage(B227_SettingsPage);
	if (B227_BotConfigPage != none)
		B227_DeletePage(B227_BotConfigPage);
}

function B227_DeletePage(out UWindowPageControlPage Page)
{
	if (Page == none)
		return;
	Pages.DeletePage(Page);
	Page = none;
}

defaultproperties
{
     Map="DM-Synergy.unr"
     MutatorList="oldskool.oldskool"
}
