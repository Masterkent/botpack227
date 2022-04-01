// ===============================================================
// SevenB.SBCarGrenade: Car Rifle grenade. Less bounce and 2x damage
// ===============================================================

class SBCarGrenade extends OSGrenade;

simulated singular function HitWall( vector HitNormal, actor Wall )
{
	bCanHitOwner = True;
	Velocity = 0.6*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	RandSpin(100000);
	speed = VSize(Velocity);
	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, FMax(0.5, speed/800) );
	if ( Velocity.Z > 400 )
		Velocity.Z = 0.5 * (400 + Velocity.Z);
	else if ( speed < 20 )
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
     Damage=200.000000
     MomentumTransfer=110000
}
