class ONPMapFix expands Info;

#exec obj load file="Botpack.u"

var bool bModifiedServerSide, bModifiedClientSide;
var ONPCoopMutator MutatorPtr;
var string CurrentMap;
var bool bApplyMapFixes;

replication
{
	reliable if (Role == ROLE_Authority)
		CurrentMap;
}

function PostBeginPlay()
{
	MutatorPtr = ONPCoopMutator(Owner);
	if (bModifiedServerSide || MutatorPtr == none)
		return;
	bModifiedServerSide = true;

	DetermineCurrentMap();
	Server_ModifyCurrentMap();
	if (bApplyMapFixes)
		Server_FixCurrentMap();
}

simulated function Tick(float DeltaTime)
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (!bModifiedClientSide)
		{
			bModifiedClientSide = true;
			Client_FixCurrentMap();
		}
	}
	Disable('Tick');
}

function DetermineCurrentMap()
{
	local int i;

	CurrentMap = string(outer.name);

	for (i = 0; i < Array_Size(MutatorPtr.MapReplacements); ++i)
		if (MutatorPtr.MapReplacements[i].SubstituteMap ~= CurrentMap)
		{
			CurrentMap = MutatorPtr.MapReplacements[i].OriginalMap;
			bApplyMapFixes = MutatorPtr.MapReplacements[i].bApplyMapFixes;
			return;
		}
	bApplyMapFixes = true;
}

function Server_ModifyCurrentMap()
{
	if (CurrentMap ~= "NP02DavidM")
		Server_ModifyCurrentMap_NP02DavidM();
	else if (CurrentMap ~= "NP06Heiko")
		Server_ModifyCurrentMap_NP06Heiko();
	else if (CurrentMap ~= "NP11Tonnberry")
		Server_ModifyCurrentMap_NP11Tonnberry();
	else if (CurrentMap ~= "NP19Part2Chico")
		Server_ModifyCurrentMap_NP19Part2Chico();
	else if (CurrentMap ~= "NP21Atje")
		Server_ModifyCurrentMap_NP21Atje();
	else if (CurrentMap ~= "NP35MClane")
		Server_ModifyCurrentMap_NP35MClane();
	else if (CurrentMap ~= "ONP-map24CoreX")
		Server_ModifyCurrentMap_ONP_map24CoreX();
	else if (CurrentMap ~= "ONP-map40Boss")
		Server_ModifyCurrentMap_ONP_map40Boss();
}

