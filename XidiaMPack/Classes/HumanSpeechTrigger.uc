// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// HumanSpeechTrigger : This trigger can be used to activate scriptedhuman speaking. used for moving lips
// ===============================================================

class HumanSpeechTrigger expands Triggers;

var () Sound Speech;
var() float SpeechVolume;
var() float SpeechRadius;
var () float FaceLastingTime;
var () name HumanTag;
var () string SpeechText;  //speech text equivilent
var () bool bUseLocalPlayerName; //for messages use local player name......

function Trigger( actor Other, pawn EventInstigator )
{
  local pawn p;
  local PlayerPawn q;
  local ScriptedHumanMessage SHM;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (p.tag==HumanTag&&p.Isa('scriptedhuman')){
       scriptedhuman(p).Scream(Speech,SLOT_TALK,SpeechVolume,true,SpeechRadius);
       p.speechtime=FaceLastingTime;
       scriptedhuman(p).SpeechTimeCur=FaceLastingTime;
       if (SpeechText=="")
         return;
       if (bUseLocalPlayerName){
           foreach AllActors(class'PlayerPawn', q) {
             if (tvplayer(q) != none)
                tvplayer(q).SayMessage(SpeechText,GetSoundDuration(Speech));
             else
                q.TeamMessage(q.PlayerReplicationInfo, SpeechText, 'Say');
           }
       }
       else if (P.MenuName!=""){
         SHM=spawn(class'ScriptedHumanMessage');
         SHM.PlayerName=P.MenuName;
         SHM.TeamName=SpeechText;
         SHM.Score=fmax(3,GetSoundDuration(Speech));
       }
    }
}

defaultproperties
{
     SpeechVolume=16.000000
     SpeechRadius=1600.000000
     FaceLastingTime=0.300000
}
