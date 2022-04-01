class B227_SpawnableTeleporter expands UTC_Teleporter;

event PostBeginPlay()
{
	if (Teleporter(Owner) != none)
	{
		ReplaceTeleporter(Teleporter(Owner));
		super.PostBeginPlay();
	}
}

function ReplaceTeleporter(Teleporter OldTelep)
{
	URL = OldTelep.URL;
	Tag = OldTelep.Tag;
	SetCollision(OldTelep.bCollideActors, OldTelep.bBlockActors, OldTelep.bBlockPlayers);
	SetCollisionSize(OldTelep.CollisionRadius, OldTelep.CollisionHeight);
	bChangesVelocity = OldTelep.bChangesVelocity;
	bReversesX = OldTelep.bReversesX;
	bReversesY = OldTelep.bReversesY;
	bReversesZ = OldTelep.bReversesZ;
	bEnabled = OldTelep.bEnabled;
	TargetVelocity = OldTelep.TargetVelocity;
	// bChangesYaw should not be copied, because its default value differs between Unreal and UT.

	OldTelep.Tag = '';
	OldTelep.URL = "";
	OldTelep.SetCollision(false);
}

static function B227_SpawnableTeleporter StaticReplaceTeleporter(
	Teleporter OldTelep,
	optional bool bNoChangesYaw,
	optional bool bChangesYawAbsolutely)
{
	local B227_SpawnableTeleporter NewTelep;

	NewTelep = OldTelep.Spawn(class'B227_SpawnableTeleporter', OldTelep, OldTelep.Tag);
	if (NewTelep != none)
	{
		NewTelep.bChangesYaw = !bNoChangesYaw;
		NewTelep.B227_bChangesYawAbsolutely = bChangesYawAbsolutely;
	}
	return NewTelep;
}

static function ReplaceLevelTeleporters(LevelInfo Level)
{
	local Teleporter Telep;

	foreach Level.AllActors(class'Teleporter', Telep)
		if (Telep.Class == class'Teleporter')
		{
			if (Telep.Tag != '' && Len(Telep.URL) == 0 ||
				Len(Telep.URL) > 0 && InStr(Telep.URL, "/") < 0 && InStr(Telep.URL, "#") < 0)
			{
				StaticReplaceTeleporter(Telep);
			}
		}
}

defaultproperties
{
	bCollideWhenPlacing=False
	bStatic=False
}