function Server_FixCurrentMap()
{
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
	else if (CurrentMap ~= "NP12Tonnberry")
		Server_FixCurrentMap_NP12Tonnberry();
	else if (CurrentMap ~= "NP13DrPest")
		Server_FixCurrentMap_NP13DrPest();
	else if (CurrentMap ~= "NP14MClaneDrPest")
		Server_FixCurrentMap_NP14MClaneDrPest();
	else if (CurrentMap ~= "NP15Chico")
		Server_FixCurrentMap_NP15Chico();
	else if (CurrentMap ~= "NP16Chico")
		Server_FixCurrentMap_NP16Chico();
	else if (CurrentMap ~= "NP17Chico")
		Server_FixCurrentMap_NP17Chico();
	else if (CurrentMap ~= "NP18Chico")
		Server_FixCurrentMap_NP18Chico();
	else if (CurrentMap ~= "NP19Part1Chico")
		Server_FixCurrentMap_NP19Part1Chico();
	else if (CurrentMap ~= "NP19Part2Chico")
		Server_FixCurrentMap_NP19Part2Chico();
	else if (CurrentMap ~= "NP19Part3ChicoHour")
		Server_FixCurrentMap_NP19Part3ChicoHour();
	else if (CurrentMap ~= "NP22DavidM")
		Server_FixCurrentMap_NP22DavidM();
	else if (CurrentMap ~= "NP23Kew")
		Server_FixCurrentMap_NP23Kew();
	else if (CurrentMap ~= "NP24MClane")
		Server_FixCurrentMap_NP24MClane();
	else if (CurrentMap ~= "NP25DavidM")
		Server_FixCurrentMap_NP25DavidM();
	else if (CurrentMap ~= "NP26DavidM")
		Server_FixCurrentMap_NP26DavidM();
	else if (CurrentMap ~= "NP27DavidM")
		Server_FixCurrentMap_NP27DavidM();
	else if (CurrentMap ~= "NP29DavidM")
		Server_FixCurrentMap_NP29DavidM();
	else if (CurrentMap ~= "NP31DavidM")
		Server_FixCurrentMap_NP31DavidM();
	else if (CurrentMap ~= "NP32Strogg")
		Server_FixCurrentMap_NP32Strogg();
	else if (CurrentMap ~= "NP33Atje")
		Server_FixCurrentMap_NP33Atje();
	else if (CurrentMap ~= "NP34Atje")
		Server_FixCurrentMap_NP34Atje();
	else if (CurrentMap ~= "NP35MClane")
		Server_FixCurrentMap_NP35MClane();
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
	else if (CurrentMap ~= "ONP-map04StaticX")
		Server_FixCurrentMap_ONP_map04StaticX();
	else if (CurrentMap ~= "ONP-map05SourWaterX")
		Server_FixCurrentMap_ONP_map05SourWaterX();
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
	else if (CurrentMap ~= "ONP-map17SiteBX")
		Server_FixCurrentMap_ONP_map17SiteBX();
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
	else if (CurrentMap ~= "ONP-map10SourWater")
		Server_FixCurrentMap_ONP_map10SourWater();
	else if (CurrentMap ~= "ONP-map11Admin")
		Server_FixCurrentMap_ONP_map11Admin();
	else if (CurrentMap ~= "ONP-map12Monorail")
		Server_FixCurrentMap_ONP_map12Monorail();
	else if (CurrentMap ~= "ONP-map13Processing")
		Server_FixCurrentMap_ONP_map13Processing();
	else if (CurrentMap ~= "ONP-map14Mine")
		Server_FixCurrentMap_ONP_map14Mine();
	else if (CurrentMap ~= "ONP-map15CrossCountry")
		Server_FixCurrentMap_ONP_map15CrossCountry();
	else if (CurrentMap ~= "ONP-map16Dam")
		Server_FixCurrentMap_ONP_map16Dam();
	else if (CurrentMap ~= "ONP-map17watersport")
		Server_FixCurrentMap_ONP_map17watersport();
	else if (CurrentMap ~= "ONP-map19Teleporter")
		Server_FixCurrentMap_ONP_map19Teleporter();
	else if (CurrentMap ~= "ONP-map20Interloper")
		Server_FixCurrentMap_ONP_map20Interloper();
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

	if (CurrentMap ~= "NP05Heiko")
		Client_FixCurrentMap_NP05Heiko();
	else if (CurrentMap ~= "NP09Silver")
		Client_FixCurrentMap_NP09Silver();
	else if (CurrentMap ~= "NP13DrPest")
		Client_FixCurrentMap_NP13DrPest();
	else if (CurrentMap ~= "ONP-map22TransferX")
		Client_FixCurrentMap_ONP_map22TransferX();
	else if (CurrentMap ~= "ONP-map24CoreX")
		Client_FixCurrentMap_ONP_map24CoreX();
	else if (CurrentMap ~= "ONP-map26EBE")
		Client_FixCurrentMap_ONP_map26EBE();
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

function Server_ModifyCurrentMap_NP02DavidM()
{
	if (!MutatorPtr.bUseAircraftLevels)
		MutatorPtr.SetNextLevel("NP04Hyperion");
}

function Server_FixCurrentMap_NP02DavidM()
{
	local Pawn P;
	local Trigger Trigger;
	local Carcass Carc;
	local ONPGibInstigator ONPGibInstigator;

	P = LoadLevelPawn("SkaarjWarrior0");
	if (P != none)
	{
		P.GroundSpeed = P.default.GroundSpeed;
		P.JumpZ = P.default.JumpZ;
	}

	P = LoadLevelPawn("SkaarjScout1");
	if (P != none)
	{
		P.GroundSpeed = P.default.GroundSpeed;
		P.JumpZ = P.default.JumpZ;
	}

	class'ONPSafeFall'.static.CreateAtActor(Level, "WaterZone0", 512, 128);

	foreach AllActors(class'Carcass', Carc, 'mercisnowdead')
		Carc.Destroy();

	AlarmPoint(LoadLevelActor("AlarmPoint25")).bDestroyAlarmTriggerer = false;

	P = LoadLevelPawn("Mercenary4");
	if (P != none)
	{
		ONPGibInstigator = Spawn(class'ONPGibInstigator',, 'mercisnowdead');
		ONPGibInstigator.Instigator = P;
		ONPGibInstigator.ThrowVelocity = ThrowStuff(LoadLevelActor("ThrowStuff0")).throwVect;
		P.Event = 'mercisnowdead';
	}

	LoadLevelTrigger("Trigger22").Event = '';

	if (class'ONPTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover62", 'toggle_biglift', 'biglift') != none)
	{
		Trigger = LoadLevelTrigger("Trigger35");
		Trigger.Event = 'toggle_biglift';
		Trigger.ReTriggerDelay = 0;

		Trigger = LoadLevelTrigger("Trigger41");
		Trigger.Event = 'toggle_biglift';
		Trigger.ReTriggerDelay = 0;
	}
}

function Server_FixCurrentMap_NP04Hyperion()
{
	local TranslatorEvent TranslatorEvent;
	local string Message;
	local Actor NaliFruit;
	local vector Pos;

	SetTriggerPawnClassProximity(LoadLevelTrigger("Trigger16"));

	InterpolateSpecialEvent("SpecialEvent10");

	TranslatorEvent = TranslatorEvent(LoadLevelActor("TranslatorEvent0"));
	Message = "Ihneya'Na's Log: The Nali betrayer got his 'device', as the Skaarj seem to call it, today. The Skaarj lord in this area tore out his left eye and replaced it with some weird metal piece. " $ "I don't know what it's doing, but Skaarj are well known for altering other creatures to fit their needs. I hope that does not include us.";
	if (TranslatorEvent != none && InStr(Message, TranslatorEvent.Message) == 0)
		TranslatorEvent.Message = Message;

	NaliFruit = LoadLevelActor("NaliFruit3");
	Pos = NaliFruit.Location;
	Pos.Z = -2743.000000;
	NaliFruit.SetLocation(Pos);
}

function Server_FixCurrentMap_NP05Heiko()
{
	LoadLevelTrigger("Trigger29").TriggerType = TT_PlayerProximity;

	// Eliminate flying tree (invisible in UT, visible in Unreal 227)
	EliminateStaticActor("Tree3");

	// Prevent falling damage
	LoadLevelActor("Light150").Region.Zone.ZoneTerminalVelocity = 980;
}

simulated function Client_FixCurrentMap_NP05Heiko()
{
	// Eliminate flying tree (invisible in UT, visible in Unreal 227)
	// Needs both server-side and client-side modifications
	EliminateStaticActor("Tree3");
}

function Server_ModifyCurrentMap_NP06Heiko()
{
	if (!MutatorPtr.bUseONPSpeech)
		LoadLevelActor("SpecialEvent5").Tag = '';
}

function Server_FixCurrentMap_NP06Heiko()
{
	local Actor A;

	class'ONPTriggerStoppedMover'.static.CreateFor(Level, "Mover15");

	LoadLevelTrigger("Trigger33").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger35").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger61").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger62").bTriggerOnceOnly = true;

	// Light486 and Light487 have bStatic == False -> they are not loaded on clients, but clients
	// rely on these objects, so clients often crash
	// bAlwaysRelevant sometimes prevents clients from crashing, sometimes not
	A = LoadLevelActor("Light486", true);
	if (A != none)
		A.bAlwaysRelevant = true;

	A = LoadLevelActor("Light487", true);
	if (A != none)
		A.bAlwaysRelevant = true;
}

function Server_FixCurrentMap_NP08Hourences()
{
	local Effects e;
	local ONPParticleFireSpawner NewFireSpawner;
	local Trigger Trigger;

	foreach AllActors(class'Effects', e)
		if (e.IsA('ParticleFireSpawner'))
		{
			NewFireSpawner = e.Spawn(class'ONPParticleFireSpawner', e.Owner, e.Tag);
			if (NewFireSpawner != none)
				NewFireSpawner.ReplaceOriginalSpawner(e);
		}

	if (class'ONPTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover33", 'toggle_lift1', 'olallalala2') != none)
	{
		Trigger = LoadLevelTrigger("Trigger80");
		Trigger.Event = 'toggle_lift1';
		Trigger.ReTriggerDelay = 0;

		Trigger = LoadLevelTrigger("Trigger81");
		Trigger.Event = 'toggle_lift1';
		Trigger.ReTriggerDelay = 0;
	}

	if (class'ONPTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover34", 'toggle_lift2', 'olallalala3') != none)
	{
		Trigger = LoadLevelTrigger("Trigger82");
		Trigger.Event = 'toggle_lift2';
		Trigger.ReTriggerDelay = 0;

		Trigger = LoadLevelTrigger("Trigger84");
		Trigger.Event = 'toggle_lift2';
		Trigger.ReTriggerDelay = 0;
	}

	if (class'ONPTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover32", 'toggle_lift3', 'olallalala1') != none)
	{
		Trigger = LoadLevelTrigger("Trigger78");
		Trigger.Event = 'toggle_lift3';
		Trigger.ReTriggerDelay = 0;

		Trigger = LoadLevelTrigger("Trigger79");
		Trigger.Event = 'toggle_lift3';
		Trigger.ReTriggerDelay = 0;
	}
}

function Server_FixCurrentMap_NP09Silver()
{
	LoadLevelDispatcher("Dispatcher4").OutEvents[4] = '';
	LoadLevelMover("Mover7").MoverEncroachType = ME_IgnoreWhenEncroach; // ME_CrushWhenEncroach may kill the Titan

	// allows players to reuse the lift
	LoadLevelMover("Mover1").bTriggerOnceOnly = false;
	LoadLevelTrigger("Trigger5").bTriggerOnceOnly = false;

	// prevents client-side glitch
	LoadLevelMover("Mover8").Tag = '';

	EliminateStaticActor("BlockAll10");
}

simulated function Client_FixCurrentMap_NP09Silver()
{
	EliminateStaticActor("BlockAll10");
}

function Server_ModifyCurrentMap_NP11Tonnberry()
{
	if (MutatorPtr.bInfiniteSpecialItems)
		MakePermanentInventoryPointsFor(class'ToxinSuit');
}

function Server_FixCurrentMap_NP11Tonnberry()
{
	local Mover m;

	m = LoadLevelMover("Mover6");
	m.PlayerBumpEvent = m.Tag;
}

function Server_FixCurrentMap_NP12Tonnberry()
{
	LoadLevelMover("Mover159").InitialState = 'TriggerOpenTimed';
	LoadLevelActor("Dispatcher15").Tag = '';
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

	if (!MutatorPtr.bUseONPSpeech)
	{
		LoadLevelDispatcher("Dispatcher9").OutDelays[1] = 0;
		LoadLevelDispatcher("Dispatcher10").OutDelays[1] = 4;
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

	P = LoadLevelPawn("NaliTrooper1");
	if (P != none)
		Spawn(class'ONPPhantomPawnAdjustment').ControlledPawn = P;
}

function Server_FixCurrentMap_NP15Chico()
{
	LoadLevelTrigger("Trigger112").bTriggerOnceOnly = true;

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light150", 2000, 1000);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light187", 4000, 3000);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode44", 1000, 800);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode255", 3000, 1500);
}

function Server_FixCurrentMap_NP16Chico()
{
	ZoneInfo(LoadLevelActor("ZoneInfo0")).ZoneVelocity = vect(0, 0, 0);

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode533", 1000, 250);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode545", 2000, 1500);
}

function Server_FixCurrentMap_NP17Chico()
{
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode293", 1500, 600);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode304", 3000, 2000);
}

function Server_FixCurrentMap_NP18Chico()
{
	LoadLevelMover("Mover27").Event = '';

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode416", 3000, 3000);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode426", 3000, 300);
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode2", 1200, 600);
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode61", 1000, 400);
	MakeNetVisibilityCylinderAt('NetVisCylinder_3', "PathNode49", 1500, 400);
	MakeNetVisibilityCylinderAt('NetVisCylinder_3', "PathNode81", 3000, 1200);
}

