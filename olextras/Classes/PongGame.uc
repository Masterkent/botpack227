// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// PongGame : Actual Pong Game
// I note that this isn't very OOP-ish, but I had to do this fast...
// Note: Simply a 200x100 Arena... then scaled.....
// Only is an actor so it can be saved...   Purely client-side!
// gutters are past Y..
// Victory: When have 7 points and at least 2 more than opposing side!
// ===============================================================

class PongGame expands Info;

//imports:
#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

const BallRadius = 5;
const BallSpeed = 102;

var Vector Ball; //ball coords. Z NOT USED.
var Vector BallVel; //ball velocity. Z NOT USED.
var float RPaddle; //Y coord of Red Paddle (player controlled) Y is top of paddle!   (0 to 100-length)
var float BPaddle; //Blue Paddle (AI controlled)    X is at 200.....
var float PredictedY; //AI: predicted Y loc of ball.
var float PaddleLength; //length of paddle
var float PaddleSpeed;
var float PaddleWidth; //width of paddle
var bool bCanBeSaved; //spawns own controller?
var Actor SoundActor; //play sounds though this.
var PongController Renderer; //the renderer.
var bool bHard; //hard AI?  Also, ball speeds up :p
var bool bHideBall;
var byte Ended; //0=no, 1=player won, 2=compwon
var int PlayerScore, ComputerScore;
var bool bHitPaddle; //only used within several functions for sound effects..
var bool bGutteredBlue; //ditto  (on blue side... red point)
var bool bGutteredRed; //ditto (on red side... blue point)
var bool bPaused; //is game paused?
var float CompPaddleMult; //difficulties...

simulated function Vector Vec(float X, float Y){
  local vector Temp;
  Temp.X=X;
  Temp.Y=y;
  return Temp;
}

function bool IsOnRedPaddle(vector test){
  return (test.X>=0&&Test.X<=PaddleWidth&&Test.Y>=RPaddle&&Test.Y<=RPaddle+PaddleLength);
}

function bool IsOnBluePaddle (vector Test){
  return (test.X<=200&&Test.X>=200-PaddleWidth&&Test.Y>=BPaddle&&Test.Y<=BPaddle+PaddleLength);
}

function float V2DSize(vector H){
  return Square(H.X)+Square(H.Y);
}
//(R-, L+)
function vector GetBestHit (vector L, vector R, vector C, out float Length, optional bool DeltaX){ //find the best one
  local float Best;
  local int BestNum;
  local vector L2, R2;
  if (DeltaX){
    L2.X=BallRadius;
    R2.X=-BallRadius;
  }
  else{
    L2.Y=BallRadius;
    R2.Y=-BallRadius;
  }
  Best=500;
  if (L.Z>0){
    Best=V2DSize(Ball-L2-L);
    BestNum=1;
  }
  if (R.Z>0){
    Length=V2DSize(Ball-R2-r);
    if (Length<Best){
      Best=Length;
      BestNum=2;
    }
  }
  if (C.Z>0){
    Length=V2DSize(Ball-C);
    if (Length<Best){
      BestNum=3;
      Best=Length;
    }
  }
  if (BestNum==0)
    return Vect(0,0,0);
  Length=SqRT(Best);
  if (BestNum==1)
    return L;
  if (BestNum==2)
    return R;
  return C;
}

