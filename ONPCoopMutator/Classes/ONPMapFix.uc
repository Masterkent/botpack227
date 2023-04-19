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

	P = Pawn(LoadLevelActor("SkaarjWarrior0", true));
	if (P != none)
	{
		P.GroundSpeed = P.default.GroundSpeed;
		P.JumpZ = P.default.JumpZ;
	}

	P = Pawn(LoadLevelActor("SkaarjScout1", true));
	if (P != none)
	{
		P.GroundSpeed = P.default.GroundSpeed;
		P.JumpZ = P.default.JumpZ;
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
	InterpolateSpecialEvent("SpecialEvent10");
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
	Dispatcher(LoadLevelActor("Dispatcher9")).OutEvents[1] = '';

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

	P = Pawn(LoadLevelActor("SkaarjTrooper0", true));
	if (P != none)
	{
		P.Health = P.default.Health;
		Spawn(class'ONPPhantomPawnAdjustment').ControlledPawn = P;
	}

	if (!MutatorPtr.bUseONPSpeech)
	{
		Dispatcher(LoadLevelActor("Dispatcher9")).OutDelays[1] = 0;
		Dispatcher(LoadLevelActor("Dispatcher10")).OutDelays[1] = 4;
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
	DisableTeleporter("Teleporter1");
}

function Server_FixCurrentMap_NP23Kew()
{
	DisableTeleporter("Teleporter1");
}

function Server_FixCurrentMap_NP24MClane()
{
	class'ONPTriggerStoppedMover'.static.CreateFor(Level, "Mover35");
	class'ONPTriggerStoppedMover'.static.CreateFor(Level, "Mover43");
}

function Server_FixCurrentMap_NP25DavidM()
{
	LoadLevelActor("SpecialEvent9").Tag = '';
}

function Server_FixCurrentMap_NP26DavidM()
{
	Dispatcher(LoadLevelActor("Dispatcher2")).OutEvents[2] = '';
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
	class'olextras.SuperAmmoShockRifle'.default.bTravel = false;
	class'BotPack.SuperShockCore'.default.bTravel = false;
	LoadLevelMover("Mover42").Tag = '';
	LoadLevelMover("AttachMover3").Tag = '';
	MakeMoverTriggerableOnceOnly("Mover6");
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
	SetEventTriggersPawnClassProximity('arhh');
	SetNamedTriggerPawnClassProximity("Trigger52");
}

function Server_FixCurrentMap_ONP_map02LinesofCommX()
{
	CreatureFactory(LoadLevelActor("CreatureFactory3")).prototype =
		CreatureFactory(LoadLevelActor("CreatureFactory2")).prototype;

	LoadLevelTrigger("Trigger13").bTriggerOnceOnly = true;
	LoadLevelMover("Mover24").StayOpenTime = 4.0;
	EarthQuake(LoadLevelActor("Earthquake1")).bThrowPlayer = false;
	EarthQuake(LoadLevelActor("Earthquake2")).bThrowPlayer = false;
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
	MakeMessageEventFor("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent11");
	MakeMessageEventFor("SpecialEvent14");
	MakeMessageEventFor("SpecialEvent17");
	MakeMessageEventFor("SpecialEvent25");
	MakeMessageEventFor("SpecialEvent27");
}

function Server_FixCurrentMap_ONP_map06ProcessingX()
{
	local Trigger Trigger;

	foreach AllActors(class'Trigger', Trigger)
		if (StrStartsWith(Trigger.Event, "splash", true))
			SetTriggerPawnClassProximity(Trigger);

	AssignInitialState(LoadLevelActor("Trigger58"), 'NormalTrigger');
	LoadLevelTrigger("Trigger64").bTriggerOnceOnly = true;
	MakeMessageEventFor("SpecialEvent1");
	MakeMessageEventFor("SpecialEvent5");
}

function Server_FixCurrentMap_ONP_map07PlanningX()
{
	LoadLevelMover("Mover0").StayOpenTime = 4.0;
	LoadLevelTrigger("Trigger82").bTriggerOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger23");
}

function Server_FixCurrentMap_ONP_map08DisposalX()
{
	LoadLevelTrigger("Trigger58").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger60").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger72").bTriggerOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger31");
}

function Server_FixCurrentMap_ONP_map09SurfaceX()
{
	SetNamedTriggerPawnClassProximity("Trigger6");
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;
	LoadLevelActor("Trigger23").Tag = '';
	CreatureFactory(LoadLevelActor("CreatureFactory0")).bCovert = false;
	CreatureFactory(LoadLevelActor("CreatureFactory1")).bCovert = false;
	CreatureFactory(LoadLevelActor("CreatureFactory2")).bCovert = false;
	SpawnTeleporterReplacement(LoadLevelActor("Trigger14", true), "ONP-map10AmbushX#", true).Tag = '';
}

