// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TDBarrel: destroys when touched
// ============================================================

class TDBarrel expands Barrel;
function Bump( actor Other )
{
  if (other.isa('pawn')&&pawn(other).bisplayer){
    Instigator = pawn(other);
    TakeDamage( 1000, Instigator, Location, Vect(0,0,1)*900,'exploded' );
    PlaySound (Sound(DynamicloadObject("AmbAncient.tilehit4",class'Sound')),SLOT_Interact);
  }
  else
    super.Bump(Other);
}

defaultproperties
{
}
