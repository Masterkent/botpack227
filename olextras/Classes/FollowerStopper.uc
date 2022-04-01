// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// FollowerStooper.  This function causes creatures to leave the following state, so they will not continue to next level.
// place the follower's TAG in FollowerTag.  Note that traveled followers all have the tag "traveled"
// Use ALL to stop all followers.
// Set ballowtouch to make this a simple touched based trigger
// NOTE THAT THIS SHOULD ONLY BE CALLED AT END OF GAME OR WHEN FOLLOWER CANNOT SEE PLAYER.  OTHER-WISE THE FOLLOWER WILL JUST ENTER STATE AGAIN. (SUPPORT FOR CO-OP)
// ============================================================

class FollowerStopper expands Triggers;
var() name FollowerTag;
var () bool bAllowTouch;

function Touch( actor Other )
{
  if (bAllowTouch&&other.bispawn&&pawn(other).bisplayer)
    trigger(other,pawn(other));
}
function Trigger( actor Other, pawn EventInstigator )
{
  local pawn p;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (FollowerTag=='ALL'||p.tag==FollowerTag)
      if (p.isa('Follower')){
        Follower(p).Setpa(none);
        Follower(P).DoRoam();
      }
}

defaultproperties
{
     FollowerTag=All
}
