// ============================================================
// olroot.oldskoolPlayerSetupScrollClient: allows dynamic swapping of client-class
// ============================================================

class oldskoolPlayerSetupScrollClient expands UMenuPlayerSetupScrollClient;
function created(){
if (ownerwindow.Isa('oldskoolnewgameclientwindow')){          //don't ask :D
if  (OldSkoolNewGameClientWindow(ownerwindow).selectedpacktype ~= "custom")
Clientclass=class'olroot.oldskoolplayersetupclient';
else
Clientclass=OldSkoolNewGameClientWindow(ownerwindow).SelectedPackclass.default.playerwindow;
}
else
ClientClass = class'olUTPlayerSetupClient';
  FixedAreaClass = None;

  Super(UWindowScrollingDialogClient).Created();
  }

defaultproperties
{
}
