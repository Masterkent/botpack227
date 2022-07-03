class SBMapFix expands Info;

#exec obj load file="Botpack.u"

var SBSPFix Mutator;
var string CurrentMap;

function PostBeginPlay()
{
	Mutator = SBSPFix(Owner);
	if (Mutator == none)
		return;
	FixCurrentMap();
	ModifyCurrentMap();
}

function FixCurrentMap()
{
	CurrentMap = string(Outer.Name);

	if (CurrentMap ~= "Jones-05-TemplePart2")
		FixCurrentMap_Jones_05_TemplePart2();
	else if (CurrentMap ~= "Jones-05-TemplePart3")
		FixCurrentMap_Jones_05_TemplePart3();
	else if (CurrentMap ~= "Jones-06-Vandora")
		FixCurrentMap_Jones_06_Vandora();
	else if (CurrentMap ~= "Jones-08-Pirate2")
		FixCurrentMap_Jones_08_Pirate2();
	else if (CurrentMap ~= "Jones-08-Pirate3")
		FixCurrentMap_Jones_08_Pirate3();
}

function ModifyCurrentMap()
{
	if (CurrentMap ~= "Jones-01-Deployment")
		ModifyCurrentMap_Jones_01_Deployment();
	else if (CurrentMap ~= "Jones-02-Darkness")
		ModifyCurrentMap_Jones_02_Darkness();
	else if (CurrentMap ~= "Jones-03-Rogue")
		ModifyCurrentMap_Jones_03_Rogue();
	else if (CurrentMap ~= "Jones-04-Trench")
		ModifyCurrentMap_Jones_04_Trench();
	else if (CurrentMap ~= "Jones-05-TemplePart3")
		ModifyCurrentMap_Jones_05_TemplePart3();
	else if (CurrentMap ~= "Jones-06-Vandora")
		ModifyCurrentMap_Jones_06_Vandora();
	else if (CurrentMap ~= "Jones-07-Noork")
		ModifyCurrentMap_Jones_07_Noork();
	else if (CurrentMap ~= "Jones-08-Pirate3")
		ModifyCurrentMap_Jones_08_Pirate3();
	else if (CurrentMap ~= "Jones-09-Scar")
		ModifyCurrentMap_Jones_09_Scar();
	else if (CurrentMap ~= "Jones-10-End")
		ModifyCurrentMap_Jones_10_End();
}

function ModifyCurrentMap_Jones_01_Deployment()
{
	if (Mutator.bSkipCutscenes)
	{
		SevenLevelInfo(LoadLevelActor("SevenLevelInfo0")).bCutScene = false;
		DisableTrigger("Trigger5");
		DisableTrigger("Trigger6");
	}
}

function ModifyCurrentMap_Jones_02_Darkness()
{
	if (Mutator.bSkipCutscenes)
		DisableTrigger("Trigger62");
}

function ModifyCurrentMap_Jones_03_Rogue()
{
	if (Mutator.bSkipCutscenes)
	{
		DisableTrigger("Trigger0");
		MakeActorRelevant("NonBuggyViewSpot10");
	}
}

function ModifyCurrentMap_Jones_04_Trench()
{
	if (Mutator.bSkipCutscenes)
		LoadLevelTrigger("Trigger4").Event = 'EndTelep';
}

function FixCurrentMap_Jones_05_TemplePart2()
{
	LoadLevelZone("ZoneInfo0").ZoneVelocity = vect(0, 0, 0);
}

function FixCurrentMap_Jones_05_TemplePart3()
{
	local Mover M;
	local DispatcherPlus Disp;
	local Teleporter Telep;
	local SBTeleportPlayer TelepZone;
	local Trigger Tr1, Tr2;
	local ScriptedPawn NaliGhost;
	local SBRadiusTeleporter NaliAreaTelep;
	local SBFallingMoverController FallingMoverController;

	// Bridge
	Tr1 = Spawn(class'Trigger',,, LoadLevelActor("Light81").Location);
	Tr1.Event = 'FallenDown';
	Tr1.TriggerType = TT_ClassProximity;
	Tr1.ClassProximityType = class'Pawn';
	Tr1.SetCollisionSize(30000, 40);
	Tr2 = LoadLevelTrigger("Trigger0"); // FallenDown
	Tr2.TriggerType = TT_ClassProximity;
	Tr2.ClassProximityType = class'Pawn';
	AssignInitialState(LoadLevelActor("SpecialEvent0"), 'KillInstigator');

	foreach AllActors(class'Mover', M, 'BridgeCollapse')
		Spawn(class'SBFallingMoverController', M, M.Tag);

	ProtectMover("Mover30");

	// Realm
	Disp = DispatcherPlus(LoadLevelActor("DispatcherPlus22"));
	Disp.OutDelays[2] = 0.1;
	Telep = Teleporter(LoadLevelActor("Teleporter5"));
	TelepZone = Spawn(class'SBTeleportPlayer',, 'TehProphetPort', Telep.Location, Telep.Rotation);
	TelepZone.FromZone = LoadLevelZone("ZoneInfo9");
	TelepZone.MoveOffset = vect(0, -8688, 0);
	TelepZone.bOnceOnly = true;

	NaliGhost = ScriptedPawn(LoadLevelActor("NaliPriest0"));
	NaliGhost.bIgnoreFriends = true;
	NaliGhost.HearingThreshold = 1000000;

	NaliAreaTelep = Spawn(class'SBRadiusTeleporter',,, NaliGhost.Location);
	NaliAreaTelep.SetCollisionSize(128, 400);
	NaliAreaTelep.URL = "TheDropZone";
	class'B227_SpawnableTeleporter'.static.StaticReplaceTeleporter(Telep,, true);

	DisableTeleporter("Teleporter2");

	// Destructible stairs at the end of the level
	M = LoadLevelMover("Mover1");
	FallingMoverController = Spawn(class'SBFallingMoverController', M, M.Tag);
	FallingMoverController.KeyMovementBitmask = 1; // move linearly between keypoints 0 and 1, then fall between keypoints 1 and 2
}

