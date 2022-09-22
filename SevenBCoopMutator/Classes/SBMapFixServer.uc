class SBMapFixServer expands SBMapFixBase;

var SBCoopMutator MutatorPtr;

function Init(string CurrentMap)
{
	super.Init(CurrentMap);
	Server_FixCurrentMap();

	MutatorPtr = SBCoopMutator(Owner);
	if (MutatorPtr != none)
		Server_ModifyCurrentMap();
}

function Server_FixCurrentMap()
{
	DeleteRemovableMovers();
	DisableConsoleCommandTriggers();

	if (CurrentMap ~= "Jones-02-Darkness")
		Server_FixCurrentMap_Jones_02_Darkness();
	else if (CurrentMap ~= "Jones-04-Trench")
		Server_FixCurrentMap_Jones_04_Trench();
	else if (CurrentMap ~= "Jones-05-Trench2")
		Server_FixCurrentMap_Jones_05_Trench2();
	else if (CurrentMap ~= "Jones-05-TemplePart2")
		Server_FixCurrentMap_Jones_05_TemplePart2();
	else if (CurrentMap ~= "Jones-05-TemplePart3")
		Server_FixCurrentMap_Jones_05_TemplePart3();
	else if (CurrentMap ~= "Jones-06-Vandora")
		Server_FixCurrentMap_Jones_06_Vandora();
	else if (CurrentMap ~= "Jones-07-Noork")
		Server_FixCurrentMap_Jones_07_Noork();
	else if (CurrentMap ~= "Jones-08-Pirate2")
		Server_FixCurrentMap_Jones_08_Pirate2();
	else if (CurrentMap ~= "Jones-08-Pirate3")
		Server_FixCurrentMap_Jones_08_Pirate3();
	else if (CurrentMap ~= "Jones-09-Scar")
		Server_FixCurrentMap_Jones_09_Scar();
}

function Server_ModifyCurrentMap()
{
	if (CurrentMap ~= "Jones-01-Deployment")
		Server_ModifyCurrentMap_Jones_01_Deployment();
	else if (CurrentMap ~= "Jones-02-Darkness")
		Server_ModifyCurrentMap_Jones_02_Darkness();
	else if (CurrentMap ~= "Jones-03-Rogue")
		Server_ModifyCurrentMap_Jones_03_Rogue();
	else if (CurrentMap ~= "Jones-05-TemplePart2")
		Server_ModifyCurrentMap_Jones_05_TemplePart2();
	else if (CurrentMap ~= "Jones-06-Vandora")
		Server_ModifyCurrentMap_Jones_06_Vandora();
	else if (CurrentMap ~= "Jones-08-Pirate")
		Server_ModifyCurrentMap_Jones_08_Pirate();
	else if (CurrentMap ~= "Jones-08-Pirate2")
		Server_ModifyCurrentMap_Jones_08_Pirate2();
}


function Server_FixCurrentMap_Jones_02_Darkness()
{
	local Decoration aDecoration;

	CreatureFactory(LoadLevelActor("CreatureFactory9")).bCovert = false;

	foreach AllActors(class'Decoration', aDecoration)
		if (aDecoration.IsA('Fan2'))
			aDecoration.bAlwaysRelevant = true;
}

function Server_FixCurrentMap_Jones_04_Trench()
{
	LoadLevelTrigger("Trigger4").Event = 'EndTelep';
}