function Server_FixCurrentMap_NP19Part1Chico()
{
	local ONPPlayerTriggeringActor TriggeringActor;
	local Pawn P;

	TriggeringActor = LoadLevelTrigger("Trigger57").Spawn(class'ONPPlayerTriggeringActor',, 'mainlift');
	TriggeringActor.SetBase(LoadLevelMover("Mover73"));

	P = LoadLevelPawn("SkaarjGunner2");
	if (P != none)
		P.AttitudeToPlayer = ATTITUDE_Hate;
	P = LoadLevelPawn("SkaarjOfficer2");
	if (P != none)
		P.AttitudeToPlayer = ATTITUDE_Hate;
}

function Server_ModifyCurrentMap_NP19Part2Chico()
{
	if (!MutatorPtr.bUseAircraftLevels)
		MutatorPtr.SetNextLevel("NP20DavidM");
}

function Server_FixCurrentMap_NP19Part2Chico()
{
	local ZoneInfo zone;
	local PressureZone pr_zone;
	local Trigger Trigger;

	zone = ZoneInfo(LoadLevelActor("ZoneInfo8"));
	zone.ZoneVelocity = vect(0, 0, 0);
	zone.ZoneGravity = vect(0, 0, 0);

	pr_zone = PressureZone(LoadLevelActor("PressureZone0"));
	pr_zone.DieDrawScale = 1;

	LoadLevelMover("Mover15").bNet = false;
	LoadLevelMover("Mover171").bNet = true;
	LoadLevelMover("Mover172").bNet = true;

	LoadLevelTrigger("Trigger20").Event = '';
	LoadLevelActor("CreatureFactory7").Tag = '';

	foreach AllActors(class'Trigger', Trigger)
		if (Trigger.Event == 'itburnS')
		{
			Trigger.bTriggerOnceOnly = false;
			Trigger.TriggerType = TT_PawnProximity;
		}
}

function Server_FixCurrentMap_NP19Part3ChicoHour()
{
	DisablePlayerStart("PlayerStart2");
	DisablePlayerStart("PlayerStart3");
	DisablePlayerStart("PlayerStart4");
	LoadLevelTrigger("Trigger22").TriggerType = TT_PlayerProximity;
	MakeMoversTriggerableOnceOnly('tunneld3', true);
	MakeMoversTriggerableOnceOnly('tunneld6', true);
	MakeMoversTriggerableOnceOnly('multidoor3ofzo', true);
	MakeMoversTriggerableOnceOnly('blaaaaahmultimoverzoveel', true);
}

function Server_ModifyCurrentMap_NP21Atje()
{
	if (MutatorPtr.bInfiniteSpecialItems)
		MakePermanentInventoryPointsFor(class'AsbestosSuit');
}

function Server_FixCurrentMap_NP22DavidM()
{
	local ONPBlockAllPanel BlockAll;
	local Actor EClip;
	local vector Pos;

	DisableTeleporter("Teleporter1");
	BlockAll = Spawn(class'ONPBlockAllPanel',,, vect(1283, -576, -98), rot(-764, 19308, 0));
	BlockAll.Skin = Texture(DynamicLoadObject("DavidMGras.Ground1", class'Texture', true)); // for footstep sounds
	BlockAll.SetScale(12);

	EClip = LoadLevelActor("EClip0");
	Pos = EClip.Location;
	Pos.Z = -636;
	EClip.SetLocation(Pos);
}

function Server_FixCurrentMap_NP23Kew()
{
	local ONPBlockAllPanel BlockAll;

	DisableTeleporter("Teleporter1");
	BlockAll = Spawn(class'ONPBlockAllPanel',,, vect(-1511, -994, -935), rot(-3500, 29152, 0));
	BlockAll.Skin = Texture(DynamicLoadObject("DavidMGras.Ground1", class'Texture', true)); // for footstep sounds
	BlockAll.SetScale(8);
}

function Server_FixCurrentMap_NP24MClane()
{
	SetEventTriggersPawnClassProximity('autsch');
	class'ONPTriggerStoppedMover'.static.CreateFor(Level, "Mover35");
	class'ONPTriggerStoppedMover'.static.CreateFor(Level, "Mover43");
}

function Server_FixCurrentMap_NP25DavidM()
{
	LoadLevelActor("SpecialEvent9").Tag = '';
}

function Server_FixCurrentMap_NP26DavidM()
{
	LoadLevelDispatcher("Dispatcher2").OutEvents[2] = '';
	LoadLevelActor("DispatcherPlus0").Tag = '';
	LoadLevelActor("Teleporter3").SetCollisionSize(60, 2048);

	DisableTeleporter("Teleporter4"); // disable singleplayer teleporter
	LoadLevelMover("Mover25").Tag = ''; // prevents the exit teleporter from being hidden from players
}

