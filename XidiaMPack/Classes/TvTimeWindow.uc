// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvTimeWindow : frame of time client
// ===============================================================

class TvTimeWindow expands UMenuFramedWindow;

function Created()
{
  bSizable = true;
  Super.Created();
  MinWinWidth = 200;
  MinWinHeight = 100;

  SetSizePos();
}

function ResolutionChanged(float W, float H)
{
  SetSizePos();
  Super.ResolutionChanged(W, H);
}

function Resized()
{
  if(WinWidth != 280)
    WinWidth = 280;

  Super.Resized();
}
function SetSizePos()
{
  local float W, H;
    if(Root.WinHeight < 400)
    SetSize(280, Min(Root.WinHeight - 32, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));
  else
    SetSize(280, Min(Root.WinHeight - 50, /*H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)*/400));

  GetDesiredDimensions(W, H);

  WinLeft = Root.WinWidth/2 - WinWidth/2;
  WinTop = Root.WinHeight/2 - WinHeight/2;
}


function SetTime (string Num,bool esca){
  TvTimeClient(UWindowScrollingDialogClient(ClientArea).ClientArea).SetTime(Num,esca);
}

defaultproperties
{
     ClientClass=Class'XidiaMPack.TvTimesScroller'
     WindowTitle="Time Spent in Each Level"
}
