class XidiaMapFixServer expands XidiaMapFixBase;

var XidiaCoopMutator MutatorPtr;

function Init(string CurrentMap)
{
	super.Init(CurrentMap);

	MutatorPtr = XidiaCoopMutator(Owner);
	Server_FixCurrentMap();
}

function Server_FixCurrentMap()
{
	DisableConsoleCommandTriggers();

	if (CurrentMap ~= "XidiaGold-Map2-Landing")
		Server_FixCurrentMap_XidiaGold_Map2_Landing();
	else if (CurrentMap ~= "XidiaGold-Map3-OutpostPheonix")
		Server_FixCurrentMap_XidiaGold_Map3_OutpostPheonix();
	else if (CurrentMap ~= "XidiaGold-Map4-Mine")
		Server_FixCurrentMap_XidiaGold_Map4_Mine();
	else if (CurrentMap ~= "XidiaGold-Map6-Derelict-b")
		Server_FixCurrentMap_XidiaGold_Map6_Derelict_b();
	else if (CurrentMap ~= "XidiaGold-Map7-Darklord")
		Server_FixCurrentMap_XidiaGold_Map7_Darklord();
	else if (CurrentMap ~= "XidiaES-Map1-SelfDestruct")
		Server_FixCurrentMap_XidiaES_Map1_SelfDestruct();
	else if (CurrentMap ~= "XidiaES-Map2-Rail")
		Server_FixCurrentMap_XidiaES_Map2_Rail();
	else if (CurrentMap ~= "XidiaES-Map3-ReOP")
		Server_FixCurrentMap_XidiaES_Map3_ReOP();
	else if (CurrentMap ~= "XidiaES-Map4-DeadMines")
		Server_FixCurrentMap_XidiaES_Map4_DeadMines();
	else if (CurrentMap ~= "XidiaES-Map6-BlackWidow")
		Server_FixCurrentMap_XidiaES_Map6_BlackWidow();
}

function Server_FixCurrentMap_XidiaGold_Map2_Landing()
{
	local Dispatcher Disp;

	Disp = Dispatcher(LoadLevelActor("Dispatcher1"));
	Disp.OutDelays[1] = 0;
	Disp.OutDelays[2] = 0;
}

function Server_FixCurrentMap_XidiaGold_Map3_OutpostPheonix()
{
	local SpecialEvent SpecialEvent;
	local SkaarjSniper Sniper;
	local Trigger Trigger;
	local VisibleTeleporter VisibleTeleporter;

	Trigger = LoadLevelTrigger("Trigger59");
	Trigger.bInitiallyActive = false;
	Trigger.InitialState = 'OtherTriggerTurnsOn';
	Trigger.Tag = 'ShockerRifle';

	Trigger = LoadLevelTrigger("Trigger60");
	Trigger.bInitiallyActive = false;
	Trigger.InitialState = 'OtherTriggerTurnsOn';
	Trigger.Tag = 'ShockerRifle';

	foreach AllActors(class'SpecialEvent', SpecialEvent, 'ShotInTheHead')
		SpecialEvent.Tag = '';

	foreach AllActors(class'SkaarjSniper', Sniper)
		if (Sniper.IsA('SkaarjSniperElite'))
		{
			Sniper.bCanStrafe = true;
			if (Sniper.Event != '')
			{
				foreach AllActors(class'Trigger', Trigger, Sniper.Event)
					if (Trigger.Event == 'ShotInTheHead')
					{
						Sniper.Tag = Sniper.Event;
						Sniper.Event = '';
						break;
					}
			}
		}

	foreach AllActors(class'VisibleTeleporter', VisibleTeleporter)
		if (!VisibleTeleporter.bSinglePlayer)
		{
			VisibleTeleporter.SetCollision(false);
			VisibleTeleporter.bHidden = true;
		}
	class'XidiaSafeFall'.static.CreateAtActor(Level, "SpecialEvent171", 512, 128);
	class'XidiaSafeFall'.static.CreateAtActor(Level, "VisibleTeleporter1", 512, 128);
}

