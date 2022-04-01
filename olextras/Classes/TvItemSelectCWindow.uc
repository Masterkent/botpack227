// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvItemSelectCWindow : This is the actual "item selector" :p
// ===============================================================

class TvItemSelectCWindow expands UMenuDialogClientWindow;

var UWindowSmallButton MainGame, Tutorial, HighScore, Custom, MonsterSmash, Pong; //Main Game

function bool CheckCustomMaps(){
  return (GetPlayerOwner().GetMapName("ONP-", "", 0) != "");
}
function created(){ //build up window
  super.created();
  Tutorial=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 10, winwidth-20, 16));
  Tutorial.settext("Play tutorial");
  Tutorial.sethelptext("RECOMMENDED FOR ALL PLAYERS.  Learn from the tutorial and then directly start Operation: Na Pali.");
  MainGame=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 30, winwidth-20, 16));
  MainGame.settext("Start Operation: Na Pali");
  MainGame.sethelptext("Click here to go directly to the Operation: Na Pali Intro Movie.");
  HighScore=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 50, winwidth-20, 16));
  HighScore.settext("View High Scores");
  HighScore.sethelptext("Click here to view High Scores and statistics.");
  Custom=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 70, winwidth-20, 16));
  Custom.settext("Custom ONP Maps");
  Custom.bDisabled=!CheckCustomMaps();
  Custom.sethelptext("Click here to play custom-made Operation: Na Pali maps!");
  MonsterSmash=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 90, winwidth-20, 16));
  MonsterSmash.bdisabled=(class'TVHSClient'.default.MaxDif==0);
  if (!MonsterSmash.bDisabled){
    MonsterSmash.settext("Play MoNsTeRSmASH!");
    MonsterSmash.sethelptext("Click here to play a singleplayer game on any map against monsters!");
  }
  else{
    MonsterSmash.settext("Secret A");
    MonsterSmash.sethelptext("Defeat Operation: Na Pali to earn access to this!");
  }
  Pong=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 110, winwidth-20, 16));
  Pong.bdisabled=(class'TVHSClient'.default.MaxDif<4);
  if (!Pong.bDisabled){
    Pong.settext("Play PoNg!");
    Pong.sethelptext("The best video game EVER MADE!");
  }
  else{
    Pong.settext("Secret B");
    Pong.sethelptext("Defeat Operation: Na Pali on UNREAL to earn access to this!");
  }
}

function BeforePaint(Canvas C, float X, float Y)
{
  Super.BeforePaint(C, X, Y);
  Tutorial.WinWidth=Winwidth-20;
  MainGame.WinWidth=Winwidth-20;
  HighScore.WinWidth=Winwidth-20;
  Custom.WinWidth=Winwidth-20;
  MonsterSmash.WinWidth=Winwidth-20;
  Pong.WinWidth=Winwidth-20;
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
        case Tutorial:
          GetPlayerOwner().ClientTravel("Nptut?Game=olextras.TVTutorial?Difficulty="$os.difficulty$"?Mutator="$os.MutatorList, TRAVEL_Absolute, false);
          ParentWindow.close();
          os.ParentWindow.Close();
          Root.Console.CloseUWindow();
          break;
        Case MainGame:
          GetPlayerOwner().ClientTravel("NP01eVOLVE?Game=olextras.tvsp?Difficulty="$os.difficulty$"?Mutator="$os.MutatorList, TRAVEL_Absolute, false);
          ParentWindow.close();
          os.ParentWindow.Close();
          Root.Console.CloseUWindow();
          break;
        Case HighScore:
          GetParent(class'UWindowFramedWindow').ShowModal(root.Createwindow(class'TvHighScoresWindow', 10, 10, 200, 200,self));
          break;
        Case Custom:
          if (!Custom.bDisabled)
            GetParent(class'UWindowFramedWindow').ShowModal(root.Createwindow(class'TVCustomMapsWindow', 10, 10, 200, 200,self));
          else
            MessageBox("Not Available", "You need to have Operation: Na Pali custom maps installed to use this feature. :p  Get them at http://www.planetunreal.com/\\nteamvortex", MB_OK, MR_OK, MR_OK);
          break;
        //add Special game case statements here!
        Case MonsterSmash:
          if (!MonsterSmash.bDisabled)
            GetParent(class'UWindowFramedWindow').ShowModal(root.Createwindow(class'TVMonsterSmashWindow', 10, 10, 200, 200,self));
          else
            MessageBox("Not Available", "You must first defeat Operation: Na Pali to unlock this secret!", MB_OK, MR_OK, MR_OK);
          break;
        Case Pong:
          if (!Pong.bDisabled)
            GetParent(class'UWindowFramedWindow').ShowModal(root.Createwindow(class'PongFramedWindow', 10, 10, 200, 200,os));
          else
            MessageBox("Not Available", "You must first defeat Operation: Na Pali on 'UNREAL' difficulty to unlock this secret!", MB_OK, MR_OK, MR_OK);
          break;
      }
  }
}

defaultproperties
{
}
