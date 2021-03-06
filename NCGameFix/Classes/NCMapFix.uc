class NCMapFix expands Info;

var NCGameFix NCGameFix;

event BeginPlay()
{
	NCGameFix = NCGameFix(Owner);
	ServerFixCurrentMap();
}

function ServerFixCurrentMap()
{
	local string CurrentMap;

	CurrentMap = string(Outer.Name);

	if (CurrentMap ~= "NCLevel001")
		ServerFixMap_NCLevel001();
	else if (CurrentMap ~= "NCLevel002")
		ServerFixMap_NCLevel002();
	else if (CurrentMap ~= "NCLevel003")
		ServerFixMap_NCLevel003();
	else if (CurrentMap ~= "NCLevel004")
		ServerFixMap_NCLevel004();
	else if (CurrentMap ~= "NCLevel004c")
		ServerFixMap_NCLevel004c();
	else if (CurrentMap ~= "NCLevel005")
		ServerFixMap_NCLevel005();
	else if (CurrentMap ~= "NCLevel005c")
		ServerFixMap_NCLevel005c();
	else if (CurrentMap ~= "NCLevel006")
		ServerFixMap_NCLevel006();
	else if (CurrentMap ~= "NCLevel007")
		ServerFixMap_NCLevel007();
	else if (CurrentMap ~= "NCLevel008a")
		ServerFixMap_NCLevel008a();
	else if (CurrentMap ~= "NCLevel008b")
		ServerFixMap_NCLevel008b();
	else if (CurrentMap ~= "NCLevel009")
		ServerFixMap_NCLevel009();
	else if (CurrentMap ~= "NCLevel012")
		ServerFixMap_NCLevel012();
	else if (CurrentMap ~= "NCLevel012b")
		ServerFixMap_NCLevel012b();
	else if (CurrentMap ~= "NCLevel014")
		ServerFixMap_NCLevel014();
	else if (CurrentMap ~= "NCLevel015")
		ServerFixMap_NCLevel015();
	else if (CurrentMap ~= "NCLevel016")
		ServerFixMap_NCLevel016();
	else if (CurrentMap ~= "NCLevel017")
		ServerFixMap_NCLevel017();
	else if (CurrentMap ~= "NCLevel018")
		ServerFixMap_NCLevel018();
	else if (CurrentMap ~= "NCLevel019")
		ServerFixMap_NCLevel019();
	else if (CurrentMap ~= "NCLevel020")
		ServerFixMap_NCLevel020();
	else if (CurrentMap ~= "NCLevel021")
		ServerFixMap_NCLevel021();
}


function ServerFixMap_NCLevel001()
{
	local Skaarj Skaarj;
	local Trigger Trigger;

	foreach AllActors(class'Skaarj', Skaarj)
		Skaarj.Health = Skaarj.default.Health;

	MakeMoverTriggerableOnceOnly("Mover3");
	MakeMoverTriggerableOnceOnly("Mover4");

	if (Level.NetMode != NM_Standalone && NCGameFix.bCoopUnlockPaths)
	{
		Trigger = LoadLevelActor("PathNode22").Spawn(class'Trigger');
		Trigger.Event = 'OpenDoors';
		Trigger.SetCollisionSize(128, 40);
		LoadLevelTrigger("Trigger1").bInitiallyActive = true;
	}
}

function ServerFixMap_NCLevel002()
{
	local Mover FinalLift;

	FinalLift = LoadLevelMover("Mover34");
	FinalLift.InitialState = 'TriggerOpenTimed';
	FinalLift.bTriggerOnceOnly = false;
}

