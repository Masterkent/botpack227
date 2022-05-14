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

defaultproperties
{
	VersionInfo="NCGameFix v1.1 [2022-05-14]"
	Version="1.1"
	bCoopUnlockPaths=True
}