function Server_FixCurrentMap_Jones_05_Trench2()
{
	local Trigger Tr;
	local Mover M;
	local SBMoverStateSensor MoverSensor;
	local SpecialEvent aSpecialEvent;
	local Dispatcher Disp;
	local SBInstantDispatcher IDisp;

	Tr = LoadLevelTrigger("Trigger10");
	Tr.bTriggerOnceOnly = false;
	Tr.Tag = 'trapdooropen';
	AssignInitialState(Tr, 'OtherTriggerTurnsOff');

	aSpecialEvent = SpecialEvent(LoadLevelActor("SpecialEvent4"));
	aSpecialEvent.Tag = '';

	M = LoadLevelMover("Mover15");
	M.OpeningSound = aSpecialEvent.Sound;
	M.ClosingSound = M.OpeningSound;
	M.ClosedSound = M.OpenedSound;
	M.StayOpenTime = 45; // 2 * Mover6.MoveTime + Dispatcher1.OutDelays[1] + Dispatcher1.OutDelays[2]
	MoverSensor = Spawn(class'SBMoverStateSensor',, 'activate_walls_trap');
	MoverSensor.bCanTriggerWhenClosed = true;
	MoverSensor.ControlledMover = M;
	MoverSensor.Event = Tr.Event;
	Tr.Event = 'activate_walls_trap';

	M = LoadLevelMover("Mover23");
	M.bTriggerOnceOnly = true;
	M.OpeningSound = aSpecialEvent.Sound;

	DisableTeleporter("Teleporter1");

	LoadLevelMover("Mover6").StayOpenTime = 0;
	LoadLevelMover("Mover22").StayOpenTime = 0;
	MakeMoverTriggerableOnceOnly("Mover13", true);
	MakeMoverTriggerableOnceOnly("Mover16", true);
	Spawn(class'SBDiscardMoversInstigator',, LoadLevelMover("Mover6").Tag);

	IDisp = Spawn(class'SBInstantDispatcher',, 'activate_crystals');
	IDisp.bTriggerOnceOnly = true;
	Disp = LoadLevelDispatcher("Dispatcher1");
	IDisp.OutEvents[0] = Disp.OutEvents[1];
	Disp.OutEvents[1] = 'activate_crystals';
}

function Server_FixCurrentMap_Jones_05_TemplePart2()
{
	// Is also changed by SBMapFixClient
	LoadLevelZone("ZoneInfo0").ZoneVelocity = vect(0, 0, 0);
}

