// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvKillStatWindow : frame
// ===============================================================

class TvKillStatWindow expands UMenuFramedWindow;

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
  if(WinWidth != 260)
    WinWidth = 260;

  Super.Resized();
}
function SetSizePos()
{
  local float W, H;
    if(Root.WinHeight < 400)
    SetSize(260, Min(Root.WinHeight - 32, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));
  else
    SetSize(260, Min(Root.WinHeight - 50, /*H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)*/400));

  GetDesiredDimensions(W, H);

  WinLeft = Root.WinWidth/2 - WinWidth/2;
  WinTop = Root.WinHeight/2 - WinHeight/2;
}

function SetStats (string Num){
  TvKillStatsClient(UWindowScrollingDialogClient(ClientArea).ClientArea).SetStats(Num);
}

defaultproperties
{
     ClientClass=Class'olextras.TVKillStatsScroller'
     WindowTitle="Game Statistics"
}
