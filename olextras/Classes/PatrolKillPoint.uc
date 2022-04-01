// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// PatrolKillPoint : Kills the guy who touches it (when on a patrol that is)
// Note: doesn't work :(. DON'T USE!
// ============================================================

class PatrolKillPoint expands PatrolPoint;
var () pawn ClassToKill; //if not
function Touch (actor other){
local pawn otherpawn;
local scriptedpawn p;
p=scriptedpawn(other);
if ((p==none)||!p.IsInState('patrolling')||p.orderobject!=self)
  return;
//kill this d00d
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

defaultproperties
{
}