function ModifyCurrentMap_Jones_05_TemplePart3()
{
	local DispatcherPlus Disp;

	if (Mutator.bSkipCutscenes)
	{
		DisableTrigger("Trigger70"); // no translator messages from the Nali

		Disp = DispatcherPlus(LoadLevelActor("DispatcherPlus23"));
		Disp.OutEvents[1] = 'BlueGate';
		Disp.OutEvents[4] = 'BlueTrig';
	}
}

function FixCurrentMap_Jones_06_Vandora()
{
	MakeMoverTriggerableOnceOnly("Mover105"); // destructible bars
	MakeMoverTriggerableOnceOnly("Mover106"); // destructible bars
}

function ModifyCurrentMap_Jones_06_Vandora()
{
	if (Mutator.bSkipCutscenes)
		MakeActorRelevant("NonBuggyViewSpot5");
}

function ModifyCurrentMap_Jones_07_Noork()
{
	if (Mutator.bSkipCutscenes)
		MakeActorRelevant("NonBuggyViewSpot6");
}

function FixCurrentMap_Jones_08_Pirate2()
{
	local Trigger Tr;

	LoadLevelActor("TranslatorEvent1").SetLocation(LoadLevelActor("Trigger11").Location);
	LoadLevelActor("TranslatorEvent2").SetLocation(LoadLevelActor("Trigger29").Location);
	DispatcherPlus(LoadLevelActor("DispatcherPlus2")).OutEvents[6] = '';
	Dispatcher(LoadLevelActor("Dispatcher3")).OutEvents[2] = '';

	Tr = LoadLevelTrigger("Trigger0");
	Tr.bTriggerOnceOnly = true;
	Spawn(class'Dispatcher',, 'Disp_cantTouchThis').OutEvents[0] = Tr.Event;
	Tr.Event = 'Disp_cantTouchThis';
}

function FixCurrentMap_Jones_08_Pirate3()
{
	DisableTeleporter("Teleporter1");
	SetDynamicLightMover("Mover13");
}

function ModifyCurrentMap_Jones_08_Pirate3()
{
	local DispatcherPlus Disp;
	local int i;

	if (Mutator.bSkipCutscenes)
	{
		LoadLevelActor("ScriptedMale1").Destroy();
		for (i = 5; i <= 13; ++i)
			MakeActorRelevant("NonBuggyViewSpot" $ i);
		Disp = DispatcherPlus(LoadLevelActor("DispatcherPlus9"));
		Disp.OutEvents[6] = 'EndPortation'; // forcing exit
	}
}

function ModifyCurrentMap_Jones_09_Scar()
{
	local Trigger StartTrigger;
	local int i;

	if (Mutator.bSkipCutscenes)
	{
		StartTrigger = LoadLevelTrigger("Trigger18");
		StartTrigger.Event = 'FightDis';
		for (i = 7; i <= 11; ++i)
			MakeActorRelevant("NonBuggyViewSpot" $ i);
	}
}

function ModifyCurrentMap_Jones_10_End()
{
	Mutator.bIsCutsceneMap = true;
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

function ZoneInfo LoadLevelZone(string ZoneName)
{
	return ZoneInfo(DynamicLoadObject(Outer.Name $ "." $ ZoneName, class'ZoneInfo'));
}

function MakeMoverTriggerableOnceOnly(string MoverName, optional bool bProtect)
{
	local Mover m;
	m = LoadLevelMover(MoverName);
	SetMoverTriggerableOnceOnly(m);
	if (bProtect)
		m.MoverEncroachType = ME_IgnoreWhenEncroach;
}

function SetMoverTriggerableOnceOnly(Mover m)
{
	m.bTriggerOnceOnly = True;
	AssignInitialState(m, 'TriggerOpenTimed');
}

function ProtectMover(string MoverName)
{
	LoadLevelMover(MoverName).MoverEncroachType = ME_IgnoreWhenEncroach;
}

function AssignInitialState(Actor A, name StateName)
{
	A.InitialState = StateName;
	if (!A.IsInState(A.InitialState))
		A.GotoState(A.InitialState);
}

function DisableTrigger(string TriggerName)
{
	LoadLevelTrigger(TriggerName).Event = '';
}

function DisableTeleporter(string TeleporterName)
{
	local Teleporter telep;

	telep = Teleporter(DynamicLoadObject(outer.name $ "." $ TeleporterName, class'Teleporter'));
	telep.SetCollision(false);
	telep.DrawType = DT_None;
	telep.URL = "";
}

function SetDynamicLightMover(string MoverName)
{
	LoadLevelMover(MoverName).bDynamicLightMover = true;
}

function MakeActorRelevant(string ActorName)
{
	local Actor A;

	A = LoadLevelActor(ActorName);
	if (A != none)
		A.bGameRelevant = true;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
}
