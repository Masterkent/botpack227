class ONPSPFix expands Mutator
	config(ONPSPFix);

var() const string VersionInfo;
var() const string Version;

var() config bool bPreventFallingOutOfWorld;

event PostBeginPlay()
{
	if (RemoveDuplicatedMutator())
		return;
	LevelStartupAdjustments();
	AddGameRules();
}

function bool RemoveDuplicatedMutator()
{
	local Mutator Mutator;

	for (Mutator = Level.Game.BaseMutator; Mutator != none; Mutator = Mutator.NextMutator)
		if (Mutator.Class == Class && Mutator != self)
		{
			Destroy();
			return true;
		}
	return false;
}

function LevelStartupAdjustments()
{
	Level.Game.bAlwaysEnhancedSightCheck = false;
	AdjustExplodingEffects();
	AdjustMusicEvents();
	AdjustTriggers();
	ReplaceCameraSpots();
	ReplaceSpawnPoints();

	FixCurrentMap();

	ReplaceTeleporters();
}

function AdjustDecorations()
{
	local Decoration Deco;

	foreach AllActors(class'Decoration', Deco)
		if (Deco.Physics == PHYS_Falling && Deco.Region.ZoneNumber == 0)
		{
			Deco.bCollideWorld = false;
			Deco.bMovable = false;
			Deco.SetPhysics(PHYS_None);
		}
}

function AdjustExplodingEffects()
{
	local ExplodingWall EW;
	local ExplosionChain EC;

	foreach AllActors(class'ExplodingWall', EW)
		EW.SetCollision(false);
	foreach AllActors(class'ExplosionChain', EC)
		EC.SetCollision(false);
}

function AdjustMusicEvents()
{
	local MusicEvent MusicEvent;

	foreach AllActors(class'MusicEvent', MusicEvent)
		if (MusicEvent.Song != none && MusicEvent.Song.Name == 'Null')
			MusicEvent.SongSection = 255; // silence
}

function AdjustTriggers()
{
	AdjustTriggersProximity();
}

function AdjustTriggersProximity()
{
	local Trigger Trigger;
	local Mover Mover;

	foreach AllActors(class'Trigger', Trigger)
		if (Trigger.TriggerType == TT_AnyProximity && Trigger.Event != '')
		{
			foreach AllActors(class'Mover', Mover, Trigger.Event)
				if (Mover.InitialState == 'TriggerControl')
				{
					Trigger.TriggerType = TT_PawnProximity;
					break;
				}
		}
}

function ReplaceCameraSpots()
{
	local KeyPoint CameraSpot;

	foreach AllActors(class'KeyPoint', CameraSpot)
		if (CameraSpot.Class.Name == 'CameraSpot' &&
			CameraSpot.Class.Outer == Outer &&
			DynamicLoadObject(Outer.Name $ ".CameraSpot.PlayerLocal", class'Object', true) != none)
		{
			class'ONPCameraSpot'.static.ReplaceCameraSpot(CameraSpot);
		}
}

function ReplaceSpawnPoints()
{
	local SpawnPoint SpawnPoint;

	foreach AllActors(class'SpawnPoint', SpawnPoint)
		if (SpawnPoint.Class == class'SpawnPoint' && SpawnPoint.Tag != '')
		{
			SpawnPoint.Spawn(class'ONPSpawnPoint',, SpawnPoint.Tag);
			SpawnPoint.Tag = '';
		}
}

function ReplaceTeleporters()
{
	class'B227_SpawnableTeleporter'.static.ReplaceLevelTeleporters(Level);
}

function FixCurrentMap()
{
	Spawn(class'ONPMapFix', self);
}

function AddGameRules()
{
	local GameRules GR;

	GR = Spawn(class'ONPGameRules', self);

	if (Level.Game.GameRules == none)
		Level.Game.GameRules = GR;
	else if (GR != None)
		Level.Game.GameRules.AddRules(GR);
}

auto state MutatorState
{
Begin:
	AdjustDecorations();
}

function string GetHumanName()
{
	return "ONPSPFix v1.33";
}

defaultproperties
{
	VersionInfo="ONPSPFix v1.33 [2024-12-05]"
	Version="1.33"
	bPreventFallingOutOfWorld=True
}