function ServerFixMap_NCLevel003()
{
	// Fixing the gates
	MakeMoverTriggerableOnceOnly("Mover46");
	MakeMoverTriggerableOnceOnly("Mover47");
	MakeMoverTriggerableOnceOnly("Mover48");
	MakeMoverTriggerableOnceOnly("Mover49");

	if (Level.NetMode != NM_Standalone)
	{
		if (NCGameFix.bCoopUnlockPaths)
		{
			LoadLevelTrigger("Trigger10").TriggerType = TT_PawnProximity;
			LoadLevelTrigger("Trigger11").TriggerType = TT_PawnProximity;
		}
		else
		{
			// If Nali1 dies, he can't open the gates, so we let players do this
			LoadLevelActor("Nali1").Event = 'open_gates';
			class'NCTriggerTypeModifier'.static.MakeInstance(self, "Trigger10", 'open_gates', TT_PawnProximity);
			class'NCTriggerTypeModifier'.static.MakeInstance(self, "Trigger11", 'open_gates', TT_PawnProximity);
		}

		// Prevent the tree near the exit from falling
		DisableTrigger("Trigger9");
	}
}

function ServerFixMap_NCLevel004()
{
	local Dispatcher Disp;
	local Teleporter ExitTelep;

	if (Level.NetMode != NM_Standalone)
	{
		LoadLevelTrigger("Trigger5").bInitiallyActive = true;

		Disp = Spawn(class'Dispatcher',, 'puzzledoor');
		Disp.OutEvents[0] = 'puzzledoor';
		Disp.OutDelays[0] = 120;
		Disp.OutEvents[1] = 'puzzledoor_opened';
		Disp.OutDelays[1] = 1.0e9;

		if (NCGameFix.bCoopUnlockPaths)
		{
			ExitTelep = LoadLevelTeleporter("Teleporter0");
			ExitTelep.bEnabled = true;
			ExitTelep.Tag = '';
		}
		ChangeNextMap("NCLevel004c", "NCLevel005");
	}
}

function ServerFixMap_NCLevel004c()
{
	ChangePhysWalkingToNoneFor(class'Nali');
}

function ServerFixMap_NCLevel005()
{
	local PlayerStart PlayerStart;

	if (Level.NetMode != NM_Standalone)
	{
		DisablePlayerStart("PlayerStart1");
		PlayerStart = PlayerStart(LoadLevelActor("PlayerStart1"));
		PlayerStart = PlayerStart.Spawn(class'NCSpawnablePlayerStart');
		PlayerStart.SetBase(LoadLevelActor("Mover25"));

		class'NCSafeFall'.static.CreateAtLocation(
			Level,
			LoadLevelActor("Trigger13").Location + vect(0, 0, 500),
			384,
			96);

		ChangeNextMap("NCLevel005c", "NCLevel006");
	}
}

function ServerFixMap_NCLevel005c()
{
	ChangePhysWalkingToNoneFor(class'Nali');
}

function ServerFixMap_NCLevel006()
{
	local Mover Lift;

	Lift = LoadLevelMover("Mover7");
	Lift.InitialState = 'TriggerOpenTimed';
	Lift.MoverEncroachType = ME_IgnoreWhenEncroach;
}

function ServerFixMap_NCLevel007()
{
	local Mover Boat;

	if (Level.NetMode != NM_Standalone)
	{
		Boat = LoadLevelMover("Mover8");
		Boat.bTriggerOnceOnly = false;
		Boat.StayOpenTime = Boat.default.StayOpenTime;
	}
}

function ServerFixMap_NCLevel008a()
{
	if (Level.NetMode != NM_Standalone)
	{
		MakeMoverPlayerBumpEventTriggered("Mover1");
		DisableTrigger("Trigger26");
		MakeMoverPlayerBumpEventTriggered("Mover2");
		DisableTrigger("Trigger11");
		MakeMoverPlayerBumpEventTriggered("Mover3");
		DisableTrigger("Trigger9");
		MakeMoverPlayerBumpEventTriggered("Mover4");
		DisableTrigger("Trigger7");
	}
}

