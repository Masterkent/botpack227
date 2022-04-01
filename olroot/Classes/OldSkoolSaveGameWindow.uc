// ============================================================
// oldskool.OldSkoolSaveGameWindow: the window...
// ============================================================

class OldSkoolSaveGameWindow expands UMenuSaveGameWindow;
function Created()
{
  bStatusBar = False;
  bSizable = False;

  Super(UmenuFramedWindow).Created();

  if (Root.WinWidth < 800)
  {
    SetSize(370, 200);
   //UMenuSaveGameClientWindow(ClientArea).SetScrollable(true);
  } else {
    SetSize(360, 575);
  }
  WinLeft = Root.WinWidth/2 - WinWidth/2;
  WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
     ClientClass=Class'olroot.OldSkoolSaveGameScrollClient'
}
