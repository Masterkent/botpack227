// ============================================================
// oldskool.oldskoolmenubar: Menubar for OldSkool....
// ============================================================

class oldskoolmenubar expands UMenuMenuBar
config(oldskool);
    var UWindowPulldownMenu options;

function Created()
{
  local Class<UWindowPulldownMenu> MultiplayerUMenuType;

  local string MultiplayerUMenuName;

  Super(Uwindowmenubar).Created();

  bAlwaysOnTop = True;

  GameItem = AddItem(GameName);
  Game = GameItem.CreateMenu(class'olroot.OldSkoolGameMenu');

  MultiplayerItem = AddItem(MultiplayerName);
  if(GetLevel().Game != None)
    MultiplayerUMenuName = GetLevel().Game.Default.MultiplayerUMenuType;
  else
    MultiplayerUMenuName = MultiplayerUMenuDefault;
  MultiplayerUMenuType = Class<UWindowPulldownMenu>(DynamicLoadObject(MultiplayerUMenuName, class'Class'));
  Multiplayer = MultiplayerItem.CreateMenu(MultiplayerUMenuType);

  OptionsItem = AddItem(OptionsName);
  Options = OptionsItem.CreateMenu(class'olroot.OldSkoolOptionsMenu');

  //-StatsItem = AddItem(StatsName);
  //-Stats = StatsItem.CreateMenu(class'Umenu.UMenuStatsMenu');

  ToolItem = AddItem(ToolName);
  Tool = ToolItem.CreateMenu(class'Umenu.UMenuToolsMenu');

  if(LoadMods())
  {
    ModItem = AddItem(ModName);
    Mods = UMenuModMenu(ModItem.CreateMenu(class<UMenuModMenu>(DynamicLoadObject(ModMenuClass, class'class'))));
    Mods.SetupMods(ModItems);
  }

  HelpItem = AddItem(HelpName);
  Help = HelpItem.CreateMenu(class'olroot.OldSkoolHelpMenu');

  OldSkoolHelpMenu(Help).Context.bChecked = ShowHelp;
  if (ShowHelp)
  {
    if(OldSkoolRootWindow(Root) != None)
      if(OldSkoolRootWindow(Root).StatusBar != None)
        OldSkoolRootWindow(Root).StatusBar.ShowWindow();
  }

  bShowMenu = True;

  Spacing = 12;
}

function SetHelp(string NewHelpText)
{
  if(OldSkoolRootWindow(Root) != None)
    if(OldSkoolRootWindow(Root).StatusBar != None)
      OldSkoolRootWindow(Root).StatusBar.SetHelp(NewHelpText);
}
function HideWindow()
{
  if(OldSkoolRootWindow(Root) != None)
    if(OldSkoolRootWindow(Root).StatusBar != None)
      OldSkoolRootWindow(Root).StatusBar.HideWindow();
  Super(UwindowMenubar).HideWindow();
}

function ShowWindow()
{
  if (ShowHelp)
  {
    if(OldSkoolRootWindow(Root) != None)
      if(OldSkoolRootWindow(Root).StatusBar != None)
        OldSkoolRootWindow(Root).StatusBar.ShowWindow();
  }
  Super(UwindowMenuBar).ShowWindow();
}

defaultproperties
{
     GameUMenuDefault="UMenu.UMenuGameMenu"
}
