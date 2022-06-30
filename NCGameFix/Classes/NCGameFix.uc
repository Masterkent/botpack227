class NCGameFix expands Mutator;

var const string VersionInfo;
var const string Version;

var() config bool bCoopUnlockPaths;

event BeginPlay()
{
	Spawn(class'NCMapFix', self);
	Spawn(class'NCGameRules', self);
	AddToPackagesMap(string(Class.Outer.Name));

	AdjustScriptedPawnStyle();
	ReplaceSpawnPoints();
}

function AdjustScriptedPawnStyle()
{
	local ScriptedPawn ScriptedPawn;

	foreach AllActors(class'ScriptedPawn', ScriptedPawn)
		if (ScriptedPawn.Style == STY_Masked)
			ScriptedPawn.Style = STY_Normal;
}

function ReplaceSpawnPoints()
{
	local SpawnPoint SpawnPoint;

	foreach AllActors(class'SpawnPoint', SpawnPoint)
		if (SpawnPoint.Class == class'SpawnPoint')
		{
			SpawnPoint.Spawn(class'NCSpawnPoint',, SpawnPoint.Tag);
			SpawnPoint.Tag = '';
		}
}

function bool CheckReplacement(Actor A, out byte bSuperRelevant)
{
	if (Level.NetMode == NM_Standalone)
		return true;

	if (NCPickup(A) != none)
		return
			NCLantern(A) != none ||
			NCSeeds(A) != none ||
			NCSkaarjLight(A) != none;

	if (NCSpell(A) != none)
		return false;

	return true;
}

defaultproperties
{
	VersionInfo="NCGameFix v1.6 [2022-06-30]"
	Version="1.6"
	bCoopUnlockPaths=True
}
