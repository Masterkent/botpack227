// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// MakeMercsDance : Triggering makes a followingmercenary of the tag dance. (no tag==all)
// ============================================================

class MakeMercsDance expands Triggers;
var () name MercTag;
var () bool bForceDance; //if true removes orders, and if no enemy, goes to waiting state.

function Trigger (actor other, pawn EventInstigator){
local pawn p;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if ((Merctag=='All'||p.tag==MercTag)&&p.IsA('followingmercenary')){
       followingmercenary(p).bDancer=true;
       if (bForceDance){
          scriptedpawn(p).orders='';
          if (p.enemy==none)
            p.GotoState('waiting');
        }
     }
}

defaultproperties
{
     MercTag=All
}
