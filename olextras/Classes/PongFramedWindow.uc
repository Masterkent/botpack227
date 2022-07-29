// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// PongFramedWindow : Simple frame for Pong
// ===============================================================

class PongFramedWindow expands UMenuFramedWindow;

function Created()
{
  local int Difficulty;

  Difficulty = oldskoolnewgameclientwindow(OwnerWindow).Difficulty;

  if (Difficulty == 1)
      WindowTitle = "PoNg - Difficulty: Medium";
  else if (Difficulty == 2)
      WindowTitle = "PoNg - Difficulty: Hard";
  else if (Difficulty >= 3)
      WindowTitle = "PoNg - Difficulty: Near Impossible";

  Super.Created();
  bSizable = false;
  SetSize(450, 225);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
}

defaultproperties
{
     ClientClass=Class'olextras.PongClientWindow'
     WindowTitle="PoNg - Difficulty: Easy"
}
