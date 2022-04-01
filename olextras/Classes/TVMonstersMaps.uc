// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVMonstersMaps : Map/setting chooser
// ===============================================================

class TVMonstersMaps expands UMenuDialogClientWindow;

var TVMonsterclient BotmatchParent;

var bool Initialized;

// Map
var UWindowComboControl MapCombo;

// Map List Button
var UWindowSmallButton MapListButton;

var UWindowEditControl NumMonsters, NumAllies; //number edit.

function Created()
{

  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos;

  Super.Created();

  DesiredWidth = 270;
  DesiredHeight = 100;

  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  BotmatchParent = TVMonsterclient(GetParent(class'TVMonsterclient'));
  if (BotmatchParent == None)
    Log("Error: TVMonstersMaps without TVMonsterclient parent.");

  // Map
  MapCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 20, CenterWidth, 1));
  MapCombo.SetButtons(True);
  MapCombo.SetText(class'UMenuStartMatchClientWindow'.default.MapText);
  MapCombo.SetHelpText(class'UMenuStartMatchClientWindow'.default.MapHelp);
  MapCombo.SetFont(F_Normal);
  MapCombo.SetEditable(False);
  IterateMaps(BotmatchParent.Map);

  // Map List Button
  MapListButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 45, 48, 16));
  MapListButton.SetText(class'UMenuStartMatchClientWindow'.default.MapListText);
  MapListButton.SetFont(F_Normal);
  MapListButton.SetHelpText(class'UMenuStartMatchClientWindow'.default.MapListHelp);

  NumMonsters = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, 70, CenterWidth, 1));
  NumMonsters.SetText("Number of Monsters");
  NumMonsters.SetHelpText("The amount of Monsters that will be spawned gradually after the game begins.  Winning occurs when all are killed.");
  NumMonsters.SetFont(F_Normal);
  NumMonsters.SetNumericOnly(True);
  NumMonsters.SetMaxLength(2);

  NumAllies = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, 95, CenterWidth, 1));
  NumAllies.SetText("Number of Allies");
  NumAllies.SetHelpText("The amount of allies that will be spawned when the game begins.");
  NumAllies.SetFont(F_Normal);
  NumAllies.SetNumericOnly(True);
  NumAllies.SetMaxLength(1);

  Initialized = True;
}

//original function
function IterateMaps(string DefaultMap)
{
  local string FirstMap, NextMap, TestMap;

  FirstMap = GetPlayerOwner().GetMapName(BotmatchParent.GameClass.Default.MapPrefix, "", 0);

  MapCombo.Clear();
  NextMap = FirstMap;

  while (!(FirstMap ~= TestMap))
  {
    // Add the map.
   if (nextmap!="" && (Left(NextMap, 2) ~= "Dm"||Left(NextMap, 3) ~= "CTF"||Left(NextMap, 3) ~= "As-"||Left(NextMap, 4) ~= "Dom-"||Left(NextMap, 3) ~= "Sw-"||Left(NextMap, 6) ~= "Sftdm-"||Left(NextMap, 5) ~= "KOTH-"||Left(NextMap, 5) ~= "RACE-"||Left(NextMap, 3) ~= "SH-"||Left(NextMap, 4) ~= "TDK-"||Left(NextMap, 3) ~= "FD-"||Left(NextMap, 3) ~= "JB-"||Left(NextMap, 4) ~= "UNF-") && InSTR(caps(NextMap),"TUTORIAL")==-1)
      MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4), NextMap);

    // Get the map.
    NextMap = GetPlayerOwner().GetMapName(BotmatchParent.GameClass.Default.MapPrefix, NextMap, 1);

    // Text to see if this is the last.
    TestMap = NextMap;
  }
  //now filter out:
  MapCombo.Sort();

  MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex2(DefaultMap, True), 0));
}

