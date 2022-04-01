// ============================================================
// oldskool.OldSkoolSlotClientWindow: Edited Umenu slot client...
// ============================================================

class OldSkoolSlotClientWindow expands UMenuDialogClientWindow
  config(oldskool);
//why 1000? 50 map packs are possible and with each having 20 saves each...it's called multiplication... note 1000 saves will make the ini PRETTY big.. Save1000.usa BTW is the quicksave......
var globalconfig string SlotNames[1000];
var globalconfig string Packsaves[50];
var localized string MonthNames[12];
var localized string SlotHelp;
var UMenuRaisedButton Slots[20];
var globalconfig string quicksavetype;
var int q;

function Created()
{
  local int ButtonWidth, ButtonLeft, ButtonTop, I;

  Super.Created();

  ButtonWidth = WinWidth - 60;
  ButtonLeft = (WinWidth - ButtonWidth)/2;


  for (I=0; I<20; I++)
  {
    ButtonTop = 35 + 25*I;
    Slots[I] = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
    Slots[I].SetHelpText(SlotHelp);
  }

}

function BeforePaint(Canvas C, float X, float Y)
{
  local int ButtonWidth, ButtonLeft, I;

  ButtonWidth = WinWidth - 60;
  ButtonLeft = (WinWidth - ButtonWidth)/2;

  for (I=0; I<20; I++)
  {
    Slots[I].SetSize(ButtonWidth, 1);
    Slots[I].WinLeft = ButtonLeft;
  }
}

defaultproperties
{
     Packsaves(0)="Custom"
     MonthNames(0)="January"
     MonthNames(1)="February"
     MonthNames(2)="March"
     MonthNames(3)="April"
     MonthNames(4)="May"
     MonthNames(5)="June"
     MonthNames(6)="July"
     MonthNames(7)="August"
     MonthNames(8)="September"
     MonthNames(9)="October"
     MonthNames(10)="November"
     MonthNames(11)="December"
     SlotHelp="Press to activate this slot. (Save/Load)"
}
