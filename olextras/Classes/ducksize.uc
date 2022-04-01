// ============================================================
// ducksize.  alllows the collision size to change if the owner has ducked.....
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// DEPRECATED. DO NOT USE
// ============================================================

class ducksize expands TournamentPickup;
var bool lastduck;
function tick(float deltathy){ //tick for universal duck code.....
 if (owner!=none&&owner.isa('playerpawn'))  {

  if(playerpawn(owner).biscrouching && !lastduck)
    Setduck(Owner.default.CollisionHeight/2);
  if(!playerpawn(owner).biscrouching && lastduck)
    Setduck(Owner.default.CollisionHeight); //keep player from sinking :D

  lastduck=playerpawn(owner).biscrouching;                     }
  else if (owner!=none){ //owner would equal none when first spawned
  log ("somehow a non-playerpawn got the duckenabler!");
  destroy();
  }
}
//is it unethical to rip stuff from Deus Ex? oops... :D I never actually knew about prepivot.... interesting what you can learn..
function bool Setduck(float newHeight)
{
  local playerpawn other;
  local float  oldHeight;
  local bool   bSuccess;
  local vector centerDelta;
  local float  deltaEyeHeight;
  other=playerpawn(owner);
  if (newHeight < 0)
    newHeight = 0;

  oldHeight = other.CollisionHeight;

  if ((oldHeight == newHeight))
    return true;

  deltaEyeHeight = other.default.collisionheight - other.Default.BaseEyeHeight;
  centerDelta    = vect(0, 0, 1)*(newHeight-oldHeight);
  bSuccess = false;
  if ((newHeight <= other.CollisionHeight))  // shrink
  {
    other.SetCollisionSize(other.default.collisionradius, newHeight);
   // if (other.Move(centerDelta))
      bSuccess = true;
   // else
     // other.SetCollisionSize(other.default.collisionradius, oldHeight);
  }
  else
  {
   // if (other.Move(centerDelta))
  //  {
      log ("stopped ducking.. reseting collision");
      other.SetCollisionSize(other.default.collisionradius, newHeight);
      bSuccess = true;
   //  }
  }
  if (bsuccess){
   other.PrePivot        -= centerDelta;
    other.BaseEyeHeight   = newHeight - deltaEyeHeight;
    other.EyeHeight    -= centerDelta.Z;
  return (bSuccess);  }
}

defaultproperties
{
     PickupMessage="You weren't supposed to pick this up!"
     ItemName="duckenabler"
     bHidden=True
}