/*   //TEST ONLY!!!!!!!!
function IterateMaps(string DefaultMap)
{
  local string Maps[8];
  local string FirstMap, NextMap, TestMap;
  local int Selected;
  local int i;
  Maps[0]="dm-deck16][.unr";
  Maps[1]="ctf-coret.unr";
  Maps[2]="np19part2chico.unr";
  Maps[3]="dom-sesmar.unr";
  Maps[4]="as-overlord.unr";
  Maps[5]="ctf-face.unr";
  Maps[6]="dm-tutorial.unr";
  Maps[7]="dm-deck16][.unr";
  FirstMap = Maps[i];

  MapCombo.Clear();
  NextMap = FirstMap;

  while (!(FirstMap ~= TestMap))
  {
    // Add the map.
    if (nextmap!="" && (Left(NextMap, 2) ~= "Dm"||Left(NextMap, 3) ~= "CTF"||Left(NextMap, 3) ~= "As-"||Left(NextMap, 4) ~= "Dom-"||Left(NextMap, 3) ~= "Sw-"||Left(NextMap, 6) ~= "Sftdm-"||Left(NextMap, 5) ~= "KOTH-"||Left(NextMap, 5) ~= "RACE-"||Left(NextMap, 3) ~= "SH-"||Left(NextMap, 4) ~= "TDK-"||Left(NextMap, 3) ~= "FD-"||Left(NextMap, 3) ~= "JB-"||Left(NextMap, 4) ~= "UNF-") && InSTR(caps(NextMap),"TUTORIAL")==-1)
      MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4), NextMap);

    i++;
    NextMap = Maps[i];
    // Text to see if this is the last.
    TestMap = NextMap;

  }
  //now filter out:
  MapCombo.Sort();

  MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex2(DefaultMap, True), 0));
}
  */
function AfterCreate()
{
  BotmatchParent.Map = MapCombo.GetValue2();
  BotmatchParent.ScreenshotWindow.SetMap(BotmatchParent.Map);
  if (NumAllies!=none)
    NumAllies.SetValue(string(class'MonsterSmash'.Default.NumFollowers));
  if (NumMonsters!=none)
    NumMonsters.SetValue(string(class'MonsterSmash'.Default.NumMonsters));
}

function BeforePaint(Canvas C, float X, float Y)
{
  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos;

  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  MapCombo.SetSize(CenterWidth, 1);
  MapCombo.WinLeft = CenterPos;
  MapCombo.EditBoxWidth = 150;

  NumAllies.SetSize(CenterWidth, 1);
  NumAllies.WinLeft = CenterPos;
  NumAllies.EditBoxWidth = 50;

  NumMonsters.SetSize(CenterWidth, 1);
  NumMonsters.WinLeft = CenterPos;
  NumMonsters.EditBoxWidth = 50;

  MapListButton.AutoWidth(C);
  MapListButton.WinWidth = MapListButton.WinWidth;
  MapListButton.WinLeft = (WinWidth - MapListButton.WinWidth)/2;
}

function Notify(UWindowDialogControl C, byte E)
{
  Super.Notify(C, E);

  switch(E)
  {
  case DE_Change:
    switch(C)
    {
    case MapCombo:
      MapChanged();
      break;
    case NumMonsters:
      class'MonsterSmash'.default.NumMonsters = int(NumMonsters.GetValue());
      break;
    case NumAllies:
      if (int(NumAllies.GetValue()) > 8)
        NumAllies.SetValue("8");
      class'MonsterSmash'.default.NumFollowers = int(NumAllies.GetValue());
      break;
    }
    break;
  case DE_Click:
    switch(C)
    {
    case MapListButton:
      GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'MonsterMapListWindow', 0, 0, 100, 100, self));
      break;
    }
  }
}

function MapChanged()
{
  if (!Initialized)
    return;

  BotmatchParent.Map = MapCombo.GetValue2();
  BotmatchParent.ScreenshotWindow.SetMap(BotmatchParent.Map);
}

defaultproperties
{
}