function ServerFixMap_NCLevel008b()
{
	local Trigger Trigger;

	LoadLevelMover("AttachMover6").InitialState = 'TriggerOpenTimed';

	if (Level.NetMode != NM_Standalone)
	{
		MakeMoverPlayerBumpEventTriggered("ElevatorMover2");
		DisableTrigger("Trigger3");
		MakeMoverPlayerBumpEventTriggered("ElevatorMover3");
		DisableTrigger("Trigger6");
		MakeMoverPlayerBumpEventTriggered("ElevatorMover5");
		DisableTrigger("Trigger10");
		MakeMoverPlayerBumpEventTriggered("ElevatorMover7");
		DisableTrigger("Trigger35");
		DisableTrigger("Trigger37");
		DisableTrigger("Trigger38");

		Trigger = LoadLevelTrigger("Trigger74");
		Trigger.bInitiallyActive = true;
		Trigger.SetCollisionSize(140, Trigger.CollisionHeight);
	}
}

function ServerFixMap_NCLevel009()
{
	local PlayerStart PlayerStart;
	local Mover Lift;
	local Mover Mover;

	// Underwater lift
	LoadLevelTrigger("Trigger1").ReTriggerDelay = 0.5; // fix for the multiple triggering bug (227i)
	Lift = LoadLevelMover("Mover0");
	Lift.MoverEncroachType = ME_IgnoreWhenEncroach;
	Lift.SetPropertyText("bUseGoodCollision", "false");

	if (Level.NetMode != NM_Standalone)
	{
		DisablePlayerStart("PlayerStart0");
		PlayerStart = PlayerStart(LoadLevelActor("PlayerStart0"));
		PlayerStart = PlayerStart.Spawn(class'NCSpawnablePlayerStart');
		PlayerStart.SetBase(LoadLevelActor("AttachMover6"));

		Lift.InitialState = 'TriggerOpenTimed';

		foreach AllActors(class'Mover', Mover, 'trapped')
			Mover.Tag = '';
		foreach AllActors(class'Mover', Mover, 'hahayourescrewed')
			Mover.Tag = '';

		LoadLevelTeleporter("Teleporter0").SetCollisionSize(160, 128);
		LoadLevelActor("TriggerLight2").Tag = '';
	}
}

function ServerFixMap_NCLevel012()
{
	local PlayerStart PlayerStart;
	local Mover Mover;
	local vector StartLocation;

	if (Level.NetMode != NM_Standalone)
	{
		DisablePlayerStart("PlayerStart0");
		PlayerStart = PlayerStart(LoadLevelActor("PlayerStart0"));
		Mover = LoadLevelMover("AttachMover0"); // Sky lift
		Mover.KeyNum = 1;
		Mover.Tag = '';
		StartLocation = PlayerStart.Location + (Mover.KeyPos[1] - Mover.KeyPos[0]);
		PlayerStart.Spawn(class'NCSpawnablePlayerStart',,, StartLocation);
		Mover = LoadLevelMover("AttachMover2"); // Sky lift door
		Mover.KeyNum = 2;
		Mover.Tag = '';
	}
}

function ServerFixMap_NCLevel012b()
{
	local Teleporter ExitTelep, NewExitTelep;
	local Decoration Deco;

	ExitTelep = LoadLevelTeleporter("Teleporter1");
	NewExitTelep = LoadLevelActor("Light251").Spawn(class'NCSpawnableTeleporter',, ExitTelep.Tag);
	NewExitTelep.bEnabled = false;
	NewExitTelep.URL = ExitTelep.URL;
	NewExitTelep.SetCollisionSize(1024, 1024);
	ExitTelep.SetCollision(false);
	ExitTelep.URL = "";

	if (Level.NetMode != NM_Standalone)
	{
		Deco = Spawn(class'SmallSteelBox',,, vect(3820, -14464, -307)); // let players with low JumpZ get on the top
		Deco.bMovable = false;
		Deco.bPushable = false;

		MakeMoverTriggerableOnceOnly("Mover17", true);
		MakeMoverTriggerableOnceOnly("Mover19", true);

		NewExitTelep.SetCollisionSize(256, 1024);
		ChangeNextMap("NCLevel012cut", "NCLevel013");
	}
}

