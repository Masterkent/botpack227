// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TutMSGWin. based on Legacy fakewindow
// allows tutorial question
// ============================================================

class TutMSGWin expands UWindowFramedWindow;

function created(){
  super.created();
  bSizable = false;
  SetSize(150, 120);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
}

defaultproperties
{
     ClientClass=Class'XidiaMPack.TvItemSelectCWindow'
     WindowTitle="Get Ready!"
}