function Server_FixCurrentMap_NP27DavidM()
{
	local Actor A;
	local Trigger Trigger;

	if (class'ONPTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover24", 'toggle_lift1', 'lift1337d') != none)
	{
		Trigger = LoadLevelTrigger("Trigger40");
		Trigger.Event = 'toggle_lift1';
		Trigger.ReTriggerDelay = 0;

		Trigger = LoadLevelTrigger("Trigger41");
		Trigger.Event = 'toggle_lift1';
		Trigger.ReTriggerDelay = 0;
	}

	A = LoadLevelActor("TvTranslocator1", true);
	if (A != none)
	{
		A.DrawType = A.default.DrawType;
		A.Mesh = A.default.Mesh;
	}

	if (class'ONPTriggerIfMoverIsStopped'.static.CreateFor(Level, "Mover52", 'toggle_lift2', 'lift13372d') != none)
	{
		Trigger = LoadLevelTrigger("Trigger35");
		Trigger.Event = 'toggle_lift2';
		Trigger.ReTriggerDelay = 0;

		Trigger = LoadLevelTrigger("Trigger42");
		Trigger.Event = 'toggle_lift2';
		Trigger.ReTriggerDelay = 0;
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
	local Mover Mover;
	local ONPMoverOpener ONPMoverOpener;
	local ONPZonedTrigger ONPZonedTrigger;

	LoadLevelActor("skaarjeyes0").Style = STY_Translucent;

	LoadLevelActor("ViewSpot4").Spawn(class'ONPViewSpot',, 'trapcam4');

	Mover = LoadLevelMover("Mover6");
	ONPMoverOpener = Spawn(class'ONPMoverOpener', Mover, 'open_homosexualdoor');
	ONPZonedTrigger = Spawn(class'ONPZonedTrigger');
	ONPZonedTrigger.ReplaceTrigger(LoadLevelTrigger("Trigger12"));
	ONPZonedTrigger.bTriggerOnceOnly = false;
	ONPZonedTrigger.Event = 'open_homosexualdoor';
	LoadLevelDispatcher("Dispatcher13").OutEvents[2] = 'open_homosexualdoor';

	MutatorPtr.bTemporarySuperShockRifle = true;
	LoadLevelMover("Mover42").Tag = '';
}

function Server_FixCurrentMap_NP32Strogg()
{
	local Effects e;
	local ONPParticleFireSpawner NewFireSpawner;

	MakeMoverTriggerableOnceOnly("Mover30");
	LoadLevelActor("TriggerLight40").InitialState = 'TriggerTurnsOff';

	AssignInitialState(LoadLevelMover("Mover47"), 'TriggerOpenTimed'); // disable mover
	AssignInitialState(LoadLevelMover("Mover48"), 'TriggerOpenTimed'); // disable mover

	foreach AllActors(class'Effects', e)
		if (e.IsA('ParticleFireSpawner'))
		{
			NewFireSpawner = e.Spawn(class'ONPParticleFireSpawner', e.Owner, e.Tag);
			if (NewFireSpawner != none)
				NewFireSpawner.ReplaceOriginalSpawner(e);
		}
}

function Server_FixCurrentMap_NP33Atje()
{
	LoadLevelActor("PlayerStart1").Tag = 'sp1';
	LoadLevelActor("PlayerStart2").Tag = 'sp1';
	LoadLevelActor("PlayerStart3").Tag = 'sp1';
	LoadLevelActor("PlayerStart4").Tag = 'sp1';

	MakeMoverTriggerableOnceOnly("Mover8");
	MakeMoverTriggerableOnceOnly("Mover9");
}

function Server_FixCurrentMap_NP34Atje()
{
	DisablePlayerStart("PlayerStart0");
	LoadLevelTrigger("Trigger24").Event = '';
}

function Server_ModifyCurrentMap_NP35MClane()
{
	MutatorPtr.SetNextLevel(MutatorPtr.ONPGameEndURL);

	if (MutatorPtr.bDiscardItemsOnGameEnd)
		Spawn(class'ONPDiscardItemsOnLevelEnd');
}

function Server_FixCurrentMap_NP35MClane()
{
	SpawnTeleporterReplacement(LoadLevelActor("ONPEndMark2"), MutatorPtr.ONPGameEndURL, false);
}


function Server_FixCurrentMap_ONP_map01FirstDayX()
{
	LoadLevelActor("Trigger12").Tag = '';
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
	LoadLevelMover("Mover24").StayOpenTime = 4.0;
	EarthQuake(LoadLevelActor("Earthquake1")).bThrowPlayer = false;
	EarthQuake(LoadLevelActor("Earthquake2")).bThrowPlayer = false;

	SetNamedTriggerPosition("Trigger65", vect(607, -5118, -1661), 512); // PlayerStart9 -> PlayerStart10

	MakeMessageEventFor("SpecialEvent4");
	MakeMessageEventFor("SpecialEvent11");
	MakeMessageEventFor("SpecialEvent28");
	MakeMessageEventFor("SpecialEvent40");
	MakeMessageEventFor("SpecialEvent45");
	MakeMessageEventFor("SpecialEvent5");
}

function Server_FixCurrentMap_ONP_map03oppressivemetalX()
{
	SetNamedTriggerPawnClassProximity("Trigger4");
	SetNamedTriggerPawnClassProximity("Trigger8");
	SetNamedTriggerPawnClassProximity("Trigger47");
	SetEventTriggersPawnClassProximity('felldoom');
}

function Server_FixCurrentMap_ONP_map04StaticX()
{
	local Actor Dispatcher;

	Dispatcher = LoadLevelActor("Dispatcher7", true);
	if (Dispatcher != none)
		Dispatcher.Tag = ''; // PlayerStart8 -> PlayerStart9
	MakeMessageEventFor("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent11");
	MakeMessageEventFor("SpecialEvent14");
	MakeMessageEventFor("SpecialEvent17");
	MakeMessageEventFor("SpecialEvent25");
	MakeMessageEventFor("SpecialEvent27");
}

function Server_FixCurrentMap_ONP_map05SourWaterX()
{
	SetNamedTriggerPosition("Trigger55", vect(-2335, -325, -80), 256); // PlayerStart6 -> PlayerStart7
}

function Server_FixCurrentMap_ONP_map06ProcessingX()
{
	local Trigger Trigger;

	foreach AllActors(class'Trigger', Trigger)
		if (StrStartsWith(Trigger.Event, "splash", true))
			SetTriggerPawnClassProximity(Trigger);

	AssignInitialState(LoadLevelActor("Trigger58"), 'NormalTrigger');
	LoadLevelTrigger("Trigger64").bTriggerOnceOnly = true;
	SetTriggerPawnClassProximity(LoadLevelTrigger("Trigger5"));

	MakeMessageEventFor("SpecialEvent1");
	MakeMessageEventFor("SpecialEvent5");
}

function Server_FixCurrentMap_ONP_map07PlanningX()
{
	LoadLevelMover("Mover0").StayOpenTime = 4.0;
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

	FixatePlayerStarts();
}

function Server_FixCurrentMap_ONP_map09SurfaceX()
{
	local TeamCannon Cannon;

	foreach AllActors(class'TeamCannon', Cannon)
		Cannon.SetPropertyText("B227_bAttackAnyDamageInstigators", "true");

	MakeFallingMoverController("Mover65");
	SetNamedTriggerPawnClassProximity("Trigger6");
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;
	LoadLevelActor("Trigger23").Tag = '';
	CreatureFactory(LoadLevelActor("CreatureFactory0")).bCovert = false;
	CreatureFactory(LoadLevelActor("CreatureFactory1")).bCovert = false;
	CreatureFactory(LoadLevelActor("CreatureFactory2")).bCovert = false;
	SpawnTeleporterReplacement(LoadLevelActor("Trigger14", true), "ONP-map10AmbushX#", true).Tag = '';

	FixatePlayerStarts();
}

function Server_FixCurrentMap_ONP_map10AmbushX()
{
	local Mover Mover;
	local ONPPlayerRelocation PlayerRelocation;

	DisablePlayerStart("PlayerStart0");

	ThingFactory(LoadLevelActor("ThingFactory0")).prototype = class'ONPLandedWarShellExplosion';
	ThingFactory(LoadLevelActor("ThingFactory1")).prototype = class'ONPLandedWarShellExplosion';
	ThingFactory(LoadLevelActor("ThingFactory2")).prototype = class'ONPLandedWarShellExplosion';

	Mover = LoadLevelMover("Mover41");
	Mover.DelayTime = 0;
	Mover.MoveTime = 1;

	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;

	PlayerRelocation = Spawn(class'ONPPlayerRelocation',, 'rise', vect(-4464.000000,-12192.000000,-512.000000));
	PlayerRelocation.MaxRelocationZ = -740.0;
	PlayerRelocation.AddZone("ZoneInfo4");
	PlayerRelocation.AddZone("ZoneInfo6");
	PlayerRelocation.AddZone("ZoneInfo12");
	PlayerRelocation.ExcludeArea(LoadLevelActor("AlarmPoint6").Location, 2000);

	MakeMessageEventFor("SpecialEvent45");
}

function Server_FixCurrentMap_ONP_map11CobaltX()
{
	LoadLevelTrigger("Trigger8").bTriggerOnceOnly = true;

	MakeMessageEventFor("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent30");
	MakeMessageEventFor("SpecialEvent56");
	MakeMessageEventFor("SpecialEvent58");
	MakeMessageEventFor("SpecialEvent69");
	MakeMessageEventFor("SpecialEvent87");
}

function Server_FixCurrentMap_ONP_map12DamX()
{
	SetEventTriggersPawnClassProximity('choppedup');
	MakeMessageEventFor("SpecialEvent30");

	FixatePlayerStarts();
}

function Server_FixCurrentMap_ONP_map13SignsX()
{
	LoadLevelActor("Trigger71").Tag = 'ambush';
	LoadLevelActor("SpecialEvent8").Tag = '';
	SetNamedTriggerPawnClassProximity("Trigger30");

	LoadLevelTrigger("Trigger11").bTriggerOnceOnly = true; // MusicEvent5

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light43", 3000, 2000);     // WarpZoneInfo1
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "ZoneInfo2", 1000, 1000);   // WarpZoneInfo2
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode285", 6000, 6000); // WarpZoneInfo3
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "Light199", 2000, 1000);    // WarpZoneInfo4
}

