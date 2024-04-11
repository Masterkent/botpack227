class ONPViewSpot expands Info;

var() bool bAllPlayers;

var bool bWasActive;

function SetViewOfPlayers()
{
	local PlayerPawn PlayerPawn;

	if (bAllPlayers)
	{
		foreach AllActors(class'PlayerPawn', PlayerPawn)
			if (PlayerPawn != Instigator &&
				PlayerPawn.PlayerReplicationInfo != none &&
				!PlayerPawn.PlayerReplicationInfo.bIsSpectator &&
				PlayerPawn.ViewTarget == none &&
				PlayerPawn.Health > 0)
			{
				PlayerPawn.EndZoom();
				PlayerPawn.ViewTarget = self;
			}
	}
	if (PlayerPawn(Instigator) != none &&
		PlayerPawn(Instigator).ViewTarget != self &&
		PlayerPawn(Instigator).Health > 0)
	{
		PlayerPawn(Instigator).EndZoom();
		PlayerPawn(Instigator).ViewTarget = self;
	}
}

function ResetViewOfPlayers()
{
	local PlayerPawn PlayerPawn;

	if (bAllPlayers)
	{
		foreach AllActors(class'PlayerPawn', PlayerPawn)
			if (PlayerPawn != Instigator &&
				PlayerPawn.PlayerReplicationInfo != none &&
				!PlayerPawn.PlayerReplicationInfo.bIsSpectator &&
				PlayerPawn.ViewTarget == self)
			{
				PlayerPawn.ViewTarget = none;
			}
	}
	if (PlayerPawn(Instigator) != none && PlayerPawn(Instigator).ViewTarget == self)
		PlayerPawn(Instigator).ViewTarget = none;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	Instigator = EventInstigator;
	SetViewOfPlayers();
	GotoState('Activated');
}

function UnTrigger(Actor Other, Pawn EventInstigator)
{
	GotoState('Deactivated');
}

state Activated
{
	event BeginState()
	{
		bWasActive = false;
	}

	event Tick(float DeltaTime)
	{
		local PlayerPawn PlayerPawn;

		bWasActive = true;

		if (bAllPlayers)
		{
			foreach AllActors(class'PlayerPawn', PlayerPawn)
				if (PlayerPawn != Instigator &&
					PlayerPawn.PlayerReplicationInfo != none &&
					!PlayerPawn.PlayerReplicationInfo.bIsSpectator &&
					PlayerPawn.ViewTarget == self &&
					PlayerPawn.Health <= 0)
				{
					PlayerPawn.ViewTarget = none;
				}
		}
		if (PlayerPawn(Instigator) != none &&
			PlayerPawn(Instigator).ViewTarget == self &&
			Instigator.Health <= 0)
		{
			PlayerPawn(Instigator).ViewTarget = none;
		}
	}
}

state Deactivated
{
	event Tick(float DeltaTime)
	{
		if (bWasActive)
		{
			ResetViewOfPlayers();
			GotoState('');
		}
		else
			bWasActive = true;
	}
}
