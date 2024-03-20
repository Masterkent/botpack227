class ONPMapFix expands Info;

#exec obj load file="Botpack.u"

var bool bModified;
var ONPSPFix MutatorPtr;
var string CurrentMap;

function PostBeginPlay()
{
	MutatorPtr = ONPSPFix(Owner);
	if (bModified || MutatorPtr == none)
		return;
	bModified = true;

	Server_FixCurrentMap();
	Client_FixCurrentMap();
}

function Server_FixCurrentMap()
{
	CurrentMap = string(Outer.Name);

	if (Left(CurrentMap, 2) ~= "NP") // Operation Na Pali
		Server_FixCurrentMap_ONP();
	else if (Left(CurrentMap, 7) ~= "ONP-map") // Xenome
		Server_FixCurrentMap_Xenome();
}

function Server_FixCurrentMap_ONP()
{
	if (CurrentMap ~= "NP02DavidM")
		Server_FixCurrentMap_NP02DavidM();
	else if (CurrentMap ~= "NP04Hyperion")
		Server_FixCurrentMap_NP04Hyperion();
	else if (CurrentMap ~= "NP05Heiko")
		Server_FixCurrentMap_NP05Heiko();
	else if (CurrentMap ~= "NP06Heiko")
		Server_FixCurrentMap_NP06Heiko();
	else if (CurrentMap ~= "NP08Hourences")
		Server_FixCurrentMap_NP08Hourences();
	else if (CurrentMap ~= "NP09Silver")
		Server_FixCurrentMap_NP09Silver();
	else if (CurrentMap ~= "NP11Tonnberry")
		Server_FixCurrentMap_NP11Tonnberry();
	else if (CurrentMap ~= "NP13DrPest")
		Server_FixCurrentMap_NP13DrPest();
	else if (CurrentMap ~= "NP14MClaneDrPest")
		Server_FixCurrentMap_NP14MClaneDrPest();
	else if (CurrentMap ~= "NP15Chico")
		Server_FixCurrentMap_NP15Chico();
	else if (CurrentMap ~= "NP16Chico")
		Server_FixCurrentMap_NP16Chico();
	else if (CurrentMap ~= "NP19Part2Chico")
		Server_FixCurrentMap_NP19Part2Chico();
	else if (CurrentMap ~= "NP19Part3ChicoHour")
		Server_FixCurrentMap_NP19Part3ChicoHour();
	else if (CurrentMap ~= "NP22DavidM")
		Server_FixCurrentMap_NP22DavidM();
	else if (CurrentMap ~= "NP23Kew")
		Server_FixCurrentMap_NP23Kew();
	else if (CurrentMap ~= "NP27DavidM")
		Server_FixCurrentMap_NP27DavidM();
	else if (CurrentMap ~= "NP29DavidM")
		Server_FixCurrentMap_NP29DavidM();
	else if (CurrentMap ~= "NP31DavidM")
		Server_FixCurrentMap_NP31DavidM();
	else if (CurrentMap ~= "NP32Strogg")
		Server_FixCurrentMap_NP32Strogg();
}