function Server_FixCurrentMap_ONP_map14SoothsayerX()
{
	local Teleporter Telep;
	local ONPPawnDestructionEvent NaliDestructionEvent;

	DisablePlayerStart("PlayerStart0");

	MakeMessageEventFor("SpecialEvent31");
	LoadLevelActor("SpecialEvent48").Tag = '';

	LoadLevelMover("Mover18").StayOpenTime = 25.1;
	LoadLevelMover("Mover78").StayOpenTime = 25.1;
	LoadLevelMover("Mover43").StayOpenTime = 4;
	LoadLevelMover("Mover44").StayOpenTime = 4;

	SetNamedTriggerPawnClassProximity("Trigger64");

	Telep = Teleporter(LoadLevelActor("Teleporter0"));
	Telep.bEnabled = false;
	Telep.Tag = 'TeleporterEnergyUp';

	LoadLevelActor("AlarmPoint18").Event = 'InitTeleporterEnergyUp';
	NaliDestructionEvent = Spawn(class'ONPPawnDestructionEvent');
	NaliDestructionEvent.AssignPawn(LoadLevelPawn("NaliPriest0"));
	NaliDestructionEvent.Event = 'InitTeleporterEnergyUp';

	EventToEvent('InitTeleporterEnergyUp', 'energyup', true);
	EventToEvent('energyup', 'TeleporterEnergyUp', true);
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

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "ZoneInfo8", 1024, 256);          // WarpZoneInfo0
	MakeNetVisibilityCylinder('NetVisCylinder_1', vect(1730, 10000, -812), 256, 256); // WarpZoneInfo1
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode162", 2000, 512);        // WarpZoneInfo2
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode193", 2000, 512);        // WarpZoneInfo3

	FixatePlayerStarts();
}

function Server_FixCurrentMap_ONP_map17SiteBX()
{
	LoadLevelTrigger("Trigger66").Event = '';
	DisablePlayerStart("PlayerStart0");
	DisablePlayerStart("PlayerStart7");
	DisablePlayerStart("PlayerStart14");
	SetNamedTriggerPosition("Trigger69", vect(12535, 9217, -5656), 256);
	SetNamedTriggerPosition("Trigger70", vect(16615, 635, -5646), 512);
	LoadLevelTrigger("Trigger71").Event = '';
	MakeMessageEventFor("SpecialEvent8");
}

function Server_FixCurrentMap_ONP_map18FriendX()
{
	local Trigger Tr;
	local ONPPawnDestructionEvent NaliDestructionEvent;

	DisablePlayerStart("PlayerStart6");
	PlayerStart(LoadLevelActor("PlayerStart13")).bEnabled = false;
	PlayerStart(LoadLevelActor("PlayerStart14")).bEnabled = false;

	Tr = LoadLevelTrigger("Trigger77");
	Tr.bInitiallyActive = true;
	Tr.Tag = '';

	LoadLevelTrigger("Trigger15").bTriggerOnceOnly = true;

	NaliDestructionEvent = Spawn(class'ONPPawnDestructionEvent');
	NaliDestructionEvent.AssignPawn(LoadLevelPawn("NaliPriest0"));
	NaliDestructionEvent.Event = 'wooddoorup';

	SetNamedTriggerPawnClassProximity("Trigger11");
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;

	SetNamedTriggerPosition("Trigger21", vect(-8270, -4494, -321), 128);
	SetNamedTriggerPosition("Trigger40", vect(2800, -6879, -2993), 512, 512);
	SetNamedTriggerPosition("Trigger43", vect(4031, 9787, -14112), 512, 512);
	SetNamedTriggerPosition("Trigger45", vect(16016, 17214, -15904), 512);
}

function Server_FixCurrentMap_ONP_map19IceX()
{
	LoadLevelTrigger("Trigger49").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger68").bTriggerOnceOnly = true; // MusicEvent5
	LoadLevelTrigger("Trigger82").bTriggerOnceOnly = true; // MusicEvent1
	LoadLevelTrigger("Trigger87").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger88").bTriggerOnceOnly = true; // MusicEvent5
	LoadLevelMover("Mover120").StayOpenTime = 4;
	MakeMessageEventFor("SpecialEvent25");
	SetNamedTriggerPawnClassProximity("Trigger73");
	FixatePlayerStarts();
}

