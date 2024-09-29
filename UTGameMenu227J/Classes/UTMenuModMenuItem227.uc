class UTMenuModMenuItem227 expands UMenuModMenuItem;

var localized string MenuCaptionDisable;

function Setup()
{
	if (class'UTMenuRootWindow227'.static.IsEnabled())
		MenuCaption = MenuCaptionDisable;
}

function Execute()
{
	local UWindowRootWindow Root;
	local WindowConsole Console;

	Root = MenuItem.Owner.Root;
	Console = Root.Console;

	if (class'UTMenuRootWindow227'.static.IsEnabled())
		Console.RootWindow = "UMenu.UMenuRootWindow";
	else
		Console.RootWindow = string(class'UTMenuRootWindow227');

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
