// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// SecretArea : This actors marks a secret area... basically implements the never-implemented "secret system".
// triggers event if found
// ===============================================================

class SecretArea expands Keypoint;

var () string FoundMessage;
var () sound FoundSound;
var () name FoundMessageType;
var () int Points;

function SetUpMessage(){
  local string outstr;
  local int pos;
  pos=instr(FoundMessage,"%i");
   while (pos!=-1){
     outstr=outstr$left(FoundMessage,pos)$Points;
     FoundMessage=mid(FoundMessage,pos+2);
     pos=instr(FoundMessage,"%i");
   }
   FoundMessage=outstr$FoundMessage;
}
function PreBeginPlay(){
  if (Level.NetMode!=Nm_StandAlone)
    destroy();
  else{
    SetupMessage();
    Super.PreBeginPlay();
  }
}
function Touch (actor Other){
  if (Other.IsA('tvplayer')){
    Instigator=pawn(Other);
    Other=none;
    Instigator.SecretCount++;
    if (tvplayer(Instigator) != none)
      tvplayer(Instigator).ScoreHolder.AddPoints(Points);
    Instigator.ClientMessage(FoundMessage,FoundMessageType);
    if (FoundSound!=none)
      PlaySound(FoundSound, SLOT_Misc, 2.0);
    if (Event!='')
      ForEach AllActors(class'actor',Other,Event)
        Other.Trigger(self,Instigator);
    Disable('touch');
  }
}

defaultproperties
{
     FoundMessage="You found a Secret Area!  %i Points awarded!"
     FoundSound=Sound'UnrealShare.Generic.Beep'
     FoundMessageType=CriticalEvent
     points=742
     bStatic=False
     bNet=False
     bIsSecretGoal=True
     CollisionRadius=50.000000
     CollisionHeight=50.000000
     bCollideActors=True
}