function bool CheckCollision(vector NewBall, out Float DeltaTime){ //see if ball would collide.
  local Vector HitLoc, HitNorm;
  local vector HLR, HLC, HLL; //3 hit loc tests.  (if z=1, did hit. if z=0, then no)
  local float SlopeY, SlopeX; //multiplied slopes.
  local Float Length;  //amount ball will move by....
  if (NewBall.X>200+BallRadius){ //gutter check...
    bGutteredBlue=true;
    DeltaTime=0;
    return false;
  }
  if (NewBall.X<0-BallRadius){ //gutter check...
    bGutteredRed=true;
    DeltaTime=0;
    return false;
  }
  SlopeY=BallVel.Y/BallVel.X;
  SlopeX=1/SlopeY;
  if (NewBall.X>=200-PaddleWidth-BallRadius){ //may be colliding with computer paddle
     if (Ball.X<200-PaddleWidth-BallRadius){    //colliding on approach
       HLC=Vec(200-PaddleWidth,Ball.Y+SlopeY*(200-PaddleWidth-BallRadius-Ball.X));  //central line
       HLR=HLC;
       HLR.Y-=BallRadius;
       HLL=HLC;
       HLL.Y+=BallRadius;
       HLC.Z=float(IsOnBluePaddle(HLC));
       HLR.Z=float(IsOnBluePaddle(HLR));
       HLL.Z=float(IsOnBluePaddle(HLL));
       HLC.X-=BallRadius;
       HLR.X-=BallRadius;
       HLL.X-=BallRadius;
       HitLoc=GetBestHit(HLL,HLR,HLC,Length);
     }
     if (HitLoc.Z==0&&BallVel.Y>0){// did not hit front.. check if hitting paddle on sides (rare.. but possible (although you already lost..))
       HLC=Vec(Ball.X+SlopeX*(BPaddle-BallRadius-Ball.Y),BPaddle);  //central line
       HLR=HLC;
       HLR.X-=BallRadius;
       HLL=HLC;
       HLL.X+=BallRadius;
       HLC.Z=float(IsOnBluePaddle(HLC));
       HLR.Z=float(IsOnBluePaddle(HLR));
       HLL.Z=float(IsOnBluePaddle(HLL));
       HLC.Y-=BallRadius;
       HLR.Y-=BallRadius;
       HLL.Y-=BallRadius;
       HitLoc=GetBestHit(HLL,HLR,HLC,Length,true);
       if (Length>vsize(NewBall-Ball))
        HitLoc=vect(0,0,0);
     }
     if (HitLoc.Z==0&&BallVel.Y<0){// did not hit top either
       HLC=Vec(Ball.X+SlopeX*(BPaddle+PaddleLength+BallRadius-Ball.Y),BPaddle+PaddleLength);  //central line
       HLR=HLC;
       HLR.X-=BallRadius;
       HLL=HLC;
       HLL.X+=BallRadius;
       HLC.Z=float(IsOnBluePaddle(HLC));
       HLR.Z=float(IsOnBluePaddle(HLR));
       HLL.Z=float(IsOnBluePaddle(HLL));
       HLC.Y+=BallRadius;
       HLR.Y+=BallRadius;
       HLL.Y+=BallRadius;
       HitLoc=GetBestHit(HLL,HLR,HLC,Length,true);
       if (Length>vsize(NewBall-Ball))
        HitLoc=vect(0,0,0);
     }
  }
  if (NewBall.X<=PaddleWidth+BallRadius){ //may be colliding with Player's paddle
     if (Ball.X>PaddleWidth+BallRadius){    //colliding on approach
       HLC=Vec(PaddleWidth,Ball.Y+SlopeY*(PaddleWidth+BallRadius-Ball.X));  //central line
       HLR=HLC;
       HLR.Y-=BallRadius;
       HLL=HLC;
       HLL.Y+=BallRadius;
       HLC.Z=float(IsOnRedPaddle(HLC));
       HLR.Z=float(IsOnRedPaddle(HLR));
       HLL.Z=float(IsOnRedPaddle(HLL));
       HLC.X+=BallRadius;
       HLR.X+=BallRadius;
       HLL.X+=BallRadius;
       HitLoc=GetBestHit(HLL,HLR,HLC,Length);
     }
     if (HitLoc.Z==0&&BallVel.Y>0){// did not hit front.. check if hitting paddle on sides (rare.. but possible (although you already lost..))
       HLC=Vec(Ball.X+SlopeX*(RPaddle-BallRadius-Ball.Y),RPaddle);  //central line
       HLR=HLC;
       HLR.X-=BallRadius;
       HLL=HLC;
       HLL.X+=BallRadius;
       HLC.Z=float(IsOnRedPaddle(HLC));
       HLR.Z=float(IsOnRedPaddle(HLR));
       HLL.Z=float(IsOnRedPaddle(HLL));
       HLC.Y-=BallRadius;
       HLR.Y-=BallRadius;
       HLL.Y-=BallRadius;
       HitLoc=GetBestHit(HLL,HLR,HLC,Length,true);
       if (Length>vsize(NewBall-Ball))
        HitLoc=vect(0,0,0);
     }
     if (HitLoc.Z==0&&BallVel.Y<0){// did not hit top either
       HLC=Vec(Ball.X+SlopeX*(RPaddle+PaddleLength+BallRadius-Ball.Y),RPaddle+PaddleLength);  //central line
       HLR=HLC;
       HLR.X-=BallRadius;
       HLL=HLC;
       HLL.X+=BallRadius;
       HLC.Z=float(IsOnRedPaddle(HLC));
       HLR.Z=float(IsOnRedPaddle(HLR));
       HLL.Z=float(IsOnRedPaddle(HLL));
       HLC.Y+=BallRadius;
       HLR.Y+=BallRadius;
       HLL.Y+=BallRadius;
       HitLoc=GetBestHit(HLL,HLR,HLC,Length,true);
       if (Length>vsize(NewBall-Ball))
        HitLoc=vect(0,0,0);
     }
  }
  HLR=vect(0,0,0);
  HLL=vect(0,0,0);
  //NOW we have to test for side Wall collision AND compare it to paddle...
  if (HitLoc.Z>0)
    bHitPaddle=true;
  if (NewBall.Y-BallRadius<0){ //hit wall. get exact location.
    HLL=Vec(SlopeX*(BallRadius-Ball.Y)+Ball.X,0);
    HLL.Z=1;
  }
  if (NewBall.Y+BallRadius>100){ //hit wall. get exact location.
    HLR=Vec(SlopeX*(100-Ball.Y-BallRadius)+Ball.X,100);
    HLR.Z=1;
  }
  HitLoc=GetBestHit(HLL,HLR,HitLoc,Length);
  if (HitLoc.Z==0){ //did not hit
    Ball=NewBall;
    DeltaTime=0;
    return false;
  }
  //did hit. move ball and alter trajectory...
  Ball+=Normal(BallVel)*Length;
  Length=Vsize(NewBall-Ball); //length moved.
  DeltaTime=fmin(DeltaTime-0.01,(Length-vsize(BallVel*deltatime))/vsize(Ballvel)); //set new time (with the hack to avoid potential infinite iterators)
  HitNorm=GetHitNorm(HitLoc);
  BallVel -= 2 * ( BallVel dot HitNorm) * HitNorm;
  CheckVelocity();
  return true;
}

