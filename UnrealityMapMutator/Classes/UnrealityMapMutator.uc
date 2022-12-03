class UnrealityMapMutator expands Mutator
	config(UnrealityMapMutator);

#exec OBJ LOAD FILE="Botpack.u"
#exec OBJ LOAD FILE="XidiaMPack.u"

var() const string VersionInfo;
var() const string Version;

var() config bool bDestructibleTeamCannons;
var() config bool bModifyUnrealDifficultyFilter;
var() config string CoopGameEndURL;
var() config string FinalBossWeapon;

event BeginPlay()
{
	if (Level.NetMode != NM_Standalone)
		CoopStartup();
	if (bDestructibleTeamCannons)
		AdjustTeamCannons();
	if (bModifyUnrealDifficultyFilter)
		ModifyUnrealDifficultyFilter();
	Server_FixCurrentMap();
}

function AdjustTeamCannons()
{
	local TeamCannon TeamCannon;

	foreach AllActors(class'TeamCannon', TeamCannon)
		TeamCannon.B227_bPermanentDamagedState = true;
}

function ModifyUnrealDifficultyFilter()
{
	local Inventory Inv;

	foreach AllActors(class'Inventory', Inv)
		if (Inv.bDifficulty2)
			Inv.bDifficulty3 = true;
}

function CoopStartup()
{
	local Actor A;

	AddToPackagesMap("UnrealityFlare");
	AddToPackagesMap("UnrealityW2");

	foreach AllActors(class'Actor', A)
		if (A.IsA('NonBuggyViewSpot'))
			A.Destroy();
}

function Server_FixCurrentMap()
{
	local string CurrentMap;

	CurrentMap = string(Outer.Name);

	if (CurrentMap ~= "Unreality-02-Siberia")
		Server_FixCurrentMap_Unreality_02_Siberia();
	else if (CurrentMap ~= "Unreality-03-TheCave")
		Server_FixCurrentMap_Unreality_03_TheCave();
	else if (CurrentMap ~= "Unreality-06-TheCave2")
		Server_FixCurrentMap_Unreality_06_TheCave2();
	else if (CurrentMap ~= "Unreality-07-OutPost")
		Server_FixCurrentMap_Unreality_07_OutPost();
	else if (CurrentMap ~= "Unreality-08-Buran")
		Server_FixCurrentMap_Unreality_08_Buran();
	else if (CurrentMap ~= "Unreality-09-Tygron")
		Server_FixCurrentMap_Unreality_09_Tygron();
}


function Server_FixCurrentMap_Unreality_02_Siberia()
{
	if (Level.NetMode != NM_Standalone)
		AddSafeFall(vect(-19500, -13000, -21000), 2500, 2000);
}

function Server_FixCurrentMap_Unreality_03_TheCave()
{
	if (Level.NetMode != NM_Standalone)
	{
		AddSafeFall(vect(-15163, 86, -2209), 2560, 960);
		LoadLevelActor("TriggeredDeath0").Destroy();
	}
}

function Server_FixCurrentMap_Unreality_06_TheCave2()
{
	LoadLevelActor("TarydiumBarrel9").Event = 'CellDoorsLeft7';
}

function Server_FixCurrentMap_Unreality_07_OutPost()
{
	if (Level.NetMode != NM_Standalone)
	{
		MakeMoverTriggerableOnceOnly("Mover20");
		MakeMoverTriggerableOnceOnly("Mover22");
		LoadLevelMover("Mover43").DelayTime = 2;
	}
}

function Server_FixCurrentMap_Unreality_08_Buran()
{
	if (Level.NetMode != NM_Standalone)
	{
		DispatcherPlus(LoadLevelActor("DispatcherPlus0")).OutEvents[0] = 'AttachTeleporter';
		MakeMoverTriggerableOnceOnly("Mover110");
		MakeMoverTriggerableOnceOnly("Mover111");
		LoadLevelActor("Teleporter0").SetCollisionSize(100,  40);
	}
}

function Server_FixCurrentMap_Unreality_09_Tygron()
{
	local ScriptedXan2 FinalBoss;
	local class<Weapon> WeaponClass;

	if (Level.NetMode != NM_Standalone)
	{
		MakeMoverTriggerableOnceOnly("Mover2");
		MakeMoverTriggerableOnceOnly("Mover3");
		if (Len(GetCoopGameEndURL()) > 0)
			Teleporter(LoadLevelActor("Teleporter1")).URL = GetCoopGameEndURL();
	}

	if (Len(FinalBossWeapon) > 0)
	{
		FinalBoss = ScriptedXan2(LoadLevelActor("ScriptedXan1"));
		WeaponClass = class<Weapon>(DynamicLoadObject(FinalBossWeapon, class'Class'));
		if (FinalBoss != none &&
			WeaponClass != none &&
			(Level.NetMode == NM_Standalone || ClassIsInServerPackages(WeaponClass)))
		{
			FinalBoss.WeaponType = WeaponClass;
		}
	}

	LoadLevelTrigger("Trigger0").TriggerType = TT_PawnProximity;
	LoadLevelTrigger("Trigger19").TriggerType = TT_PawnProximity;
}


function AddSafeFall(vector Pos, float CollisionRadius, float CollisionHeight)
{
	local UnrealitySafeFall SafeFall;

	SafeFall = Spawn(class'UnrealitySafeFall',,, Pos);
	if (SafeFall != none)
		SafeFall.SetCollisionSize(CollisionRadius, CollisionHeight);
}

function Actor LoadLevelActor(string ActorName, optional bool bMayFail)
{
	return Actor(DynamicLoadObject(Outer.Name $ "." $ ActorName, class'Actor', bMayFail));
}

function Mover LoadLevelMover(string MoverName)
{
	return Mover(DynamicLoadObject(Outer.Name $ "." $ MoverName, class'Mover'));
}

function Trigger LoadLevelTrigger(string TriggerName)
{
	return Trigger(DynamicLoadObject(Outer.Name $ "." $ TriggerName, class'Trigger'));
}

function MakeMoverTriggerableOnceOnly(string MoverName, optional bool bProtect)
{
	local Mover Mover;

	Mover = LoadLevelMover(MoverName);
	SetMoverTriggerableOnceOnly(Mover);
	if (bProtect)
		Mover.MoverEncroachType = ME_IgnoreWhenEncroach;
}

function SetMoverTriggerableOnceOnly(Mover Mover)
{
	Mover.bTriggerOnceOnly = True;
	Mover.InitialState = 'TriggerOpenTimed';
}

function bool ClassIsInServerPackages(class<Object> ObjectClass)
{
	local Object OuterObj;

	for (OuterObj = ObjectClass; OuterObj.Outer != none; OuterObj = OuterObj.Outer) {}
	return IsInPackageMap(string(OuterObj.Name));
}

function string GetCoopGameEndURL()
{
	if (Len(CoopGameEndURL) == 0 || InStr(CoopGameEndURL, "#") == 0 || InStr(CoopGameEndURL, "/") == 0)
		return "";
	if (InStr(CoopGameEndURL, "#") > 0 || InStr(CoopGameEndURL, "/") > 0)
		return CoopGameEndURL;
	return CoopGameEndURL $ "#";
}

function string GetHumanName()
{
	return "UnrealityMapMutator v1.0";
}

defaultproperties
{
	VersionInfo="UnrealityMapMutator v1.0 [2022-12-03]"
	Version="1.0"
	bDestructibleTeamCannons=True
	bModifyUnrealDifficultyFilter=True
	CoopGameEndURL="Unreality-02-Siberia#"
	FinalBossWeapon="XidiaMPack.XidiaShockRifle"
}