function Server_FixCurrentMap_Xenome()
{
	// X series
	if (CurrentMap ~= "ONP-map01FirstDayX")
		Server_FixCurrentMap_ONP_map01FirstDayX();
	else if (CurrentMap ~= "ONP-map02LinesofCommX")
		Server_FixCurrentMap_ONP_map02LinesofCommX();
	else if (CurrentMap ~= "ONP-map03oppressivemetalX")
		Server_FixCurrentMap_ONP_map03oppressivemetalX();
	else if (CurrentMap ~= "ONP-map06ProcessingX")
		Server_FixCurrentMap_ONP_map06ProcessingX();
	else if (CurrentMap ~= "ONP-map07PlanningX")
		Server_FixCurrentMap_ONP_map07PlanningX();
	else if (CurrentMap ~= "ONP-map08DisposalX")
		Server_FixCurrentMap_ONP_map08DisposalX();
	else if (CurrentMap ~= "ONP-map09SurfaceX")
		Server_FixCurrentMap_ONP_map09SurfaceX();
	else if (CurrentMap ~= "ONP-map10AmbushX")
		Server_FixCurrentMap_ONP_map10AmbushX();
	else if (CurrentMap ~= "ONP-map11CobaltX")
		Server_FixCurrentMap_ONP_map11CobaltX();
	else if (CurrentMap ~= "ONP-map12DamX")
		Server_FixCurrentMap_ONP_map12DamX();
	else if (CurrentMap ~= "ONP-map13SignsX")
		Server_FixCurrentMap_ONP_map13SignsX();
	else if (CurrentMap ~= "ONP-map14SoothsayerX")
		Server_FixCurrentMap_ONP_map14SoothsayerX();
	else if (CurrentMap ~= "ONP-map15RevelationX")
		Server_FixCurrentMap_ONP_map15RevelationX();
	else if (CurrentMap ~= "ONP-map16BoldX")
		Server_FixCurrentMap_ONP_map16BoldX();
	else if (CurrentMap ~= "ONP-map18FriendX")
		Server_FixCurrentMap_ONP_map18FriendX();
	else if (CurrentMap ~= "ONP-map19IceX")
		Server_FixCurrentMap_ONP_map19IceX();
	else if (CurrentMap ~= "ONP-map20InterloperX")
		Server_FixCurrentMap_ONP_map20InterloperX();
	else if (CurrentMap ~= "ONP-map21NestX")
		Server_FixCurrentMap_ONP_map21NestX();
	else if (CurrentMap ~= "ONP-map22TransferX")
		Server_FixCurrentMap_ONP_map22TransferX();
	else if (CurrentMap ~= "ONP-map23PowerPlayX")
		Server_FixCurrentMap_ONP_map23PowerPlayX();
	else if (CurrentMap ~= "ONP-map24CoreX")
		Server_FixCurrentMap_ONP_map24CoreX();

	// non-X series
	else if (CurrentMap ~= "ONP-map01FirstDay")
		Server_FixCurrentMap_ONP_map01FirstDay();
	else if (CurrentMap ~= "ONP-map02Detour")
		Server_FixCurrentMap_ONP_map02Detour();
	else if (CurrentMap ~= "ONP-map03Watchyourstep")
		Server_FixCurrentMap_ONP_map03Watchyourstep();
	else if (CurrentMap ~= "ONP-map04LabEntrance")
		Server_FixCurrentMap_ONP_map04LabEntrance();
	else if (CurrentMap ~= "ONP-map05FriendlyFire")
		Server_FixCurrentMap_ONP_map05FriendlyFire();
	else if (CurrentMap ~= "ONP-map06PowerPlay")
		Server_FixCurrentMap_ONP_map06PowerPlay();
	else if (CurrentMap ~= "ONP-map07Questionableethics")
		Server_FixCurrentMap_ONP_map07Questionableethics();
	else if (CurrentMap ~= "ONP-map09ComplexSituation")
		Server_FixCurrentMap_ONP_map09ComplexSituation();
	else if (CurrentMap ~= "ONP-map13Processing")
		Server_FixCurrentMap_ONP_map13Processing();
	else if (CurrentMap ~= "ONP-map14Mine")
		Server_FixCurrentMap_ONP_map14Mine();
	else if (CurrentMap ~= "ONP-map15CrossCountry")
		Server_FixCurrentMap_ONP_map15CrossCountry();
	else if (CurrentMap ~= "ONP-map16Dam")
		Server_FixCurrentMap_ONP_map16Dam();
	else if (CurrentMap ~= "ONP-map19Teleporter")
		Server_FixCurrentMap_ONP_map19Teleporter();
	else if (CurrentMap ~= "ONP-map21Welcome")
		Server_FixCurrentMap_ONP_map21Welcome();
	else if (CurrentMap ~= "ONP-map22Disposal")
		Server_FixCurrentMap_ONP_map22Disposal();
	else if (CurrentMap ~= "ONP-map23Newfoe")
		Server_FixCurrentMap_ONP_map23Newfoe();
	else if (CurrentMap ~= "ONP-map24Agenda")
		Server_FixCurrentMap_ONP_map24Agenda();
	else if (CurrentMap ~= "ONP-map25Communications")
		Server_FixCurrentMap_ONP_map25Communications();
	else if (CurrentMap ~= "ONP-map26EBE")
		Server_FixCurrentMap_ONP_map26EBE();
	else if (CurrentMap ~= "ONP-map27Entrance")
		Server_FixCurrentMap_ONP_map27Entrance();
	else if (CurrentMap ~= "ONP-map28Bellyofthebeast")
		Server_FixCurrentMap_ONP_map28Bellyofthebeast();
	else if (CurrentMap ~= "ONP-map30Ruins")
		Server_FixCurrentMap_ONP_map30Ruins();
	else if (CurrentMap ~= "ONP-map31Dogsofwar")
		Server_FixCurrentMap_ONP_map31Dogsofwar();
	else if (CurrentMap ~= "ONP-map32Gauntlet")
		Server_FixCurrentMap_ONP_map32Gauntlet();
	else if (CurrentMap ~= "ONP-map35Genetics")
		Server_FixCurrentMap_ONP_map35Genetics();
	else if (CurrentMap ~= "ONP-map36Birthing")
		Server_FixCurrentMap_ONP_map36Birthing();
	else if (CurrentMap ~= "ONP-map37Halted")
		Server_FixCurrentMap_ONP_map37Halted();
	else if (CurrentMap ~= "ONP-map38Tothecore")
		Server_FixCurrentMap_ONP_map38Tothecore();
	else if (CurrentMap ~= "ONP-map39Escape")
		Server_FixCurrentMap_ONP_map39Escape();
	else if (CurrentMap ~= "ONP-map40Boss")
		Server_FixCurrentMap_ONP_map40Boss();
}

