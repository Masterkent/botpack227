class UTMenuModMenuItem227 expands UMenuModMenuItem;

var localized string MenuCaptionDisable;

function Setup()
{
	if (class'UTMenuRootWindow227'.default.bEnabled)
		MenuCaption = MenuCaptionDisable;
}

function Execute()
{
	local UWindowRootWindow Root;
	local WindowConsole Console;

	Root = MenuItem.Owner.Root;
	Console = Root.Console;

	if (class'UTMenuRootWindow227'.default.bEnabled)
		Console.RootWindow = "UMenu.UMenuRootWindow";
	else
		Console.RootWindow = string(class'UTMenuRootWindow227');

	class'UTMenuRootWindow227'.default.bEnabled = !class'UTMenuRootWindow227'.default.bEnabled;
	Console.default.RootWindow = Console.RootWindow;
	Console.SaveConfig();
	Console.ResetUWindow();
	Console.LaunchUWindow();
}

defaultproperties
{
	MenuCaption="Switch to UTGameMenu227"
	MenuCaptionDisable="Switch to UMenu"
	MenuHelp="Changes the game menu"
}
