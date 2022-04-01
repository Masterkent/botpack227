// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVCustomMaps : Window simply to select a map with "ONP-" in it and nothing more.....
// ===============================================================

class TVCustomMaps expands TVMonstersMaps;

function Created()
{

  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos;

  Super(UMenuDialogClientWindow).Created();

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
  MapCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 50, CenterWidth, 1));
  MapCombo.SetButtons(True);
  MapCombo.SetText(class'UMenuStartMatchClientWindow'.default.MapText);
  MapCombo.SetHelpText(class'UMenuStartMatchClientWindow'.default.MapHelp);
  MapCombo.SetFont(F_Normal);
  MapCombo.SetEditable(False);
  IterateMaps(BotmatchParent.Map);

  Initialized = True;
}

function IterateMaps(string DefaultMap)
{
  local string FirstMap, NextMap, TestMap;

  FirstMap = GetPlayerOwner().GetMapName("ONP-", "", 0);

  MapCombo.Clear();
  NextMap = FirstMap;

  while (!(FirstMap ~= TestMap))
  {
    // Add the map.
   if (nextmap!="")
      MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4), NextMap);

    // Get the map.
    NextMap = GetPlayerOwner().GetMapName("ONP-", NextMap, 1);

    // Text to see if this is the last.
    TestMap = NextMap;
  }
  //now filter out:
  MapCombo.Sort();

  MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex2(DefaultMap, True), 0));
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
}

defaultproperties
{
}