function CheckVelocity(){ //verify ball isn't at too much of an angle
  local vector VNorm;
  local float Speed;
  VNorm=Normal(BallVel);
  if (abs(VNorm.Y)>0.95){ //ensure not to steepy.
    Speed=vsize(BallVel);
    VNorm.Y=fclamp(VNorm.Y,-0.95,0.95);
    vnorm.x=class'TvVehicle'.static.Sign(vnorm.x)*sqrt(1-Square(Vnorm.y));
    BallVel=VNorm*Speed;
  }
}
//0-60 degrees (0-.866 Y)
function vector GetHitNorm(vector HitLocation){ //Calculate the hitnormal on a "wannabe" eliptical surface..)
  local vector HitNorm;
  if (HitLocation.Y==0) //top wall
    return vect(0,1,0);
  if (HitLocation.Y==100) //bottom wall
    return vect(0,-1,0);
  //calculate from Paddles...
  if (HitLocation.X==200-PaddleWidth-Ballradius){  //hit computer Paddle...
    HitNorm.X=-1;
    HitNorm.Y=(-1.33/PaddleLength)*((BPaddle+PaddleLength/2)-HitLocation.Y);
    return Normal(HitNorm);
  }
  if (HitLocation.X==PaddleWidth+BallRadius){  //hit player Paddle...
    HitNorm.X=1;
    HitNorm.Y=(-1.33/PaddleLength)*((RPaddle+PaddleLength/2)-HitLocation.Y);
    return Normal(HitNorm);
  }
  if (HitLocation.X>100)   //player / conputer paddle sides.
    HitNorm.Y=BPaddle;
  else
    HitNorm.Y=RPaddle;
  if (HitLocation.Y<HitNorm.Y+PaddleLength/2) //above paddle
    return Vect(0,-1,0);
  else
    return Vect(0,1,0);   //below
}
simulated function UpdateBall(float DeltaTime){
  local vector Goal;
  local bool bDidCollide;
  While (DeltaTime>0&&!bHideBall){ //big hack...
    Goal=Ball+BallVel*DeltaTime;
    bDidCollide=(CheckCollision(Goal, DeltaTime) || bDidCollide);
  }
  if (bDidCollide){
    if (bHitPaddle){
      if (SoundActor.Isa('PlayerPawn'))
        PlayerPawn(SoundActor).ClientPlaySound(Sound'PHitPaddle');
      else
        SoundActor.PlaySound(Sound'PHitPaddle');
      if (bHard)
        BallVel*=1.09; //speed up
      else
        BallVel*=1.03+(CompPaddleMult-1)/15.0;
    }
    else{
      if (SoundActor.Isa('PlayerPawn'))
        PlayerPawn(SoundActor).ClientPlaySound(Sound'PHitWall');
      else
        SoundActor.PlaySound(Sound'PHitWall');
    }
  }
  if (bGutteredBlue){
    PlayerScore++;
    bHideBall=true;
  }
  if (bGutteredRed){
    ComputerScore++;
    bHideBall=true;
  }
  if (bHideBall){ //someone scored!
    bGutteredRed=false;
    bGutteredBlue=false;
    RPaddle=default.RPaddle;
    BPaddle=default.BPaddle;
    Ball=vect(100,50,0);
    if (SoundActor.Isa('PlayerPawn'))
      PlayerPawn(SoundActor).ClientPlaySound(Sound'Pscore');
    else
      SoundActor.PlaySound(Sound'PScore');
    if (PlayerScore>=7&&PlayerScore-ComputerScore>=2)
      Ended=1;
    else if (ComputerScore>=7&&ComputerScore-PlayerScore>=2)
      Ended=2;
    else
      SetTimer(0.8,false);
  }
}