function ServerFixMap_NCLevel014()
{
	local Mover Mover;
	local Actor SteelBox;

	foreach AllActors(class'Mover', Mover, 'Reactor')
		Mover.MoverEncroachType = ME_IgnoreWhenEncroach;

	SteelBox = LoadLevelActor("SteelBox13");
	SteelBox.SetCollisionSize(class'SteelBox'.default.CollisionRadius * SteelBox.DrawScale, SteelBox.CollisionHeight);

	if (Level.NetMode != NM_Standalone)
	{
		SteelBox.bMovable = false;
		if (NCGameFix.bCoopUnlockPaths)
			LoadLevelTrigger("Trigger50").bInitiallyActive = true;
	}
}

function ServerFixMap_NCLevel015()
{
	local Teleporter ExitTelep;

	if (Level.NetMode != NM_Standalone)
	{
		ExitTelep = LoadLevelTeleporter("Teleporter5");
		ExitTelep.Tag = 'LowerBuildingAttack';
	}
}

function ServerFixMap_NCLevel016()
{
	local PlayerStart PlayerStart;
	local Mover Mover;
	local NCSpawnableTeleporter Telep;

	LoadLevelTrigger("Trigger105").TriggerType = TT_PlayerProximity; // NPCs shouldn't be able to trigger this

	if (Level.NetMode == NM_Standalone)
		DisablePlayerStart("PlayerStart0");
	else
	{
		PlayerStart = PlayerStart(LoadLevelActor("PlayerStart0"));
		PlayerStart.bEnabled = false;
		PlayerStart.Tag = 'minicar';

		PlayerStart = PlayerStart(LoadLevelActor("PlayerStart1"));
		PlayerStart.Tag = 'minicar';

		Dispatcher(LoadLevelActor("Dispatcher2")).OutEvents[5] = 'enable_craft_teleporter';

		Telep = LoadLevelActor("PathNode14").Spawn(class'NCSpawnableTeleporter');
		Telep.bDrawWhenEnabled = true;
		Telep.bEnabled = false;
		Telep.SetCollisionSize(60, 40);
		Telep.Style = STY_Translucent;
		Telep.Texture = WetTexture(DynamicLoadObject("SpaceFX.worm3f", class'WetTexture'));
		Telep.URL = "craft_teleporter";
		Telep.Tag = 'enable_craft_teleporter';
		AddToPackagesMap("SpaceFX");

		Telep = LoadLevelActor("PathNode122").Spawn(class'NCSpawnableTeleporter',, 'craft_teleporter',, rot(0, 16384, 0));
		Telep.bChangesYaw = true;
		Telep.B227_bChangesYawAbsolutely = true;
		Telep.SetCollision(false);

		foreach AllActors(class'Mover', Mover, 'Listen25')
			SetMoverTriggerableOnceOnly(Mover);

		LoadLevelTrigger("Trigger4").bTriggerOnceOnly = false;
		LoadLevelMover("Mover7").InitialState = 'TriggerOpenTimed';
	}
}

function ServerFixMap_NCLevel017()
{
	local Mover Mover;

	if (Level.NetMode != NM_Standalone)
	{
		foreach AllActors(class'Mover', Mover, 'cogs')
			SetMoverTriggerableOnceOnly(Mover);
		MakeMoverTriggerableOnceOnly("Mover23");
		LoadLevelTrigger("Trigger9").bInitiallyActive = true;
		LoadLevelTrigger("Trigger34").bInitiallyActive = true;
		LoadLevelTrigger("Trigger0").Tag = 'contactenabled';
		LoadLevelTrigger("Trigger35").Tag = 'contactenabled';
		LoadLevelActor("NCTalkerNali3").bNet = false;
		ChangeNextMap("NCLevel017c", "NCLevel018");
	}
}

