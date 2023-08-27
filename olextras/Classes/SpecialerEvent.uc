// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// SpecialerEvent: an ENHANCED SpecialEvent
// USAGE:
// always use as you would a normal special event.
// INTERLOPATION: SET UP AS YOU WOULD NORMALLY, AGAIN BEING SURE ITS INITIALSTATE IS "PLAYERPATH"
// VAPRIZEINSTIGATOR STATE: Acts like the alarm point bKillMe. Instigator will be removed without a trace (no blood/carcass).  will only work on non-players!
// MyMESSAGETYPES: Legal types are SAY, CRITICALEVENT, EVENT, DEATHMESSAGE, AND PICKUP.
// Criticalevent is the normal central blue, event is a message in the speech area, say can be used to make the player
// (on local computer) appear to say something.  Deathmesasge looks like a message and pickup is a pickup message
// NOTE: new.. added support for
// ============================================================

class SpecialerEvent expands SpecialEvent;
var () name MyMessageType;
var () bool DoubleVolume; //should sounds for playerplaysound be double normal volume?

event BroadcastSayMessage( coerce string Msg, float time, pawn EventInstigator)
{
  local Pawn P;
  local bool bBeep;
  local name Type;

  Type = 'Say';

  for( P=Level.PawnList; P!=None; P=P.nextPawn ){
    if (tvplayer(P) != none)
      tvplayer(P).SayMessage(Msg,time,EventInstigator.PlayerReplicationInfo);
    else if( P.bIsPlayer || P.IsA('MessagingSpectator') )
    {
      if (class'UTC_GameInfo'.static.B227_MutatorBroadcastMessage(self, P, Msg, bBeep, Type))
        P.ClientMessage( Msg, 'Say', bBeep );
    }
  }
}
function Trigger( actor Other, pawn EventInstigator )
{
  local string InterpolatedMessage;

  if (Message=="")
    return;
  if (MyMessageType=='Say'&&Sound!=none){
    if( bBroadcast){
      BroadcastSayMessage(Message, GetSoundDuration(Sound), EventInstigator); // Broadcast message to all players.
      return;
    }
    else if( tvplayer(EventInstigator)!=None)
    {
    // Send message to instigator only.
      tvplayer(EventInstigator).SayMessage( Message,GetSoundDuration(Sound) );
      return;
    }
  }

  if (InStr(Message, "%k") >= 0)
  {
    if (EventInstigator == none || Len(EventInstigator.GetHumanName()) == 0)
      return;
    InterpolatedMessage = ReplaceStr(Message, "%k", EventInstigator.GetHumanName());
  }
  else
    InterpolatedMessage = Message;

  if( bBroadcast )
    BroadcastMessage(InterpolatedMessage, true, MyMessageType); // Broadcast message to all players.
  else if( EventInstigator!=None && len(InterpolatedMessage)!=0 )
  {
    // Send message to instigator only.
    EventInstigator.ClientMessage( InterpolatedMessage, MyMessageType );
  }
}

// Send the player on a spline path through the level. UsAaR33: edited so that there is no level.netmode check
state() PlayerPath
{
  function Trigger( actor Other, pawn EventInstigator )
  {
    local InterpolationPoint i;
    Global.Trigger( Self, EventInstigator );
    if( EventInstigator!=None && EventInstigator.bIsPlayer)
    {
      foreach AllActors( class 'InterpolationPoint', i, Event )
      {
        if( i.Position == 0 )
        {
          EventInstigator.GotoState('');       //in netplay, client adjustposition will fix the state problems :P
          EventInstigator.SetCollision(True,false,false);
          EventInstigator.bCollideWorld = False;
          EventInstigator.Target = i;
          EventInstigator.SetPhysics(PHYS_Interpolating);
          EventInstigator.PhysRate = 1.0;
          EventInstigator.PhysAlpha = 0.0;
          EventInstigator.bInterpolating = true;
          if (AmbientSound!=none) //don't try to change music :P
          EventInstigator.AmbientSound = AmbientSound;
          if (level.netmode!=nm_standalone){
          EventInstigator.bhidden=true;
          if (tvplayer(EventInstigator)!=none)
          tvplayer(EventInstigator).dointerpolate(i);} //tell client to interpolate.
        }
      }
    }
  }
}
state() VaporizeInstigator //kill instigator without a trace :)
{
  function Trigger( actor Other, pawn p )
  {
    local pawn otherpawn;
    Global.Trigger(other,p);
    if (p==none||p.bisplayer||p.IsA('playerpawn'))
      return;
     for (otherpawn=level.pawnlist;otherpawn!=none;otherpawn=otherpawn.nextpawn)
        OtherPawn.Killed(p, p, '');
     level.game.Killed(p, p, '');
     if( p.Event != '' )
       foreach AllActors( class 'Actor', other, p.Event )
          other.Trigger( p, P.Instigator );
      p.Weapon = None;
      Level.Game.DiscardInventory(p);
      p.Destroy();
   }
}

// Play a sound.
state() PlayersPlaySoundEffect
{
  function Trigger( actor Other, pawn EventInstigator )
  {
    local pawn P;
    bBroadcast=true; //hack
    Global.Trigger( Self, EventInstigator );

    for ( P=Level.PawnList; P!=None; P=P.NextPawn )
      if ( P.bIsPlayer && P.IsA('PlayerPawn') )
        class'UTC_PlayerPawn'.static.UTSF_ClientPlaySound(PlayerPawn(P), Sound,, DoubleVolume);
  }
}

defaultproperties
{
     MyMessageType='
}
