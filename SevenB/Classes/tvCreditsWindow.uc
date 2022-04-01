// ============================================================
// XidiaMPack.tvCreditsWindow: This is actually a hack so that it will load the credits map.
// ============================================================

class tvCreditsWindow expands UnrealCreditsWindow;
/*
function created(){
close();
  ownerwindow.ParentWindow.Close();   //ownerwindow is botmatch parent
 Root.Console.CloseUWindow();
GetPlayerOwner().ClientTravel( "NPCredits2.unr?Game=olextras.tvsp", TRAVEL_Absolute, False );
}
function ShowWindow(); //do nothing
function bool WaitModal() //less accessed nones
{
hidewindow(); //for window to hide
parentwindow=none; //may give error but must do this.
return true;
}
  */

defaultproperties
{
     ClientClass=Class'SevenB.TVCreditsCW'
     WindowTitle="7 Bullets Credits - The MasterMinds"
}
