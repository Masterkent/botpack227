// ===============================================================
// TvPickup : This is a pickup class designed with co-op in mind.
// Essentially it allows clients to directly activate inventory items, stopping unnecessary network delays.
// Note that bActive should still be checked, so server acts as the official bool keeper (replicates after client sets)
// ===============================================================

class TvPickup expands UTC_Pickup
abstract;
var class<Pickup> RealClass; //original class->to get defaults

simulated function PostBeginPlay(){ //copy localization of item
  Super.PostBeginPlay();
  ExpireMessage=RealClass.default.ExpireMessage;
  PickupMessage=RealClass.default.PickupMessage;
  ItemName=RealClass.default.ItemName;
  if ( ItemName == "" )
    ItemName = GetSimItemName(string(RealClass));

}

function TravelPostAccept()
{
  Super.TravelPostAccept();
  //-bActive=false; //force deactivate.
}

simulated function String GetSimItemName( string FullName )
{
  local int pos;

  pos = InStr(FullName, ".");
  While ( pos != -1 )
  {
    FullName = Right(FullName, Len(FullName) - pos - 1);
    pos = InStr(FullName, ".");
  }

  return FullName;
}

function Activate()
{
  if( bActivatable)
  {
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogItemActivate(Self, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogItemActivate(Self, Pawn(Owner));

    if ( M_Activated != "" && owner.Isa('playerpawn') && viewport(playerpawn(owner).player)!=none)
      Pawn(Owner).ClientMessage(ItemName$M_Activated);
    GoToState('Activated');
  }
}
state Activated
{
  function Activate()
  {
    if ( (Pawn(Owner) != None) && Pawn(Owner).bAutoActivate
      && bAutoActivate && (Charge>0) )
        return;
    if ( M_Deactivated != "" && playerpawn(owner)!=none && viewport(playerpawn(owner).player)!=none)
      Pawn(Owner).ClientMessage(ItemName$M_Deactivated);
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
    GoToState('DeActivated');
  }
}
simulated function bool ClientActivate(); //implemented in ClientControl state.  return true if do not activate on server

state ClientControl { //this is the state that clients (and never server) are always in.

  simulated function bool ClientActivate(){
     bActive = !bActive;
     if (!bActive && M_Deactivated != "")
       Pawn(Owner).ClientMessage(ItemName$M_Deactivated);
     else if (bActive && M_Activated != "")
       Pawn(Owner).ClientMessage(ItemName$M_Activated);
     return false;
  }

}

//other hacks:
auto state Pickup
{
  // When touched by an actor.
  function Touch( actor Other )
  {
    local Inventory Copy;
    if ( ValidTouch(Other) )
    {
      Copy = SpawnCopy(Pawn(Other));
      if (Level.Game.LocalLog != None)
        Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
      if (Level.Game.WorldLog != None)
        Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
      if (bActivatable && Pawn(Other).SelectedItem==None)
        Pawn(Other).SelectedItem=Copy;
      if (bActivatable && bAutoActivate && Pawn(Other).bAutoActivate) Copy.Activate();
      if ( PickupMessageClass == None )
        Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
      else
        class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Pawn(Other), PickupMessageClass, 0, None, None, RealClass);
      PlaySound (PickupSound,,2.0);
      Pickup(Copy).PickupFunction(Pawn(Other));
    }
  }
}

defaultproperties
{
}
