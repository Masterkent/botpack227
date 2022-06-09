class ONPPlayerMoveTrigger expands Trigger;

var() bool bNoReenter;

var array<PlayerPawn> TouchingPlayers;
var int TouchingPlayersNum;

static function ONPPlayerMoveTrigger StaticReplaceTrigger(Trigger Trigger)
{
	local ONPPlayerMoveTrigger NewTrigger;

	NewTrigger = Trigger.Spawn(class'ONPPlayerMoveTrigger');
	NewTrigger.SetCollisionSize(Trigger.CollisionRadius, Trigger.CollisionHeight);
	NewTrigger.bTriggerOnceOnly = Trigger.bTriggerOnceOnly;
	NewTrigger.Event = Trigger.Event;
	NewTrigger.Message = Trigger.Message;
	NewTrigger.TriggerType = TT_PlayerProximity;

	Trigger.SetCollision(false);

	return NewTrigger;
}

event Touch(Actor A)
{
}

event UnTouch(Actor A)
{
	RemoveTouchingPlayer(PlayerPawn(A));
	if (bNoReenter)
		DisableThisTrigger();
}

event Tick(float DeltaTime)
{
	SetLocation(Location); // hack for updating the touch list
	CheckTouchingPlayers();
}

function CheckTouchingPlayers()
{
	local PlayerPawn P;

	foreach TouchingActors(class'PlayerPawn', P)
	{
		if (FindTouchingPlayer(P) >= 0)
			return;
		if (PlayerApproaches(P))
		{
			AddTouchingPlayer(P);
			CauseEventBy(P);
		}
	}
}

function int FindTouchingPlayer(PlayerPawn P)
{
	local int i;

	for (i = 0; i < TouchingPlayersNum; ++i)
		if (TouchingPlayers[i] == P)
			return i;
	return -1;
}

function AddTouchingPlayer(PlayerPawn P)
{
	local int i;

	for (i = 0; i < TouchingPlayersNum; ++i)
		if (TouchingPlayers[i] == none)
			break;
	TouchingPlayers[i] = P;
	if (i == TouchingPlayersNum)
		TouchingPlayersNum++;
}

function RemoveTouchingPlayer(PlayerPawn P)
{
	local int i;

	if (P == none)
		return;
	i = FindTouchingPlayer(P);
	if (i >= 0)
		TouchingPlayers[i] = none;
}

function bool PlayerApproaches(PlayerPawn P)
{
	return P.Velocity dot (Location - P.Location) > 0;
}

function CauseEventBy(PlayerPawn P)
{
	local Actor A;

	if (!bCollideActors)
		return;

	foreach AllActors(class'Actor', A, Event)
		A.Trigger(P, P);

	if (bTriggerOnceOnly)
		DisableThisTrigger();
}

function DisableThisTrigger()
{
	SetCollision(false);
	Disable('Tick');
}
