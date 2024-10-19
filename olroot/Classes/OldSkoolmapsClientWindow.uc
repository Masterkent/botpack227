// ============================================================
//  OldSkool.OldSkoolmapsClientWindow: mostly an edited Umenu and UTmenu start match window......
//  Pretty complex stuff here...
//  no extending becuase 80%+ of the functions are changed around... so match that supers are useless too.....
// ============================================================

class OldSkoolmapsClientWindow expands UMenuDialogClientWindow
Config (OldSkool);
var bool Initialized;
var OldSkoolNewGameClientWindow BotmatchParent;
//used to record the number that the "other maps" is set to...
var int P;

// MapPacks
var UWindowComboControl PackCombo;
var localized string PackText;
var localized string PackHelp;
var string Packs[50];
var int MaxPacks;
//filters out maps found it packs......
var string filtermaps[512];

// Difficulty   (more or less ripped from umenunewgameclientwindow)
var UWindowComboControl SkillCombo;
var UMenuLabelControl SkillLabel;

// Map (if not a map pack)
var UWindowComboControl MapCombo;

// flyby button (only for mappacks w/ flyby's...Unreal/Legacy/Ballad of Ash)   also used for refreshing... a duel function button :D duel function buttons are copyrighted 2000 by UsAaR33.  The copyright office has never seen this though.  Uhh, All rights reserved.
var UWindowSmallButton FlyByButton;
var localized string FlyByText;
var localized string FlyByHelp;
//if true, button is set to refresh.  If false it is set to flyby.  Notify needs to know this...
var bool refreshmode;

// credits button (legacy/unreal/teamvortex only right now)
var UWindowSmallButton creditsButton;
var localized string creditsText;
var localized string creditsHelp;
//playersetup...
var UWindowSmallButton PlayerSetupButton;
//strings to save, so next time this won't take so long :D  (512 sounds cool, ehh? prob. won't EVER get that amount!!)
var globalconfig string LoadedMaps[512];
//first and last maps read..next time it loads, we read from the last map saved and stop at the first map
var config string FirstMap, LastMap;
//bMapsIterated set true when maps are iterated so won't be called ever again....
var bool bMapsIterated;
//bQuickMode variable set in the OldSkool options... with this the menus cache the stuff.......
var config bool bQuickMode;


