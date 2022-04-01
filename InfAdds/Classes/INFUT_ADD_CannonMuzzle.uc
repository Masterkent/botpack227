//=============================================================================
// INFUT_ADD_CannonMuzzle.
//
// written by N.Bogenrieder (aka Beppo)
//=============================================================================
class INFUT_ADD_CannonMuzzle extends CannonMuzzle
	abstract;

function PostBeginPlay()
{
		Super.PostBeginPlay();
		LoopAnim('Shoot');
}

defaultproperties
{
     DrawScale=0.125000
}
