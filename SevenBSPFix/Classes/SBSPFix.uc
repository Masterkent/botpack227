class SBSPFix expands Mutator;

var() const string VersionInfo;
var() const string Version;

var() config bool bSkipCutscenes;

var bool bIsCutsceneMap;

function PostBeginPlay()
{
	LevelStartupAdjustments();
}

function LevelStartupAdjustments()
{
	FixCurrentMap();
	FixExitTeleporters();
	RemoveCutsceneActors();
}

function FixCurrentMap()
{
	Spawn(class'SBMapFix', self);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Other.Class == class'Botpack.SuperShockRifle')
	{
		Other.MultiSkins[1] = texture'Botpack.SASMD_t';
		Weapon(Other).bTravel = false;
		Weapon(Other).PickupAmmoCount = class'SuperShockCore'.default.MaxAmmo;
	}

	return true;
}

function FixExitTeleporters()
{
	local Teleporter Telep;

	foreach AllActors(class'Teleporter', Telep)
		if (!Telep.bEnabled &&
			Telep.Tag != '' &&
			(InStr(Telep.URL, "/") >= 0 || InStr(Telep.URL, "#") >= 0))
		{
			Spawn(class'SBTeleporterTouch',, Telep.Tag);
		}
}

function RemoveCutsceneActors()
{
	local Actor A;

	if (!bSkipCutscenes || bIsCutsceneMap)
		return;

	foreach AllActors(class'Actor', A)
		if (A.IsA('PlayerMotionFreeze') ||
			A.IsA('ViewSpot') ||
			A.IsA('ViewSpotStop') ||
			A.IsA('NonBuggyViewSpot'))
		{
			if (A.bGameRelevant)
				A.bGameRelevant = false;
			else
				A.Destroy();
		}
}

function string GetHumanName()
{
	return "SBSPFix v1.6";
}

defaultproperties
{
	VersionInfo="SBSPFix v1.6 [2022-12-22]"
	Version="1.6"
}
