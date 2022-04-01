// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// AwardNotifyWindow : Notifies player when he wins awards......
// ===============================================================

class AwardNotifyWindow expands UMenuFramedWindow;

function Created()
{
  Super.Created();
  bSizable = false;
  SetSize(500, 200);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
  AwardClient(clientarea).CreateControl(class'UWindowSmallOKButton', 2, WinHeight-36, winwidth-8, 16);
  bleaveonscreen=true;
}
function Close(optional bool bByParent)
{
  Super.Close(bByParent);
  Root.Console.bQuickKeyEnable = False;
  Root.Console.CloseUWindow();
}

defaultproperties
{
     ClientClass=Class'olextras.AwardClient'
     WindowTitle="Congratulations!"
}
