// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// GunFireSensorZone : A specialized zone that calls an event when a player fires his weapon.
// ============================================================

class GunFireSensorZone expands ZoneInfo;

var () bool bActive;   //active? Triggering changes this property.
var () float EventCallDelay;    //delay until events are called
var () bool bCallEventOnceOnly; //only trigger other actors once?
var () bool bTriggerOnceOnly;  //be triggered once only?

//internal:
var bool bTriggered;
var bool bCalledEvent;
var bool bInTimer;

function Trigger( actor Other, pawn EventInstigator )
{
  if (!btriggered)
    bActive=!bactive;
  if (bTriggeronceonly)
    btriggered=true;
}

function GunFired(pawn p){
  if (!bactive||bInTimer||bCalledEvent)
    return;
  bInTimer=true;
  Instigator=p;
  if (EventCallDelay!=0)
    SetTimer(EventCallDelay, false);
  else
    Timer();
}

function Timer(){
  local actor a;
  if (bCallEventOnceOnly)
    bCalledEvent=true;
  bInTimer=false;
  if (event!='')
    foreach AllActors(class'actor',a,event)
      a.Trigger(self,Instigator);
}

defaultproperties
{
     bActive=True
     EventCallDelay=0.320000
     bCallEventOnceOnly=True
     bTriggerOnceOnly=True
}
