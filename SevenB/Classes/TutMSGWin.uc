// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TutMSGWin. based on Legacy fakewindow
// allows tutorial question
// ============================================================

class TutMSGWin expands UWindowFramedWindow;

function created(){
  super.created();
  bSizable = false;
  SetSize(150, 80);
  WinLeft = (Root.WinWidth - WinWidth) / 2;
  WinTop = (Root.WinHeight - WinHeight) / 2;
}

defaultproperties
{
     ClientClass=Class'SevenB.TvItemSelectCWindow'
     WindowTitle="Get Ready!"
}
