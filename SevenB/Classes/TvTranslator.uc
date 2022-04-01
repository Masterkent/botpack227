// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvTranslator : fully client-side translotor. makes multiplayer games much better...
// History is contorlled here as well... forceactive/deactive helps much as well...
// ===============================================================

class TvTranslator expands TvPickup;

var() localized string NewMessage;
var bool bNewMessage, bNotNewMessage;
var TranslatorHistoryList TList;   //translator message history.

simulated function PostBeginPlay(){ //copy localization of item
  Super.PostBeginPlay();
  NewMessage=class'translator'.default.NewMessage;
}
function TravelPreAccept()
{
  if ( Pawn(Owner).FindInventoryType(class) == None )
    Super.TravelPreAccept();
}

simulated function ForceDeactivate(){ //force translator to deactivate:
  if (!bActive)
    return;
  bActive=false;
  bNewMessage = False;
  bNotNewMessage = False;
  if (M_Deactivated != "")
    Pawn(Owner).ClientMessage(ItemName$M_Deactivated);
}
simulated function ForceActivate(){ //force translator to activate
  if (bActive)
    return;
  bActive=true;
  if (M_Activated != "")
    Pawn(Owner).ClientMessage(ItemName$M_Activated);
}

simulated function PrevHistory(){
  if (TList.Prev!=none)
    Tlist=Tlist.Prev;
}
simulated function NextHistory(){
  if (TList.Next!=none)
    Tlist=Tlist.Next;
}
//used by function below it.
function bool IsEnemy(pawn P){
 return (!p.bisplayer&&p.health>0&&p.attitudetoplayer<4&&((p.isa('scriptedpawn')&&!P.IsA('nali')&&!P.IsA('cow'))||p.isa('ParentBlob')||P.IsA('teamcannon')));
}
//only works in standalone! in client game always returns false
function bool PotentialEnemies(){
  local pawn p;
/*  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (p.Enemy==playerowner&&IsEnemy(p))
      return false;*/
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (IsEnemy(p)&&P.ActorReachable(owner))
      return true;
  return false;
}

simulated function ParseMessage (out string message){ //parse out parameters of translator messages
   local int i;
   i = InStr(message, "\\n");
   while(i != -1)
   {
     message = Left(message, i) $ Chr(13) $ Mid(message, i + 2);
     i = InStr(message, "\\n");
   }
}

simulated function SetMessage(string InMessage){
  ParseMessage(InMessage);
  if (Tlist==none){
    Tlist = Spawn (class'TranslatorHistoryList',owner);
    Tlist.message=InMessage;
  }
  else
    Tlist=TList.Process(InMessage);
  if (bNewMessage&&!PotentialEnemies())
    ForceActivate();

}

simulated function string GetMessage(){
  if (Tlist!=none)
    return TList.Message;
  return NewMessage;
}
simulated function bool ClientActivate(){ //use this as well server-side
  bActive = !bActive;
  if (!bActive){
    if (M_Deactivated != "")
      Pawn(Owner).ClientMessage(ItemName$M_Deactivated);
    bNewMessage = False;
    bNotNewMessage = False;
  }
  else if (bActive && M_Activated != "")
    Pawn(Owner).ClientMessage(ItemName$M_Activated);
  return true;
}
state Activated
{
  function BeginState();

  function EndState();
Begin:
}

state Deactivated
{
Begin:
}

defaultproperties
{
     RealClass=Class'UnrealShare.Translator'
     bActivatable=True
     bDisplayableInv=True
     PickupViewMesh=LodMesh'UnrealShare.TranslatorMesh'
     StatusIcon=Texture'SevenB.Icons.TransI'
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     Icon=Texture'UnrealShare.Icons.I_Tran'
     Mesh=LodMesh'UnrealShare.TranslatorMesh'
     CollisionHeight=5.000000
}