simulated function Client_FixCurrentMap()
{
	FixLightEffects();

	CurrentMap = string(Outer.Name);

	if (CurrentMap ~= "NP13DrPest")
		Client_FixCurrentMap_NP13DrPest();
	else if (CurrentMap ~= "ONP-map22TransferX")
		Client_FixCurrentMap_ONP_map22TransferX();
}

simulated function FixLightEffects()
{
	local Light L;
	local bool bModifiedLighting;

	foreach AllActors(class'Light', L)
		if ((L.bStatic || L.bNoDelete) && int(L.LightEffect) == 19)
		{
			L.LightEffect = LE_None;
			bModifiedLighting = true;
		}
	if (bModifiedLighting)
		Level.GetLocalPlayerPawn().ConsoleCommand("Flush");
}

function Server_FixCurrentMap_NP02DavidM()
{
	local ScriptedPawn ScriptedPawn;
	local Pawn P;
	local Trigger Trigger;
	local ONPPlayerMoveTrigger MoveTrigger;

	ScriptedPawn = ScriptedPawn(LoadLevelActor("SkaarjScout0"));
	ScriptedPawn.AttitudeToPlayer = ATTITUDE_Ignore;
	ScriptedPawn.bHateWhenTriggered = true;

	P = LoadLevelPawn("Mercenary4");
	if (P != none)
		P.Event = 'mercisnowdead';

	Trigger = LoadLevelTrigger("Trigger3");
	MoveTrigger = class'ONPPlayerMoveTrigger'.static.StaticReplaceTrigger(Trigger);
	MoveTrigger.bNoReenter = true;

	LoadLevelMover("Mover48").MoverEncroachType = ME_IgnoreWhenEncroach;
}

function Server_FixCurrentMap_NP04Hyperion()
{
	InterpolateSpecialEvent("SpecialEvent10");
}

function Server_FixCurrentMap_NP05Heiko()
{
	LoadLevelTrigger("Trigger29").TriggerType = TT_PlayerProximity;

	// Eliminate flying tree (invisible in UT, visible in Unreal 227)
	EliminateStaticActor("Tree3");
}

function Server_FixCurrentMap_NP06Heiko()
{
	LoadLevelTrigger("Trigger33").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger35").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger61").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger62").bTriggerOnceOnly = true;
}

function Server_FixCurrentMap_NP08Hourences()
{
	local Effects e;
	local ONPParticleFireSpawner NewFireSpawner;

	foreach AllActors(class'Effects', e)
		if (e.IsA('ParticleFireSpawner'))
		{
			NewFireSpawner = e.Spawn(class'ONPParticleFireSpawner', e.Owner, e.Tag);
			if (NewFireSpawner != none)
				NewFireSpawner.ReplaceOriginalSpawner(e);
		}
}

function Server_FixCurrentMap_NP09Silver()
{
	LoadLevelDispatcher("Dispatcher9").OutEvents[1] = '';
	EliminateStaticActor("BlockAll10");
}

function Server_FixCurrentMap_NP11Tonnberry()
{
	local Mover m;

	m = LoadLevelMover("Mover6");
	m.PlayerBumpEvent = m.Tag;
}

function Server_FixCurrentMap_NP13DrPest()
{
	local Pawn P;

	LoadLevelTrigger("Trigger4").TriggerType = TT_PlayerProximity;

	P = LoadLevelPawn("SkaarjTrooper0");
	if (P != none)
	{
		P.Health = P.default.Health;
		Spawn(class'ONPPhantomPawnAdjustment').ControlledPawn = P;
	}
}

simulated function Client_FixCurrentMap_NP13DrPest()
{
	local Texture Texture;

	Texture = Texture(DynamicLoadObject(Outer.Name $ "." $ "geilekabelkurz", class'Texture', true));
	if (Texture != none)
		Texture.bTransparent = true;
	Texture = Texture(DynamicLoadObject(Outer.Name $ "." $ "geilekabellang", class'Texture', true));
	if (Texture != none)
		Texture.bTransparent = true;
}

function Server_FixCurrentMap_NP14MClaneDrPest()
{
	local Pawn P;

	LoadLevelActor("PlayerStart0").Tag = 'sp1';

	P = Pawn(LoadLevelActor("NaliTrooper1", true));
	if (P != none)
		Spawn(class'ONPPhantomPawnAdjustment').ControlledPawn = P;
}

function Server_FixCurrentMap_NP15Chico()
{
	LoadLevelTrigger("Trigger112").bTriggerOnceOnly = true;
}

function Server_FixCurrentMap_NP16Chico()
{
	ZoneInfo(LoadLevelActor("ZoneInfo0")).ZoneVelocity = vect(0, 0, 0);
}

