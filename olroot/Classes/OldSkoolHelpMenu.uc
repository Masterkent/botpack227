// ============================================================
// oldskool.OldSkoolHelpMenu: To use the PROPER root window (i.e. oldskool root window)
// ============================================================

class OldSkoolHelpMenu expands UMenuHelpMenu;
/*-
function ExecuteItem(UWindowPulldownMenuItem I)
{
  local UmenuMenuBar MenuBar;

  MenuBar = UmenuMenuBar(GetMenuBar());

  switch(I)
  {
  case Context:
    Context.bChecked = !Context.bChecked;
    MenuBar.ShowHelp = !MenuBar.ShowHelp;
    if (Context.bChecked)
    {
      if(OldSkoolRootWindow(Root) != None)
        if(OldSkoolRootWindow(Root).StatusBar != None)
          OldSkoolRootWindow(Root).StatusBar.ShowWindow();
    } else {
      if(OldSkoolRootWindow(Root) != None)
        if(OldSkoolRootWindow(Root).StatusBar != None)
          OldSkoolRootWindow(Root).StatusBar.HideWindow();
    }
    MenuBar.SaveConfig();
    break;
  case EpicURL:
    GetPlayerOwner().ConsoleCommand("start http://www.epicgames.com/");
    break;
  case SupportURL:
    GetPlayerOwner().ConsoleCommand("start http://www.gtgames.com/support");
    break;
  case About:
    if(class'GameInfo'.Default.DemoBuild == 1)
      Root.CreateWindow(class'UTCreditsWindow', 100, 100, 100, 100);
    else
    {
      GetPlayerOwner().ClientTravel( "UTCredits.unr", TRAVEL_Absolute, False );
      Root.Console.CloseUWindow();
    }
    break;
  }

  Super(UwindowPullDownMenu).ExecuteItem(I);
}
*/
defaultproperties
{
}