function Server_FixCurrentMap_ONP_map20InterloperX()
{
	LoadLevelMover("Mover97").StayOpenTime = 4;
	MakeMessageEventFor("SpecialEvent25");
	SetEventTriggersPawnClassProximity('Death');
	SetEventTriggersPawnClassProximity('ohdearyoufell');

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Trigger47", 1500, 256); // WarpZoneInfo0
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light1653", 400, 128);  // WarpZoneInfo1
}

function Server_FixCurrentMap_ONP_map21NestX()
{
	LoadLevelMover("RotatingMover0").Tag = 'hiveoff_stop_rotating';
	Spawn(class'ONPEventUntrigger',, 'hiveoff').Event = 'hiveoff_stop_rotating';

	DisablePlayerStart("PlayerStart0");
	DisablePlayerStart("PlayerStart10");
	LoadLevelActor("PlayerStart14").Tag = 'PlayerStart8';
	LoadLevelTrigger("Trigger93").Event = '';
	EventToEvent('Shield', 'players8', true);

	MakeMessageEventFor("SpecialEvent2");
	SetEventTriggersPawnClassProximity('wasted');
}

function Server_FixCurrentMap_ONP_map22TransferX()
{
	local Dispatcher Dispatcher;

	LoadLevelActor("PlayerStart4").Tag = 'playst0';
	LoadLevelActor("PlayerStart5").Tag = 'playst0';
	LoadLevelActor("PlayerStart6").Tag = 'playst0';
	LoadLevelActor("PlayerStart7").Tag = 'playst0';
	LoadLevelActor("PlayerStart8").Tag = 'playst0';
	LoadLevelActor("PlayerStart9").Tag = 'playst0';
	LoadLevelActor("PlayerStart10").Tag = 'playst0';
	DisablePlayerStart("PlayerStart0");
	DisablePlayerStart("PlayerStart2");
	LoadLevelDispatcher("Dispatcher52").OutEvents[1] = 'playst0'; // initial PlayerStarts -> PlayerStart1
	EventToEvent('player4', 'player4_disp', true);
	Dispatcher = LoadLevelDispatcher("Dispatcher55");
	Dispatcher.Tag = 'player4_disp';
	Dispatcher.OutEvents[1] = 'playst2'; // PlayerStart1 -> PlayerStart3

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
	FixatePlayerStarts();
	SetEventTriggersPawnClassProximity('wasted');

	MakeMessageEventFor("SpecialEvent25");
	MakeMessageEventFor("SpecialEvent27");
	MakeMessageEventFor("SpecialEvent30");
	MakeMessageEventFor("SpecialEvent34");
	MakeMessageEventFor("SpecialEvent38");
	MakeMessageEventFor("SpecialEvent45");
	MakeMessageEventFor("SpecialEvent62");
}

function Server_ModifyCurrentMap_ONP_map24CoreX()
{
	MutatorPtr.SetNextLevel(MutatorPtr.PXGameEndURL);

	if (MutatorPtr.bDiscardItemsOnGameEnd)
		Spawn(class'ONPDiscardItemsOnLevelEnd');
}

function Server_FixCurrentMap_ONP_map24CoreX()
{
	local PlayerStart PlayerStart;
	local Trigger Trigger;
	local Dispatcher Dispatcher;

	ReplacePlayerStart("PlayerStart9", vect(-10373, -8671, 3115), 16384);
	DisablePlayerStart("PlayerStart11");
	ReplacePlayerStart("PlayerStart12", vect(-10373, -8671, 3115), 16384);
	LoadLevelActor("PlayerStart2").Tag = 'playerst0';
	LoadLevelActor("PlayerStart3").Tag = 'playerst0';
	LoadLevelActor("PlayerStart4").Tag = 'playerst0';
	LoadLevelActor("PlayerStart5").Tag = 'playerst0';
	LoadLevelActor("PlayerStart6").Tag = 'playerst0';
	LoadLevelActor("PlayerStart7").Tag = 'playerst0';
	LoadLevelActor("PlayerStart13").Tag = 'playerst0';
	LoadLevelDispatcher("Dispatcher56").OutEvents[1] = 'playerst0';
	LoadLevelDispatcher("Dispatcher37").OutEvents[1] = 'playerst1';
	LoadLevelDispatcher("Dispatcher38").OutEvents[1] = 'playerst2';
	LoadLevelDispatcher("Dispatcher39").OutEvents[3] = 'playerst3';
	LoadLevelDispatcher("Dispatcher42").OutEvents[1] = 'playerst4';
	LoadLevelDispatcher("Dispatcher58").OutEvents[3] = 'playerst6';
	PlayerStart = PlayerStart(LoadLevelActor("PlayerStart0"));
	PlayerStart.bEnabled = false;
	PlayerStart.Tag = 'playerst11';
	Trigger = Spawn(class'Trigger',,, PlayerStart.Location);
	Trigger.SetCollisionSize(512, 40);
	Trigger.Event = 'playst11';
	Trigger.bTriggerOnceOnly = true;
	Dispatcher = Spawn(class'Dispatcher',, 'playst11');
	Dispatcher.OutEvents[0] = 'playerst11';
	Dispatcher.OutEvents[1] = 'playerst10';

	LoadLevelTrigger("Trigger95").bTriggerOnceOnly = true; // MusicEvent2
	LoadLevelTrigger("Trigger96").bTriggerOnceOnly = true; // MusicEvent3
	LoadLevelTrigger("Trigger110").bTriggerOnceOnly = true;

	MakeLocalMessageEventFor("SpecialEvent127"); // Health Regeneration
	MakeMessageEventFor("SpecialEvent128");
	MakeMessageEventFor("SpecialEvent133");

	LoadLevelTrigger("Trigger57").Tag = 'dispone';

	MakeDecorationUnmovableAt("SteelBox3", vect(-10130, -8850, 10842.6));
	MakeDecorationUnmovableAt("SteelBox4", vect(-12750, -3230, 2714.57));

	SetEventTriggersPawnClassProximity('Death');
	SetEventTriggersPawnClassProximity('electric');
	SetNamedTriggerPawnClassProximity("Trigger56");

	Teleporter(LoadLevelActor("Teleporter19")).URL = MutatorPtr.PXGameEndURL;

	Common_FixCurrentMap_ONP_map24CoreX();
}

simulated function Client_FixCurrentMap_ONP_map24CoreX()
{
	Common_FixCurrentMap_ONP_map24CoreX();
}

simulated function Common_FixCurrentMap_ONP_map24CoreX()
{
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
	MakeDecorationUnmovable("SmallSteelBox4");
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
	MakeLocalMessageEventFor("SpecialEvent27");
}

function Server_FixCurrentMap_ONP_map05FriendlyFire()
{
	DisableTeleporter("fadeoutTeleporter1");
	SetNamedTriggerPawnClassProximity("Trigger1");
	MakeFallingMoverController("Mover79");

	MakeMessageEventFor("SpecialEvent27");
	MakeLocalMessageEventFor("SpecialEvent39");
}