function Server_FixCurrentMap_NP19Part2Chico()
{
	local ZoneInfo zone;
	local PressureZone pr_zone;
	local AlarmPoint AlarmPoint;
	local Trigger Trigger;

	zone = ZoneInfo(LoadLevelActor("ZoneInfo8"));
	zone.ZoneVelocity = vect(0, 0, 0);
	zone.ZoneGravity = vect(0, 0, 0);

	pr_zone = PressureZone(LoadLevelActor("PressureZone0"));
	pr_zone.DieDrawScale = 1;

	LoadLevelTrigger("Trigger20").Event = '';
	Spawn(class'ONPLevelStartTrigger').Event = 'lasersunder1';

	AlarmPoint(LoadLevelActor("AlarmPoint10")).NextAlarm = 'PathToAlarmPoint11';

	AlarmPoint = AlarmPoint(LoadLevelActor("AlarmPoint13"));
	AlarmPoint = Spawn(class'ONPSpawnableAlarmPoint',, 'PathToAlarmPoint11', AlarmPoint.Location + vect(200, 0, 0));
	AlarmPoint.bNoFail = true;
	AlarmPoint.NextAlarmObject = LoadLevelActor("AlarmPoint11");
	AlarmPoint.NextAlarm = AlarmPoint.NextAlarmObject.Tag;

	foreach AllActors(class'Trigger', Trigger)
		if (Trigger.Event == 'itburnS')
		{
			if (Trigger.Name == 'Trigger35' ||
				Trigger.Name == 'Trigger75' ||
				Trigger.Name == 'Trigger76' ||
				Trigger.Name == 'Trigger77')
			{
				Trigger.InitialState = 'OtherTriggerToggles';
				Trigger.Tag = 'lasersunder1';
				Trigger.TriggerType = TT_PawnProximity;
			}
			Trigger.bTriggerOnceOnly = false;
		}
}

function Server_FixCurrentMap_NP19Part3ChicoHour()
{
	LoadLevelTrigger("Trigger22").TriggerType = TT_PlayerProximity;
}

function Server_FixCurrentMap_NP22DavidM()
{
	DisableTeleporter("Teleporter1");
}

function Server_FixCurrentMap_NP23Kew()
{
	DisableTeleporter("Teleporter1");
}

function Server_FixCurrentMap_NP27DavidM()
{
	local Actor A;

	A = LoadLevelActor("TvTranslocator1", true);
	if (A != none)
	{
		A.DrawType = A.default.DrawType;
		A.Mesh = A.default.Mesh;
	}

	LoadLevelTrigger("Trigger46").TriggerType = TT_PawnProximity;
	LoadLevelTrigger("Trigger47").TriggerType = TT_PawnProximity;
}

function Server_FixCurrentMap_NP29DavidM()
{
	// disable useless teleporter
	DisableTeleporter("Teleporter6");
}

function Server_FixCurrentMap_NP31DavidM()
{
	MakeMoverTriggerableOnceOnly("Mover6");
}

function Server_FixCurrentMap_NP32Strogg()
{
	local Effects e;
	local ONPParticleFireSpawner NewFireSpawner;

	foreach AllActors(class'Effects', e)
		if (e.IsA('ParticleFireSpawner'))
		{
			NewFireSpawner = e.Spawn(class'ONPParticleFireSpawner', e.Owner, e.Tag);
			if (NewFireSpawner != none)
				NewFireSpawner.ReplaceOriginalSpawner(e);
		}
}


function Server_FixCurrentMap_ONP_map01FirstDayX()
{
	MakeFallingMoverController("Mover6");
	MakeFallingMoverController("Mover41");
	SetEventTriggersPawnClassProximity('arhh');
	SetNamedTriggerPawnClassProximity("Trigger52");
}

function Server_FixCurrentMap_ONP_map02LinesofCommX()
{
	CreatureFactory(LoadLevelActor("CreatureFactory3")).prototype =
		CreatureFactory(LoadLevelActor("CreatureFactory2")).prototype;

	LoadLevelTrigger("Trigger13").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger54").bTriggerOnceOnly = true; // MusicEvent3
	EarthQuake(LoadLevelActor("Earthquake1")).bThrowPlayer = false;
	EarthQuake(LoadLevelActor("Earthquake2")).bThrowPlayer = false;
}

function Server_FixCurrentMap_ONP_map03oppressivemetalX()
{
	SetNamedTriggerPawnClassProximity("Trigger4");
	SetNamedTriggerPawnClassProximity("Trigger8");
	SetNamedTriggerPawnClassProximity("Trigger47");
	SetEventTriggersPawnClassProximity('felldoom');
}

function Server_FixCurrentMap_ONP_map06ProcessingX()
{
	local Trigger Trigger;

	foreach AllActors(class'Trigger', Trigger)
		if (StrStartsWith(Trigger.Event, "splash", true))
			SetTriggerPawnClassProximity(Trigger);

	LoadLevelTrigger("Trigger64").bTriggerOnceOnly = true;
	SetTriggerPawnClassProximity(LoadLevelTrigger("Trigger5"));
}

function Server_FixCurrentMap_ONP_map07PlanningX()
{
	LoadLevelTrigger("Trigger82").bTriggerOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger23");
	MakeFallingMoverController("Mover65");
	MakeFallingMoverController("Mover83");
	MakeFallingMoverController("Mover98");
}

