// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// ScriptedHumanMessage : Used to propograte text messages. Not owned at all..
// ===============================================================

class ScriptedHumanMessage expands PlayerReplicationInfo;

//Uses PlayerName, TalkTexture, Score (Message Time) and TeamName (Message).....

simulated function PostBeginPlay(){
  if (Level.NetMode!=nm_dedicatedServer)
    Enable('tick');
  else
    Disable('tick');
}

simulated function Tick (float Delta){
  local TVPlayer P;
  if (PlayerName!=""&&Score>0&&TeamName!=""){
    //hack fix!
    if (PlayerName~="Jane")
      PlayerName="Chryss";
    foreach allactors(class'TvPlayer',P)
      if (viewport(P.player)!=none)
        P.SayMessage(TeamName,Score,self);
     LifeSpan=Score+0.5;
     Disable('tick');
  }
}

defaultproperties
{
     Team=3
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
}
