class SBTeleportPlayer expands Info;

var ZoneInfo FromZone;
var vector MoveOffset;
var bool bOnceOnly;

event Trigger(Actor A, Pawn EventInstigator)
{
	TeleportPlayer();
	if (bOnceOnly)
		GotoState('Inactive');
}

function TeleportPlayer()
{
	local PlayerPawn P;

	P = Level.GetLocalPlayerPawn();

	if (P == none)
		return;
	if (P.Region.Zone == FromZone)
		MovePawnToCondLocation(P, Location, MoveOffset);
	else
	{
		MovePawnTo(P, Location);
		P.ClientSetRotation(Rotation);
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

state Inactive
{
	ignores Trigger;
}