function Server_FixCurrentMap_ONP_map06PowerPlay()
{
	SetEventTriggersPawnClassProximity('ouch');
	MakeLocalMessageEventFor("SpecialEvent5");
}

function Server_FixCurrentMap_ONP_map07Questionableethics()
{
	SetEventTriggersPawnClassProximity('aarrhh');
	MakeLocalMessageEventFor("SpecialEvent5");
	MakeLocalMessageEventFor("SpecialEvent7");
}

function Server_FixCurrentMap_ONP_map09ComplexSituation()
{
	SetEventTriggersPawnClassProximity('aarrhh');
	LoadLevelMusicEvent("MusicEvent2").bOnceOnly = true;

	MakeMessageEventFor("SpecialEvent5");
	MakeMessageEventFor("SpecialEvent7");
	MakeMessageEventFor("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent11");
	MakeMessageEventFor("SpecialEvent14");
	MakeMessageEventFor("SpecialEvent17");
}

function Server_FixCurrentMap_ONP_map10SourWater()
{
	MakeLocalMessageEventFor("SpecialEvent5");
}

function Server_FixCurrentMap_ONP_map11Admin()
{
	MakeMessageEventFor("SpecialEvent43");
	MutatorPtr.SetNextLevel("ONP-map13Processing");
}

function Server_FixCurrentMap_ONP_map12Monorail()
{
	local Trigger Tr;

	foreach AllActors(class'Trigger', Tr)
		if (StrStartsWith(Tr.Event, "open", true))
			Tr.bTriggerOnceOnly = false;
}

function Server_FixCurrentMap_ONP_map13Processing()
{
	SetNamedTriggerPawnClassProximity("Trigger29");
	MakeMessageEventFor("SpecialEvent2");
}

function Server_FixCurrentMap_ONP_map14Mine()
{
	LoadLevelMover("Mover1").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger2");
	SetNamedTriggerPawnClassProximity("Trigger16");
	InterpolateSpecialEvent("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent45");
}

function Server_FixCurrentMap_ONP_map15CrossCountry()
{
	LoadLevelTrigger("Trigger6").bTriggerOnceOnly = true; // MusicEvent0
	MakeMessageEventFor("SpecialEvent0");
}

function Server_FixCurrentMap_ONP_map16Dam()
{
	local ONPCameraSpot Cam;

	foreach AllActors(class'ONPCameraSpot', Cam, 'blockerdoor')
		Cam.Tag = 'blockerdoor_trigger';

	LoadLevelTrigger("Trigger10").Event = 'blockerdoor_trigger';
	EventToEvent('blockerdoor_trigger', 'blockerdoor', true);
}

function Server_FixCurrentMap_ONP_map17watersport()
{
	local ONPPlayerRelocation PlayerRelocation;

	PlayerRelocation = Spawn(class'ONPPlayerRelocation',, 'rise', vect(1136.000000,-1184.000000,-304.000000));
	PlayerRelocation.MaxRelocationZ = -530.0;
	PlayerRelocation.AddZone("LevelInfo0");
	PlayerRelocation.AddZone("WaterZone2");
	PlayerRelocation.AddZone("ZoneInfo1");
	PlayerRelocation.AddZone("ZoneInfo6");

	MakeMessageEventFor("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent16");
}

function Server_FixCurrentMap_ONP_map19Teleporter()
{
	LoadLevelTrigger("Trigger32").bTriggerOnceOnly = true;
	SetEventTriggersPawnClassProximity('killkill');
	SetEventTriggersPawnClassProximity('killkill2');
	MakeFallingMoverController("Mover0");

	MakeMessageEventFor("SpecialEvent13");
	MakeMessageEventFor("SpecialEvent16");
	MakeMessageEventFor("SpecialEvent22");
}

function Server_FixCurrentMap_ONP_map20Interloper()
{
	local SpecialEvent HeadShotEvent;
	local Trigger HeadShotTrigger;
	local SkaarjSniper Sniper;

	foreach AllActors(class'SpecialEvent', HeadShotEvent, 'ShotInTheHead')
		HeadShotEvent.Tag = '';

	foreach AllActors(class'Trigger', HeadShotTrigger)
		if (HeadShotTrigger.Event == 'ShotInTheHead')
		{
			foreach AllActors(class'SkaarjSniper', Sniper)
				if (Sniper.Event == HeadShotTrigger.Tag)
				{
					Sniper.Tag = Sniper.Event;
					Sniper.Event = '';
					Sniper.AttitudeToPlayer = ATTITUDE_Hate;
					break;
				}
			HeadShotTrigger.Event = HeadShotTrigger.Tag;
			HeadShotTrigger.Tag = '';
		}
}

function Server_FixCurrentMap_ONP_map21Welcome()
{
	LoadLevelMover("Mover0").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger23");
	MakeFallingMoverController("Mover65");
	MakeMessageEventFor("SpecialEvent16");
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

	MakeMessageEventFor("SpecialEvent5");
	MakeMessageEventFor("SpecialEvent6");
	MakeMessageEventFor("SpecialEvent8");
}

function Server_FixCurrentMap_ONP_map26EBE()
{
	MakeDecorationUnmovable("SteelBox7");

	Common_FixCurrentMap_ONP_map26EBE();

	SetNamedTriggerPawnClassProximity("Trigger0");

	MakeMessageEventFor("SpecialEvent0");
}

simulated function Client_FixCurrentMap_ONP_map26EBE()
{
	Common_FixCurrentMap_ONP_map26EBE();
}

simulated function Common_FixCurrentMap_ONP_map26EBE()
{
	local Mover Mover;
	local int CollisionFlags;

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
}

function Server_FixCurrentMap_ONP_map27Entrance()
{
	SetEventTriggersPawnClassProximity('burnbaby');
}

function Server_FixCurrentMap_ONP_map28Bellyofthebeast()
{
	DisablePlayerStart("PlayerStart0");
	SetEventTriggersPawnClassProximity('zapped');
	SetNamedTriggerPawnClassProximity("Trigger5");
	SetNamedTriggerPawnClassProximity("Trigger40");

	MakeMessageEventFor("SpecialEvent7");
	MakeMessageEventFor("SpecialEvent8");
	MakeMessageEventFor("SpecialEvent16");
	MakeMessageEventFor("SpecialEvent27");
	MakeMessageEventFor("SpecialEvent31");
	MakeMessageEventFor("SpecialEvent35");
	MakeMessageEventFor("SpecialEvent39");
	MakeMessageEventFor("SpecialEvent43");
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
	MakeMessageEventFor("SpecialEvent45");
}

function Server_FixCurrentMap_ONP_map31Dogsofwar()
{
	LoadLevelTrigger("Trigger2").bTriggerOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent1").bOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent3").bOnceOnly = true;
	MakeMessageEventFor("SpecialEvent29");
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
	MakeMessageEventFor("SpecialEvent5");
}

function Server_FixCurrentMap_ONP_map37Halted()
{
	SetNamedTriggerPawnClassProximity("Trigger14");
	MakeMessageEventFor("SpecialEvent11");
	MakeMessageEventFor("SpecialEvent13");
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
	MakeMessageEventFor("SpecialEvent5");
}

