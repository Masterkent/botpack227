// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// PongClientWindow : Routes various stuff to pong game
// ===============================================================

class PongClientWindow expands UWindowDialogClientWindow;

var PongGame Pong;
var PongController Control;

var bool bPressingDown, bPressingUp;
var bool bDidEnd;
var string BaseTitle;

var bool bHasKeyBoardFocus;   //pausing...

function KeyFocusEnter()
{
  Super.KeyFocusEnter();
  bHasKeyboardFocus = True;
}

function KeyFocusExit()
{
  Super.KeyFocusExit();
  bHasKeyboardFocus = False;
}

function Created(){
  Control = new (none) class'PongController';
  Pong=Control.Initialize(GetEntryLevel());
  Pong.SoundActor=GetPlayerOwner();
  BaseTitle=UWindowFramedWindow(ParentWindow).WindowTitle;
  switch (oldskoolnewgameclientwindow(OwnerWindow).Difficulty){
    Case 0:
      Pong.CompPaddleMult=0.7;
      break;
    Case 1:
      Pong.CompPaddleMult=1;
      break;
    Case 2:
      Pong.CompPaddleMult=1.3;
      break;
    Case 3:
      Pong.CompPaddleMult=1;
      Pong.bHard=true;
      Pong.CompPaddleMult=0.7;
      break;
  }
  SetAcceptsFocus();
}

function Close(optional bool bByParent)
{
  Super.Close(bByParent);
  CancelAcceptsFocus();
  Control=none;
  Pong.Destroy();
}

function Paint(Canvas C, float X, float Y)
{
  C.ClipX = WinWidth;
  C.ClipY = WinHeight;
  Control.PostRender(C);
}

function Tick(float DeltaTime){
  Super.Tick(DeltaTime);
  if (Pong==none){ //wierd...
    Close();
    return;
  }
  Pong.bPaused=(!bHasKeyBoardFocus||!IsActive());
  if (!bHasKeyBoardFocus||!IsActive()){
    bPressingDown=false;
    bPressingUp=false;
    return;
  }
  if (bPressingDown^^bPressingUp){
    if (bPressingDown)
      Pong.DownKey(deltaTime);
    else
      Pong.UpKey(deltaTime);
  }
  if (!bDidEnd&&Pong.Ended>0){
    UWindowFramedWindow(ParentWindow).WindowTitle="Game Over";
    bDidEnd=true;
    if (GetPlayerOwner().IsA('TournamentPlayer'));
      TournamentPlayer(GetPlayerOwner()).PlayWinMessage(Pong.Ended==1);
  }
  UWindowFramedWindow(ParentWindow).WindowTitle=BaseTitle@"(You:"@Pong.PlayerScore@" Computer:"@Pong.ComputerScore$")";
}                        //down=40   //up=38
function KeyDown(int Key, float X, float Y)
{
   Super.KeyDown (Key,X,Y);
   if (Key==40)
     bPressingDown=true;
   else if (Key==38)
     bPressingUp=true;
}
function KeyUp(int Key, float X, float Y)
{
   Super.KeyUp (Key,X,Y);
   if (Key==40)
     bPressingDown=false;
   else if (Key==38)
     bPressingUp=false;
}

defaultproperties
{
}