function Server_FixCurrentMap_XidiaGold_Map4_Mine()
{
	SpecialEvent(LoadLevelActor("SpecialEvent30")).bBroadcast = true;
	SpecialEvent(LoadLevelActor("SpecialEvent33")).bBroadcast = true;
}

function Server_FixCurrentMap_XidiaGold_Map6_Derelict_b()
{
	class'XidiaTriggerStoppedMover'.static.CreateFor(Level, "Mover36");
}

function Server_FixCurrentMap_XidiaGold_Map7_Darklord()
{
	local Mover Mover;
	local Trigger Trigger;

	class'XidiaTriggerStoppedMover'.static.CreateFor(Level, "Mover13");

	Mover = LoadLevelMover("Mover17");
	Mover.InitialState = 'TriggerOpenTimed';
	Mover.Tag = 'ToTheEnd2';

	LoadLevelMover("Mover31").MoveTime = 10;
	if (class'XidiaTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover31", 'Trigger_EyeOfTheBeholder', 'EyeOfTheBeholder') != none)
	{
		Trigger = LoadLevelTrigger("Trigger27");
		Trigger.Event = 'Trigger_EyeOfTheBeholder';
		Trigger.ReTriggerDelay = 0;
	}
}

function Server_FixCurrentMap_XidiaES_Map1_SelfDestruct()
{
	local Trigger Trigger;

	if (class'XidiaTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover31", 'Trigger_EyeOfTheBeholder', 'EyeOfTheBeholder') != none)
	{
		foreach AllActors(class'Trigger', Trigger)
			if (Trigger.Event == 'EyeOfTheBeholder')
			{
				Trigger.Event = 'Trigger_EyeOfTheBeholder';
				Trigger.ReTriggerDelay = 0;
			}
	}
}

function Server_FixCurrentMap_XidiaES_Map2_Rail()
{
	DisableTrigger("Trigger51");
	EventToEvent('TeleToNextMap', 'EnableTeleToNextMap', true);
	LoadLevelActor("Teleporter0").Tag = 'EnableTeleToNextMap';
}

function Server_FixCurrentMap_XidiaES_Map3_ReOP()
{
	local Mover Mover;

	Mover = LoadLevelMover("Mover44");
	Mover.bTriggerOnceOnly = true;
	Mover.InitialState = 'TriggerOpenTimed';

	LoadLevelMover("Mover74").MoveTime = 10;
	LoadLevelTrigger("Trigger20").bTriggerOnceOnly = false;
}

function Server_FixCurrentMap_XidiaES_Map4_DeadMines()
{
	local Trigger Trigger;

	if (class'XidiaTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover18", 'Trigger_Tram001', 'Tram001') != none)
	{
		foreach AllActors(class'Trigger', Trigger)
			if (Trigger.Event == 'Tram001')
				Trigger.Event = 'Trigger_Tram001';
	}

	LoadLevelTrigger("Trigger43").bTriggerOnceOnly = false;
	LoadLevelTrigger("Trigger46").bInitiallyActive = true;
	class'XidiaSafeFall'.static.CreateAtActor(Level, "Mover44", 512, 512);
}

function Server_FixCurrentMap_XidiaES_Map6_BlackWidow()
{
	if (MutatorPtr.bUseXidiaJumpBoots)
		MutatorPtr.bGiveXidiaJumpBoots = true;
}


function EventToEvent(name OriginalEventName, name NewEventName, optional bool bTriggerOnceOnly)
{
	local XidiaEventToEvent XidiaEventToEvent;

	XidiaEventToEvent = Spawn(class'XidiaEventToEvent',, OriginalEventName);
	XidiaEventToEvent.Event = NewEventName;
	XidiaEventToEvent.bTriggerOnceOnly = bTriggerOnceOnly;
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
