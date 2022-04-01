// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvTranslatorEvent : Normal translator event, only with replicated variables and such. simulated and works client-side
// ===============================================================

class TvTranslatorEvent expands Triggers;

// Human readable triggering message.
var() localized string Message;
var() localized string AltMessage;
var() sound NewMessageSound;
var() bool bTriggerAltMessage;
var bool bHitOnce;
var() float ReTriggerDelay; //minimum time before trigger can be triggered again
var    float TriggerTime;
var int MsgSwap, oldswap; //replication

var TvTranslator Trans;

var() localized String M_NewMessage;
var() localized String M_TransMessage;

replication{
  reliable if (Role==Role_Authority)
    Message, ReTriggerDelay, MsgSwap, NewMessageSound;
}
simulated function PostBeginPlay(){
  Texture=none;
}

function Trigger( actor Other, pawn EventInstigator )
{
  local Actor Targets;
  local string Temp;

  if (bTriggerAltMessage)
  {
    Temp = Message;
    Message = AltMessage;
    AltMessage = Temp;
    MsgSwap++;
    foreach TouchingActors(class'Actor', Targets)
      if (tvplayer(Targets)!=none)
        tvplayer(Targets).TouchTrans(self);
  }
  else if (tvplayer(EventInstigator)!=none)
    tvplayer(EventInstigator).TouchTrans(self);
}

function UnTrigger( actor Other, pawn EventInstigator )
{
  if (tvplayer(EventInstigator)!=none)
    tvplayer(EventInstigator).TouchTrans(self,true);
}


simulated function Touch( actor Other )
{
  if (!Other.IsA('playerpawn')) Return;

  if (Message=="") Return;

  if (OldSwap!=MsgSwap){
    OldSwap=MsgSwap;
    bHitOnce=false;
  }
  if ( ReTriggerDelay > 0 )
  {
    if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
      return;
    TriggerTime = Level.TimeSeconds;
  }

  if (TVHUD(playerpawn(Other).myhud)!=none)
    Trans=TVHUD(playerpawn(Other).myhud).TvTranslator;
  if (Trans==none)
    return;
  if (!bHitOnce)
    Trans.bNewMessage = true;
  else
    Trans.bNotNewMessage = true;
  if (!bHitOnce)
    Pawn(Other).ClientMessage(M_NewMessage);
  else
    Pawn(Other).ClientMessage(M_TransMessage);
  Trans.SetMessage(Message);
  bHitOnce = True;
  PlaySound(NewMessageSound, SLOT_Misc);
}

simulated function UnTouch( actor Other )
{
  if (Trans!=None){
    if (Level.TimeSeconds - TriggerTime>0.1)
      Trans.ForceDeactivate();
    else{
      Trans.bNotNewMessage = false;
      Trans.bNewMessage = false;
   }
  }
}

defaultproperties
{
     NewMessageSound=Sound'UnrealShare.Pickups.TransA3'
     ReTriggerDelay=0.250000
     M_NewMessage="New Translator Message"
     M_TransMessage="Translator Message"
     bHidden=False
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'UnrealShare.S_Message'
}
