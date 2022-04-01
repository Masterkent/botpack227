// ============================================================
// oldskool.OldSkoolLoadGameClientWindow: Load the game...
// ============================================================

class OldSkoolLoadGameClientWindow extends OldSkoolSlotClientWindow;
var UMenuRaisedButton RestartButton;
//Pack vars...
var UWindowComboControl PackCombo;
var localized string PackHelp;
var string Packs[50];
var int MaxPacks;
var int P;

function Created()
{
  local int I, j, Selection, A, B;
  local class<Mappack> TempClass;
  local string NextPack;
  local string TempPacks[50];
  local bool bFoundSavedMapPack;
  local int ButtonWidth, ButtonLeft, ButtonTop;
  local int CenterWidth, CenterPos;

  Super.Created();

   DesiredWidth = 350;
  DesiredHeight = 575;
    // Mappacks
  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;
  PackCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 10, CenterWidth, 1));
  PackCombo.SetButtons(True);
  PackCombo.SetText("Map Pack:");
  PackCombo.SetHelpText(PackHelp);
  PackCombo.SetFont(F_Normal);
  PackCombo.SetEditable(False);


  // Add all map packs.
   NextPack = GetPlayerOwner().GetNextInt("MapPack", 0);
  //Custom has to be set to 0....

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
      Packs[MaxPacks] = TempPacks[i];
      if ( !bFoundSavedMapPack && (Packs[MaxPacks] ~= class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType) )
      {
        bFoundSavedMapPack = true;
        Selection = MaxPacks+1;
      }
      TempClass = Class<mappack>(DynamicLoadObject(Packs[MaxPacks], class'Class'));
      PackCombo.AddItem(TempClass.Default.Title);
    }
      MaxPacks++;
  }

  PackCombo.AddItem("Custom Map Saves");
  If (Selection==0)
  Selection=P;
  else
  //reduce it by one...
  Selection--;
  PackCombo.SetSelectedIndex(Selection);


//save loading.....
   if (!(class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType ~= "custom")){
  for (A=1; A<50; A++){
  //unless the INI is corrupt the "" are empty classes......
  if ((class'olroot.oldskoolslotclientwindow'.default.Packsaves[A]~=class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType) || (class'olroot.oldskoolslotclientwindow'.default.Packsaves[A]==""))
  q=A;
  if (q != 0)
  break;    //stops for?
  }
  If (class'olroot.oldskoolslotclientwindow'.default.Packsaves[Q]==""){
  class'olroot.oldskoolslotclientwindow'.default.Packsaves[Q]=class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType;
  /*class'olroot.oldskoolslotclientwindow'.static.staticSaveConfig();*/}
  }
  //now we load the save labels........... (wow, what big math I use :D) A is the names (range 0 to 999) B is the actual slot (range 0 to 19)
  for (A=(20*q); A<(20*Q+20); A++){
  If (class'olroot.oldskoolslotclientwindow'.default.SlotNames[A] != "")
  Slots[B].SetText(class'olroot.oldskoolslotclientwindow'.default.SlotNames[A]);
  else
  Slots[B].SetText("..Empty..");
  b++;
  }
  //restart stuff
  ButtonWidth = WinWidth - 60;
  ButtonLeft = (WinWidth - ButtonWidth)/2;

  ButtonTop = 25 + 25*21;
  RestartButton = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
  RestartButton.SetText("Restart"@GetLevel().Title);
  RestartButton.SetHelpText("Press to restart the current level.");
  if (Getlevel().Game==None||!GetLevel().Game.IsA('SinglePlayer2')){
  RestartButton.SetText("QuickSave");
  RestartButton.SetHelpText("Press to load your quicksave.");
  if (class'olroot.OldSkoolSlotClientWindow'.default.quicksavetype=="")
  Restartbutton.HideWindow();
  }

}

function BeforePaint(Canvas C, float X, float Y)
{
  local int ButtonWidth, ButtonLeft;
  local int CenterWidth, CenterPos;

  Super.BeforePaint(C, X, Y);

  ButtonWidth = WinWidth - 60;
  ButtonLeft = (WinWidth - ButtonWidth)/2;

    CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  RestartButton.SetSize(ButtonWidth, 1);
  RestartButton.WinLeft = ButtonLeft;

  PackCombo.SetSize(CenterWidth, 1);
  PackCombo.WinLeft = CenterPos;
  PackCombo.EditBoxWidth = 150;
}

