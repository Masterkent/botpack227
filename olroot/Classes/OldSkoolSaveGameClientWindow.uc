// ============================================================
// oldskool.OldSkoolSaveGameClientWindow: The modified save game window.....
// ============================================================

class OldSkoolSaveGameClientWindow extends OldSkoolSlotClientWindow;
//var OldSkoolNewGameClientWindow Classholder;
var int q;         //default tells Legacy about oldskool version.
var string skills[4];

function created(){
local int a,b;
  super.created();
  q=0; //reinitialize.
  DesiredWidth = 350;
  DesiredHeight = 555;

//save loading.....
   if (!(class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType ~= "custom")){
  for (A=1; A<50; A++){
  //unless the INI is corrupt the "" are empty classes......
  if ((class'olroot.oldskoolslotclientwindow'.default.Packsaves[A]~=class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType) || (class'olroot.oldskoolslotclientwindow'.default.Packsaves[A]==""))
  q=A;
  //I haven't fully understood break... I'm too lazy to recompile if it fails...... break if q assigned...
  if (q != 0)
  break;
  }
  If (class'olroot.oldskoolslotclientwindow'.default.Packsaves[Q]==""){
  class'olroot.oldskoolslotclientwindow'.default.Packsaves[Q]=class'olroot.oldskoolnewgameclientwindow'.default.SelectedPackType;
  class'olroot.oldskoolslotclientwindow'.Static.staticSaveConfig();}
  }
  //now we load the save labels........... (wow, what big math I use :D) A is the names (range 0 to 999) B is the actual slot (range 0 to 19)
  for (A=(20*q); A<(20*Q+20); A++){
  If (class'olroot.oldskoolslotclientwindow'.default.SlotNames[A] != "")
  Slots[B].SetText(class'olroot.oldskoolslotclientwindow'.default.SlotNames[A]);
  else
  Slots[B].SetText("..Empty..");
  b++;
  }
   }

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

  local int I;
  local int Selection;

  Super.Notify(C, E);

  switch(E)
  {
  //should never get here, but just in case....
  case DE_Click:
    if ( GetPlayerOwner().Health <= 0 )
      return;

    if ( GetLevel().Minute < 10 )
      UMenuRaisedButton(C).SetText(GetLevel().Title@"on"@skills[GetLevel().Game.Difficulty]@GetLevel().Hour$"\:0"$GetLevel().Minute$" "$MonthNames[GetLevel().Month - 1]@GetLevel().Day);
    else
      UMenuRaisedButton(C).SetText(GetLevel().Title@"on"@skills[GetLevel().Game.Difficulty]@GetLevel().Hour$"\:"$GetLevel().Minute@MonthNames[GetLevel().Month - 1]@GetLevel().Day);
    /*why the hell is this here???????????? I don't even think it is implamented... but I'll leave it, just for Beta testing...
    if ( GetLevel().NetMode != NM_Standalone )
      UMenuRaisedButton(C).SetText("Net:"$UMenuRaisedButton(C).Text);  */
    log ("Q= "$Q);
    for (I=0; I<20; I++)
      if (C == Slots[I])
        Selection = Q*20+I;

    class'olroot.oldskoolslotclientwindow'.default.SlotNames[Selection] = UMenuRaisedButton(C).Text;
    class'olroot.oldskoolslotclientwindow'.static.staticSaveConfig();

    Root.GetPlayerOwner().ConsoleCommand("SaveGame "$Selection);
    ClosePressed();
    break;
  }
}

defaultproperties
{
     q=2
     Skills(0)="Easy"
     Skills(1)="Medium"
     Skills(2)="Hard"
     Skills(3)="Unreal"
     SlotHelp="Press to Save a game to this slot"
}
