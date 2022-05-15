class NCGameFix expands Mutator;

var const string VersionInfo;
var const string Version;

var() config bool bCoopUnlockPaths;

event BeginPlay()
{
	Spawn(class'NCMapFix', self);
	Spawn(class'NCGameRules', self);
	AddToPackagesMap(string(Class.Outer.Name));

	ReplaceSpawnPoints();
}

function ReplaceSpawnPoints()
{
	local SpawnPoint SpawnPoint;
	local NCSpawnPoint NCSpawnPoint;

	foreach AllActors(class'SpawnPoint', SpawnPoint)
		if (SpawnPoint.Class == class'SpawnPoint')
		{
			NCSpawnPoint = SpawnPoint.Spawn(class'NCSpawnPoint',, SpawnPoint.Tag);
			SpawnPoint.Tag = '';
		}
}

function bool CheckReplacement(Actor A, out byte bSuperRelevant)
{
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
	VersionInfo="NCGameFix v1.2 [2022-05-15]"
	Version="1.2"
	bCoopUnlockPaths=True
}
