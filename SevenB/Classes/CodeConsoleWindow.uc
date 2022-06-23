// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// CodeConsoleWindow. This uwindow is the input consolewindow for the codeconsole.
// Painted as a translator area.
// note that it will not accept any key other than a number. This includes backspaces as well (for it is meant to emulate a code system, and backspaces are not allowed)
// ============================================================

class CodeConsoleWindow expands UWindowWindow;
var codeconsole CC;   //the code console
var string TypedCode; //code being typed.

//draw like a translator window
function Paint(Canvas Canvas, float X, float Y)
{
  local float tempx, tempy;
  local byte oldstyle;
  local float XL, YL;
  local float Scale;

  if (root.buwindowactive||!bAcceptsFocus)
    return;
  Canvas.Reset();
  Canvas.bCenter = false;
  Canvas.Font = class'FontInfo'.static.GetStaticSmallFont(class'UTC_HUD'.static.B227_ScaledFontScreenWidth(Canvas));
  Canvas.SetClip(Root.RealWidth,Root.RealHeight);
  TempX = Canvas.CurX;
  TempY = Canvas.CurY;
  oldstyle=canvas.style;
  Canvas.Style = 2;
  Canvas.DrawColor.g = 255;
  Canvas.DrawColor.r = 255;
  Canvas.DrawColor.b = 255;
  Scale = FMax(1.0, FMin(Canvas.SizeX, Canvas.SizeY * 4 / 3) / 640);
  Canvas.SetPos(Root.RealWidth/2 - 128 * Scale, Root.RealHeight/2 - 68 * Scale);
  Canvas.DrawIcon(texture'TranslatorHUD3', Scale);
  Canvas.SetPos(Root.RealWidth/2 - 110 * Scale, Root.RealHeight/2 - 52 * Scale);
  Canvas.Style = 1;
  Canvas.DrawColor.R = 0;
  Canvas.DrawColor.B = 0;
  Canvas.DrawText(CC.SecurityPrompt, False);
  Canvas.StrLen("T", XL, YL);
  Canvas.SetPos(Root.RealWidth/2 - 110 * Scale, Root.RealHeight/2 - 52 * Scale + YL);
  Canvas.DrawText("(> "$TypedCode$"_", False);
  Canvas.CurX = TempX;
  Canvas.CurY = TempY;
  Canvas.Style=OldStyle;
  Canvas.Reset();
}

function KeyDown( int Key, float MouseX, float MouseY )
{
  if( Key>=0x30 && Key<=0x39 )  //numberic only
  {
//     log ("key is "$key$" which is in ASC"@chr(key);
     typedcode=typedcode$chr(key);
     if (len(typedcode)==CC.digits){
     //  log ("code test");
       CC.TestCode(tvplayer(getplayerowner()),int(typedcode));
       close();  //done so close this.
     }
     else if (CC.KeyEnterSound!=none) //sound
       CC.PlaySound(CC.KeyEnterSound, SLOT_Misc);
  }
  else if (Key == 0x8) // backspace
    TypedCode = Left(TypedCode, Max(0, Len(TypedCode) - 1));
}
function created(){ //hack to hide mouse.
   // log ("CREATING code console window");
  root.console.bquickkeyenable=false;
  SetAcceptsFocus(); //very important :D
}

//closing menu stuff:
function Close(optional bool bByParent)
{
  //log ("closing code console window");
  CC.bActive=false;
  bwindowvisible=true;
  bleaveonscreen=false;
  CancelAcceptsFocus();
  HideWindow();
  Root.Console.CloseUWindow();
}

function NotifyBeforeLevelChange(){ //if new level, remove window
  close();
}

defaultproperties
{
     bLeaveOnscreen=True
}
