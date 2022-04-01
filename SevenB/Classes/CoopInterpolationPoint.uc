// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// CoopInterpolationPoint.  Need for co-op support of INPs.  YOU MUST USE THIS FOR CO-OP SUPPORT.
// defaulted as role_none and will unhide player.
// ============================================================

class CoopInterpolationPoint expands InterpolationPoint;

function InterpolateEnd( actor Other )
{
  if( bEndOfPath )
  {
    if( Pawn(Other)!=None && Pawn(Other).bIsPlayer )
    {
      Other.bCollideWorld = True;
      Other.bInterpolating = false;
      if ( Pawn(Other).Health > 0 )
      {
        Other.SetCollision(true,true,true);
        Other.bhidden=false;
        Other.SetPhysics(PHYS_Falling);
        Other.AmbientSound = None;
        if ( Other.IsA('PlayerPawn') )
          Other.GotoState('PlayerWalking');
      }
    }
  }
}

defaultproperties
{
     RemoteRole=ROLE_None
}