function Server_FixCurrentMap_ONP_map10AmbushX()
{
	local ONPPlayerRelocation PlayerRelocation;

	DisablePlayerStart("PlayerStart0");

	LoadLevelActor("ThingFactory0").Tag = '';
	LoadLevelActor("ThingFactory1").Tag = '';
	LoadLevelActor("ThingFactory2").Tag = '';

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
}

function Server_FixCurrentMap_ONP_map13SignsX()
{
	LoadLevelActor("Trigger71").Tag = 'ambush';
	LoadLevelActor("SpecialEvent8").Tag = '';
	SetNamedTriggerPawnClassProximity("Trigger30");

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light43", 3000, 2000);     // WarpZoneInfo1
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "ZoneInfo2", 1000, 1000);   // WarpZoneInfo2
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode285", 6000, 6000); // WarpZoneInfo3
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "Light199", 2000, 1000);    // WarpZoneInfo4
}

function Server_FixCurrentMap_ONP_map14SoothsayerX()
{
	local Teleporter Telep;
	local ONPPawnDestructionEvent NaliDestructionEvent;
	local Counter TeleporterEnergyUp;

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
	NaliDestructionEvent.AssignPawn(Pawn(LoadLevelActor("NaliPriest0")));
	NaliDestructionEvent.Event = 'InitTeleporterEnergyUp';

	TeleporterEnergyUp = Spawn(class'Counter',, 'InitTeleporterEnergyUp');
	TeleporterEnergyUp.Event = 'energyup';
	TeleporterEnergyUp.NumToCount = 1;

	TeleporterEnergyUp = Spawn(class'Counter',, 'energyup');
	TeleporterEnergyUp.Event = 'TeleporterEnergyUp';
	TeleporterEnergyUp.NumToCount = 1;
}

function Server_FixCurrentMap_ONP_map15RevelationX()
{
	SetNamedTriggerPawnClassProximity("Trigger62");
}

function Server_FixCurrentMap_ONP_map16BoldX()
{
	SetEventTriggersPawnClassProximity('diced');
	SetEventTriggersPawnClassProximity('wasted');

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "ZoneInfo8", 1024, 256);          // WarpZoneInfo0
	MakeNetVisibilityCylinder('NetVisCylinder_1', vect(1730, 10000, -812), 256, 256); // WarpZoneInfo1
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode162", 2000, 512);        // WarpZoneInfo2
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode193", 2000, 512);        // WarpZoneInfo3
}

function Server_FixCurrentMap_ONP_map17SiteBX()
{
	DisablePlayerStart("PlayerStart0");
	DisablePlayerStart("PlayerStart7");
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
	NaliDestructionEvent.AssignPawn(Pawn(LoadLevelActor("NaliPriest0")));
	NaliDestructionEvent.Event = 'wooddoorup';

	SetNamedTriggerPawnClassProximity("Trigger11");
}

function Server_FixCurrentMap_ONP_map19IceX()
{
	LoadLevelMover("Mover120").StayOpenTime = 4;
	MakeMessageEventFor("SpecialEvent25");
	SetNamedTriggerPawnClassProximity("Trigger73");
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
	DisablePlayerStart("PlayerStart0");
	DisablePlayerStart("PlayerStart10");
	MakeMessageEventFor("SpecialEvent2");
	SetEventTriggersPawnClassProximity('wasted');
}

function Server_FixCurrentMap_ONP_map22TransferX()
{
	DisablePlayerStart("PlayerStart0");
	DisablePlayerStart("PlayerStart1");
	DisablePlayerStart("PlayerStart2");
	DisablePlayerStart("PlayerStart3");

	LoadLevelTrigger("Trigger29").bTriggerOnceOnly = true;
	LoadLevelMover("Mover56").MoverEncroachType = ME_IgnoreWhenEncroach;

	SetNamedTriggerPawnClassProximity("Trigger46");
	SetEventTriggersPawnClassProximity('chopped');
	SetEventTriggersPawnClassProximity('ohdearyoufell');
}

simulated function Client_FixCurrentMap_ONP_map22TransferX()
{
	LoadLevelMover("Mover26").bDynamicLightMover = false;
}

simulated function Client_FixCurrentMap_ONP_map26EBE()
{
	Common_FixCurrentMap_ONP_map26EBE();
}

