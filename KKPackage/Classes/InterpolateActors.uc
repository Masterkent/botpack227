class InterpolateActors extends Triggers;

var() name PatheName;
var() name ActorName;

simulated function Actor ReturnActor()
{
           local Actor Acr;

           foreach AllActors(class'Actor', Acr, ActorName)
           {
               return Acr;
               break;
           }
           return none;
}

function Trigger( actor Other, pawn EventInstigator )
{
        local InterpolationPoint i;
        if(ReturnActor() == none) return;
        foreach AllActors(class'InterpolationPoint', i, PatheName)
	{
		if( i.Position == 0 )
		{
			ReturnActor().SetCollision(True,false,false);
			ReturnActor().bCollideWorld = False;
			ReturnActor().Target = i;
			ReturnActor().SetPhysics(PHYS_Interpolating);
			ReturnActor().PhysRate = 1.0;
			ReturnActor().PhysAlpha = 0.0;
			ReturnActor().bInterpolating = true;
		}
	}
}

defaultproperties
{
}
