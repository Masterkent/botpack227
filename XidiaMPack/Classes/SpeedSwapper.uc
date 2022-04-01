// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// SpeedSwapper : A cool little actor that when triggered will change the gamespeed/pause. FUN.
// The actors event is used for when speed swaps are complete  (for pauses, when it becomes unpaused again)
// Note that bNet is false on default (for obvious reasons)
// WARNING! Be careful to not have two of these running at once!
// ============================================================

class SpeedSwapper expands Triggers;
var () float Speed; //what gamespeed should it become?  (0=default speed)  N/A if Pause is true.
var () float Time; //how long should swap take. if pause: how long is pause? (no infinite for obvious reasons :) ).
//Time is absolute. INDEPENDENT of gamespeed.
var () bool Pause; //pause all action?
var () bool TriggerOnceOnly;
//internal:
var float SpeedAccel; //"acceleration" of gamespeed (increment/seconds)
var float timey;  //counter
var pawn Instigator;  //the d00d who triggered this

function PreBeginPlay(){
  Super.PreBeginPlay();
  if (Speed==0) //default it.
    Speed=level.timedilation;
}
function TriggerOthers(){
local actor A;
  if (event!='')
    ForEach AllActors (class'actor',A,event)
      A.Trigger(self,Instigator);
}

function Timer(){
  level.bPlayersOnly=false;
  TriggerOthers();
}
function Trigger(actor Other, pawn EventInstigator)
{
  Instigator=EventInstigator;
  if (Pause){
    level.bplayersonly=true;
    SetTimer(time/level.timedilation,false);
  }
  else{
    if (Time==0){
      Level.TimeDilation=Speed;
      level.game.GameSpeed = Speed;
      level.game.SetTimer(Speed,true);
      TriggerOthers();
    }
    else{
      Enable('tick');
      SpeedAccel=(Speed-level.TimeDilation)/Time*level.timedilation;
      timey=0;
    }
  }
  if (TriggerOnceOnly)
    Disable('trigger');
}
event tick(float deltatime){ //speed stuff
  if (SpeedAccel==0||level.pauser!="")
    return;
  deltatime=min(deltatime,time-timey); //don't go over
  timey+=deltatime; //counter
  Level.TimeDilation+=SpeedAccel*deltatime/*Time*/;
  level.game.GameSpeed = Level.TimeDilation;
  if (timey>=time){
    SpeedAccel=0;
    level.game.SetTimer(Level.TimeDilation,true); //gameinfo timer
    TriggerOthers();
  }
}

defaultproperties
{
     speed=0.400000
     Time=0.200000
     bAlwaysTick=True
}
