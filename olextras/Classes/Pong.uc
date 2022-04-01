// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// Pong : For use with my credits map. ued too unstable to code with :/
// ===============================================================

class Pong expands TVVehicle;

#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

var() Texture Game;
var() Texture PlayerScore;
var() Texture CompScore;
var() string MyText;
var() string IntroText[9];
var() float IntroTimes[9];
var float mytime; //timer broken...
var () name WinEvent;
var () name LooseEvent;
var() Font Font;
var() color FontColor;
var() float YPos;

var bool bDidEnd;
var int CurIntro;
var PongGame Pongy;
var ScriptTexController Control;

event VehicleCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
  Controller.Vehicle=none;
  Controller.viewtarget=none;
  Controller.PlayerCalcView(ViewActor,CameraLocation,CameraRotation);
  Controller.Vehicle=self;
  Controller.ViewTarget=self;
}

function BuildControl(){
  if (Control==none)
    Control=new (none) class'ScriptTexController';
  Pongy=Control.Initialize(Controller,Pongy);
}

function Touch (actor other){
  Bump(Other);
}

function Timery (){
//  Controller.ClientMessage("Timer entry... Curintro is"@CurIntro);
  CurIntro++;
  if (CurIntro<9&&IntroText[CurIntro]!=""){
    MyText=IntroText[CurIntro];
    //SetTimer(IntroTimes[CurIntro],false);
    mytime=IntroTimes[CurIntro];
  }
  else
    BuildControl(); //start pong
//  Controller.ClientMessage("Timer ext... Curintro is"@CurIntro@" -Timer rate ="@TimerRate);
}
function Timer(); //not work?
function GetIn (tvplayer Driver){
  Controller=Driver;
//  Controller.ClientMessage(Driver@"Geting in pong vehcile!");
  SetOwner(driver);
  Driver.Vehicle=self;
  Driver.GotoState('VehicleControl');
  Driver.bBehindview=false;
  //pong
  CurIntro=-1;
  Timery();
}

function Tick (float Deltatime){
   if (Control==none)
     Control=new (none) class'ScriptTexController';
}
function VehicleTick(float deltatime){
   local actor A;
   local name InName;
   Controller.aLookUp*=0.5;
   Controller.aTurn*=0.5;
   Controller.UpdateRotation(deltatime,1);
  if (Control==none)
     BuildControl();
  if (mytime>0){
    mytime-=deltatime;
    if (mytime<=0)
      Timery();
  }
//  Controller.ClientMessage("Tick check.. Curintro is"@CurIntro@" -Timer rate ="@TimerRate);
   if (Pongy==none)
     return;
   if (Controller.aForward>0)
     Pongy.UpKey(deltatime);
   else if (Controller.aForward<0)
     Pongy.DownKey(deltatime);
  if (!bDidEnd&&Pongy.Ended>0){
    bDidEnd=true;
    Controller.PlayWinMessage(Pongy.Ended==1);
    if (Pongy.Ended==1)
      InName=WinEvent;
    else
      InName=LooseEvent;
    if (Pongy.Ended==1){
      Controller.PlayerMod=1;
      TVHUD(Controller.myhud).OldPlayerMod=1;
    }
    SetOwner(none);
    DisAble('bump');
   // Controller.VEhicle=none;
    Controller.bHidden=false; //?
    ForEach Allactors(class'Actor',A,InName)
      A.Trigger(Self,Controller);
    Controller.Walk();
  }
}
simulated function BeginPlay()
{
  if(Game != None)
    ScriptedTexture(Game).NotifyActor = Self;
  if(PlayerScore != None)
    ScriptedTexture(PlayerScore).NotifyActor = Self;
  if(CompScore != None)
    ScriptedTexture(CompScore).NotifyActor = Self;
}

simulated function Destroyed()
{
  if(Game != None)
    ScriptedTexture(Game).NotifyActor = None;
  if(PlayerScore != None)
    ScriptedTexture(PlayerScore).NotifyActor = None;
  if(CompScore != None)
    ScriptedTexture(CompScore).NotifyActor = None;

}

simulated event RenderTexture(ScriptedTexture Tex)
{
  if (Pongy==none&&Game!=Tex)
    return;
  if (Pongy==none){
    Control.Tex=Tex;
    Control.ScaleX=float(Tex.Usize)/200.0;
    Control.ScaleY=float(Tex.Vsize)/100.0;
    Control.Font=Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
    Control.DrawColor=FontColor;
    Control.CenterText(MyText, true);
    Control.Tex=none;
    return;
  }
  if (Tex==Game){
    Tex.ReplaceTexture(Texture'ONPBlackTex');
    Control.RenderTexture(Tex);
  }
  else if (Tex==PlayerScore)
    Tex.DrawColoredText( Ypos, 180, string(Pongy.PlayerScore), Font, FontColor );
  else if (Tex==CompScore)
    Tex.DrawColoredText( Ypos, 180, string(Pongy.ComputerScore), Font, FontColor );
}

defaultproperties
{
     YPos=87.000000
     bHidden=True
     DrawType=DT_Sprite
     Texture=Texture'Engine.S_Keypoint'
     bBlockActors=False
}
