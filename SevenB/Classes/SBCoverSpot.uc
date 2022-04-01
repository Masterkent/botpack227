// ===============================================================
// SevenB.SBCoverSpot: Goal is to force scriptedpawn to do a "tactical move"
// I'm not sure if this will work.
// ===============================================================

class SBCoverSpot extends Triggers;

var() bool bInitiallyActive;

function Touch( actor Other )
{
	local vector X, Y, Z, DodgeDir;
	if ( bInitiallyActive && Other.IsA('ScriptedPawn') && pawn(other).enemy!=none ){
		GetAxes(other.Rotation,X,Y,Z);
		DodgeDir = normal(location - other.location) cross Z;
		if ( ((location - other.location) Dot Y) > 0 )
		{
			DodgeDir *= -1;
			ScriptedPawn(other).TryToDuck(DodgeDir, true);
		}
		else
			ScriptedPawn(other).TryToDuck(DodgeDir, false);
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	bInitiallyActive = !bInitiallyActive;
}

defaultproperties
{
     bInitiallyActive=True
}
