//=============================================================================
// Jumper.
// Creatures will jump on hitting this trigger in direction specified
//=============================================================================
class Kicker extends Triggers;

var() vector KickVelocity;
var() name KickedClasses;
var() bool bKillVelocity;
var() bool bRandomize;

var bool B227_bPostTouchSupported;

replication
{
	reliable if (Role == ROLE_Authority && !bRandomize)
		KickVelocity,
		KickedClasses,
		bKillVelocity;

	reliable if (Role == ROLE_Authority)
		bRandomize;
}

simulated event PostBeginPlay()
{
	B227_bPostTouchSupported = DynamicLoadObject("Engine.Actor.SetPendingTouch", class'Function', true) != none;
}

simulated function Touch( actor Other )
{
	local Actor A;

	if (!Other.IsA(KickedClasses))
		return;
	if (Other.Physics != PHYS_Falling && Other.Physics != PHYS_Walking && Other.Physics != PHYS_Spider)
		return;
	if (Level.NetMode == NM_Client && (!Other.bCollideWorld || bRandomize)) // PlayerPawn.ClientAdjustLocation may initiate touching by SetLocation
		return;

	if (Other.Role >= ROLE_AutonomousProxy)
		B227_SetPendingTouch(Other);
	if (Role == ROLE_Authority && Event != '')
		foreach AllActors(class'Actor', A, Event)
			A.Trigger(Other, Other.Instigator);
}

simulated event PostTouch(Actor Other)
{
	B227_PostTouch(Other);
}

simulated function B227_SetPendingTouch(Actor Other)
{
	if (B227_bPostTouchSupported)
		SetPendingTouch(Other);
	else if (Level.NetMode != NM_Client)
		class'B227_KickerTouch'.static.MakeInstance(self, Other);
}

simulated function B227_PostTouch(Actor Other)
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
	if (Other.Physics == PHYS_Walking || Other.Physics == PHYS_Spider)
		Other.SetPhysics(PHYS_Falling);
	Other.Velocity += Push;
}

defaultproperties
{
	KickedClasses=Pawn
	RemoteRole=ROLE_SimulatedProxy
	bDirectional=True
	bAlwaysRelevant=True
}
