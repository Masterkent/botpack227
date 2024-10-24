class UTMenuModMenuItem227 expands UMenuModMenuItem;

var localized string MenuCaption_SwitchToUMenu;
var localized string MenuCaption_SwitchToOtherMenu;

function Setup()
{
	if (class'UTMenuRootWindow227'.static.IsEnabled())
	{
		if (class'UTMenuRootWindow227'.static.HasPreviousRootWindowType())
			MenuCaption = MenuCaption_SwitchToOtherMenu;
		else
			MenuCaption = MenuCaption_SwitchToUMenu;
	}
}

function Execute()
{
	local UWindowRootWindow Root;
	local WindowConsole Console;

	Root = MenuItem.Owner.Root;
	Console = Root.Console;

	if (class'UTMenuRootWindow227'.static.IsEnabled())
	{
		if (class'UTMenuRootWindow227'.static.HasPreviousRootWindowType())
			ShowRootWindowSelector();
		else
			class'UTMenuRootWindow227'.static.SwitchRootWindow(Console, "UMenu.UMenuRootWindow");
	}
	else
		class'UTMenuRootWindow227'.static.SwitchRootWindow(Console, string(class'UTMenuRootWindow227'));
}

function ShowRootWindowSelector()
{
	local UTXMenuRootWindowSelector227 W;

	W = UTXMenuRootWindowSelector227(MenuItem.Owner.Root.CreateWindow(class'UTXMenuRootWindowSelector227', 100, 100, 100, 100));
	W.SetupSelector();
	MenuItem.Owner.Root.ShowModal(W);
}

defaultproperties
{
	MenuCaption="Switch to UTGameMenu227"
	MenuCaption_SwitchToUMenu="Switch to UMenu"
	MenuCaption_SwitchToOtherMenu="Switch to Other Menu"
	MenuHelp="Changes the game menu"
}
