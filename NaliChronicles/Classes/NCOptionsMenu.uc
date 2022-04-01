// Mostly ripped from UT
// Sergey 'Eater' Levin, 2002

class NCOptionsMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Preferences, Prioritize, Desktop, Advanced;

var localized string PreferencesName;
var localized string PreferencesHelp;
var localized string PrioritizeName;
var localized string PrioritizeHelp;
var localized string DesktopName;
var localized string DesktopHelp;

var Class<UWindowWindow> PlayerWindowClass;
var class<UWindowWindow> WeaponPriorityWindowClass;

function Created()
{
	Super.Created();

	Preferences = AddMenuItem(PreferencesName, None);
	Prioritize = AddMenuItem(PrioritizeName, None);

	AddMenuItem("-", None);

	Desktop = AddMenuItem(DesktopName, None);
	Desktop.bChecked = Root.Console.ShowDesktop;
}

function ShowPreferences(optional bool bNetworkSettings)
{
	local NCOptionsWindow O;

	O = NCOptionsWindow(Root.CreateWindow(Class'NCOptionsWindow', 100, 100, 200, 200, Self, True));
	if(bNetworkSettings)
		NCOptionsClientWindow(O.ClientArea).ShowNetworkTab();
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Preferences:
		ShowPreferences();
		break;
	case Prioritize:
		// Create prioritize weapons dialog.
		Root.CreateWindow(WeaponPriorityWindowClass, 100, 100, 200, 200, Self, True);
		break;
	case Desktop:
		// Toggle show desktop.
		Desktop.bChecked = !Desktop.bChecked;
		Root.Console.ShowDesktop = !Root.Console.ShowDesktop;
		Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
		Root.Console.SaveConfig();
		break;
	}

	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Preferences:
		UMenuMenuBar(GetMenuBar()).SetHelp(PreferencesHelp);
		break;
	case Prioritize:
		UMenuMenuBar(GetMenuBar()).SetHelp(PrioritizeHelp);
		break;
	case Desktop:
		UMenuMenuBar(GetMenuBar()).SetHelp(DesktopHelp);
		break;
	}

	Super.Select(I);
}

defaultproperties
{
     PreferencesName="&Preferences"
     PreferencesHelp="Change your game options, audio and video setup, controls and other options."
     PrioritizeName="&Weapons"
     PrioritizeHelp="Change your weapon priority, view and set weapon options."
     DesktopName="Show &Desktop"
     DesktopHelp="Toggle between showing your game behind the menus, or the desktop logo."
     WeaponPriorityWindowClass=Class'UMenu.UMenuWeaponPriorityWindow'
}
