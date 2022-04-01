// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvItemSelectCWindow : This is the actual "item selector" :p
// ===============================================================

class TvItemSelectCWindow expands UMenuDialogClientWindow;

var UWindowSmallButton SevenB, HighScore; //Main Game  (add gold select here)?

function created(){ //build up window
  super.created();
  SevenB=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 10, winwidth-20, 16));
  SevenB.settext("Start Seven Bullets");
  SevenB.sethelptext("Click here to start Seven Bullets!");
  HighScore=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 30, winwidth-20, 16));
  HighScore.settext("View High Scores");
  HighScore.sethelptext("Click here to view High Scores and statistics.");
}

function BeforePaint(Canvas C, float X, float Y)
{
  Super.BeforePaint(C, X, Y);
  SevenB.WinWidth=Winwidth-20;
  HighScore.WinWidth=Winwidth-20;
}

function Notify(UWindowDialogControl C, byte E)  //control notification.
{
  local oldskoolnewgameclientwindow os;

  Super.Notify(C, E);

  switch(E)
  {
    case DE_Click:    //buttons
      os=oldskoolnewgameclientwindow(OldSkoolNewgamewindow(root.FindChildWindow(class'OldSkoolNewgamewindow',true)).clientarea);
      if (os==none){
        log ("CRITICAL ERROR! CANNOT FIND NEWGAME CLIENT WINDOW!");
        return;
      }
      switch(C)
      {

        Case SevenB:
          GetPlayerOwner().ClientTravel(class'SevenBPack'.default.Maps[0]$"?Game=SevenB.tvsp?Difficulty="$os.difficulty$"?Mutator="$os.MutatorList, TRAVEL_Absolute, false);
          ParentWindow.close();
          os.ParentWindow.Close();
          Root.Console.CloseUWindow();
          break;

        Case HighScore:
          GetParent(class'UWindowFramedWindow').ShowModal(root.Createwindow(class'TvHighScoresWindow', 10, 10, 200, 200,self));
          break;
      }
  }
}

defaultproperties
{
}