function Server_FixCurrentMap_ONP_map39Escape()
{
	local EarthQuake EQ;

	AssignInitialState(LoadLevelMover("Mover59"), 'TriggerOpenTimed'); // disable mover

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

	MakeMessageEventFor("SpecialEvent5");
}

function Server_ModifyCurrentMap_ONP_map40Boss()
{
	MutatorPtr.SetNextLevel(MutatorPtr.PX0GameEndURL);

	if (MutatorPtr.bDiscardItemsOnGameEnd)
		Spawn(class'ONPDiscardItemsOnLevelEnd');
}

function Server_FixCurrentMap_ONP_map40Boss()
{
	AssignInitialState(LoadLevelActor("Trigger4"), 'NormalTrigger');
	Teleporter(LoadLevelActor("fadeoutTeleporter0")).URL = MutatorPtr.PX0GameEndURL;
	SetEventTriggersPawnClassProximity('pitofdeath');
}


simulated function Actor LoadLevelActor(string ActorName, optional bool bMayFail)
{
	return Actor(DynamicLoadObject(outer.name $ "." $ ActorName, class'Actor', bMayFail));
}

simulated function Mover LoadLevelMover(string ActorName)
{
	return Mover(DynamicLoadObject(outer.name $ "." $ ActorName, class'Mover'));
}

function Trigger LoadLevelTrigger(string ActorName)
{
	return Trigger(DynamicLoadObject(outer.name $ "." $ ActorName, class'Trigger'));
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

function MakeMoversTriggerableOnceOnly(name MoverTag, optional bool bProtect)
{
	local Mover m;

	foreach AllActors(class'Mover', m, MoverTag)
	{
		SetMoverTriggerableOnceOnly(m);
		if (bProtect)
			m.MoverEncroachType = ME_IgnoreWhenEncroach;
	}
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

function SetNamedTriggerPosition(
	string TriggerName,
	vector NewLocation,
	optional float NewCollisionRadius,
	optional float NewCollisionHeight)
{
	local Trigger Trigger;

	Trigger = Trigger(LoadLevelActor(TriggerName, true));
	if (Trigger != none)
	{
		Trigger.SetLocation(NewLocation);
		if (NewCollisionRadius > 0)
			Trigger.SetCollisionSize(NewCollisionRadius, Trigger.CollisionHeight);
		if (NewCollisionHeight > 0)
			Trigger.SetCollisionSize(Trigger.CollisionRadius, NewCollisionHeight);
	}
}

function AssignInitialState(Actor A, name StateName)
{
	A.InitialState = StateName;
	if (!A.IsInState(A.InitialState))
		A.GotoState(A.InitialState);
}

function FixatePlayerStarts()
{
	local PlayerStart PlayerStart;

	foreach AllActors(class'PlayerStart', PlayerStart)
		PlayerStart.Tag = '';
}

function DisablePlayerStart(string PlayerStartName)
{
	local PlayerStart PlayerStart;

	PlayerStart = PlayerStart(DynamicLoadObject(Outer.Name $ "." $ PlayerStartName, class'PlayerStart'));
	PlayerStart.bSinglePlayerStart = false;
	PlayerStart.bCoopStart = false;
}

function ReplacePlayerStart(string PlayerStartName, vector NewLocation, int NewRotationYaw, optional name NewStartTag)
{
	local PlayerStart PlayerStart, NewPlayerStart;
	local rotator NewRotation;

	PlayerStart = PlayerStart(DynamicLoadObject(Outer.Name $ "." $ PlayerStartName, class'PlayerStart'));
	if (PlayerStart != none)
	{
		if (NewStartTag == '')
			NewStartTag = PlayerStart.Tag;
		NewRotation.Yaw = NewRotationYaw;
		NewPlayerStart = Spawn(class'ONPSpawnablePlayerStart',, NewStartTag, NewLocation, NewRotation);
	}

	if (NewPlayerStart != none)
	{
		NewPlayerStart.bSinglePlayerStart = PlayerStart.bSinglePlayerStart;
		NewPlayerStart.bCoopStart = PlayerStart.bCoopStart;
		NewPlayerStart.bEnabled = PlayerStart.bEnabled;
		PlayerStart.bSinglePlayerStart = false;
		PlayerStart.bCoopStart = false;
	}
}

function DisableTeleporter(string TeleporterName)
{
	local Teleporter telep;

	telep = Teleporter(DynamicLoadObject(outer.name $ "." $ TeleporterName, class'Teleporter'));
	telep.SetCollision(false);
	telep.DrawType = DT_None;
	telep.URL = "";
}

function Teleporter SpawnTeleporterReplacement(Actor A, string URL, bool bInitiallyEnabled)
{
	local ONPSpawnableTeleporter EndTelep;

	if (A != none)
		EndTelep = A.Spawn(class'ONPSpawnableTeleporter',, A.Tag);
	if (EndTelep == none)
		return none;
	A.Tag = '';
	A.SetCollision(false);

	EndTelep.bEnabled = bInitiallyEnabled;
	EndTelep.SetCollisionSize(A.CollisionRadius, A.CollisionHeight);
	EndTelep.URL = URL;
	return EndTelep;
}

function MakeMessageEventFor(string SpecialEventName)
{
	class'ONPMessageEvent'.static.WrapSpecialEvent(SpecialEvent(LoadLevelActor(SpecialEventName)));
}

function MakeLocalMessageEventFor(string SpecialEventName)
{
	local SpecialEvent SpecialEvent;

	SpecialEvent = SpecialEvent(LoadLevelActor(SpecialEventName));
	if (SpecialEvent != none)
		SpecialEvent.bBroadcast = false;
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

function MakeDecorationUnmovableAt(string DecorationName, vector Pos)
{
	local Decoration Deco;

	Deco = Decoration(LoadLevelActor(DecorationName));
	if (Deco != none)
	{
		Deco.SetLocation(Pos);
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

function MakePermanentInventoryPointsFor(class<Inventory> InventoryClass)
{
	local Actor inv;

	foreach AllActors(InventoryClass, inv)
		if (inv.Owner == none && !Inventory(inv).bHeldItem)
			Spawn(class'ONPInventoryTrigger').AttachInventory(Inventory(inv));
}

function MakeNetVisibilityCylinderAt(name CylinderTag, string ActorName, float CylinderRadius, float CylinderHeight)
{
	MakeNetVisibilityCylinder(CylinderTag, LoadLevelActor(ActorName).Location, CylinderRadius, CylinderHeight); 
}

function MakeNetVisibilityCylinder(
	name CylinderTag,
	vector CylinderLocation,
	float CylinderRadius,
	float CylinderHeight)
{
	local ONPNetVisibilityCylinder Cylinder;

	Cylinder = Spawn(class'ONPNetVisibilityCylinder',, CylinderTag, CylinderLocation);
	if (Cylinder != none)
		Cylinder.SetCollisionSize(CylinderRadius, CylinderHeight);
}

static function bool DivideStr(string S, string Delim, out string L, out string R)
{
	local int i;

	i = InStr(S, Delim);
	if (i < 0)
		return false;
	L = Left(S, i);
	R = Mid(S, i + 1);
	return true;
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
