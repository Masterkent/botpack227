//=============================================================================
// Jumper.
// Creatures will jump on hitting this trigger in direction specified
//=============================================================================
class Kicker extends Triggers;

var() vector KickVelocity;
var() name KickedClasses;
var() bool bKillVelocity;
var() bool bRandomize;

/* 227j version
simulated function Touch( actor Other )
{
	local Actor A;

	if ( !Other.IsA(KickedClasses) )
		return;
	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, Other.Instigator );
}

simulated function PostTouch( actor Other )
{
	local bool bWasFalling;
	local vector Push;
	local float PMag;

	bWasFalling = ( Other.Physics == PHYS_Falling );
	if ( bKillVelocity )
		Push = -1 * Other.Velocity;
	else
		Push.Z = -1 * Other.Velocity.Z;
	if ( bRandomize )
	{
		PMag = VSize(KickVelocity);
		Push += PMag * Normal(KickVelocity + 0.5 * PMag * VRand());
	}
	else
		Push += KickVelocity;
	if ( Other.IsA('Bot') )
	{
		if ( bWasFalling )
			Bot(Other).bJumpOffPawn = true;
		Bot(Other).SetFall();
	}
	Other.SetPhysics(PHYS_Falling);
	Other.Velocity += Push;
}
*/

// 227i version
simulated function Touch( actor Other )
{
	local Actor A;

	if ( !Other.IsA(KickedClasses) )
		return;
	class'B227_KickerTouch'.static.MakeInstance(self, Other);
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, Other.Instigator );
}

// 227i version
simulated function B227_PostTouch( actor Other )
{
	local bool bWasFalling;
	local vector Push;
	local float PMag;

	bWasFalling = ( Other.Physics == PHYS_Falling );
	if ( bKillVelocity )
		Push = -1 * Other.Velocity;
	else
		Push.Z = -1 * Other.Velocity.Z;
	if ( bRandomize )
	{
		PMag = VSize(KickVelocity);
		Push += PMag * Normal(KickVelocity + 0.5 * PMag * VRand());
	}
	else
		Push += KickVelocity;
	if ( Bot(Other) != none )
	{
		if ( bWasFalling )
			Bot(Other).bJumpOffPawn = true;
		Bot(Other).SetFall();
	}
	if (Other.Physics == PHYS_Walking)
		Other.SetPhysics(PHYS_Falling);
	Other.Velocity += Push;
}

defaultproperties
{
	KickedClasses=Pawn
	RemoteRole=ROLE_SimulatedProxy
	bDirectional=True
}
