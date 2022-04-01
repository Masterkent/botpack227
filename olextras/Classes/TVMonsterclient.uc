// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVMonsterclient : The main "splitter".
// ===============================================================

class TVMonsterclient expands UMenuBotmatchClientWindow; //I really don't like this, but must for maplist support.

// Window
var TVMonstersMaps Maps;
var class<TVMonstersMaps> MapWindow;
var string GameString;

function Created()
{

  Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
  Splitter.SplitPos = 280;
  Splitter.MaxSplitPos = 280;
  Splitter.bRightGrow = True;

  ScreenshotWindow = UMenuScreenshotCW(Splitter.CreateWindow(class'UMenuScreenshotCW', 0, 0, WinWidth, WinHeight));

  Maps = TVMonstersMaps(Splitter.CreateWindow(Mapwindow, 0, 0, WinWidth, WinHeight));

  Splitter.LeftClientWindow = Maps;
  Splitter.RightClientWindow = ScreenshotWindow;

  CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
  StartButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-106, WinHeight-24, 48, 16));
  StartButton.SetText(StartText);

  Super(UWindowDialogClientWindow).Created();
}

function StartPressed()
{
  local string URL;

  // Reset the game class.
  GameClass.Static.ResetGame();

  URL = Map $ "?Game="$GameString$"?Difficulty="$OldSkoolNewGameClientWindow(root.FindChildWindow(class'OldSkoolNewgameClientwindow',true)).difficulty$"?Mutator="$class'OldSkoolNewGameClientWindow'.default.MutatorList;

  ParentWindow.Close();
  root.FindChildWindow(class'OldSkoolNewgamewindow',true).Close();
  root.FindChildWindow(class'TutMSGWin',true).Close();
  Root.Console.CloseUWindow();
  GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
}

defaultproperties
{
     Mapwindow=Class'olextras.TVMonstersMaps'
     GameString="olextras.MonsterSmash"
     GameClass=Class'olextras.MonsterSmash'
}
