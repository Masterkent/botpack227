class UTMenuRootWindow227 expands UMenuRootWindow;

var const string VersionInfo;
var const string Version;

var bool bEnabled;

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

defaultproperties
{
	VersionInfo="UTGameMenu227 v1.1 [2023-01-27]"
	Version="1.1"
}