function Server_FixCurrentMap_ONP_map23PowerPlayX()
{
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
	local Decoration SteelBox;

	DisablePlayerStart("PlayerStart0");
	MakeLocalMessageEventFor("SpecialEvent127"); // Health Regeneration
	MakeMessageEventFor("SpecialEvent128");
	MakeMessageEventFor("SpecialEvent133");

	SteelBox = Decoration(LoadLevelActor("SteelBox3"));
	SteelBox.SetLocation(vect(-10130, -8850, 0) + vect(0, 0, 1) * SteelBox.Location.Z);
	SteelBox.bPushable = false;
	SteelBox.bMovable = false;

	SteelBox = Decoration(LoadLevelActor("SteelBox4"));
	SteelBox.SetLocation(vect(-12750, -3230, 0) + vect(0, 0, 1) * SteelBox.Location.Z);
	SteelBox.bPushable = false;
	SteelBox.bMovable = false;

	SetEventTriggersPawnClassProximity('Death');
	SetEventTriggersPawnClassProximity('electric');
	SetNamedTriggerPawnClassProximity("Trigger56");

	Teleporter(LoadLevelActor("Teleporter19")).URL = MutatorPtr.PXGameEndURL;
}


function Server_FixCurrentMap_ONP_map01FirstDay()
{
	SetEventTriggersPawnClassProximity('arhh');
	SetNamedTriggerPawnClassProximity("Trigger52");
}

function Server_FixCurrentMap_ONP_map02Detour()
{
	DisableTeleporter("fadeoutTeleporter3");
}

function Server_FixCurrentMap_ONP_map04LabEntrance()
{
	LoadLevelTrigger("Trigger44").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger51").bTriggerOnceOnly = false;
	LoadLevelMover("Mover79").StayOpenTime = 4;
	SetEventTriggersPawnClassProximity('aarrhh');
	MakeLocalMessageEventFor("SpecialEvent27");
}

function Server_FixCurrentMap_ONP_map05FriendlyFire()
{
	DisableTeleporter("fadeoutTeleporter1");
	SetNamedTriggerPawnClassProximity("Trigger1");
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
	MakeMessageEventFor("SpecialEvent0");
}

function Server_FixCurrentMap_ONP_map16Dam()
{
	local Counter BlockerDoor;
	local ONPCameraSpot Cam;

	foreach AllActors(class'ONPCameraSpot', Cam, 'blockerdoor')
		Cam.Tag = 'blockerdoor_trigger';

	LoadLevelTrigger("Trigger10").Event = 'blockerdoor_trigger';
	BlockerDoor = Spawn(class'Counter',, 'blockerdoor_trigger');
	BlockerDoor.Event = 'blockerdoor';
	BlockerDoor.NumToCount = 1;
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
	MakeMessageEventFor("SpecialEvent16");
}

function Server_FixCurrentMap_ONP_map22Disposal()
{
	LoadLevelMover("Mover34").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger31");
}

function Server_FixCurrentMap_ONP_map23Newfoe()
{
	SetNamedTriggerPawnClassProximity("Trigger21");
}

function Server_FixCurrentMap_ONP_map25Communications()
{
	MakeMessageEventFor("SpecialEvent5");
	MakeMessageEventFor("SpecialEvent6");
	MakeMessageEventFor("SpecialEvent8");
}

function Server_FixCurrentMap_ONP_map26EBE()
{
	local Decoration SteelBox;

	SteelBox = Decoration(LoadLevelActor("SteelBox7"));
	SteelBox.bPushable = false;
	SteelBox.bMovable = false;

	Common_FixCurrentMap_ONP_map26EBE();

	SetNamedTriggerPawnClassProximity("Trigger0");

	MakeMessageEventFor("SpecialEvent0");
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
	LoadLevelTrigger("Trigger19").bTriggerOnceOnly = true;
	MakeMessageEventFor("SpecialEvent45");
}

function Server_FixCurrentMap_ONP_map31Dogsofwar()
{
	MakeMessageEventFor("SpecialEvent29");
}

function Server_FixCurrentMap_ONP_map35Genetics()
{
	SetEventTriggersPawnClassProximity('fallwaste');
}

function Server_FixCurrentMap_ONP_map36Birthing()
{
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
	local Mover LaserMover;

	foreach AllActors(class'Mover', LaserMover)
		if (InStr(Locs(string(LaserMover.Tag)), "laser") == 0)
			LaserMover.bNet = false;

	LoadLevelActor("SpecialEvent9").Tag = '';

	SetNamedTriggerPawnClassProximity("Trigger5");
	MakeMessageEventFor("SpecialEvent5");
}

function Server_FixCurrentMap_ONP_map39Escape()
{
	local EarthQuake EQ;

	AssignInitialState(LoadLevelMover("Mover59"), 'TriggerOpenTimed'); // disable mover

	foreach AllActors(class'EarthQuake', EQ)
		EQ.bThrowPlayer = false;

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

simulated function Mover LoadLevelMover(string MoverName)
{
	return Mover(DynamicLoadObject(outer.name $ "." $ MoverName, class'Mover'));
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

function AssignInitialState(Actor A, name StateName)
{
	A.InitialState = StateName;
	if (!A.IsInState(A.InitialState))
		A.GotoState(A.InitialState);
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
