//=============================================================================
// MovieInterpolater.
//=============================================================================
class MovieInterpolater expands Triggers;

var() float DesiredRate;
var() float DesiredAlpha;

function Trigger(actor Other, pawn EventInstigator)
{
	local InterpolationPoint i;
	
	if(EventInstigator!=None)
	{
		foreach AllActors( class 'InterpolationPoint', i, Event )
		{
			if(i.Position == 0)
			{
				EventInstigator.GotoState('');
				EventInstigator.SetCollision(True,false,false);
				EventInstigator.bCollideWorld = False;
				EventInstigator.Target = i;
				EventInstigator.SetPhysics(PHYS_Interpolating);
				EventInstigator.PhysRate = DesiredRate;
				EventInstigator.PhysAlpha = DesiredAlpha;
				EventInstigator.bInterpolating = true;
				EventInstigator.AmbientSound = AmbientSound;
			}
		}
	}
}

defaultproperties
{
				DesiredRate=1.000000
}
