// ============================================================
// oldskool.oldskoolUTConfigIndivBotsCW: simply uses the mesh client with animations......
// ============================================================

class oldskoolUTConfigIndivBotsCW expands UMenuConfigIndivBotsCW;

function Created()
{
  Super(umenudialogclientwindow).Created();
  Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));

  Splitter.RightClientWindow = UMenuPlayerMeshClient(Splitter.CreateWindow(class'Olroot.OldSkoolPlayerMeshClient', 0, 0, 100, 100));
  Splitter.LeftClientWindow = Splitter.CreateWindow(PlayerSetupClass, 0, 0, 100, 100, OwnerWindow);

  Splitter.bRightGrow = True;
  Splitter.SplitPos = 240;
}

defaultproperties
{
}