function Server_FixCurrentMap_Jones_05_TemplePart3()
{
	local Mover M;
	local SBSpawnableTeleporter Telep;
	local SBTeleportPlayersFromZone TelepZone;
	local SBMoverEventHandler MoverEventHandler;
	local DispatcherPlus Disp;
	local Dispatcher TimeoutDisp, DoorDisp;
	local SBInstantDispatcher IDisp;
	local Trigger Tr1, Tr2;
	local ThingFactory InvFactory;
	local ScriptedPawn NaliGhost;
	local SBRadiusTeleporter NaliAreaTelep;
	local SBFallingMoverController FallingMoverController;

	DisablePlayerStart("PlayerStart1");
	DisablePlayerStart("PlayerStart2");
	DisablePlayerStart("PlayerStart3");
	DisablePlayerStart("PlayerStart4");
	DisablePlayerStart("PlayerStart5");
	DisablePlayerStart("PlayerStart6");

	// Bridge
	Telep = Spawn(class'SBSpawnableTeleporter',, 'GuardianDefeatedDispatcher', LoadLevelActor("Pathnode143").Location);
	Telep.bDrawWhenEnabled = true;
	Telep.bEnabled = false;
	Telep.SetCollisionSize(60, 40);
	Telep.Style = STY_Translucent;
	Telep.Texture = WetTexture(DynamicLoadObject("SpaceFX.worm3f", class'WetTexture'));
	Telep.URL = "bridge_other_side";
	AddToPackagesMap("SpaceFX");
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

	Telep = Spawn(class'SBSpawnableTeleporter',, 'bridge_other_side', LoadLevelActor("Pathnode154").Location, rot(0, 0, 0));
	Telep.bChangesYaw = true;
	Telep.B227_bChangesYawAbsolutely = true;
	Telep.SetCollision(false);
	Tr1 = LoadLevelTrigger("Trigger37");
	Tr2 = Spawn(class'Trigger',,, Tr1.Location);
	Tr2.SetCollisionSize(Tr1.CollisionRadius, Tr1.CollisionHeight);
	Tr2.Event = 'GuardianDieTimeout';
	TimeoutDisp = Spawn(class'Dispatcher',, 'GuardianDieTimeout');
	TimeoutDisp.OutDelays[0] = 240;
	TimeoutDisp.OutEvents[0] = Tr1.Tag;

	ProtectMover("Mover30");

	// Part with "Broken ShockRifle"
	M = LoadLevelMover("Mover64");
	M.bNet = true;
	M.MoverEncroachType = ME_IgnoreWhenEncroach;
	LoadLevelTrigger("Trigger39").bNet = true;
	LoadLevelTrigger("Trigger59").bNet = true;
	LoadLevelTrigger("Trigger72").bNet = true;
	LoadLevelTrigger("Trigger47").bTriggerOnceOnly = true; // message "You have no reason to take the Broken Shockrifle"

	LoadLevelDispatcher("Dispatcher6").OutEvents[3] = 'ASMDtrigger';

	// Door to chamber with Titans
	LoadLevelActor("Mover63").Event = 'ProphetChamberDoor_Open_Disp';
	Spawn(class'SBMoverStateController',, 'Mover_ProphetChamberDoor').MoverName = 'Mover62';
	M = LoadLevelMover("Mover62");

	LoadLevelDispatcherPlus("DispatcherPlus19").OutEvents[1] = 'ProphetChamberDoor_Close';
	IDisp = Spawn(class'SBInstantDispatcher',, 'ProphetChamberDoor_Open_Disp');
	IDisp.ConditionTrigger = MakeConditionTrigger('ProphetChamberDoor_Close', 'OtherTriggerTurnsOff', true);
	IDisp.OutEvents[0] = 'ProphetChamberDoor_Open';
	IDisp = Spawn(class'SBInstantDispatcher',, 'ProphetChamberDoor_Open_Disp');
	IDisp.ConditionTrigger = MakeConditionTrigger('ProphetChamberDoor_Close', 'OtherTriggerTurnsOn', false);
	IDisp.OutEvents[0] = 'ProphetChamberDoor_Disp';
	DoorDisp = Spawn(class'Dispatcher',, 'ProphetChamberDoor_Disp');
	DoorDisp.OutEvents[0] = 'ProphetChamberDoor_Open';
	DoorDisp.OutEvents[1] = 'ProphetChamberDoor_Close';
	DoorDisp.OutDelays[1] = M.MoveTime + M.StayOpenTime;

	MoverEventHandler = Spawn(class'SBMoverEventHandler',, 'ProphetChamberDoor_Open');
	MoverEventHandler.ControllerTag = 'Mover_ProphetChamberDoor';
	MoverEventHandler.MoverPosChange = 'Open';

	MoverEventHandler = Spawn(class'SBMoverEventHandler',, 'ProphetChamberDoor_Close');
	MoverEventHandler.ControllerTag = 'Mover_ProphetChamberDoor';
	MoverEventHandler.MoverPosChange = 'Close';

	MoverEventHandler = Spawn(class'SBMoverEventHandler',, 'RealmExported');
	MoverEventHandler.ControllerTag = 'Mover_ProphetChamberDoor';
	MoverEventHandler.MoverPosChange = 'Close';
	MoverEventHandler.bPermanentChange = true;

	// SuperShockRifle
	LoadLevelActor("Knife13").bHidden = true;
	InvFactory = ThingFactory(LoadLevelActor("ThingFactory0"));
	InvFactory.bFalling = false;
	Spawn(class'SBKillActors',, 'TheGiftHasBeenSpent').ActorClass = class'SuperShockRifle';
	Spawn(class'SBKillActors',, 'TheGiftHasBeenSpent').ActorClass = class'SuperShockCore';

	// Realm
	Disp = LoadLevelDispatcherPlus("DispatcherPlus22");
	Disp.OutEvents[1] = 'RealmExported';
	Disp.OutTrigger[2] = 1;

	TelepZone = Spawn(class'SBTeleportPlayersFromZone',, 'TehProphetPort');
	TelepZone.Zone = LoadLevelZone("ZoneInfo9");
	TelepZone.MoveOffset = vect(0, -8688, 0);

	NaliGhost = ScriptedPawn(LoadLevelActor("NaliPriest0"));
	NaliGhost.bIgnoreFriends = true;
	NaliGhost.HearingThreshold = 1000000;

	NaliAreaTelep = Spawn(class'SBRadiusTeleporter',,, NaliGhost.Location);
	NaliAreaTelep.SetCollisionSize(128, 400);
	NaliAreaTelep.URL = "TheDropZone";
	class'B227_SpawnableTeleporter'.static.StaticReplaceTeleporter(Teleporter(LoadLevelActor("Teleporter5")),, true);

	DisableTrigger("Trigger70"); // no translator messages from the Nali

	Disp = LoadLevelDispatcherPlus("DispatcherPlus23");
	Disp.OutEvents[1] = 'BlueGate';
	Disp.OutEvents[3] = 'BlueTrig';

	DisableTeleporter("Teleporter2");
	LoadLevelActor("Teleporter1").Tag = '';
	Telep = Spawn(class'SBSpawnableTeleporter',, 'RealmExported', vect(12272, -6032, -300), rot(0, 16332, 0));
	Telep.bChangesYaw = true;
	Telep.SetCollision(false);

	// Destructible stairs at the end of the level
	M = LoadLevelMover("Mover1");
	FallingMoverController = Spawn(class'SBFallingMoverController', M, M.Tag);
	FallingMoverController.KeyMovementBitmask = 1; // move linearly between keypoints 0 and 1, then fall between keypoints 1 and 2
}

