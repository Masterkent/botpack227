//=============================================================================
// ONPSPFix v1.6                                             Author: Masterkent
//                                                             Date: 2022-06-06
//=============================================================================

class ONPSPFix expands Mutator;

var() const string VersionInfo;
var() const string Version;

function PostBeginPlay()
{
	LevelStartupAdjustments();
}

function LevelStartupAdjustments()
{
	Level.Game.bAlwaysEnhancedSightCheck = false;
	AdjustDecorations();
	AdjustExplodingEffects();
	AdjustMusicEvents();
	AdjustTriggers();
	ReplaceCameraSpots();
	ReplaceTeleporters();

	FixCurrentMap();
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

function ReplaceTeleporters()
{
	class'B227_SpawnableTeleporter'.static.ReplaceLevelTeleporters(Level);
}

function FixCurrentMap()
{
	Spawn(class'ONPMapFix', self);
}

function string GetHumanName()
{
	return "ONPSPFix v1.6";
}

defaultproperties
{
	VersionInfo="ONPSPFix v1.6 [2022-06-06]"
	Version="1.6"
}
