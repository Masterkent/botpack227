// ============================================================
// oldskool.OldSkoolOptionsMenu: To call new player setup, weapon priorities, and the configuration.....
// ============================================================

class OldSkoolOptionsMenu expands UmenuOptionsMenu;


var UWindowPulldownMenuItem Oldconfig;

var localized string OldconfigName;        //possibility for future.....
var localized string Oldconfighelp;
var localized string advancedname;
var localized string advancedhelp;

function Created()
{
  Super(UwindowPulldownMenu).Created();

  Preferences = AddMenuItem(PreferencesName, None);
  Player = AddMenuItem(PlayerMenuName, None);
  Prioritize = AddMenuItem(PrioritizeName, None);

  AddMenuItem("-", None);
  Oldconfig = AddMenuItem(OldconfigName, None);
  Advanced = AddMenuItem(AdvancedName, None);
  AddMenuItem("-", None);
  Desktop = AddMenuItem(DesktopName, None);
  Desktop.bChecked = Root.Console.ShowDesktop;
  }

function ExecuteItem(UWindowPulldownMenuItem I)
{
local class<mappack> packclass;
if (class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="Custom"&&class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="")
  packclass=Class<MapPack>(DynamicLoadObject(class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType, class'Class'));

  switch (I)
  {
  case Preferences:
    ShowPreferences();
    break;
  case Prioritize:
    // Create prioritize weapons dialog.
    if ((GetLevel().Game.Isa('SinglePlayer2'))&&(class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType!="Custom"))
    Root.CreateWindow(PackClass.default.WeaponWindowClass, 100, 100, 200, 200, Self, True);
    else
    Root.CreateWindow(WeaponPriorityWindowClass, 100, 100, 200, 200, Self, True);
    break;
  case Oldconfig:
    // Create the oldskoolconfiguration stuff.  dynamic loading to reduce startup time.......
    Root.CreateWindow(class<uwindowwindow>(DynamicLoadObject("oldskool.OldskoolConfigWindow", class'class')) , 100, 100, 200, 200, Self, True);
    break;
  case Desktop:
    // Toggle show desktop.
    Desktop.bChecked = !Desktop.bChecked;
    Root.Console.ShowDesktop = !Root.Console.ShowDesktop;
    Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
    Root.Console.SaveConfig();
    break;
  case Player:
    // Create player dialog.
    PlayerSetup();
    break;
  case Advanced:   //advanced options....
    Root.GetPlayerOwner().ConsoleCommand( "preferences");
    break;
  }

  Super(UwindowPulldownMenu).ExecuteItem(I);        //as things are changed........
}

function Select(UWindowPulldownMenuItem I)
{
  switch (I)
  {
  case Oldconfig:
    oldskoolMenuBar(GetMenuBar()).SetHelp(OldconfigHelp);
    break;
  case Advanced:
    oldskoolMenuBar(GetMenuBar()).SetHelp(AdvancedHelp);
    break;
  }

  Super.Select(I);
}

defaultproperties
{
     OldconfigName="Old&Skool Configuration"
     Oldconfighelp="Confugure OldSkool"
     advancedname="&Advanced Options"
     AdvancedHelp="Goto the advanced options menu.  Warning: under a few 3d cards, this MAY cause UT to crash."
     PlayerWindowClass=Class'olroot.OldSkoolPlayerWindow'
     WeaponPriorityWindowClass=Class'olroot.OldskoolWeaponPriorityWindow'
}