function ServerFixMap_NCLevel018()
{
	local Teleporter ExitTelep;
	local Trigger Trigger;
	local Counter Counter;

	if (Level.NetMode != NM_Standalone && NCGameFix.bCoopUnlockPaths)
	{
		ExitTelep = LoadLevelTeleporter("Teleporter0");
		ExitTelep.Tag = 'enable_exit';
		Trigger = LoadLevelActor("WaterZone1").Spawn(class'Trigger');
		Trigger.SetCollisionSize(256, 256);
		Trigger.Event = 'Exit';
		Counter = Spawn(class'Counter',, 'Exit');
		Counter.Event = 'enable_exit';
		Counter.NumToCount = 1;

		LoadLevelTrigger("Trigger2").bInitiallyActive = true;
	}
}

function ServerFixMap_NCLevel019()
{
	local Mover Mover;
	local Trigger Trigger;
	local Counter Counter;
	local Teleporter ExitTelep;
	local Dispatcher Disp;

	Mover = LoadLevelMover("Mover5");
	Mover.SetCollision(Mover.bCollideActors, false, Mover.bBlockPlayers);

	if (Level.NetMode != NM_Standalone)
	{
		LoadLevelMover("Mover12").Tag = '';

		Disp = Dispatcher(LoadLevelActor("Dispatcher2"));
		Disp.OutDelays[0] = 1;
		Disp.OutDelays[3] = 1;
		Disp.OutEvents[3] = 'captainsafe';

		Disp = Dispatcher(LoadLevelActor("Dispatcher4"));
		Disp.OutDelays[6] = 45;

		Disp = Dispatcher(LoadLevelActor("Dispatcher6"));
		Disp.OutDelays[2] = 45;

		Disp = Dispatcher(LoadLevelActor("Dispatcher17"));
		Disp.OutDelays[2] = 1;

		if (NCGameFix.bCoopUnlockPaths)
		{
			Trigger = LoadLevelActor("AlarmPoint2").Spawn(class'Trigger');
			Trigger.bTriggerOnceOnly = true;
			Trigger.SetCollisionSize(120, 40);
			Trigger.Event = 'lettheasswhoopingbegin';
			LoadLevelActor("Counter0").Event = '';

			Trigger = LoadLevelActor("NCLogbookEntry6").Spawn(class'Trigger');
			Trigger.SetCollisionSize(80, 40);
			Trigger.Event = 'finalendportal';

			Counter = Spawn(class'Counter',, 'finalendportal');
			Counter.Event = 'enable_finalendportal';
			Counter.NumToCount = 1;

			ExitTelep = LoadLevelTeleporter("Teleporter1");
			ExitTelep.Tag = 'enable_finalendportal';
		}
	}
}

function ServerFixMap_NCLevel020()
{
	local PlayerStart PlayerStart;
	local Mover ExitElev;
	local Trigger ExitElevTriggerUpward;
	local Trigger ExitElevTriggerDownward;

	ExitElev = LoadLevelMover("Mover40");
	ExitElev.Tag = '';
	Spawn(class'NCTriggerClosedMover', ExitElev, 'exitelev');
	Spawn(class'NCTriggerOpenedMover', ExitElev, 'exitelev_upward');

	ExitElevTriggerUpward = LoadLevelTrigger("Trigger16");
	ExitElevTriggerUpward.Event = 'exitelev_upward';
	ExitElevTriggerUpward.bInitiallyActive = true;

	ExitElevTriggerDownward = ExitElevTriggerUpward.Spawn(class'Trigger',, 'exitelev');
	ExitElevTriggerDownward.SetCollisionSize(120, ExitElevTriggerUpward.CollisionHeight);
	ExitElevTriggerDownward.Event = 'exitelev';
	ExitElevTriggerDownward.bInitiallyActive = false;
	AssignInitialState(ExitElevTriggerDownward, 'OtherTriggerTurnsOn');

	if (Level.NetMode != NM_Standalone)
	{
		DisablePlayerStart("PlayerStart0");
		PlayerStart = PlayerStart(LoadLevelActor("PlayerStart0"));
		PlayerStart = PlayerStart.Spawn(class'NCSpawnablePlayerStart');
		PlayerStart.SetBase(LoadLevelActor("Mover37"));

		if (NCGameFix.bCoopUnlockPaths)
			ExitElevTriggerDownward.bInitiallyActive = true;
	}
}

