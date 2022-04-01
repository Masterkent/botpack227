// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// ONPEndMark : This actor should exist only ONCE in Operation: Na Pali.  controls high score saving.
// Note: can warp or set cutscene.
// Event is triggered when player is doen with notification stuff.
// ===============================================================

class XidiaEndMark expands Keypoint;

var() bool    bEnabled;      //End Event is activated
var() string NextMapURL;  //next map to go to?
var() bool MissionPackSwap;
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
  log ("xidiaEndMark Triggered!");
  if (TriggerActivated)
    Touch(EventInstigator);
  else
    bEnabled=!bEnabled;
}

function Tick (float delta){ //only called after pause undone
local actor A;
 if (bNoTick||level.pauser!="")
  return;
 if (NextMapURL!=""&&(!MissionPackSwap || tvsp(level.game).XidiaMode==2)){  //only go if incident selected
    if (tvsp(level.game).XidiaMode==2 && MissionPackSwap)
      tvsp(level.game).noItems=true;
    Level.Game.SendPlayer(playerpawn(Instigator), NextMapURL);
 }
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

function TVPlayer FindPlayer(){
  local pawn p;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (p.IsA('TvPlayer'))
      return tvplayer(p);
}

function touch (actor Other){
local actor A;
local TvPlayer P;
local int i;
  log ("xidiaEndMark Touched!");
 if ( !bEnabled )
   return;
 P=tvplayer(other);
 if (P==none)
   P=FindPlayer();
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
 log ("xidiaEndMark-saving stats!");
 class'TVHSClient'.static.SaveScores(P.scoreHolder,P.PlayerReplicationInfo.PlayerName,!MissionPackSwap); //implement enterable names?
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