function Server_FixCurrentMap_ONP_map08DisposalX()
{
	local Trigger Trigger;

	LoadLevelTrigger("Trigger58").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger59").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger60").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger72").bTriggerOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger31");
	SetNamedTriggerPawnClassProximity("Trigger75");

	MakeEventRepeater('gloop', 1.0);
	foreach AllActors(class'Trigger', Trigger)
		if (Trigger.Event == 'gloop')
			Trigger.RepeatTriggerTime = 0;
}

function Server_FixCurrentMap_ONP_map09SurfaceX()
{
	local TeamCannon Cannon;

	foreach AllActors(class'TeamCannon', Cannon)
		Cannon.SetPropertyText("B227_bAttackAnyDamageInstigators", "true");

	MakeFallingMoverController("Mover65");
	SetNamedTriggerPawnClassProximity("Trigger6");
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;
	if (Level.Game.Difficulty >= 3)
	{
		CreatureFactory(LoadLevelActor("CreatureFactory0")).bCovert = false;
		CreatureFactory(LoadLevelActor("CreatureFactory1")).bCovert = false;
		CreatureFactory(LoadLevelActor("CreatureFactory2")).bCovert = false;
	}
}

function Server_FixCurrentMap_ONP_map10AmbushX()
{
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;
}

