// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvHighScoresWindow : Simply the frame of the high scores window
// ===============================================================

class TvHighScoresWindow expands UMenuFramedWindow;

var UWindowSmallCloseButton CloseButton;  //close

function Created()
{
  Super.Created();
  bSizable = false;
  SetSize(647, 320);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
  CloseButton = UWindowSmallcloseButton(TVHSClient(clientarea).CreateControl(class'UWindowSmallcloseButton', 2, WinHeight-36, winwidth-8, 16));
}

defaultproperties
{
     ClientClass=Class'SevenB.TVHSClient'
     WindowTitle="Seven Bullets - High Scores"
}