function Server_FixCurrentMap_Jones_06_Vandora()
{
	local Mover M;
	local ScriptedFemale ScriptedFemale;
	local int i;

	LoadLevelMover("Mover9").InitialState = 'TriggerOpenTimed';
	LoadLevelMover("Mover12").InitialState = 'TriggerOpenTimed';
	class'SBTriggerStoppedMover'.static.CreateFor(Level, "Mover10");

	MakeMoverTriggerableOnceOnly("Mover105"); // destructible bars
	MakeMoverTriggerableOnceOnly("Mover106"); // destructible bars

	M = LoadLevelMover("Mover71");
	M.Tag = 'SpinnerLairPadlock';
	SetMoverTriggerableOnceOnly(M);

	M = LoadLevelMover("Mover72");
	M.Tag = 'SpinnerLairPadlock';
	SetMoverTriggerableOnceOnly(M);

	ScriptedFemale = ScriptedFemale(LoadLevelActor("ScriptedFemale2"));
	ScriptedFemale.CarcassType = ScriptedFemale.default.CarcassType;
	for (i = 0; i < ArrayCount(ScriptedFemale.Deaths); ++i)
		ScriptedFemale.Deaths[i] = ScriptedFemale.default.Deaths[i];
}

function Server_FixCurrentMap_Jones_07_Noork()
{
	local Dispatcher Disp;
	local SpecialEvent SpecialEvent;
	local ScriptedHuman ScriptedHuman;
	local ScriptedPawn ScriptedPawn;

	DisableNonSPPlayerStarts();

	LoadLevelTrigger("Trigger43").Event = 'PlatformSniper';
	LoadLevelTrigger("Trigger44").Event = 'CliffSniper';
	LoadLevelTrigger("Trigger45").Event = 'CraneSniper';
	LoadLevelTrigger("Trigger46").Event = 'ReturnoftheCraneSniper';
	LoadLevelTrigger("Trigger47").Event = 'SneakySniper';
	LoadLevelTrigger("Trigger48").Event = 'SonofSneakySniper';

	LoadLevelActor("ScriptedMale0").Tag = 'PlatformSniper';
	LoadLevelActor("ScriptedMale3").Tag = 'CliffSniper';
	LoadLevelActor("ScriptedFemale0").Tag = 'CraneSniper';
	LoadLevelActor("ScriptedMale6").Tag = 'ReturnoftheCraneSniper';
	LoadLevelActor("ScriptedMale9").Tag = 'SneakySniper';
	LoadLevelActor("ScriptedMale7").Tag = 'SonofSneakySniper';

	foreach AllActors(class'SpecialEvent', SpecialEvent, 'ShotInTheHead')
		SpecialEvent.Tag = '';
	foreach AllActors(class'ScriptedHuman', ScriptedHuman)
	{
		ScriptedHuman.bCanStrafe = true;
		if (ScriptedHuman.AccelRate == 0)
			ScriptedHuman.AccelRate = ScriptedHuman.default.AccelRate;
		if (ScriptedHuman.GroundSpeed == 0)
		{
			ScriptedHuman.GroundSpeed = ScriptedHuman.default.GroundSpeed;
			ScriptedHuman.JumpZ = 0;
		}
	}

	LoadLevelMover("Mover22").InitialState = 'TriggerOpenTimed';
	LoadLevelMover("Mover26").InitialState = 'TriggerOpenTimed';
	LoadLevelTrigger("Trigger21").ReTriggerDelay = 0;
	class'SBTriggerStoppedMover'.static.CreateFor(Level, "Mover23");

	Disp = LoadLevelDispatcher("Dispatcher10");
	Disp.OutDelays[0] = 1;
	Disp.OutEvents[1] = '';
	MakeDamageEventFor("SpecialEvent78");

	LoadLevelActor("ScarredOne0").bNet = false;
	ScriptedPawn = ScriptedPawn(LoadLevelActor("ScarredOne1"));
	ScriptedPawn.AttitudeToPlayer = ATTITUDE_Hate;
	ScriptedPawn.CarcassType = ScriptedPawn.default.CarcassType;
}