function Server_FixCurrentMap_ONP_map11CobaltX()
{
	LoadLevelTrigger("Trigger8").bTriggerOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map12DamX()
{
	SetEventTriggersPawnClassProximity('choppedup');
}

function Server_FixCurrentMap_ONP_map13SignsX()
{
	LoadLevelTrigger("Trigger11").bTriggerOnceOnly = true; // MusicEvent5
	SetNamedTriggerPawnClassProximity("Trigger30");
}

function Server_FixCurrentMap_ONP_map14SoothsayerX()
{
	local Teleporter Telep;

	Telep = Teleporter(LoadLevelActor("Teleporter0"));
	Telep.bEnabled = false;
	Telep.Tag = 'TeleporterEnergyUp';

	EventToEvent('energyup', 'TeleporterEnergyUp', true);

	SetNamedTriggerPawnClassProximity("Trigger64");
}

function Server_FixCurrentMap_ONP_map15RevelationX()
{
	SetNamedTriggerPawnClassProximity("Trigger62");
}

function Server_FixCurrentMap_ONP_map16BoldX()
{
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;
	LoadLevelTrigger("Trigger105").bInitiallyActive = true;
	LoadLevelActor("SpecialEvent49").Tag = '';
	SetEventTriggersPawnClassProximity('diced');
	SetEventTriggersPawnClassProximity('wasted');
}

function Server_FixCurrentMap_ONP_map18FriendX()
{
	LoadLevelTrigger("Trigger15").bTriggerOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger11");
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;
}

function Server_FixCurrentMap_ONP_map19IceX()
{
	LoadLevelTrigger("Trigger49").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger68").bTriggerOnceOnly = true; // MusicEvent5
	LoadLevelTrigger("Trigger82").bTriggerOnceOnly = true; // MusicEvent1
	LoadLevelTrigger("Trigger87").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger88").bTriggerOnceOnly = true; // MusicEvent5
	SetNamedTriggerPawnClassProximity("Trigger73");
}

function Server_FixCurrentMap_ONP_map20InterloperX()
{
	SetEventTriggersPawnClassProximity('Death');
	SetEventTriggersPawnClassProximity('ohdearyoufell');
}

function Server_FixCurrentMap_ONP_map21NestX()
{
	LoadLevelMover("RotatingMover0").Tag = 'hiveoff_stop_rotating';
	Spawn(class'ONPEventUntrigger',, 'hiveoff').Event = 'hiveoff_stop_rotating';

	SetEventTriggersPawnClassProximity('wasted');
}

function Server_FixCurrentMap_ONP_map22TransferX()
{
	LoadLevelTrigger("Trigger29").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger51").bTriggerOnceOnly = true;
	LoadLevelMover("Mover56").MoverEncroachType = ME_IgnoreWhenEncroach;

	SetNamedTriggerPawnClassProximity("Trigger46");
	SetEventTriggersPawnClassProximity('chopped');
	SetEventTriggersPawnClassProximity('ohdearyoufell');
}

simulated function Client_FixCurrentMap_ONP_map22TransferX()
{
	LoadLevelMover("Mover26").bDynamicLightMover = false;
}

function Server_FixCurrentMap_ONP_map23PowerPlayX()
{
	SetEventTriggersPawnClassProximity('wasted');
}

function Server_FixCurrentMap_ONP_map24CoreX()
{
	LoadLevelTrigger("Trigger95").bTriggerOnceOnly = true; // MusicEvent2
	LoadLevelTrigger("Trigger96").bTriggerOnceOnly = true; // MusicEvent3
	LoadLevelTrigger("Trigger110").bTriggerOnceOnly = true;
	SetEventTriggersPawnClassProximity('Death');
	SetEventTriggersPawnClassProximity('electric');
	SetNamedTriggerPawnClassProximity("Trigger56");
	LoadLevelActor("BlockAll4").SetCollisionSize(256, 20);
}


function Server_FixCurrentMap_ONP_map01FirstDay()
{
	SetEventTriggersPawnClassProximity('arhh');
	SetNamedTriggerPawnClassProximity("Trigger52");
}

function Server_FixCurrentMap_ONP_map02Detour()
{
	DisableTeleporter("fadeoutTeleporter3");
	LoadLevelMover("Mover0").MoveTime = 1.0;
	MakeFallingMoverController("Mover1");
}

function Server_FixCurrentMap_ONP_map03Watchyourstep()
{
	MakeFallingMoverController("Mover6");
}

function Server_FixCurrentMap_ONP_map04LabEntrance()
{
	LoadLevelTrigger("Trigger44").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger51").bTriggerOnceOnly = false;
	LoadLevelTrigger("Trigger63").bTriggerOnceOnly = true; // MusicEvent3
	LoadLevelMover("Mover79").StayOpenTime = 4;
	SetEventTriggersPawnClassProximity('aarrhh');
	MakeFallingMoverController("Mover50");
	MakeFallingMoverController("Mover51");
}

function Server_FixCurrentMap_ONP_map05FriendlyFire()
{
	DisableTeleporter("fadeoutTeleporter1");
	SetNamedTriggerPawnClassProximity("Trigger1");
	MakeFallingMoverController("Mover79");
}

function Server_FixCurrentMap_ONP_map06PowerPlay()
{
	SetEventTriggersPawnClassProximity('ouch');
}

function Server_FixCurrentMap_ONP_map07Questionableethics()
{
	SetEventTriggersPawnClassProximity('aarrhh');
}

function Server_FixCurrentMap_ONP_map09ComplexSituation()
{
	SetEventTriggersPawnClassProximity('aarrhh');
	LoadLevelMusicEvent("MusicEvent2").bOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map13Processing()
{
	SetNamedTriggerPawnClassProximity("Trigger29");
}

function Server_FixCurrentMap_ONP_map14Mine()
{
	LoadLevelMover("Mover1").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger2");
	SetNamedTriggerPawnClassProximity("Trigger16");
	InterpolateSpecialEvent("SpecialEvent10");
}

function Server_FixCurrentMap_ONP_map15CrossCountry()
{
	LoadLevelTrigger("Trigger6").bTriggerOnceOnly = true; // MusicEvent0
}

function Server_FixCurrentMap_ONP_map16Dam()
{
	local ONPCameraSpot Cam;

	foreach AllActors(class'ONPCameraSpot', Cam, 'blockerdoor')
		Cam.Tag = 'blockerdoor_trigger';

	LoadLevelTrigger("Trigger10").Event = 'blockerdoor_trigger';
	EventToEvent('blockerdoor_trigger', 'blockerdoor', true);
}

function Server_FixCurrentMap_ONP_map19Teleporter()
{
	LoadLevelTrigger("Trigger32").bTriggerOnceOnly = true;
	SetEventTriggersPawnClassProximity('killkill');
	SetEventTriggersPawnClassProximity('killkill2');
	MakeFallingMoverController("Mover0");
}

function Server_FixCurrentMap_ONP_map21Welcome()
{
	LoadLevelMover("Mover0").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger23");
	MakeFallingMoverController("Mover65");
}

function Server_FixCurrentMap_ONP_map22Disposal()
{
	local Trigger Trigger;

	LoadLevelMover("Mover34").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger31");

	MakeEventRepeater('gloop', 1.0);
	foreach AllActors(class'Trigger', Trigger)
		if (Trigger.Event == 'gloop')
			Trigger.RepeatTriggerTime = 0;
}

function Server_FixCurrentMap_ONP_map23Newfoe()
{
	LoadLevelMusicEvent("MusicEvent0").bOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent2").bOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger21");
}

function Server_FixCurrentMap_ONP_map24Agenda()
{
	LoadLevelMusicEvent("MusicEvent0").bOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map25Communications()
{
	MakeFallingMoverController("Mover5");
	MakeFallingMoverController("Mover6");
	MakeFallingMoverController("Mover7");
	MakeFallingMoverController("Mover8");
	MakeFallingMoverController("Mover9");
	MakeFallingMoverController("Mover93");
}

function Server_FixCurrentMap_ONP_map26EBE()
{
	local Mover Mover;
	local int CollisionFlags;

	MakeDecorationUnmovable("SteelBox7");

	Mover = LoadLevelMover("Mover12");
	Mover.BasePos.X = -12448;
	Mover.BaseRot.Yaw = 49152;
	Mover.KeyPos[1].X = 0;
	Mover.KeyRot[1].Yaw = 0;
	CollisionFlags = GetActorCollisionFlags(Mover);
	Mover.SetCollision(false, false, false);
	Mover.SetLocation(Mover.BasePos);
	Mover.SetRotation(Mover.BaseRot);
	SetActorCollisionWithFlags(Mover, CollisionFlags);

	Mover = LoadLevelMover("Mover13");
	Mover.BasePos.X = -12448;
	Mover.BaseRot.Yaw = 49152;
	Mover.KeyPos[1].X = 0;
	Mover.KeyRot[1].Yaw = 0;
	CollisionFlags = GetActorCollisionFlags(Mover);
	Mover.SetCollision(false, false, false);
	Mover.SetLocation(Mover.BasePos);
	Mover.SetRotation(Mover.BaseRot);
	SetActorCollisionWithFlags(Mover, CollisionFlags);

	SetNamedTriggerPawnClassProximity("Trigger0");
}

function Server_FixCurrentMap_ONP_map27Entrance()
{
	SetEventTriggersPawnClassProximity('burnbaby');
}

function Server_FixCurrentMap_ONP_map28Bellyofthebeast()
{
	SetEventTriggersPawnClassProximity('zapped');
	SetNamedTriggerPawnClassProximity("Trigger5");
	SetNamedTriggerPawnClassProximity("Trigger40");
}

function Server_FixCurrentMap_ONP_map30Ruins()
{
	local ONPSurfaceDamageTrigger DamageTrigger;

	LoadLevelActor("SpecialEvent2").Tag = '';
	DamageTrigger = Spawn(class'ONPSurfaceDamageTrigger',, 'lavakill');
	DamageTrigger.TextureName = 'Lava1';
	DamageTrigger.DamagePerSec = 50;
	DamageTrigger.DamageType = 'Burned';

	LoadLevelTrigger("Trigger19").bTriggerOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map31Dogsofwar()
{
	LoadLevelTrigger("Trigger2").bTriggerOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent1").bOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent3").bOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map32Gauntlet()
{
	MakeFallingMoverController("Mover0");
}

function Server_FixCurrentMap_ONP_map35Genetics()
{
	SetEventTriggersPawnClassProximity('fallwaste');
	MakeFallingMoverController("Mover0");
}

function Server_FixCurrentMap_ONP_map36Birthing()
{
	LoadLevelMusicEvent("MusicEvent2").bOnceOnly = true;
	SetEventTriggersPawnClassProximity('Death');
	SetNamedTriggerPawnClassProximity("Trigger11");
}

function Server_FixCurrentMap_ONP_map37Halted()
{
	SetNamedTriggerPawnClassProximity("Trigger14");
}

function Server_FixCurrentMap_ONP_map38Tothecore()
{
	local class<Actor> ONPLaserDisablerClass;
	local Actor LaserDisabler;

	ONPLaserDisablerClass = class<Actor>(DynamicLoadObject(Class.Outer.Name $ "." $ "ONPLaserDisabler", class'Class'));
	LaserDisabler = Spawn(ONPLaserDisablerClass,,, vect(5056, -6848, -2606));
	LaserDisabler.SetCollisionSize(96, 40);
	LaserDisabler.SetPropertyText("Delay", "15");

	SetEventTriggersPawnClassProximity('turfed');
	SetNamedTriggerPawnClassProximity("Trigger5");
}

function Server_FixCurrentMap_ONP_map39Escape()
{
	local EarthQuake EQ;

	foreach AllActors(class'EarthQuake', EQ)
		EQ.bThrowPlayer = false;

	LoadLevelMover("Mover50").MoveTime = 1.0; // Pipe
	LoadLevelDispatcher("Dispatcher0").OutDelays[1] = 1.0; // Pipe landing

	MakeFallingMoverController("Mover14");
	MakeFallingMoverController("Mover15");
	MakeFallingMoverController("Mover22");
	MakeFallingMoverController("Mover25");
	MakeFallingMoverController("Mover48");
	MakeFallingMoverController("Mover87", 0, 0.5);
	MakeFallingMoverController("Mover88", 0, 0.5);
	MakeFallingMoverController("Mover89", 0, 0.5);
	MakeFallingMoverController("Mover90", 0, 0.5);
	MakeFallingMoverController("Mover91", 0, 0.5);
	MakeFallingMoverController("Mover92", 0, 0.5);
	MakeFallingMoverController("Mover93", 0, 0.5);
	MakeFallingMoverController("Mover94", 0, 0.5);
	MakeFallingMoverController("Mover95", 0, 0.5);
	MakeFallingMoverController("Mover96", 0, 0.5);
	MakeFallingMoverController("Mover97", 0, 0.5);
	MakeFallingMoverController("Mover98", 0, 0.5);
	MakeFallingMoverController("Mover99", 0, 0.5);
	MakeFallingMoverController("Mover100", 0, 0.5);
	MakeFallingMoverController("Mover101", 0, 0.5);
	MakeFallingMoverController("Mover102", 0, 0.5);
	MakeFallingMoverController("Mover103", 0, 0.5);
	MakeFallingMoverController("Mover104", 0, 0.5);
	MakeFallingMoverController("Mover109");
}

function Server_FixCurrentMap_ONP_map40Boss()
{
	SetEventTriggersPawnClassProximity('pitofdeath');
}


simulated function Actor LoadLevelActor(string ActorName, optional bool bMayFail)
{
	return Actor(DynamicLoadObject(Outer.Name $ "." $ ActorName, class'Actor', bMayFail));
}

simulated function Mover LoadLevelMover(string ActorName)
{
	return Mover(DynamicLoadObject(Outer.Name $ "." $ ActorName, class'Mover'));
}

function Trigger LoadLevelTrigger(string ActorName)
{
	return Trigger(DynamicLoadObject(Outer.Name $ "." $ ActorName, class'Trigger'));
}

function Dispatcher LoadLevelDispatcher(string ActorName)
{
	return Dispatcher(LoadLevelActor(ActorName));
}

function MusicEvent LoadLevelMusicEvent(string ActorName)
{
	return MusicEvent(LoadLevelActor(ActorName));
}

function Pawn LoadLevelPawn(string ActorName)
{
	return Pawn(LoadLevelActor(ActorName, true));
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

function SetTriggerPawnClassProximity(Trigger Trigger)
{
	Trigger.TriggerType = TT_ClassProximity;
	Trigger.ClassProximityType = class'Pawn';
}

function SetNamedTriggerPawnClassProximity(string TriggerName)
{
	SetTriggerPawnClassProximity(LoadLevelTrigger(TriggerName));
}

function SetEventTriggersPawnClassProximity(name EventName)
{
	local Trigger Trigger;

	foreach AllActors(class'Trigger', Trigger)
		if (Trigger.Event == EventName)
			SetTriggerPawnClassProximity(Trigger);
}

function AssignInitialState(Actor A, name StateName)
{
	A.InitialState = StateName;
	if (!A.IsInState(A.InitialState))
		A.GotoState(A.InitialState);
}

function DisablePlayerStart(string PlayerStartName)
{
	local PlayerStart ps;
	ps = PlayerStart(DynamicLoadObject(Outer.Name $ "." $ PlayerStartName, class'PlayerStart'));
	ps.bSinglePlayerStart = False;
	ps.bCoopStart = False;
}

function DisableTeleporter(string TeleporterName)
{
	local Teleporter telep;

	telep = Teleporter(DynamicLoadObject(Outer.Name $ "." $ TeleporterName, class'Teleporter'));
	telep.SetCollision(false);
	telep.DrawType = DT_None;
	telep.URL = "";
}

function InterpolateSpecialEvent(string SpecialEventName)
{
	class'ONPInterpolateSpecialEvent'.static.WrapSpecialEvent(SpecialEvent(LoadLevelActor(SpecialEventName)));
}

function EventToEvent(name Tag, name Event, bool bTriggerOnceOnly)
{
	local ONPEventToEvent ONPEventToEvent;

	ONPEventToEvent = Spawn(class'ONPEventToEvent',, Tag);
	ONPEventToEvent.Event = Event;
	ONPEventToEvent.bTriggerOnceOnly = bTriggerOnceOnly;
}

function MakeEventRepeater(name EventName, float RepeatTriggerTime)
{
	local ONPEventRepeater EventRepeater;

	EventRepeater = Spawn(class'ONPEventRepeater',, EventName);
	if (EventRepeater != none)
	{
		EventRepeater.Event = EventName;
		EventRepeater.RepeatTriggerTime = RepeatTriggerTime;
	}
}

function MakeFallingMoverController(string MoverName, optional int KeyMovementBitmask, optional float GravityScale)
{
	local Mover M;
	local ONPFallingMoverController Controller;

	M = LoadLevelMover(MoverName);
	if (M != none)
	{
		Controller = Spawn(class'ONPFallingMoverController', M, M.Tag);
		if (Controller != none)
		{
			Controller.KeyMovementBitmask = KeyMovementBitmask;
			if (GravityScale > 0)
				Controller.GravityScale = GravityScale;
		}
		if (M.MoverEncroachType != ME_CrushWhenEncroach)
			M.MoverEncroachType = ME_IgnoreWhenEncroach;
	}
}

function MakeDecorationUnmovable(string DecorationName)
{
	local Decoration Deco;

	Deco = Decoration(LoadLevelActor(DecorationName));
	if (Deco != none)
	{
		Deco.bPushable = false;
		Deco.bMovable = false;
	}
}

simulated function EliminateStaticActor(string ActorName)
{
	local Actor A;
	A = LoadLevelActor(ActorName);
	A.SetCollision(false);
	A.bProjTarget = false;
	A.DrawType = DT_None;
}

function int GetActorCollisionFlags(Actor A)
{
	return int(A.bCollideActors) + (int(A.bBlockActors) << 1) + (int(A.bBlockActors) << 2);
}

function SetActorCollisionWithFlags(Actor A, int CollisionFlags)
{
	A.SetCollision((CollisionFlags & 1) > 0, (CollisionFlags & 2) > 0, (CollisionFlags & 4) > 0);
}

static function bool StrStartsWith(coerce string S, string SubStr, bool bCaseInsensitive)
{
	if (bCaseInsensitive)
		return Left(S, Len(SubStr)) ~= SubStr;
	return Left(S, Len(SubStr)) == SubStr;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
}
