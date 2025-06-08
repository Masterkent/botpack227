// ============================================================
// OldSkool.OldSkoolNewGameClientWindow: I felt like copying stuff thus all this does is split a main window and the screenshot...
// ============================================================

class OldSkoolNewGameClientWindow expands UWindowDialogClientWindow
config (OldSkool);
var OldSkoolScreenshotCW ScreenshotWindow;
var OldSkoolMapsClientWindow Mapwindow;
var localized string StartText;
var UWindowSmallButton StartButton;
var UWindowSmallButton coopButton;
var UWindowSmallButton CloseButton;
var UWindowHSplitter Splitter;
var config string MutatorList;
var config string Map, SelectedPackType;
var int Difficulty;
var class<MapPack> SelectedPackclass;


function Created()
{
  Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
  Splitter.SplitPos = 280;
  Splitter.MaxSplitPos = 280;
  Splitter.bRightGrow = True;
   //screenshot and map split.....
  ScreenshotWindow = OldSkoolScreenshotCW(Splitter.CreateWindow(class'olroot.OldSkoolScreenshotCW', 0, 0, WinWidth, WinHeight));
  Mapwindow = OldSkoolMapsClientWindow(Splitter.CreateWindow(class'olroot.OldSkoolmapsclientwindow', 0, 0, WinWidth, WinHeight));

  Splitter.LeftClientWindow = MapWindow;
  Splitter.RightClientWindow = ScreenshotWindow;

  CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
  StartButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16));
  coopButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-156, WinHeight-24, 48, 16));
  StartButton.SetText(class'umenu.umenubotmatchclientwindow'.default.StartText);    ///localization
  CloseButton.SetText(class'uwindow.uwindowsmallclosebutton'.default.closetext);
  CoopButton.SetText("Co-op");
    /*stupid PD menu music thing :D
      MenuSong = Music(DynamicLoadObject("oldskoolmenu.perfectmenu", class'Music'));
      GetPlayerOwner().ClientSetMusic( MenuSong, 0, 0, MTRAN_Fade );       */


  Super.Created();
}

function Resized()
{
  if(ParentWindow.WinWidth == 520)
  {
    Splitter.bSizable = False;
    Splitter.MinWinWidth = 0;
  }
  else
    Splitter.MinWinWidth = 100;

  Splitter.WinWidth = WinWidth;
  Splitter.WinHeight = WinHeight - 24;  // OK, Cancel area

  CloseButton.WinLeft = WinWidth-52;
  CloseButton.WinTop = WinHeight-20;
   coopButton.WinLeft = WinWidth-152;
 coopButton.WinTop = WinHeight-20;
  StartButton.WinLeft = WinWidth-102;
  StartButton.WinTop = WinHeight-20;
}

function Paint(Canvas C, float X, float Y)
{
  local Texture T;

  T = GetLookAndFeelTexture();
  DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
}

function Notify(UWindowDialogControl C, byte E)
{
  Super.Notify(C, E);

  switch(E)
  {
  case DE_Click:
    switch (C)
    {
    case StartButton:
      StartPressed();
      break;
    case closeButton:
      ClosePressed();
      break;

    case coopbutton:
    GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class<uwindowwindow>(Dynamicloadobject("oldskool.coopwindow", class'class')), 0, 0, 100, 100, self));
      break;
    }
    break;
  }
}

function StartPressed()
{
  local string URL;
  if (selectedpackclass.default.additionalmenu==None&&!(selectedpacktype~="custom"))
  URL = Map$"?Game="$selectedpackclass.default.spgameinfo$"?Difficulty="$difficulty$"?Mutator="$MutatorList;
  else if (selectedpacktype~="custom")
  URL = Map$"?Game=oldskool.singleplayer2?Difficulty="$difficulty$"?Mutator="$MutatorList;
  else{
  GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(SelectedPackClass.default.additionalmenu, 0, 0, 100, 100));
  return;}
  ParentWindow.Close();
  Root.Console.CloseUWindow();
  GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}

//we don't want to save configs... I probably would have gotton away with simply overriding close, but I didn't feel like doind extensive testing......   by parent not even needed! LOL! I'm lazy :D
function ClosePressed(optional bool bByParent)
{
    local UWindowWindow Prev, Child;

  for(Child = LastChildWindow;Child != None;Child = Prev)
  {
    Prev = Child.PrevSiblingWindow;
    Child.Close(True);
  }
  if(!bByParent)
    //-HideWindow();
    ParentWindow.Close(bByParent);
}
function SaveConfigs()
{
  Super.SaveConfigs();
  SaveConfig();
}

defaultproperties
{
     StartText="Start"
     Map="Vortex2"
     SelectedPackType="oldskool.origunreal"
}