simulated function PostBeginPlay(){
  SetTimer(0.8,false);
}
simulated function Destroyed(){
  Renderer.Game=none;
  Renderer=none;
}
simulated function Timer(){ //used for restarts.
  bHideBall=false;
  Ball=vect(100,50,0);
  BallVel=vect(-5,1,0);
  if (!bHard&&frand()<0.5)
    BallVel.X*=-1;
  if (frand()<0.5)
    BallVel.Y*=-1;
  if (!bCanBeSaved){
    RPaddle=default.RPaddle;
    BPaddle=default.BPaddle;
  }
  BallVel=BallSpeed*Normal(BallVel);
}

simulated function UpKey(float delta){ //player has up key pressed....
local vector FakeBall;
  if (Ended>0) //something else is responsible for restart
    return;
  RPaddle-=delta*PaddleSpeed;
  if (RPaddle<0)
    RPaddle=0;
  FakeBall=Ball;
  FakeBall.Y+=BallRadius;
  if (IsOnRedPaddle(FakeBall+vec(BAllRadius,0))||IsOnRedPaddle(FakeBall-vec(BAllRadius,0))){
    Ball.Y=fmax(RPaddle-BallRadius,BallRadius);
    if (Ball.Y==BallRadius){
      RPaddle=fmax(RPaddle,2*BallRadius);
      if (RPaddle==2*BallRadius){ //force ball velocity y to be 0...
        BallVel.X=class'TvVehicle'.static.Sign(BallVel.x)*vsize(BallVel);
        BallVel.Y=0;
      }
    }
    if (BallVel.Y>0)
      BallVel -= 2 * ( BallVel dot vect(0,-1,0) ) * vect(0,-1,0);
    if (SoundActor.Isa('PlayerPawn'))
      PlayerPawn(SoundActor).ClientPlaySound(Sound'PHitPaddle');
    else
      SoundActor.PlaySound(Sound'PHitPaddle');
  }
}

