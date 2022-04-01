// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// WorkingTriggeredAmbientSound : Triggering changes the actor's ambientsound
// ============================================================

class WorkingTriggeredAmbientSound expands Triggers;
var () bool bInitiallyPlaying;  //is the sound playing on default?
var () sound TheSound; //the ambience.

function PreBeginPlay(){
  Super.PreBeginPlay();
  if (bInitiallyPlaying)
    ambientsound=TheSound;
}

function Trigger( actor Other, pawn EventInstigator )
{
  if (AmbientSound!=None)
    AmbientSound=none;
  else
    AmbientSound=TheSound;
}

state() TriggerToggled
{
}


state() OppositeWhileTriggered
{
  function Trigger( actor Other, pawn EventInstigator )
  {
   if (AmbientSound==none^^bInitiallyPlaying)
     global.Trigger(other,eventinstigator);
  }
  function UnTrigger( actor Other, pawn EventInstigator )
  {
   if (AmbientSound!=none^^!bInitiallyPlaying)
     global.Trigger(other,eventinstigator);
  }

}

defaultproperties
{
}