function Server_FixCurrentMap_Jones_08_Pirate2()
{
	local Trigger Tr;

	LoadLevelActor("TranslatorEvent1").SetLocation(LoadLevelActor("Trigger11").Location);
	LoadLevelActor("TranslatorEvent2").SetLocation(LoadLevelActor("Trigger29").Location);
	LoadLevelDispatcherPlus("DispatcherPlus2").OutEvents[6] = '';
	LoadLevelDispatcher("Dispatcher3").OutEvents[2] = '';

	Tr = LoadLevelTrigger("Trigger0");
	Tr.bTriggerOnceOnly = true;
	Spawn(class'Dispatcher',, 'Disp_cantTouchThis').OutEvents[0] = Tr.Event;
	Tr.Event = 'Disp_cantTouchThis';
}

function Server_FixCurrentMap_Jones_08_Pirate3()
{
	local Mover LiftLever, Lift;
	local SpecialEvent aSpecialEvent;
	local Dispatcher Disp;
	local float LiftFlapsPreTime, LiftFlapsPostTime;
	local Trigger Tr;

	DisableNonSPPlayerStarts();

	Lift = LoadLevelMover("Mover13");
	AssignInitialState(Lift, 'TriggerOpenTimed');
	LiftLever = LoadLevelMover("Mover12");
	LiftLever.StayOpenTime = Lift.DelayTime + Lift.StayOpenTime + 2 * Lift.MoveTime;
	AssignInitialState(LiftLever, 'TriggerOpenTimed');
	DisableTrigger("Trigger3");
	DisableTrigger("Trigger4");
	LiftFlapsPreTime = 10;
	LiftFlapsPostTime = 2;
	Disp = Spawn(class'Dispatcher',, Lift.Tag);
	Disp.OutEvents[0] = 'RoofTopLiftFlaps';
	Disp.OutDelays[0] = Lift.DelayTime + Lift.MoveTime - LiftFlapsPreTime;
	LoadLevelMover("Mover15").StayOpenTime = LiftFlapsPreTime + Lift.StayOpenTime + LiftFlapsPostTime;
	LoadLevelMover("Mover16").StayOpenTime = LiftFlapsPreTime + Lift.StayOpenTime + LiftFlapsPostTime;
	foreach AllActors(class'SpecialEvent', aSpecialEvent, LiftLever.Tag)
		aSpecialEvent.Tag = Lift.Tag;

	Tr = Spawn(class'Trigger',,, vect(0, 3808, 768));
	Tr.Event = 'falling_down';
	Tr.SetCollisionSize(1024 * Sqrt(2), 40);
	Tr.TriggerType = TT_ClassProximity;
	Tr.ClassProximityType = class'Pawn';
	aSpecialEvent = Spawn(class'SpecialEvent',, 'falling_down');
	AssignInitialState(aSpecialEvent, 'KillInstigator');

	DisableTeleporter("Teleporter1");
	LoadLevelActor("Teleporter0").Tag = 'EnableEndPortation';
	LoadLevelDispatcherPlus("DispatcherPlus6").OutEvents[7] = 'EnableEndPortation';
}

