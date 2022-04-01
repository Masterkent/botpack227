// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVMonsterSmashWindow : The framed window for monster smash. smash 'em!
// ===============================================================

class TVMonsterSmashWindow expands UMenuFramedWindow;

function Created()
{
  bStatusBar = False;
  bSizable = False;

  Super.Created();

  SetSizePos();
}

function SetSizePos()
{
  if(Root.WinHeight < 290)
    SetSize(Min(Root.WinWidth-10, 520) , 220);
  else
    SetSize(Min(Root.WinWidth-10, 520), 270);

  WinLeft = Root.WinWidth/2 - WinWidth/2;
  WinTop = Root.WinHeight/2 - WinHeight/2;
}

function ResolutionChanged(float W, float H)
{
  SetSizePos();
  Super.ResolutionChanged(W, H);
}

defaultproperties
{
     ClientClass=Class'olextras.TVMonsterclient'
     WindowTitle="MoNsTeRSmASH"
}