function PackChanged()
{
  local int CurrentPack, A, B;
  //save loading.....
  Q=0;
  CurrentPack = PackCombo.GetSelectedIndex();
  if (!(PackCombo.GetValue() ~= "custom map saves")){
  for (A=1; A<50; A++){
  //unless the INI is corrupt the "" are empty classes......  (loading can build the P too....
  if ((class'olroot.oldskoolslotclientwindow'.default.Packsaves[A]==Packs[CurrentPack]) || (class'olroot.oldskoolslotclientwindow'.default.Packsaves[A]==""))
  q=A;
  //I haven't fully understood break... I'm too lazy to recompile if it fails...... break if q assigned...
  if (q != 0)
  break;
  }
  If (class'olroot.oldskoolslotclientwindow'.default.Packsaves[Q]==""){
  class'olroot.oldskoolslotclientwindow'.default.Packsaves[Q]=class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType;
  }}
  //now we load the save labels........... (wow, what big math I use :D) A is the names (range 0 to 999) B is the actual slot (range 0 to 19)
  for (A=(20*q); A<(20*Q+20); A++){
  If (class'olroot.oldskoolslotclientwindow'.default.SlotNames[A] != "")
  Slots[B].SetText(class'olroot.oldskoolslotclientwindow'.default.SlotNames[A]);
  else
  Slots[B].SetText("..Empty..");
  b++;

 }}
function ClosePressed(optional bool bByParent)
{
    local UWindowWindow Prev, Child;

  for(Child = LastChildWindow;Child != None;Child = Prev)
  {
    Prev = Child.PrevSiblingWindow;
    Child.Close(True);
  }

    HideWindow();
    ParentWindow.Close(bByParent);
    Root.Console.CloseUWindow();
}
function Notify(UWindowDialogControl C, byte E)
{
  local int I, CurrentPack;
  local int Selection;
  local class<mappack> packclass;

  Super.Notify(C, E);

  switch(E)
  {
  case DE_Change:

      PackChanged();
      break;

  case DE_Click:
    if ( C == RestartButton )
    {
      if (GetLevel().Game.IsA('SinglePlayer2'))
      Root.GetPlayerOwner().ReStartLevel();
      else {
      CurrentPack = PackCombo.GetSelectedIndex();
  if (class'olroot.OldSkoolSlotClientWindow'.default.quicksavetype ~= "Custom")
  PackClass = Class<Mappack>(DynamicLoadObject(class'olroot.OldSkoolSlotClientWindow'.default.quicksaveType, class'Class'));
    if ((packclass != None)&&(packclass.default.loadrelevent)) {          //a gameinfo should turn this off.....
    packclass.default.bLoaded = true;
    packclass.static.StaticSaveConfig(); }
    //to fix the stupid loading bug.....    hopfully travel_absolute is on and the second thing is set to false by default... (damn native funtions :()
    //the loading is so screwed up that the \ has to be used twice (don't ask why...)
    //Root.GetPlayerOwner().ConsoleCommand( "open ..\\save\\save1000.usa");
    GetPlayerOwner().ClientTravel( "?load=1000", TRAVEL_Absolute, false);
    }
    ClosePressed();                         //closes u-window and DOESN'T save configs......
    return;
    }

    else if ( UMenuRaisedButton(C).Text ~= "..Empty.." )
    {
      return;
    }

    else{ for (I=0; I<20; I++)
    {
      if (C == Slots[I])
      Selection = Q*20+I;
    }

  CurrentPack = PackCombo.GetSelectedIndex();
  if (PackCombo.GetValue() != "Custom Map Saves") {
  class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType = Packs[CurrentPack];
  PackClass = Class<Mappack>(DynamicLoadObject(class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType, class'Class'));  }
  else
  class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType = "Custom";
  class'olroot.OldSkoolNewGameClientWindow'.static.StaticSaveConfig();
    //to fix the stupid loading bug.....    hopfully travel_absolute is on and the second thing is set to false by default... (damn native funtions :()
    //the loading is so screwed up that the \ has to be used twice (don't ask why...)
    if ((packclass != None)&&(packclass.default.loadrelevent)) {
    packclass.default.bLoaded = true;
    packclass.static.StaticSaveConfig(); }
    //Root.GetPlayerOwner().ConsoleCommand( "open ..\\save\\save"$Selection$".usa");
    GetPlayerOwner().ClientTravel( "?load="$Selection, TRAVEL_Absolute, false);
    ClosePressed();}
    break;
  }
  }

defaultproperties
{
     PackHelp="Select the episode of maps to load from.  Select Custom Map Saves to load a save from a custom map."
     SlotHelp="Press to Load a game from this slot"
}