function Created()
{
  local int i, j, Selection, c, b;
  local class<mappack> TempClass;
  local string NextPack;
  local string TempPacks[50];
  local bool bFoundSavedMapPack;
  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos;
  local int DifficultiesNum;

  log ("Map Client Opened");

  Super.Created();

  DesiredWidth = 270;
  DesiredHeight = 100;

  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;
  //I'm too lasy to chenge this part around, so it will stay as the master for the screenshot editing
  BotmatchParent = OldSkoolNewGameClientWindow(GetParent(class'olroot.oldskoolnewgameclientwindow'));
  //NEVER should happen....... except cause of h4x0rs :D
  if (BotmatchParent == None)
    Log("Error: MapsClientWindow without newgamesclient window.  Stop hacking these scripts you idiot!!!");

  // Mappacks
  PackCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 20, CenterWidth, 1));
  PackCombo.SetButtons(True);
  PackCombo.SetText(PackText);
  PackCombo.SetHelpText(PackHelp);
  PackCombo.SetFont(F_Normal);
  PackCombo.SetEditable(False);


  // Add all map packs.
   NextPack = GetPlayerOwner().GetNextInt("MapPack", 0);
  while (NextPack != "")
  {
   TempClass = Class<mappack>(DynamicLoadObject(NextPack, class'Class'));
    //is the map pack valid?  Note: there is a potential bug here, if a map is called vortex2li for instance, but there was no vortex2, it would still be considered valid, but I doubt this would ever happen.....
      if( GetPlayerOwner().GetMapName(string(TempClass.default.maps[0]), "", 0) != ""){
    TempPacks[i] = NextPack;
    i++; }
    j++;
    //when the loop is complete P will be set to the same index that the custom Maps thingy is...
    p=i;
    NextPack = GetPlayerOwner().GetNextInt("MapPack", j);
  }

   // Fill the control.
  for (i=0; i<50; i++)
  {
    if (TempPacks[i] != "")
    {
      b=0;
      Packs[MaxPacks] = TempPacks[i];
      if ( !bFoundSavedMapPack && (Packs[MaxPacks] ~= BotmatchParent.SelectedPackType) )
      {
        bFoundSavedMapPack = true;
        Selection = MaxPacks;
      }
      TempClass = Class<mappack>(DynamicLoadObject(Packs[MaxPacks], class'Class'));
      PackCombo.AddItem(TempClass.Default.Title);
       //builds list of excluded maps
      while (TempClass.default.maps[b] != ''){
      filtermaps[c]=string(TempClass.default.maps[b]);
      c++;
      b++;}
      MaxPacks++;
    }
  }
  PackCombo.AddItem("Custom Maps");
  if (BotmatchParent.SelectedPackType~="custom")
  PackCombo.SetSelectedIndex(p);
  else
  PackCombo.SetSelectedIndex(Selection);
  if (PackCombo.GetSelectedIndex() != P){
  BotmatchParent.SelectedPackType = Packs[Selection];
  BotmatchParent.SelectedPackClass = Class<Mappack>(DynamicLoadObject(BotmatchParent.SelectedPackType, class'Class'));
  BotmatchParent.Map = string(BotmatchParent.SelectedPackClass.default.maps[0]);}
  else
  BotmatchParent.SelectedPackType = "Custom";

  // Map
  MapCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 45, CenterWidth, 1));
  MapCombo.SetButtons(True);
  MapCombo.SetText(class'umenu.umenustartmatchclientwindow'.default.MapText);
  MapCombo.SetHelpText(class'umenu.umenustartmatchclientwindow'.default.MapHelp);
  MapCombo.SetFont(F_Normal);
  MapCombo.SetEditable(False);
  //only iterate maps if maps bar selected, which would ONLY occur if no map packs were valid.....
  if (PackCombo.GetSelectedIndex() == P){
  if (bQuickMode)
  IterateMapsQuick(BotmatchParent.Map);
  else
  IterateMaps(BotmatchParent.Map);}

  //difficulty:
  SkillLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, 95, CenterWidth, 1));
  SkillCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 70, CenterWidth, 1));
  skillCombo.SetButtons(True);
  SkillCombo.SetText(class'umenu.umenunewgameclientwindow'.default.SkillText);
  SkillCombo.SetHelpText(class'umenu.umenunewgameclientwindow'.default.SkillHelp);
  SkillCombo.SetFont(F_Normal);
  SkillCombo.SetEditable(False);

  DifficultiesNum = int(GetDefaultObject(class'UMenuNewGameClientWindow').GetPropertyText("Skills[]"));
  for (I=0; I<DifficultiesNum; I++)
    SkillCombo.AddItem(class'umenu.umenunewgameclientwindow'.default.Skills[I]);
  //deathmatch plus difficulty info is irrevelent to this....... Ut intro also gives no dif. level...
  if (GetLevel().Game.Difficulty < DifficultiesNum && !GetLevel().Game.Isa('DeathMatchPlus')){
    SkillCombo.SetSelectedIndex(GetLevel().Game.Difficulty);
    BotmatchParent.Difficulty = GetLevel().Game.Difficulty;
  }
  else {
    //defaults at medium
    BotmatchParent.Difficulty=1;
    SkillCombo.SetSelectedIndex(1);
  }
  SkillLabel.SetText(class'UMenu.UMenuNewGameClientWindow'.default.SkillStrings[SkillCombo.GetSelectedIndex()]);
  SkillLabel.Align = TA_Center;


  // Flyby Button
  FlyByButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 120, 48, 16));
  FlyByButton.SetText(FlybyText);
  FlyByButton.SetFont(F_Normal);
  FlyByButton.SetHelpText(FlyByHelp);
  if (PackCombo.GetSelectedIndex() == P){
  If (bQuickMode){
  FlyByButton.SetText("Refresh");
  refreshmode=true;
  FlyByButton.SetHelpText("Press to refresh the map list.  Only needed to be pushed if you have DELETED maps or changed the map paths around.");}
  else
  FlyByButton.HideWindow();
  }

  // Credits Button
  CreditsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 145, 48, 16));
  CreditsButton.SetText(CreditsText);
  CreditsButton.SetFont(F_Normal);
  CreditsButton.SetHelpText(CreditsHelp);

    // Player Setup Button (no use really, but Nemo_NX said to add it....)
  PlayerSetupButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 170, 48, 16));
  //PlayerSetupButton.Align = TA_Center;
  PlayerSetupButton.SetText("Player Setup");
  PlayerSetupButton.SetFont(F_Normal);
  PlayerSetupButton.SetHelpText("Select Digital Representation");

  //flyby or no flyby????? (custom maps of course are set to refresh or nothing....)
  if (PackCombo.GetSelectedIndex() != P){
  If (BotmatchParent.SelectedPackClass.default.flyby=="")
  FlyByButton.HideWindow();
  else
  FlyByButton.ShowWindow();}

  //credits or no credits?
  if (PackCombo.GetSelectedIndex() != P){
  If (BotmatchParent.SelectedPackClass.default.creditswindow==None)
  CreditsButton.HideWindow();
  else
  CreditsButton.ShowWindow();}
  //custom maps can't have credits :D
  else
  CreditsButton.HideWindow();
  Initialized = true;
}
//too many maps bog load time down? like me... load 'em quickly!!!!!!!!
function IterateMapsQuick(string DefaultMap)
{
  local string NextMap, TestMap, WarningMap;
  local int i, k;
  local bool bfirstload, filtered;


  if (Firstmap == ""){
  Log ("Mapclientwindow: First time load detected");
  FirstMap = GetPlayerOwner().GetMapName("", "", 0);
  bfirstload=true;}
  //minor changes.. regarding where it stops....
  if (!bFirstLoad){
  NextMap = LastMap;
  //by the name... alerts if first map was deleted...
  WarningMap = LastMap;
  //add all of the SP maps that are known to exist.....   (-1 so it doesn't load the lastmap twice....)
  MapCombo.Clear();
  for(i=0;i < 512;i++) {
  filtered=false;
  if (loadedmaps[i]=="")//array count doesn't work right, so we must break when this stops....
  break;
  for (k=0; k<Arraycount(loadedmaps); k++){
      if (loadedmaps[i]~=filtermaps[k])
      filtered=true;}
      if (!filtered)
  MapCombo.AddItem(LoadedMaps[i]);
  }
  NextMap = GetPlayerOwner().GetMapName("", LastMap, 1);
  //causes while loop to stop before it starts.....

  //i=max(0,i-1); //would be one ahead.

  while (!(FirstMap ~= nextmap))
  {
     log ("MapClientWindow.adding: "$nextmap);
  //Last Map WILL be the last map read before it goes back to the beginning!!
     filtered=false;
     LastMap=NextMap;
    // Add the map (can't be from various gametypes).
    if(!(Left(NextMap, 2) ~= "Dm")&&!(Left(NextMap, 3) ~= "CTF")&&!(Left(NextMap, 3) ~= "As-")&&!(Left(NextMap, 4) ~= "Dom-")&&!(Left(NextMap, 3) ~= "Sw-")&&!(Left(NextMap, 3) ~= "RA-")&&!(Left(NextMap, 6) ~= "Sftdm-")&&!(Left(NextMap, 7) ~= "ut-logo")&&!(Left(NextMap, 5) ~= "KOTH-")&&!(Left(NextMap, 4) ~= "EOL_")&&!(Left(NextMap, 5) ~= "RACE-")&&!(Left(NextMap, 4) ~= "Usk8")&&!(Left(NextMap, 3) ~= "SH-")&&!(Left(NextMap, 9) ~= "CityIntro")&&!(Left(NextMap, 3) ~= "JS_")&&!(Left(NextMap, 3) ~= "UL-")&&!(Left(NextMap, 9) ~= "UTcredits")&&!(Left(NextMap, 4) ~= "TDK-")&&!(Left(NextMap, 3) ~= "FD-")&&!(Left(NextMap, 3) ~= "JB-")&&!(Left(NextMap, 4) ~= "UNF-")&&Nextmap!="")
      //left kills off the .UNR part :D
      {
      //probably not the best way, but hell it works :D
      for (k=0; k<512; k++){
      if (nextmap~= (filtermaps[k]$".unr"))
      filtered=true;}
      if (!filtered)
      MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4), NextMap);
      //saves each valid map for the next time..... without the UNR extension of course....
      LoadedMaps[i]=Left(NextMap, Len(NextMap) - 4);
      i++;}

    // Get the map.
    NextMap = GetPlayerOwner().GetMapName("", NextMap, 1);

    //This should never occur!!!!! Only used in emergencies!!!!! Caused by deleted the first map...
    if (WarningMap ~= LastMap){
    log ("Critical Error!! First map ever read has been deleted!! Resetting all variables to defaults!!!!");
    LastMap="";
    FirstMap="";
    for(i=0;i<512;i++)
    LoadedMaps[i]="";
    }
    //just so break; can be called and kill the loop......
    if (WarningMap ~= lastmap)
    break;

  }}
  else{
  NextMap = FirstMap;
  while (!(FirstMap ~= TestMap))
     {
    filtered=false;
    //Last Map WILL be the last map read before it goes back to the beginning!!
     LastMap=NextMap;
    // Add the map (can't be from various gametypes).
    if(!(Left(NextMap, 2) ~= "Dm")&&!(Left(NextMap, 3) ~= "CTF")&&!(Left(NextMap, 3) ~= "As-")&&!(Left(NextMap, 4) ~= "Dom-")&&!(Left(NextMap, 3) ~= "Sw-")&&!(Left(NextMap, 3) ~= "RA-")&&!(Left(NextMap, 6) ~= "Sftdm-")&&!(Left(NextMap, 7) ~= "ut-logo")&&!(Left(NextMap, 5) ~= "KOTH-")&&!(Left(NextMap, 4) ~= "EOL_")&&!(Left(NextMap, 5) ~= "RACE-")&&!(Left(NextMap, 4) ~= "Usk8")&&!(Left(NextMap, 3) ~= "SH-")&&!(Left(NextMap, 9) ~= "CityIntro")&&!(Left(NextMap, 3) ~= "JS_")&&!(Left(NextMap, 3) ~= "UL-")&&!(Left(NextMap, 9) ~= "UTcredits")&&!(Left(NextMap, 4) ~= "TDK-")&&!(Left(NextMap, 3) ~= "FD-")&&!(Left(NextMap, 3) ~= "JB-")&&!(Left(NextMap, 4) ~= "UNF-")&&nextmap!="")

      //left kills off the .UNR part :D
      {
      for (k=0; k<512; k++){
      if (nextmap ~= (filtermaps[k]$".unr"))
      filtered=true;}
      if (!filtered)
      MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4), NextMap);
      //saves each valid map for the next time..... without the UNR extension of course....
      LoadedMaps[i]= Left(NextMap, Len(NextMap) - 4);
      i++;}

    // Get the map.
    NextMap = GetPlayerOwner().GetMapName("", NextMap, 1);

    // Test to see if this is the last.
    TestMap = NextMap;
  }}
  //save all the last map, loaded maps, and first map crud......
  SaveConfig();
  MapCombo.Sort();
  bMapsIterated=True;
  MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex2(DefaultMap, True), 0));
}
//crummy slow old way, if user doesn't have many maps...
function IterateMaps(string DefaultMap)
{
  local string NextMap, TestMap, FirstMaplocal;
  local int k;
  local bool filtered;

  FirstMaplocal = GetPlayerOwner().GetMapName("", "", 0);

  NextMap = FirstMaplocal;

  while (!(FirstMaplocal ~= TestMap))
  {
    filtered=false;
    // Add the map (can't be from various gametypes).
    if(!(Left(NextMap, 2) ~= "Dm")&&!(Left(NextMap, 3) ~= "CTF")&&!(Left(NextMap, 3) ~= "As-")&&!(Left(NextMap, 4) ~= "Dom-")&&!(Left(NextMap, 3) ~= "Sw-")&&!(Left(NextMap, 3) ~= "RA-")&&!(Left(NextMap, 6) ~= "Sftdm-")&&!(Left(NextMap, 7) ~= "ut-logo")&&!(Left(NextMap, 5) ~= "KOTH-")&&!(Left(NextMap, 4) ~= "EOL_")&&!(Left(NextMap, 5) ~= "RACE-")&&!(Left(NextMap, 4) ~= "Usk8")&&!(Left(NextMap, 3) ~= "SH-")&&!(Left(NextMap, 9) ~= "CityIntro")&&!(Left(NextMap, 3) ~= "JS_")&&!(Left(NextMap, 3) ~= "UL-")&&!(Left(NextMap, 9) ~= "UTcredits")&&!(Left(NextMap, 4) ~= "TDK-")&&!(Left(NextMap, 3) ~= "FD-")&&!(Left(NextMap, 3) ~= "JB-")&&!(Left(NextMap, 4) ~= "UNF-")&&nextmap!="")
     //left kills off the .UNR part :D
      for (k=0; k<512; k++){
      if (NextMap ~= (filtermaps[k]$".unr"))
      filtered=true;}
      if (!filtered)
      MapCombo.AddItem(Left(NextMap, Len(NextMap) - 4), NextMap);


    // Get the map.
    NextMap = GetPlayerOwner().GetMapName("", NextMap, 1);

    // Test to see if this is the last.
    TestMap = NextMap;
  }
  MapCombo.Sort();
  bMapsIterated=True;
  MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex2(DefaultMap, True), 0));
}
function AfterCreate()
{
  if (PackCombo.GetSelectedIndex() == P){
  BotmatchParent.Map = MapCombo.GetValue2();
  BotmatchParent.screenshotWindow.SetMap(BotmatchParent.Map);
  MapCombo.ShowWindow();
  }
  else {
  BotmatchParent.ScreenshotWindow.SetPack(BotmatchParent.SelectedPackType);
  Mapcombo.HideWindow(); }
}
function BeforePaint(Canvas C, float X, float Y)        //set up size.......
{
  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos;

  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  PackCombo.SetSize(CenterWidth, 1);
  PackCombo.WinLeft = CenterPos;
  PackCombo.EditBoxWidth = 150;


  MapCombo.SetSize(CenterWidth, 1);
  MapCombo.WinLeft = CenterPos;
  MapCombo.EditBoxWidth = 150;

  SkillCombo.SetSize(CenterWidth, 1);
  SkillCombo.WinLeft = CenterPos;
  SkillCombo.EditBoxWidth = 150;

  SkillLabel.SetSize(CenterWidth, 1);
  SkillLabel.WinLeft = CenterPos;

  FlybyButton.AutoWidth(C);
  PlayerSetupbutton.AutoWidth(C);
  CreditsButton.AutoWidth(C);

  FlybyButton.WinWidth = Max(FlybyButton.WinWidth, CreditsButton.WinWidth);
  CreditsButton.WinWidth = FlybyButton.WinWidth;
  PlayerSetupbutton.WinWidth = FlybyButton.WinWidth*1.5;

  FlybyButton.WinLeft = (WinWidth - FlybyButton.WinWidth)/2;
  CreditsButton.WinLeft = (WinWidth - FlybyButton.WinWidth)/2;
  PlayerSetupbutton.WinLeft = (WinWidth - Playersetupbutton.WinWidth)/2;
}

