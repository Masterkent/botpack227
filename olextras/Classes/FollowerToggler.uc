// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// FollowerToggler : This actor is used to make followers NPC's and vice-versa.
// ===============================================================

class FollowerToggler expands Triggers;

var () name FollowerTag; //tag of follower to alter.
var () bool bAutoFollowTriggerer; //if true, automatically follows the player who triggered this event.
var() enum EFollowerSwap
{
  Follower,  //normal follower
  NPCAggressive, //NPC that seeks out baddies.
  NPCNonAggressive, //only attacks when hit.
} Become;

function Trigger( actor Other, pawn EventInstigator )
{
  local pawn p;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (P.Tag==FollowerTag && Follower(P) != none){
      if (Become==Follower){
        Follower(P).OnlyAttackWhenControlled=false;
        Follower(P).bCoward=false;
        if (bAutoFollowTriggerer&&EventInstigator.IsA('tvplayer')){
          Follower(P).temp=EventInstigator;
          P.GotoState('Greeting');
        }
      }
      else{
        Follower(P).SetPA(none);
        Follower(P).bCoward=true;
        Follower(P).OnlyAttackWhenControlled=(Become==NPCNonAggressive);
        P.GotoState('waiting');
      }
    }
}

defaultproperties
{
     bAutoFollowTriggerer=True
}
