// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// ONPEndMark : This actor should exist only ONCE in Operation: Na Pali.  controls high score saving.
// Note: can warp or set cutscene.
// Event is triggered when player is doen with notification stuff.
// ===============================================================

class ONPEndMark expands Keypoint;

var() bool    bEnabled;      //End Event is activated
var() string NextMapURL;  //next map to go to?
var() string CoopNextMapURL; //next map to go to in co-op?
var () bool bStartCutScene;
var () bool TriggerActivated; //activate when triggered?
var bool bNoTick; //disable not work right...

function PreBeginPlay(){
  Super.PreBeginPlay();
  Disable('tick');
  Enable('Touch');
}
function Trigger (actor Other, Pawn EventInstigator){
  if (TriggerActivated)
    Touch(EventInstigator);
  else
    bEnabled=!bEnabled;
}

function Tick (float delta){ //only called after pause undone
local actor A;
 if (bNoTick||level.pauser!="")
  return;
 if (NextMapURL!="")
   Level.Game.SendPlayer(playerpawn(Instigator), NextMapURL);
 if (Event!='')
   ForEach AllActors (class'actor',A,event)
     A.Trigger(self,instigator);
 if (bStartCutScene){
   Tvplayer(Instigator).playermod=1;
   TvPlayer(Instigator).Linfo.bCutScene=true;
 }
 Disable('tick');
 bNoTick=true;
}
function touch (actor Other){
local actor A;
local TvPlayer P;
local int i;
local AwardNotifyWindow Award;
 if ( !bEnabled )
   return;
 P=tvplayer(other);
 if (P==none)
   return;
 if (level.netmode!=nm_standalone){ //screw this, just teleport
   if (CoopNextMapURL!="")
     NextMapURL=CoopNextMapURL;
   if (NextMapURL!="")
     Level.Game.SendPlayer(P, NextMapURL);
   if (Event!='')
     ForEach AllActors (class'actor',A,event)
       A.Trigger(self,pawn(other));
   return;
 }
 Disable('touch');
 Instigator=P;
 if (!P.Linfo.bCutScene)
   for (i=0;i<36;i++)
     if (P.ScoreHolder.Times[i]<=0){
       P.ScoreHolder.Times[i]=P.MyTime;
       break;
     }
 P.ScoreHolder.AccumTime+=P.MyTime;
 P.MyTime=0;
 P.ScoreHolder.TotalLevelSecrets+=Level.Game.SecretGoals;
 P.ScoreHolder.TotalSecretsFound+=P.SecretCount;
 level.game.SecretGoals=0;
 P.SecretCount=0;
 //REWARDS
 if (level.game.difficulty+1>class'TVHSClient'.default.MaxDif){
  WindowConsole(P.Player.Console).bQuickKeyEnable = true;  //ensures it will then close.....
  WindowConsole(P.Player.Console).LaunchUWindow();   //open window.....
  Award=AwardNotifyWindow(WindowConsole(P.Player.Console).Root.CreateWindow(class'AwardNotifyWindow', 100, 100, 200, 200));
  AwardClient(Award.ClientArea).SetAwards(level.game.difficulty);
  p.setpause(true);
 }
 class'TVHSClient'.static.SaveScores(P.scoreHolder,P.PlayerReplicationInfo.PlayerName); //implement enterable names?
 Enable('tick');
 bNoTick=false;
}

defaultproperties
{
     bEnabled=True
     bStartCutScene=True
     bNoTick=True
     bStatic=False
     CollisionRadius=50.000000
     CollisionHeight=50.000000
     bCollideActors=True
}
