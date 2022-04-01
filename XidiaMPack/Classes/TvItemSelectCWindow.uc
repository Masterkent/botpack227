// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvItemSelectCWindow : This is the actual "item selector" :p
// ===============================================================

class TvItemSelectCWindow expands UMenuDialogClientWindow;

var UWindowSmallButton OldG, MPack, Incident, HighScore; //Main Game  (add gold select here)?

function created(){ //build up window
  super.created();
  Incident=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 10, winwidth-20, 16));
  Incident.settext("Start Xidia: Gold");
  Incident.sethelptext("Click here to start Xidia: Gold. Xidia: The Incident and Xidia: The Escape combined!");
  OldG=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 30, winwidth-20, 16));
  OldG.settext("Start Xidia: The Incident");
  OldG.sethelptext("Click here to start Xidia: The Incident (original, updated xidia maps).");
  MPack=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 50, winwidth-20, 16));
  MPack.settext("Start Xidia: The Escape");
  MPack.sethelptext("Click here to start Xidia: The Escape (all new mission pack).");
  HighScore=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 70, winwidth-20, 16));
  HighScore.settext("View High Scores");
  HighScore.sethelptext("Click here to view High Scores and statistics.");
}

function BeforePaint(Canvas C, float X, float Y)
{
  Super.BeforePaint(C, X, Y);
  Incident.WinWidth=Winwidth-20;
  OldG.WinWidth=Winwidth-20;
  MPack.WinWidth=Winwidth-20;
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
        Case Incident:
          GetPlayerOwner().ClientTravel(class'XidiaPack'.default.Maps[0]$"?Game=XidiaMPack.tvsp?Difficulty="$os.difficulty$"?XidiaMode=2?Mutator="$os.MutatorList, TRAVEL_Absolute, false);
          ParentWindow.close();
          os.ParentWindow.Close();
          Root.Console.CloseUWindow();
          break;
        Case OldG:
          GetPlayerOwner().ClientTravel(class'XidiaPack'.default.Maps[0]$"?Game=XidiaMPack.tvsp?Difficulty="$os.difficulty$"?XidiaMode=0?Mutator="$os.MutatorList, TRAVEL_Absolute, false);
          ParentWindow.close();
          os.ParentWindow.Close();
          Root.Console.CloseUWindow();
          break;
        Case MPack:
          GetPlayerOwner().ClientTravel(class'XidiaPack'.default.Maps[class'XidiaPack'.default.ExpStart-1]$"?Game=XidiaMPack.tvsp?Difficulty="$os.difficulty$"?XidiaMode=1?Mutator="$os.MutatorList, TRAVEL_Absolute, false);
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
