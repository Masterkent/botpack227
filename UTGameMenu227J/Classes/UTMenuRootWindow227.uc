class UTMenuRootWindow227 expands UMenuRootWindow;

var const string VersionInfo;
var const string Version;

var bool bEnabled;
var bool bShowedManagerWindow;

function Created()
{
	default.bEnabled = true;

	super(UWindowRootWindow).Created();

	StatusBar = UMenuStatusBar(CreateWindow(class'UMenuStatusBar', 0, 0, 50, 16));
	StatusBar.HideWindow();

	MenuBar = UMenuMenuBar(CreateWindow(class'UTMenuMenuBar227', 50, 0, 500, 16));

	BetaFont = Font(DynamicLoadObject("UWindowFonts.UTFont40", class'Font'));
	Resized();
}

function Tick(float Delta)
{
	super.Tick(Delta);
	if (!Console.IsA('TournamentConsole') &&
		!bShowedManagerWindow &&
		!Console.bQuickKeyEnable &&
		bWindowVisible &&
		GetLevel().NetMode == NM_Standalone &&
		GetLevel().Game.IsA('TrophyGame'))
	{
		bShowedManagerWindow = true;
		MenuBar.HideWindow();
		CreateWindow(class<UWindowWindow>(DynamicLoadObject("UTMenu.ManagerWindow", Class'Class')), 100, 100, 200, 200, self, true);
	}
}

function CloseActiveWindow()
{
	super.CloseActiveWindow();
	if (!bWindowVisible)
		bShowedManagerWindow = false;
}

defaultproperties
{
	VersionInfo="UTGameMenu227 v3.0 [2024-03-31]"
	Version="3.0"
}
