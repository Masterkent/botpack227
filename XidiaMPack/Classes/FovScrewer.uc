// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// FovScrewer : screws up Field of View.  Trigggering enables/disables... well, use like a keyinveryer
// ============================================================

class FovScrewer expands Triggers;
var () byte minfov;
var () byte maxfov;
var () byte AverageChange;
var bool bdec;
var float zoomlevel, OldFov;
var playerpawn localplayer;
var () bool bInitiallyActive;
var bool bActive, bWasActive;

replication{
  reliable if (role==role_authority)
    bactive;
}

simulated function PostBeginPlay(){
  super.Postbeginplay();
  bActive=bInitiallyActive;
  zoomlevel=minfov;
  if (level.netmode==nm_dedicatedserver)
    disable('tick');
}

simulated function GetLocalPlayer(){ //net stuff
  local playerpawn p;
  ForEach AllActors(class'playerpawn',p)
    if (viewport(p.player)!=none){
      localplayer=p;
      return;
    }
}

simulated function Tick(float deltatime){
  if (localplayer==none)
     GetLocalPlayer();
  if (!bactive){
    if (bWasActive&&localplayer!=none)
      localplayer.desiredfov=OldFov;
    bWasActive=false;
    return;
  }
  if (!bWasActive){
    if (localplayer!=none)
      OldFov=localplayer.desiredfov;
    bWasActive=true;
  }

  if (frand()<0.1)
    return;
  DeltaTime/=level.timedilation;
  if (bdec)
    DeltaTime*=-1;
  ZoomLevel += DeltaTime * AverageChange*fclamp(frand(),0.1,0.9);
  if (zoomlevel<minfov){
    zoomlevel=minfov;
    bdec=false;
  }
  else if (zoomlevel>maxfov){
    zoomlevel=maxfov;
    bdec=true;
  }
  if (localplayer!=none)
    localplayer.desiredfov=zoomlevel;
}
function Trigger( actor Other, pawn EventInstigator )
{
  bActive=!bactive;
}

state() TriggerToggled
{
}


state() OppositeWhileTriggered
{
  function Trigger( actor Other, pawn EventInstigator )
  {
   if (!bactive^^bInitiallyActive)
     global.Trigger(other,eventinstigator);
  }
  function UnTrigger( actor Other, pawn EventInstigator )
  {
   if (bActive^^!bInitiallyActive)
     global.Trigger(other,eventinstigator);
  }

}

defaultproperties
{
     minfov=63
     maxfov=135
     AverageChange=64
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
