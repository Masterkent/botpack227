class SBTeleportPlayersFromZone expands Info;

var ZoneInfo Zone;
var vector MoveOffset;

var private bool bDelayedRelocation;

event BeginPlay()
{
	Disable('Tick');
}

event Trigger(Actor A, Pawn EventInstigator)
{
	TeleportPlayers();
	Enable('Tick');
	bDelayedRelocation = true;
}

event Tick(float DeltaTime)
{
	if (bDelayedRelocation)
		TeleportPlayers();
}

function TeleportPlayers()
{
	local Pawn P;
	if (Zone == none)
		return;
	foreach Zone.ZoneActors(class'Pawn', P)
		if (P.PlayerReplicationInfo != none &&
			(!bDelayedRelocation || !P.IsInState('CheatFlying')))
		{
			MovePawnToCondLocation(P, Location, MoveOffset);
		}
}

function bool MovePawnToCondLocation(Pawn P, vector NewLocation, vector MoveOffset)
{
	if (VSize(MoveOffset) > 0)
		return MovePawnTo(P, P.Location + MoveOffset);
	return MovePawnTo(P, NewLocation);
}

function bool MovePawnTo(Pawn P, vector NewLocation)
{
	local vector OldLocation;
	local bool bPawnCollideActors, bPawnBlockActors, bPawnBlockPlayers;
	local bool Result;

	OldLocation = P.Location;
	bPawnCollideActors = P.bCollideActors;
	bPawnBlockActors = P.bBlockActors;
	bPawnBlockPlayers = P.bBlockPlayers;

	P.SetCollision(false, false, false); // prevents telefragging
	Result = P.SetLocation(NewLocation);
	P.SetCollision(bPawnCollideActors, bPawnBlockActors, bPawnBlockPlayers);

	return Result;
}