simulated function DownKey(float delta){ //player has down key pressed....
local vector FakeBall;
  if (Ended>0) //something else is responsible for restart
    return;
  RPaddle+=delta*PaddleSpeed;
  if (RPaddle>100-PaddleLength)
    RPaddle=100-PaddleLength;
  FakeBall=Ball;
  FakeBall.Y-=BallRadius;
  if (IsOnRedPaddle(FakeBall+vec(BAllRadius,0))||IsOnRedPaddle(FakeBall-vec(BAllRadius,0))){
    Ball.Y=fmin(RPaddle+PaddleLength+BallRadius,100-BallRadius);
    if (Ball.Y==100-BallRadius){
      RPaddle=fmax(RPaddle,100-2*BallRadius);
      if (RPaddle==100-2*BallRadius){ //force ball velocity y to be 0...
        BallVel.X=class'TvVehicle'.static.Sign(BallVel.x)*vsize(BallVel);
        BallVel.Y=0;
      }
    }
    if (BallVel.Y<0)
      BallVel -= 2 * ( BallVel dot vect(0,1,0) ) * vect(0,1,0);
    if (SoundActor.Isa('PlayerPawn'))
      PlayerPawn(SoundActor).ClientPlaySound(Sound'PHitPaddle');
    else
      SoundActor.PlaySound(Sound'PHitPaddle');
  }
}

