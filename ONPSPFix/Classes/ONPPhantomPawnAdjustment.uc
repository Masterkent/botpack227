class ONPPhantomPawnAdjustment expands Info;

var Pawn ControlledPawn;

function Tick(float DeltaTime)
{
	if (ControlledPawn == none || ControlledPawn.bDeleteMe)
	{
		Destroy();
		return;
	}
	if (ControlledPawn.Health > 0 && IsPhantomPawn(ControlledPawn) && HasNonPhantomBehavior(ControlledPawn))
		MakePawnNormal(ControlledPawn);
}

static function bool IsPhantomPawn(Pawn P)
{
	return
		!P.bCollideActors ||
		!P.bBlockActors ||
		!P.bBlockPlayers ||
		!P.bProjTarget;
}

static function bool HasNonPhantomBehavior(Pawn P)
{
	local name StateName;

	StateName = P.GetStateName();

	if (StateName == '' ||
		StateName == 'StartUp' ||
		StateName == 'Waiting' ||
		StateName == 'Patroling' ||
		StateName == 'Guarding' ||
		StateName == 'Ambushing' ||
		StateName == 'Acquisition' ||
		StateName == 'Attacking' ||
		StateName == 'TriggerAlarm' ||
		StateName == 'AlarmPaused')
	{
		return false;
	}
	return true;
}

function MakePawnNormal(Pawn P)
{
	P.SetCollision(true, true, true);
	P.bProjTarget = true;
}

defaultproperties
{
	RemoteRole=ROLE_None
}