function Server_FixCurrentMap_Jones_09_Scar()
{
	local Trigger StartTrigger;
	local DispatcherPlus Disp;

	StartTrigger = LoadLevelTrigger("Trigger18");
	StartTrigger.bNet = true;
	StartTrigger.SetCollisionSize(555, StartTrigger.CollisionHeight);
	StartTrigger.Tag = 'ScarredOneFinaleMusic';
	AssignInitialState(StartTrigger, 'OtherTriggerTurnsOff');

	ScriptedPawn(LoadLevelActor("TheScarredOne1")).FirstHatePlayerEvent = 'ScarredOneFinaleMusic';
	Disp = LoadLevelDispatcherPlus("DispatcherPlus2");
	Disp.OutEvents[6] = '';

	Disp = LoadLevelDispatcherPlus("DispatcherPlus4");
	Disp.OutEvents[2] = '';
	Disp.OutEvents[4] = 'EndActorz';
}


function Server_ModifyCurrentMap_Jones_01_Deployment()
{
	if (!MutatorPtr.bUseSpeech)
		AdjustTriggeredTeleporter("Teleporter0", "Trigger8");
}

function Server_ModifyCurrentMap_Jones_02_Darkness()
{
	if (!MutatorPtr.bUseSpeech)
		AdjustTriggeredTeleporter("Teleporter0", "Trigger72");
}

function Server_ModifyCurrentMap_Jones_03_Rogue()
{
	local Dispatcher Disp;
	local Mover Mover;
	local ScriptedPawn ScriptedPawn;

	if (!MutatorPtr.bUseSpeech)
		AdjustTriggeredTeleporter("Teleporter0", "Trigger38");

	if (MutatorPtr.bModifyRogueScarredOne)
	{
		LoadLevelActor("Dispatcher8").bNet = true;
		LoadLevelActor("Trigger22").bNet = true;

		MakeMoverTriggerableOnceOnly("AttachMover0");
		foreach AllActors(class'Mover', Mover, 'SewageProcessorDoors')
		{
			Mover.bNet = true;
			SetMoverTriggerableOnceOnly(Mover);
		}

		ScriptedPawn = ScriptedPawn(LoadLevelActor("TheScarredOne0"));
		ScriptedPawn.bNet = true;
		ScriptedPawn.CarcassType = ScriptedPawn.default.CarcassType;

		Disp = Spawn(class'Dispatcher',, 'TheGhostOfOraghar');
		Disp.OutEvents[0] = 'ScarredOneWindow';
		Disp.OutDelays[0] = 8;
	}
}

function Server_ModifyCurrentMap_Jones_05_TemplePart2()
{
	if (!MutatorPtr.bUseSpeech)
		AdjustTriggeredTeleporter("Teleporter0",, 128);
}

function Server_ModifyCurrentMap_Jones_06_Vandora()
{
	local Actor Telep;

	if (!MutatorPtr.bUseSpeech)
	{
		Telep = LoadLevelActor("Teleporter0");
		Telep.Tag = 'SpinnerLairPadlock';
		Telep.SetCollisionSize(125, Telep.CollisionHeight);
	}
}

