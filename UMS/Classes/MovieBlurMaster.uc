//=============================================================================
// MovieBlurMaster. Handles Movie Blur FX.
//=============================================================================
class MovieBlurMaster expands UMS;

var float MotionBlurTime;
var float MotionBlurFadeRate;
var bool bMotionBlur;

function Timer() 
{
	local pawn P;
	local projectile Proj;
	local weapon Weap;
	local MovieBlur MyBlur;
	
	if (bMotionBlur) 
	{	
		for(P = Level.PawnList; P != None; P = P.NextPawn) {
			MyBlur = Spawn(class'MovieBlur', P, , P.Location, P.Rotation);
			MyBlur.FadeRate = MotionBlurFadeRate;
		}
		foreach AllActors(class'Projectile',Proj) {
			MyBlur = Spawn(class'MovieBlur', Proj, , Proj.Location, Proj.Rotation);
			MyBlur.FadeRate = MotionBlurFadeRate;
			
		}
		foreach AllActors(class'Weapon',Weap) {
			MyBlur = Spawn(class'MovieBlur', Weap, , Weap.Location, Weap.Rotation);
			MyBlur.FadeRate = MotionBlurFadeRate;
		}
	}

}

defaultproperties
{
}