simulated function UpdateAI (float DeltaTime){
  local Vector FakeBall, FakeVel, LastFake;
  local float SlopeX;
  local bool bUp, bDown;
  if (bHard&&bHitPaddle){ //predict balls location exactly as it land at 200-paddleWidth
    if (BallVel.X<=0)
      return;
    FakeVel=BallVel;
    FakeBall=Ball;
    LastFake=FakeBall;
    while (FakeBall.x<200-paddlewidth-BallRadius){
      LastFake=FakeBall;
      SlopeX=FakeVel.X/FakeVel.Y;
      if (FakeVel.Y<0){   //go up
        FakeBall=Vec(FakeBall.X+SlopeX*(BallRadius-FakeBall.Y),BallRadius);
        FakeVel -= 2 * ( FakeVel dot vect(0,1,0)) * vect(0,1,0);
      }
      else{ //go down
        FakeBall=Vec(FakeBall.X+SlopeX*(100-BallRadius-FakeBall.Y),100-BallRadius);
        FakeVel -= 2 * ( FakeVel dot vect(0,-1,0)) * vect(0,-1,0);
      }
    }
    //now find where hit 200-paddlewidth
    PredictedY=fclamp(LastFake.Y+(1/SlopeX)*(200-PaddleWidth-BallRadius-LastFake.X)-PaddleLength/2,0,100-PaddleLength);
  }
  bUp=(PredictedY<BPaddle);
  bDown=(PredictedY>BPaddle);
  class'TvVehicle'.static.Approach(BPaddle,CompPaddleMult*deltaTime*PaddleSpeed,PredictedY);
  if (bUP){
    FakeBall=Ball;
    FakeBall.Y+=BallRadius;
    if (IsOnBluePaddle(FakeBall+vec(BAllRadius,0))||IsOnBluePaddle(FakeBall-vec(BAllRadius,0))){
      Ball.Y=fmax(BPaddle-BallRadius,BallRadius);
      if (Ball.Y==BallRadius){
        BPaddle=fmax(BPaddle,2*BallRadius);
        if (BPaddle==2*BallRadius){ //force ball velocity y to be 0...
         BallVel.X=class'TvVehicle'.static.Sign(BallVel.x)*vsize(BallVel);
         BallVel.Y=0;
        }
      }
      if (BallVel.Y>0)
        BallVel -= 2 * ( BallVel dot vect(0,-1,0) ) * vect(0,-1,0);
      if (SoundActor.Isa('PlayerPawn'))
        PlayerPawn(SoundActor).ClientPlaySound(Sound'PHitPaddle');
      else
        SoundActor.PlaySound(Sound'PHitPaddle');
    }
  }
  else if (bDown){
    FakeBall=Ball;
    FakeBall.Y-=BallRadius;
    if (IsOnBluePaddle(FakeBall+vec(BAllRadius,0))||IsOnBluePaddle(FakeBall-vec(BAllRadius,0))){
      Ball.Y=fmin(BPaddle+PaddleLength+BallRadius,100-BallRadius);
      if (Ball.Y==100-BallRadius){
        BPaddle=fmax(BPaddle,100-2*BallRadius);
        if (BPaddle==100-2*BallRadius){ //force ball velocity y to be 0...
         BallVel.X=class'TvVehicle'.static.Sign(BallVel.x)*vsize(BallVel);
         BallVel.Y=0;
        }
      }
      if (BallVel.Y<0)
        BallVel -= 2 * ( BallVel dot vect(0,1,0) ) * vect(0,1,0);
      if (SoundActor.Isa('PlayerPawn'))
        PlayerPawn(SoundActor).ClientPlaySound(Sound'PHitPaddle');
      else
        SoundActor.PlaySound(Sound'PHitPaddle');
    }
  }
}

simulated function Tick(float DeltaTime){ //master updater.
  if (bHideBall||bPaused) //something else is responsible for restart
    return;
  UpdateBall(DeltaTime);
  if (!bHard)
    PredictedY=fclamp(Ball.Y-PaddleLength/2,0,100-PaddleLength);
  UpdateAI(Deltatime);
  bHitPaddle=false;
}

simulated function DoRender(){ //rendering calls are valid now
  ///local float Xl, Yl;
  Renderer.DrawColor=Renderer.default.DrawColor;
  Renderer.DrawRect(0,RPaddle,Texture'RedPad',PaddleWidth*2,PaddleLength);
  Renderer.DrawRect(200-PaddleWidth,BPaddle,Texture'BluePad',PaddleWidth*2,PaddleLength);
  //scores:
/*  Renderer.DrawColor.R=0;
  Renderer.DrawColor.G=255;
  Renderer.DrawColor.B=0;
  Renderer.DrawText(PaddleWidth*Renderer.ScaleX,5,"You:"@PlayerScore);
  Renderer.TextSize("Computer:"@ComputerScore,Xl,YL);
  Renderer.DrawText(200-PaddleWidth*Renderer.ScaleX-Xl,5,"Computer:"@ComputerScore);
  */
  if (!bHideBall)    //ball draws over scores :p
    Renderer.DrawRect(Ball.X-BallRadius,Ball.Y-BallRadius,Texture'Ball',2*BallRadius,2*BallRadius);
  else if (Ended==0)
    Renderer.CenterText("Get Ready!");
  else if (Ended==1)
    Renderer.CenterText("You Win!");
  else if (Ended==2)
    Renderer.CenterText("Computer Wins!");
}

defaultproperties
{
     RPaddle=40.000000
     BPaddle=40.000000
     PaddleLength=20.000000
     PaddleSpeed=70.000000
     PaddleWidth=8.000000
     bHideBall=True
     CompPaddleMult=1.000000
     RemoteRole=ROLE_None
}
