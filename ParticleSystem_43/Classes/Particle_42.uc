//=============================================================================
// Particle_43.
//=============================================================================
class Particle_42 expands Effects;

var() vector InitialAccel;
var() vector TerminalVelocity;
var() bool bAccelerating;
var() bool bFadingNow;
var() bool bFadingInNow;
var() float FadeTime;
var() float SpawnTime;
var() float FadeScaleFactor;
var() float FadeInTime;
var() float FadeInScaleFactor;

simulated function Timer()
{
	if (bAccelerating) {
		//Accelerate particle if it hasn't reached it's terminal velocity
		if ((Velocity.Z < TerminalVelocity.Z)&&(Velocity.Z > -TerminalVelocity.Z))
			velocity.Z += InitialAccel.Z;

		if ((Velocity.X < TerminalVelocity.X)&&(Velocity.X > -TerminalVelocity.X))
			velocity.X += InitialAccel.X;

		if ((Velocity.Y < TerminalVelocity.Y)&&(Velocity.Y > -TerminalVelocity.Y))
			velocity.Y += InitialAccel.Y;
	}
	if (bFadingInNow) {
		ScaleGlow = ScaleGlow + FadeInScaleFactor / FadeInTime;
		if ( ScaleGlow >= FadeInScaleFactor * 10 ) {
			ScaleGlow = FadeInScaleFactor * 10;
			bFadingInNow = false;
		}
	}
	if (FadeTime > 0) {
		//Check to see if we are fading yet...
		if ((!bFadingNow )&&(LifeSpan - Level.TimeSeconds + SpawnTime <= FadeTime ))
			bFadingNow = true;
		if (bFadingNow)
			ScaleGlow = ScaleGlow - FadeScaleFactor / FadeTime;
	}
	SetTimer(0.1, false);
}

simulated function HitWall(vector HitNormal, actor HitWall)
{
	Destroy();
}

simulated function Landed(vector HitNormal)
{
	Destroy();
}

defaultproperties
{
	Physics=PHYS_Projectile
	DrawType=DT_Sprite
	Style=STY_Translucent
	bUnlit=True
}
