// ===============================================================
// SevenB.KillPawn: kills specified pawnz
// ===============================================================

class KillPawn extends Triggers;
var () name PawnTag;

function Trigger( actor Other, pawn EventInstigator )
{
  local pawn p;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (p.tag==PawnTag){
         if (p.Health <=0)
    		continue;
		 p.Died (EventInstigator, 'KillPawn', p.location);
    }
}

defaultproperties
{
}