function MapChanged()
{
  if (!Initialized)
    return;

  BotmatchParent.Map = MapCombo.GetValue();
  BotmatchParent.ScreenshotWindow.SetMap(BotmatchParent.Map);
}
function SkillChanged()
{
  SkillLabel.SetText(class'umenu.umenunewgameclientwindow'.default.SkillStrings[SkillCombo.GetSelectedIndex()]);
  BotmatchParent.Difficulty= SkillCombo.GetSelectedIndex();
}

function PackChanged()
{
  local int CurrentPack;
  local class<Mappack> loady;
  if (!Initialized)
    return;

  CurrentPack = PackCombo.GetSelectedIndex();
  if (PackCombo.GetSelectedIndex() != P){
  BotmatchParent.SelectedPackType = Packs[CurrentPack];
  BotmatchParent.SelectedPackClass = Class<Mappack>(DynamicLoadObject(BotmatchParent.SelectedPackType, class'Class'));}
  else
  BotmatchParent.SelectedPackType = "Custom";
   if (PackCombo.GetSelectedIndex() == P){
    MapCombo.Showwindow();
     BotmatchParent.Map = MapCombo.GetValue();

   BotmatchParent.ScreenshotWindow.SetMap(BotmatchParent.Map);
    //only would be true if someone couldn't decide :D
    CreditsButton.HideWindow();
    if (bQuickMode){
    if (!bMapsIterated)
  IterateMapsQuick(BotmatchParent.Map);
    FlyByButton.SetText("Refresh");
     refreshmode=true;
     FlyByButton.ShowWindow();
     FlyByButton.SetHelpText("Press to refresh the map list.  Only needed to be pushed if you have DELETED maps.");}
  else {
   if (!bMapsIterated)
  IterateMaps(BotmatchParent.Map);
  FlyByButton.HideWindow();}}
  else {
    BotmatchParent.ScreenshotWindow.SetPack(BotmatchParent.SelectedPackType);
    MapCombo.HideWindow();
    loady= Class<mappack>(DynamicLoadObject(PackCombo.GetValue(), class'Class'));
    BotmatchParent.Map = string(BotmatchParent.SelectedPackClass.default.maps[0]);
    FlyByButton.SetText(FlyByText);
    FlyByButton.SetHelpText(FlyByHelp);
    refreshmode=false;
     //to flyby or to not flyby?????  that is the question... :D
      If (BotmatchParent.SelectedPackClass.default.flyby=="")
  FlyByButton.HideWindow();
  else
  FlyByButton.ShowWindow();
  //credits or no credits?
  If (BotmatchParent.SelectedPackClass.default.creditswindow==None)
  CreditsButton.HideWindow();
  else
  CreditsButton.ShowWindow();}
}
function flyfresh(){
local int i;
if (refreshmode){
log ("Refreshing lists... deleting all variables...");
    LastMap="";
    FirstMap="";
    for(i=0;i<512;i++)
    LoadedMaps[i]="";
    MapCombo.Clear();
    Iteratemapsquick(BotmatchParent.Map);
}
else{
 BotmatchParent.ParentWindow.Close();
 Root.Console.CloseUWindow();
GetPlayerOwner().ClientTravel( BotmatchParent.SelectedPackClass.default.flyby, TRAVEL_Absolute, False );}
}
function Notify(UWindowDialogControl C, byte E)
{
  Super.Notify(C, E);

  switch(E)
  {
  case DE_Change:
    switch(C)
    {
    case PackCombo:
      PackChanged();
      break;
    case MapCombo:
      MapChanged();
      break;
    case SkillCombo:
        SkillChanged();
        break;
    }
    break;
  case DE_Click:
    switch(C)
    {
    case FlyByButton:
      FlyFresh();
      break;

    case CreditsButton:
     GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(BotmatchParent.SelectedPackClass.default.creditswindow, 0, 0, 100, 100, BotmatchParent));
     break;
    case PlayerSetupButton:
     GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'OldSkoolPlayerWindow', 0, 0, 100, 100, BotmatchParent));
     break;
    }
   break;
  }
}

defaultproperties
{
     PackText="Map Pack:"
     PackHelp="Select the episode of maps to play.  If you want to play an individual map, choose custom maps."
     FlyByText="View FlyBy"
     FlyByHelp="Click the Button to display the FlyBy of this pack.  I recommend you use this, before starting the pack."
     creditsText="Credits"
     creditsHelp="Click this button to see the names of the dedicated people who brought this map pack to you."
     bQuickMode=True
}
