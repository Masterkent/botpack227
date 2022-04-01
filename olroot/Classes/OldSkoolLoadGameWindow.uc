// ============================================================
// oldskool.OldSkoolLoadGameWindow: The Window...
// ============================================================

class OldSkoolLoadGameWindow expands UMenuLoadGameWindow;
function Created()
{
  //if (ownerwindow!=none)
  bStatusBar = False;
  bSizable = False;

  Super(UwindowFramedWindow).Created();

  if (Root.WinWidth < 800)
  {
    SetSize(370, 200);
    //UMenuLoadGameClientWindow(ClientArea).SetScrollable(true);
  } else {
    SetSize(370, 590);
  }
  WinLeft = Root.WinWidth/2 - WinWidth/2;
  WinTop = Root.WinHeight/2 - WinHeight/2;
//if (ownerwindow==none) //if the hud called it...
  bleaveonscreen=true;
}
function Close(optional bool bByParent)
{
  Super.Close(bByParent);
  if (!ownerwindow.isa('oldskoolgamemenu')){ //if the hud called it...
  Root.Console.bQuickKeyEnable = False;
  Root.Console.CloseUWindow();}
}

defaultproperties
{
     ClientClass=Class'olroot.OldSkoolLoadGameScrollClient'
}