function ServerFixMap_NCLevel021()
{
	local NCTracingTrigger WarLordTracer;
	local Counter Counter;
	local Dispatcher EndDispatcher;

	if (Level.NetMode != NM_Standalone)
	{
		WarLordTracer = Spawn(class'NCTracingTrigger',, 'SaucerAttack', LoadLevelActor("AmbientSound10").Location);
		WarLordTracer.Event = 'warlorddie';
		WarLordTracer.SetTracedActor(LoadLevelActor("WarLord0"));

		Counter = Spawn(class'Counter',, 'warlorddie');
		Counter.Event = 'warlord_is_eliminated';
		Counter.NumToCount = 1;

		EndDispatcher = Dispatcher(LoadLevelActor("Dispatcher3"));
		EndDispatcher.Tag = 'warlord_is_eliminated';

		LoadLevelTrigger("Trigger3").Event = '';
		ChangeNextMap("NCLevel021c", "NCLevel001");
	}
}


function MakeMoverTriggerableOnceOnly(string MoverName, optional bool bProtect)
{
	local Mover M;
	M = LoadLevelMover(MoverName);
	SetMoverTriggerableOnceOnly(m);
	if (bProtect)
		m.MoverEncroachType = ME_IgnoreWhenEncroach;
}

function SetMoverTriggerableOnceOnly(Mover M)
{
	M.bTriggerOnceOnly = True;
	AssignInitialState(M, 'TriggerOpenTimed');
}

function MakeMoverPlayerBumpEventTriggered(string MoverName)
{
	local Mover M;
	M = LoadLevelMover(MoverName);
	M.PlayerBumpEvent = M.Tag;
}

function AssignInitialState(Actor A, name StateName)
{
	A.InitialState = StateName;
	if (!A.IsInState(A.InitialState))
		A.GotoState(A.InitialState);
}

simulated function Actor LoadLevelActor(string ActorName, optional bool bMayFail)
{
	return Actor(DynamicLoadObject(outer.name $ "." $ ActorName, class'Actor', bMayFail));
}

simulated function Mover LoadLevelMover(string MoverName)
{
	return Mover(DynamicLoadObject(outer.name $ "." $ MoverName, class'Mover'));
}

function Trigger LoadLevelTrigger(string TriggerName)
{
	return Trigger(DynamicLoadObject(outer.name $ "." $ TriggerName, class'Trigger'));
}

function DisableTrigger(string TriggerName)
{
	LoadLevelTrigger(TriggerName).Event = '';
}

function Teleporter LoadLevelTeleporter(string TeleporterName)
{
	return Teleporter(LoadLevelActor(TeleporterName));
}

function ChangeNextMap(string OldMapName, string NewMapName)
{
	local Teleporter Telep;

	foreach AllActors(class'Teleporter', Telep)
		if ((InStr(Telep.URL, "#") > 0 || InStr(Telep.URL, "/") > 0) &&
			Left(Telep.URL, Len(OldMapName)) ~= OldMapName)
		{
			Telep.URL = NewMapName $ "#";
		}
}

function DisablePlayerStart(string PlayerStartName)
{
	local PlayerStart PlayerStart;

	PlayerStart = PlayerStart(DynamicLoadObject(outer.name $ "." $ PlayerStartName, class'PlayerStart'));
	PlayerStart.bSinglePlayerStart = False;
	PlayerStart.bCoopStart = False;
}

function ChangePhysWalkingToNoneFor(class<Pawn> PawnClass)
{
	local Actor P;

	foreach AllActors(PawnClass, P)
		Spawn(class'NCPhysWalkingToNone', P);
}
