class B227_VacuumZoneInfluence expands Info;

var ZoneInfo Zone;
var bool bScreamed;
var bool bActive;
var float TimePassed, LastTimePassed, ClientTimePassed;
var float KillTime;
var float StartFlashScale, EndFlashScale;
var vector StartFlashFog, EndFlashFog;
var float DieFOV;

replication
{
	reliable if (Role == ROLE_Authority)
		bActive,
		TimePassed,
		KillTime,
		StartFlashScale,
		EndFlashScale,
		StartFlashFog,
		EndFlashFog,
		DieFOV;
}

static function B227_VacuumZoneInfluence GetInstance(Pawn Pawn, ZoneInfo Zone, bool bCreate)
{
	local B227_VacuumZoneInfluence Influence;

	foreach Pawn.ChildActors(class'B227_VacuumZoneInfluence', Influence)
	{
		if (Influence.Zone == Zone)
			return Influence;
		Influence.Destroy();
	}
	if (bCreate)
	{
		Influence = Pawn.Spawn(class'B227_VacuumZoneInfluence', Pawn);
		if (Influence != none)
			Influence.Zone = Zone;
		return Influence;
	}
	return none;
}

simulated event Tick(float DeltaTime)
{
	local Pawn PawnOwner;
	local PlayerPawn PlayerOwner;
	local VacuumZone VacuumZone;
	local float Ratio;
	local float curScale;
	local vector curFog;
	local float curFOV, DesiredFOV;

	PawnOwner = Pawn(Owner);
	PlayerOwner = PlayerPawn(Owner);

	if (Level.NetMode != NM_Client)
	{
		if (PawnOwner == none || PawnOwner.bDeleteMe || PawnOwner.Region.Zone != Zone)
		{
			Destroy();
			return;
		}

		bActive =
			PawnOwner.Health > 0 &&
			(PawnOwner.PlayerReplicationInfo == none || !PawnOwner.PlayerReplicationInfo.bIsSpectator);
		if (!bActive)
			return;

		VacuumZone = VacuumZone(PawnOwner.Region.Zone);
		if (VacuumZone != none && VacuumZone.KillTime > 0)
		{
			TimePassed += DeltaTime;
			Ratio = FMin(1.0, TimePassed / VacuumZone.KillTime);
			PawnOwner.Fatness = Min(255, PawnOwner.default.Fatness + (255 - PawnOwner.default.Fatness) * Ratio);

			if (PlayerOwner != none)
			{
				KillTime = VacuumZone.KillTime;
				StartFlashScale = VacuumZone.StartFlashScale;
				EndFlashScale = VacuumZone.EndFlashScale;
				StartFlashFog = VacuumZone.StartFlashFog * 1000;
				EndFlashFog = VacuumZone.EndFlashFog * 1000;
				DieFOV = VacuumZone.DieFOV;
			}

			if (TimePassed >= VacuumZone.KillTime)
			{
				VacuumZone.B227_AdjustDamageString();
				Level.Game.SpecialDamageString = VacuumZone.DamageString;
				PawnOwner.TakeDamage
				(
					10000,
					none,
					PawnOwner.Location,
					Vect(0,0,0),
					VacuumZone.DamageType
				);
				Level.Game.SpecialDamageString = "";
				VacuumZone.MakeNormal(PawnOwner);
				TimePassed = 0;
			}
		}
	}
	else if (!bNetOwner)
		return;

	if (Level.NetMode != NM_DedicatedServer && bActive && PlayerOwner != none)
	{
		if (ClientTimePassed < TimePassed || TimePassed < LastTimePassed)
			ClientTimePassed = TimePassed;
		else
			ClientTimePassed += DeltaTime;
		LastTimePassed = TimePassed;

		Ratio = FMin(1.0, ClientTimePassed / KillTime);
		curScale = StartFlashScale + Ratio * (EndFlashScale - StartFlashScale);
		curFog = StartFlashFog + Ratio * (EndFlashFog - StartFlashFog);
		PlayerOwner.ClientFlash(curScale, curFog);
		curFOV = PlayerOwner.default.FOVAngle + Ratio * (DieFOV - PlayerOwner.default.FOVAngle);
		curFOV = FClamp(curFOV, 1, 179);
		DesiredFOV = FClamp(PlayerOwner.DesiredFOV, 1, 170);
		PlayerOwner.FOVAngle = ATan(Tan(curFOV * Pi / 360) * Tan(DesiredFOV * Pi / 360)) * 360 / Pi;
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
