class NCGameFix expands Mutator;

var const string VersionInfo;
var const string Version;

var() config bool bCoopUnlockPaths;

event BeginPlay()
{
	Spawn(class'NCMapFix', self);
	Spawn(class'NCGameRules', self);
	AddToPackagesMap(string(Class.Outer.Name));
}

defaultproperties
{
	VersionInfo="NCGameFix v1.0 [2022-05-12]"
	Version="1.0"
	bCoopUnlockPaths=True
}
