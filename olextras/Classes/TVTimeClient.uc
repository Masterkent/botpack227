// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVTimeClient : Actual time listings
// ===============================================================

class TVTimeClient expands UMenuDialogClientWindow;
var string MapTimes[36];

function CutInfo(out string Info, out int i){
  Info=mid(Info,i+1);
  i=instr(Info,chr(17));
}

function SetTime (string Time){
  local int i, pos;
  pos=-1;
  for (i=0;i<36;i++){
    CutInfo(Time,pos);
    if (pos==-1)
      return;
    MapTimes[i]=class'TVHSCLient'.static.GetTime(left(time,pos));
  }
}
function WriteText(canvas C, string text, out float Y, optional bool Right){
  local float W, H;
  if (Right){
    TextSize(C, text, W, H);
    if (UWindowScrollingDialogClient(ParentWindow).bShowVertSB)
      W+=UWindowScrollingDialogClient(ParentWindow).VertSb.WinWidth;
    ClipText(C, WinWidth - W - 5, Y, text, true);
  }
  else
    ClipText(C, 5, Y, text, true);
  if (Right)
    Y+=H+4;
}

//entry point of render info.
function Paint(Canvas C, float X, float Y)
{
  local int i;
  Super.Paint(C,X,Y);
  //Set black:
  c.drawcolor.R=0;
  c.drawcolor.G=0;
  c.drawcolor.B=0;
  C.Font=root.fonts[F_Bold];
  Y=5;
  for (i=0;i<36;i++){
    if (MapTimes[i]=="")
      return;
    WriteText(C, string(i+1)$". "$class'TeamVortex'.default.MapTitles[i], Y);
    WriteTEXT(C,MapTimes[i],Y,true);
  }
  DesiredHeight=Y+11;
}

defaultproperties
{
}