function Server_ModifyCurrentMap_Jones_08_Pirate()
{
	if (!MutatorPtr.bUseSpeech)
		AdjustTriggeredTeleporter("Teleporter0",, 128);
}

function Server_ModifyCurrentMap_Jones_08_Pirate2()
{
	if (!MutatorPtr.bUseSpeech)
		AdjustTriggeredTeleporter("Teleporter0");
}


function DeleteRemovableMovers()
{
	local Mover m;
	foreach AllActors(class'Mover', m)
		if (!m.bStatic && !m.bNoDelete)
			m.Destroy();
}

function DisableConsoleCommandTriggers()
{
	local ConsoleCommandTrigger tr;
	foreach AllActors(class'ConsoleCommandTrigger', tr)
	{
		tr.Tag = '';
		tr.Command = "";
	}
}

function Dispatcher LoadLevelDispatcher(string DispatcherName)
{
	return Dispatcher(LoadLevelActor(DispatcherName));
}

function DispatcherPlus LoadLevelDispatcherPlus(string DispatcherName)
{
	return DispatcherPlus(LoadLevelActor(DispatcherName));
}

function ZoneInfo LoadLevelZone(string ZoneName)
{
	return ZoneInfo(DynamicLoadObject(outer.name $ "." $ ZoneName, class'ZoneInfo'));
}

function Trigger LoadLevelTrigger(string TriggerName)
{
	return Trigger(DynamicLoadObject(outer.name $ "." $ TriggerName, class'Trigger'));
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

function DisableNonSPPlayerStarts()
{
	local PlayerStart ps;
	foreach AllActors(class'PlayerStart', ps)
		if (ps.class == class'PlayerStart' && !ps.bSinglePlayerStart)
			ps.bCoopStart = false;
}

function DisablePlayerStart(string PlayerStartName)
{
	local PlayerStart ps;
	ps = PlayerStart(DynamicLoadObject(outer.name $ "." $ PlayerStartName, class'PlayerStart'));
	ps.bSinglePlayerStart = False;
	ps.bCoopStart = False;
}

function DisableTeleporter(string TeleporterName)
{
	local Teleporter telep;

	telep = Teleporter(DynamicLoadObject(outer.name $ "." $ TeleporterName, class'Teleporter'));
	telep.SetCollision(false);
	telep.DrawType = DT_None;
	telep.URL = "";
}

function AdjustTriggeredTeleporter(string TeleporterName, optional string TriggerName, optional float NewCollisionRadius)
{
	local Teleporter Telep;
	local Trigger Tr;
	local vector HorizontalOffset;
	local float VerticalOffset;

	Telep = Teleporter(LoadLevelActor(TeleporterName));
	Telep.bEnabled = true;
	Telep.Tag = '';

	if (TriggerName != "")
	{
		Tr = LoadLevelTrigger(TriggerName);
		HorizontalOffset = Tr.Location - Telep.Location;
		VerticalOffset = HorizontalOffset.Z;
		HorizontalOffset.Z = 0;
		if (NewCollisionRadius == 0)
			NewCollisionRadius = Tr.CollisionRadius + VSize(HorizontalOffset);
		Telep.SetCollisionSize(NewCollisionRadius, Tr.CollisionHeight + Abs(VerticalOffset));
	}
	else if (NewCollisionRadius != 0)
		Telep.SetCollisionSize(NewCollisionRadius, Telep.CollisionHeight);
}

function Trigger MakeConditionTrigger(name ConditionTag, name InitialStateName, bool InitialCondition)
{
	local Trigger result;

	result = Spawn(class'Trigger',, ConditionTag);
	AssignInitialState(result, InitialStateName);
	result.bInitiallyActive = InitialCondition;

	return result;
}

function MakeDamageEventFor(string SpecialEventName)
{
	class'SBDamageEvent'.static.WrapSpecialEvent(SpecialEvent(LoadLevelActor(SpecialEventName)));
}
