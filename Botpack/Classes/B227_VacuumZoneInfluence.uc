class B227_VacuumZoneInfluence expands Info;

var ZoneInfo Zone;
var bool bScreamed;
var bool bActive;
var float TimePassed;
var float curScale;
var vector curFog;
var float curFOV;

replication
{
	reliable if (Role == ROLE_Authority)
		bActive,
		curScale,
		curFog,
		curFOV;
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
	local float ratio;
	local float MainFOV;

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
			ratio = FMin(1.0, TimePassed / VacuumZone.KillTime);
			PawnOwner.Fatness = Min(255, PawnOwner.default.Fatness + (255 - PawnOwner.default.Fatness) * ratio);

			if (PlayerOwner != none)
			{
				curScale = (VacuumZone.EndFlashScale - VacuumZone.StartFlashScale) * ratio + VacuumZone.StartFlashScale;
				curFog = (VacuumZone.EndFlashFog - VacuumZone.StartFlashFog ) * ratio + VacuumZone.StartFlashFog;
				curFog *= 1000;
				curFOV = (VacuumZone.DieFOV - PlayerOwner.default.FOVAngle) * ratio + PlayerOwner.default.FOVAngle;
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
				if (PlayerOwner != none)
					curFOV = PlayerOwner.default.FOVAngle;
			}
		}
	}
	else if (!bNetOwner)
		return;

	if (Level.NetMode != NM_DedicatedServer && bActive && PlayerOwner != none)
	{
		PlayerOwner.ClientFlash(curScale, curFog);
		curFOV = FClamp(curFOV, 1, 179);
		MainFOV = FClamp(PlayerOwner.MainFOV, 1, 170);
		PlayerOwner.FOVAngle = ATan(Tan(curFOV * Pi / 360) * Tan(MainFOV * Pi / 360)) * 360 / Pi;
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
