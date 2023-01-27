// ============================================================
// oldskool.oldskoolconfigwindow: whatever
// ============================================================
class OldskoolConfigWindow expands UWindowFramedWindow;
/*
function Created()
{
Super.Created();
SetSize(250, 480);
WinLeft = (Root.WinWidth - WinWidth) / 2;
WinTop = (Root.WinHeight - WinHeight) / 2;
} */
function Created()
{
  bStatusBar = False;
  bSizable = True;

  Super.Created();

  MinWinWidth = 200;
  MinWinHeight = 100;

  SetSizePos();
}

function SetSizePos()
{
  local float W, H;

  if(Root.WinHeight < 400)
    SetSize(B227_DesiredWinWidth(), Min(Root.WinHeight - 32, H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)));
  else
    SetSize(B227_DesiredWinWidth(), Min(Root.WinHeight - 50, /*H + (LookAndFeel.FrameT.H + LookAndFeel.FrameB.H)*/480));

  GetDesiredDimensions(W, H);

  WinLeft = Root.WinWidth/2 - WinWidth/2;
  WinTop = Root.WinHeight/2 - WinHeight/2;
}

function ResolutionChanged(float W, float H)
{
  SetSizePos();
  Super.ResolutionChanged(W, H);
}

function Resized()
{
  if(WinWidth != B227_DesiredWinWidth())
    WinWidth = B227_DesiredWinWidth();

  Super.Resized();
}

//mem hack
function HideWindow()
{
  local uwindowwindow p;
  Super.HideWindow();
  p=root.createwindow(class'uwindowwindow',0,0,1,1,self); //holds this in mem.
  p.bTransient=true;
  p.sendtoback();
}

static function float B227_DesiredWinWidth()
{
	return 320;
}

static function float B227_ControlXOffset()
{
	return (B227_DesiredWinWidth() - 260.0) / 2;
}

defaultproperties
{
     ClientClass=Class'OldSkool.OldSkoolPagesClientWindow'
     WindowTitle="Configure OldSkool"
}
