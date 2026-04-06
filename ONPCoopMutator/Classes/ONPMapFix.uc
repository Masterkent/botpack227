class ONPMapFix expands Info;

#exec obj load file="Botpack.u"

var bool bModifiedServerSide, bModifiedClientSide;
var ONPCoopMutator MutatorPtr;
var string CurrentMap;
var string CurrentMapGUID;
var bool bApplyMapFixes;

replication
{
	reliable if (Role == ROLE_Authority)
		bApplyMapFixes,
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
	{
		bApplyMapFixes = Server_FixCurrentMap();
		if (bApplyMapFixes)
			Log("ONPCoopMutator applied server-side map fixes:" @ CurrentMap);
	}
}

simulated function PostNetBeginPlay()
{
	if (!bModifiedClientSide)
	{
		Client_FixCurrentMap();
		bModifiedClientSide = true;
	}
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

function bool Server_FixCurrentMap()
{
	if (Left(CurrentMap, 2) ~= "NP") // Operation Na Pali
		return Server_FixCurrentMap_ONP();
	if (Left(CurrentMap, 7) ~= "ONP-map") // Xenome
		return Server_FixCurrentMap_Xenome();
	return false;
}

function bool Server_FixCurrentMap_ONP()
{
	if (!MutatorPtr.bFixCampaign_ONP)
		return false;

	if (CurrentMap ~= "NP02DavidM")
		return Server_FixCurrentMap_NP02DavidM();
	if (CurrentMap ~= "NP04Hyperion")
		return Server_FixCurrentMap_NP04Hyperion();
	if (CurrentMap ~= "NP05Heiko")
		return Server_FixCurrentMap_NP05Heiko();
	if (CurrentMap ~= "NP06Heiko")
		return Server_FixCurrentMap_NP06Heiko();
	if (CurrentMap ~= "NP08Hourences")
		return Server_FixCurrentMap_NP08Hourences();
	if (CurrentMap ~= "NP09Silver")
		return Server_FixCurrentMap_NP09Silver();
	if (CurrentMap ~= "NP11Tonnberry")
		return Server_FixCurrentMap_NP11Tonnberry();
	if (CurrentMap ~= "NP12Tonnberry")
		return Server_FixCurrentMap_NP12Tonnberry();
	if (CurrentMap ~= "NP13DrPest")
		return Server_FixCurrentMap_NP13DrPest();
	if (CurrentMap ~= "NP14MClaneDrPest")
		return Server_FixCurrentMap_NP14MClaneDrPest();
	if (CurrentMap ~= "NP15Chico")
		return Server_FixCurrentMap_NP15Chico();
	if (CurrentMap ~= "NP16Chico")
		return Server_FixCurrentMap_NP16Chico();
	if (CurrentMap ~= "NP17Chico")
		return Server_FixCurrentMap_NP17Chico();
	if (CurrentMap ~= "NP18Chico")
		return Server_FixCurrentMap_NP18Chico();
	if (CurrentMap ~= "NP19Part1Chico")
		return Server_FixCurrentMap_NP19Part1Chico();
	if (CurrentMap ~= "NP19Part2Chico")
		return Server_FixCurrentMap_NP19Part2Chico();
	if (CurrentMap ~= "NP19Part3ChicoHour")
		return Server_FixCurrentMap_NP19Part3ChicoHour();
	if (CurrentMap ~= "NP22DavidM")
		return Server_FixCurrentMap_NP22DavidM();
	if (CurrentMap ~= "NP23Kew")
		return Server_FixCurrentMap_NP23Kew();
	if (CurrentMap ~= "NP24MClane")
		return Server_FixCurrentMap_NP24MClane();
	if (CurrentMap ~= "NP25DavidM")
		return Server_FixCurrentMap_NP25DavidM();
	if (CurrentMap ~= "NP26DavidM")
		return Server_FixCurrentMap_NP26DavidM();
	if (CurrentMap ~= "NP27DavidM")
		return Server_FixCurrentMap_NP27DavidM();
	if (CurrentMap ~= "NP29DavidM")
		return Server_FixCurrentMap_NP29DavidM();
	if (CurrentMap ~= "NP31DavidM")
		return Server_FixCurrentMap_NP31DavidM();
	if (CurrentMap ~= "NP32Strogg")
		return Server_FixCurrentMap_NP32Strogg();
	if (CurrentMap ~= "NP33Atje")
		return Server_FixCurrentMap_NP33Atje();
	if (CurrentMap ~= "NP34Atje")
		return Server_FixCurrentMap_NP34Atje();
	if (CurrentMap ~= "NP35MClane")
		return Server_FixCurrentMap_NP35MClane();
	return false;
}

function bool Server_FixCurrentMap_Xenome()
{
	CurrentMapGUID = GetCurrentMapGUID();

	if (MutatorPtr.bFixCampaign_PX1)
	{
		if (CurrentMap ~= "ONP-map01FirstDay")
			return Server_FixCurrentMap_ONP_map01FirstDay();
		if (CurrentMap ~= "ONP-map02Detour")
			return Server_FixCurrentMap_ONP_map02Detour();
		if (CurrentMap ~= "ONP-map03Watchyourstep")
			return Server_FixCurrentMap_ONP_map03Watchyourstep();
		if (CurrentMap ~= "ONP-map04LabEntrance")
			return Server_FixCurrentMap_ONP_map04LabEntrance();
		if (CurrentMap ~= "ONP-map05FriendlyFire")
			return Server_FixCurrentMap_ONP_map05FriendlyFire();
		if (CurrentMap ~= "ONP-map06PowerPlay")
			return Server_FixCurrentMap_ONP_map06PowerPlay();
		if (CurrentMap ~= "ONP-map07Questionableethics")
			return Server_FixCurrentMap_ONP_map07Questionableethics();
		if (CurrentMap ~= "ONP-map09ComplexSituation")
			return Server_FixCurrentMap_ONP_map09ComplexSituation();
		if (CurrentMap ~= "ONP-map10SourWater")
			return Server_FixCurrentMap_ONP_map10SourWater();
		if (CurrentMap ~= "ONP-map11Admin")
			return Server_FixCurrentMap_ONP_map11Admin();
		if (CurrentMap ~= "ONP-map12Monorail")
			return Server_FixCurrentMap_ONP_map12Monorail();
		if (CurrentMap ~= "ONP-map13Processing")
			return Server_FixCurrentMap_ONP_map13Processing();
		if (CurrentMap ~= "ONP-map14Mine")
			return Server_FixCurrentMap_ONP_map14Mine();
		if (CurrentMap ~= "ONP-map15CrossCountry")
			return Server_FixCurrentMap_ONP_map15CrossCountry();
		if (CurrentMap ~= "ONP-map16Dam")
			return Server_FixCurrentMap_ONP_map16Dam();
		if (CurrentMap ~= "ONP-map17watersport")
			return Server_FixCurrentMap_ONP_map17watersport();
		if (CurrentMap ~= "ONP-map19Teleporter")
			return Server_FixCurrentMap_ONP_map19Teleporter();
		if (CurrentMap ~= "ONP-map20Interloper")
			return Server_FixCurrentMap_ONP_map20Interloper();
		if (CurrentMap ~= "ONP-map21Welcome")
			return Server_FixCurrentMap_ONP_map21Welcome();
		if (CurrentMap ~= "ONP-map22Disposal")
			return Server_FixCurrentMap_ONP_map22Disposal();
		if (CurrentMap ~= "ONP-map23Newfoe")
			return Server_FixCurrentMap_ONP_map23Newfoe();
		if (CurrentMap ~= "ONP-map24Agenda")
			return Server_FixCurrentMap_ONP_map24Agenda();
		if (CurrentMap ~= "ONP-map25Communications")
			return Server_FixCurrentMap_ONP_map25Communications();
		if (CurrentMap ~= "ONP-map26EBE")
			return Server_FixCurrentMap_ONP_map26EBE();
		if (CurrentMap ~= "ONP-map27Entrance")
			return Server_FixCurrentMap_ONP_map27Entrance();
		if (CurrentMap ~= "ONP-map28Bellyofthebeast")
			return Server_FixCurrentMap_ONP_map28Bellyofthebeast();
		if (CurrentMap ~= "ONP-map30Ruins")
			return Server_FixCurrentMap_ONP_map30Ruins();
		if (CurrentMap ~= "ONP-map31Dogsofwar")
			return Server_FixCurrentMap_ONP_map31Dogsofwar();
		if (CurrentMap ~= "ONP-map32Gauntlet")
			return Server_FixCurrentMap_ONP_map32Gauntlet();
		if (CurrentMap ~= "ONP-map35Genetics")
			return Server_FixCurrentMap_ONP_map35Genetics();
		if (CurrentMap ~= "ONP-map36Birthing")
			return Server_FixCurrentMap_ONP_map36Birthing();
		if (CurrentMap ~= "ONP-map37Halted")
			return Server_FixCurrentMap_ONP_map37Halted();
		if (CurrentMap ~= "ONP-map38Tothecore")
			return Server_FixCurrentMap_ONP_map38Tothecore();
		if (CurrentMap ~= "ONP-map39Escape")
			return Server_FixCurrentMap_ONP_map39Escape();
		if (CurrentMap ~= "ONP-map40Boss")
			return Server_FixCurrentMap_ONP_map40Boss();
	}

	if (MutatorPtr.bFixCampaign_PX2)
	{
		if (CurrentMap ~= "ONP-map01FirstDayX")
			return Server_FixCurrentMap_ONP_map01FirstDayX();
		if (CurrentMap ~= "ONP-map02LinesofCommX")
			return Server_FixCurrentMap_ONP_map02LinesofCommX();
		if (CurrentMap ~= "ONP-map03oppressivemetalX")
			return Server_FixCurrentMap_ONP_map03oppressivemetalX();
		if (CurrentMap ~= "ONP-map04StaticX")
			return Server_FixCurrentMap_ONP_map04StaticX();
		if (CurrentMap ~= "ONP-map05SourWaterX")
			return Server_FixCurrentMap_ONP_map05SourWaterX();
		if (CurrentMap ~= "ONP-map06ProcessingX")
			return Server_FixCurrentMap_ONP_map06ProcessingX();
		if (CurrentMap ~= "ONP-map07PlanningX")
			return Server_FixCurrentMap_ONP_map07PlanningX();
		if (CurrentMap ~= "ONP-map08DisposalX")
			return Server_FixCurrentMap_ONP_map08DisposalX();
		if (CurrentMap ~= "ONP-map09SurfaceX")
			return Server_FixCurrentMap_ONP_map09SurfaceX();
		if (CurrentMap ~= "ONP-map10AmbushX")
			return Server_FixCurrentMap_ONP_map10AmbushX();
		if (CurrentMap ~= "ONP-map11CobaltX")
			return Server_FixCurrentMap_ONP_map11CobaltX();
		if (CurrentMap ~= "ONP-map12DamX")
			return Server_FixCurrentMap_ONP_map12DamX();
		if (CurrentMap ~= "ONP-map13SignsX")
			return Server_FixCurrentMap_ONP_map13SignsX();
		if (CurrentMap ~= "ONP-map14SoothsayerX")
			return Server_FixCurrentMap_ONP_map14SoothsayerX();
		if (CurrentMap ~= "ONP-map15RevelationX")
			return Server_FixCurrentMap_ONP_map15RevelationX();
		if (CurrentMap ~= "ONP-map16BoldX")
			return Server_FixCurrentMap_ONP_map16BoldX();
		if (CurrentMap ~= "ONP-map17SiteBX")
			return Server_FixCurrentMap_ONP_map17SiteBX();
		if (CurrentMap ~= "ONP-map18FriendX")
			return Server_FixCurrentMap_ONP_map18FriendX();
		if (CurrentMap ~= "ONP-map19IceX")
			return Server_FixCurrentMap_ONP_map19IceX();
		if (CurrentMap ~= "ONP-map20InterloperX")
			return Server_FixCurrentMap_ONP_map20InterloperX();
		if (CurrentMap ~= "ONP-map21NestX")
			return Server_FixCurrentMap_ONP_map21NestX();
		if (CurrentMap ~= "ONP-map22TransferX")
			return Server_FixCurrentMap_ONP_map22TransferX();
		if (CurrentMap ~= "ONP-map23PowerPlayX")
			return Server_FixCurrentMap_ONP_map23PowerPlayX();
		if (CurrentMap ~= "ONP-map24CoreX")
			return Server_FixCurrentMap_ONP_map24CoreX();
	}

	return false;
}

simulated function Client_FixCurrentMap()
{
	FixLightEffects();

	if (bApplyMapFixes)
		Log("ONPCoopMutator applied server-side map fixes:" @ CurrentMap);
	else
		return;

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
	else
		return;
	Log("ONPCoopMutator applied client-side map fixes:" @ CurrentMap);
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

function bool Server_FixCurrentMap_NP02DavidM()
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

	return true;
}

function bool Server_FixCurrentMap_NP04Hyperion()
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

	return true;
}

function bool Server_FixCurrentMap_NP05Heiko()
{
	LoadLevelTrigger("Trigger29").TriggerType = TT_PlayerProximity;

	// Eliminate flying tree (invisible in UT, visible in Unreal 227)
	EliminateStaticActor("Tree3");

	// Prevent falling damage
	LoadLevelActor("Light150").Region.Zone.ZoneTerminalVelocity = 980;

	return true;
}

simulated function bool Client_FixCurrentMap_NP05Heiko()
{
	// Eliminate flying tree (invisible in UT, visible in Unreal 227)
	// Needs both server-side and client-side modifications
	EliminateStaticActor("Tree3");

	return true;
}

function Server_ModifyCurrentMap_NP06Heiko()
{
	FixNPCNetFilter();
	if (!MutatorPtr.bUseONPSpeech)
		LoadLevelActor("SpecialEvent5").Tag = '';
}

function bool Server_FixCurrentMap_NP06Heiko()
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

	return true;
}

function bool Server_FixCurrentMap_NP08Hourences()
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

	return true;
}

function bool Server_FixCurrentMap_NP09Silver()
{
	LoadLevelDispatcher("Dispatcher4").OutEvents[4] = '';
	LoadLevelMover("Mover7").MoverEncroachType = ME_IgnoreWhenEncroach; // ME_CrushWhenEncroach may kill the Titan

	// allows players to reuse the lift
	LoadLevelMover("Mover1").bTriggerOnceOnly = false;
	LoadLevelTrigger("Trigger5").bTriggerOnceOnly = false;

	// prevents client-side glitch
	LoadLevelMover("Mover8").Tag = '';

	EliminateStaticActor("BlockAll10");

	return true;
}

simulated function bool Client_FixCurrentMap_NP09Silver()
{
	EliminateStaticActor("BlockAll10");

	return true;
}

function Server_ModifyCurrentMap_NP11Tonnberry()
{
	if (MutatorPtr.bInfiniteSpecialItems)
		MakePermanentInventoryPointsFor(class'ToxinSuit');
}

function bool Server_FixCurrentMap_NP11Tonnberry()
{
	local Mover m;

	m = LoadLevelMover("Mover6");
	m.PlayerBumpEvent = m.Tag;

	return true;
}

function bool Server_FixCurrentMap_NP12Tonnberry()
{
	LoadLevelMover("Mover159").InitialState = 'TriggerOpenTimed';
	LoadLevelActor("Dispatcher15").Tag = '';

	return true;
}

function bool Server_FixCurrentMap_NP13DrPest()
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

	return true;
}

simulated function bool Client_FixCurrentMap_NP13DrPest()
{
	local Texture Texture;

	Texture = Texture(DynamicLoadObject(Outer.Name $ "." $ "geilekabelkurz", class'Texture', true));
	if (Texture != none)
		Texture.bTransparent = true;
	Texture = Texture(DynamicLoadObject(Outer.Name $ "." $ "geilekabellang", class'Texture', true));
	if (Texture != none)
		Texture.bTransparent = true;

	return true;
}

function bool Server_FixCurrentMap_NP14MClaneDrPest()
{
	local Pawn P;

	LoadLevelActor("PlayerStart0").Tag = 'sp1';

	P = LoadLevelPawn("NaliTrooper1");
	if (P != none)
		Spawn(class'ONPPhantomPawnAdjustment').ControlledPawn = P;

	return true;
}

function bool Server_FixCurrentMap_NP15Chico()
{
	LoadLevelTrigger("Trigger112").bTriggerOnceOnly = true;

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light150", 2000, 1000);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light187", 4000, 3000);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode44", 1000, 800);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode255", 3000, 1500);

	return true;
}

function bool Server_FixCurrentMap_NP16Chico()
{
	ZoneInfo(LoadLevelActor("ZoneInfo0")).ZoneVelocity = vect(0, 0, 0);

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode533", 1000, 250);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode545", 2000, 1500);

	return true;
}

function bool Server_FixCurrentMap_NP17Chico()
{
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode293", 1500, 600);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode304", 3000, 2000);

	return true;
}

function bool Server_FixCurrentMap_NP18Chico()
{
	LoadLevelMover("Mover27").Event = '';

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode416", 3000, 3000);
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "PathNode426", 3000, 300);
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode2", 1200, 600);
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode61", 1000, 400);
	MakeNetVisibilityCylinderAt('NetVisCylinder_3', "PathNode49", 1500, 400);
	MakeNetVisibilityCylinderAt('NetVisCylinder_3', "PathNode81", 3000, 1200);

	return true;
}

function bool Server_FixCurrentMap_NP19Part1Chico()
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

	return true;
}

function Server_ModifyCurrentMap_NP19Part2Chico()
{
	if (!MutatorPtr.bUseAircraftLevels)
		MutatorPtr.SetNextLevel("NP20DavidM");
}

function bool Server_FixCurrentMap_NP19Part2Chico()
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

	return true;
}

function bool Server_FixCurrentMap_NP19Part3ChicoHour()
{
	DisablePlayerStart("PlayerStart2");
	DisablePlayerStart("PlayerStart3");
	DisablePlayerStart("PlayerStart4");
	LoadLevelTrigger("Trigger22").TriggerType = TT_PlayerProximity;
	MakeMoversTriggerableOnceOnly('tunneld3', true);
	MakeMoversTriggerableOnceOnly('tunneld6', true);
	MakeMoversTriggerableOnceOnly('multidoor3ofzo', true);
	MakeMoversTriggerableOnceOnly('blaaaaahmultimoverzoveel', true);

	return true;
}

function Server_ModifyCurrentMap_NP21Atje()
{
	if (MutatorPtr.bInfiniteSpecialItems)
		MakePermanentInventoryPointsFor(class'AsbestosSuit');
}

function bool Server_FixCurrentMap_NP22DavidM()
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

	return true;
}

function bool Server_FixCurrentMap_NP23Kew()
{
	local ONPBlockAllPanel BlockAll;

	DisableTeleporter("Teleporter1");
	BlockAll = Spawn(class'ONPBlockAllPanel',,, vect(-1511, -994, -935), rot(-3500, 29152, 0));
	BlockAll.Skin = Texture(DynamicLoadObject("DavidMGras.Ground1", class'Texture', true)); // for footstep sounds
	BlockAll.SetScale(8);

	return true;
}

function bool Server_FixCurrentMap_NP24MClane()
{
	SetEventTriggersPawnClassProximity('autsch');
	class'ONPTriggerStoppedMover'.static.CreateFor(Level, "Mover35");
	class'ONPTriggerStoppedMover'.static.CreateFor(Level, "Mover43");

	return true;
}

function bool Server_FixCurrentMap_NP25DavidM()
{
	LoadLevelActor("SpecialEvent9").Tag = '';

	return true;
}

function bool Server_FixCurrentMap_NP26DavidM()
{
	LoadLevelDispatcher("Dispatcher2").OutEvents[2] = '';
	LoadLevelActor("DispatcherPlus0").Tag = '';
	LoadLevelActor("Teleporter3").SetCollisionSize(60, 2048);

	DisableTeleporter("Teleporter4"); // disable singleplayer teleporter
	LoadLevelMover("Mover25").Tag = ''; // prevents the exit teleporter from being hidden from players

	return true;
}

function bool Server_FixCurrentMap_NP27DavidM()
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

	return true;
}

function bool Server_FixCurrentMap_NP29DavidM()
{
	// disable useless teleporter
	DisableTeleporter("Teleporter6");

	return true;
}

function bool Server_FixCurrentMap_NP31DavidM()
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

	return true;
}

function bool Server_FixCurrentMap_NP32Strogg()
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

	return true;
}

function bool Server_FixCurrentMap_NP33Atje()
{
	LoadLevelActor("PlayerStart1").Tag = 'sp1';
	LoadLevelActor("PlayerStart2").Tag = 'sp1';
	LoadLevelActor("PlayerStart3").Tag = 'sp1';
	LoadLevelActor("PlayerStart4").Tag = 'sp1';

	MakeMoverTriggerableOnceOnly("Mover8");
	MakeMoverTriggerableOnceOnly("Mover9");

	return true;
}

function bool Server_FixCurrentMap_NP34Atje()
{
	DisablePlayerStart("PlayerStart0");
	LoadLevelTrigger("Trigger24").Event = '';

	return true;
}

function Server_ModifyCurrentMap_NP35MClane()
{
	MutatorPtr.SetNextLevel(MutatorPtr.ONPGameEndURL);

	if (MutatorPtr.bDiscardItemsOnGameEnd)
		Spawn(class'ONPDiscardItemsOnLevelEnd');
}

function bool Server_FixCurrentMap_NP35MClane()
{
	SpawnTeleporterReplacement(LoadLevelActor("ONPEndMark2"), MutatorPtr.ONPGameEndURL, false);

	return true;
}


function bool Server_FixCurrentMap_ONP_map01FirstDay()
{
	SetEventTriggersPawnClassProximity('arhh');
	SetNamedTriggerPawnClassProximity("Trigger52");

	return true;
}

function bool Server_FixCurrentMap_ONP_map02Detour()
{
	DisableTeleporter("fadeoutTeleporter3");
	LoadLevelMover("Mover0").MoveTime = 1.0;
	MakeFallingMoverController("Mover1");

	return true;
}

function bool Server_FixCurrentMap_ONP_map03Watchyourstep()
{
	MakeFallingMoverController("Mover6");
	MakeDecorationUnmovable("SmallSteelBox4");

	return true;
}

function bool Server_FixCurrentMap_ONP_map04LabEntrance()
{
	LoadLevelTrigger("Trigger44").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger51").bTriggerOnceOnly = false;
	LoadLevelTrigger("Trigger63").bTriggerOnceOnly = true; // MusicEvent3
	LoadLevelMover("Mover79").StayOpenTime = 4;
	SetEventTriggersPawnClassProximity('aarrhh');
	MakeFallingMoverController("Mover50");
	MakeFallingMoverController("Mover51");
	MakeLocalMessageEventFor("SpecialEvent27");

	return true;
}

function bool Server_FixCurrentMap_ONP_map05FriendlyFire()
{
	DisableTeleporter("fadeoutTeleporter1");
	SetNamedTriggerPawnClassProximity("Trigger1");
	MakeFallingMoverController("Mover79");

	MakeMessageEventFor("SpecialEvent27");
	MakeLocalMessageEventFor("SpecialEvent39");

	return true;
}

function bool Server_FixCurrentMap_ONP_map06PowerPlay()
{
	SetEventTriggersPawnClassProximity('ouch');
	MakeLocalMessageEventFor("SpecialEvent5");

	return true;
}

function bool Server_FixCurrentMap_ONP_map07Questionableethics()
{
	SetEventTriggersPawnClassProximity('aarrhh');
	MakeLocalMessageEventFor("SpecialEvent5");
	MakeLocalMessageEventFor("SpecialEvent7");

	return true;
}

function bool Server_FixCurrentMap_ONP_map09ComplexSituation()
{
	SetEventTriggersPawnClassProximity('aarrhh');
	LoadLevelMusicEvent("MusicEvent2").bOnceOnly = true;

	MakeMessageEventFor("SpecialEvent5");
	MakeMessageEventFor("SpecialEvent7");
	MakeMessageEventFor("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent11");
	MakeMessageEventFor("SpecialEvent14");
	MakeMessageEventFor("SpecialEvent17");

	return true;
}

function bool Server_FixCurrentMap_ONP_map10SourWater()
{
	MakeLocalMessageEventFor("SpecialEvent5");

	return true;
}

function bool Server_FixCurrentMap_ONP_map11Admin()
{
	MakeMessageEventFor("SpecialEvent43");
	MutatorPtr.SetNextLevel("ONP-map13Processing");

	return true;
}

function bool Server_FixCurrentMap_ONP_map12Monorail()
{
	local Trigger Tr;

	foreach AllActors(class'Trigger', Tr)
		if (StrStartsWith(Tr.Event, "open", true))
			Tr.bTriggerOnceOnly = false;

	return true;
}

function bool Server_FixCurrentMap_ONP_map13Processing()
{
	SetNamedTriggerPawnClassProximity("Trigger29");
	MakeMessageEventFor("SpecialEvent2");

	return true;
}

function bool Server_FixCurrentMap_ONP_map14Mine()
{
	LoadLevelMover("Mover1").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger2");
	SetNamedTriggerPawnClassProximity("Trigger16");
	InterpolateSpecialEvent("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent45");

	return true;
}

function bool Server_FixCurrentMap_ONP_map15CrossCountry()
{
	LoadLevelTrigger("Trigger6").bTriggerOnceOnly = true; // MusicEvent0
	MakeMessageEventFor("SpecialEvent0");

	return true;
}

function bool Server_FixCurrentMap_ONP_map16Dam()
{
	local ONPCameraSpot Cam;

	foreach AllActors(class'ONPCameraSpot', Cam, 'blockerdoor')
		Cam.Tag = 'blockerdoor_trigger';

	LoadLevelTrigger("Trigger10").Event = 'blockerdoor_trigger';
	EventToEvent('blockerdoor_trigger', 'blockerdoor', true);

	return true;
}

function bool Server_FixCurrentMap_ONP_map17watersport()
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

	return true;
}

function bool Server_FixCurrentMap_ONP_map19Teleporter()
{
	LoadLevelTrigger("Trigger32").bTriggerOnceOnly = true;
	SetEventTriggersPawnClassProximity('killkill');
	SetEventTriggersPawnClassProximity('killkill2');
	MakeFallingMoverController("Mover0");

	MakeMessageEventFor("SpecialEvent13");
	MakeMessageEventFor("SpecialEvent16");
	MakeMessageEventFor("SpecialEvent22");

	return true;
}

function bool Server_FixCurrentMap_ONP_map20Interloper()
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

	return true;
}

function bool Server_FixCurrentMap_ONP_map21Welcome()
{
	LoadLevelMover("Mover0").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger23");
	MakeFallingMoverController("Mover65");
	MakeMessageEventFor("SpecialEvent16");

	return true;
}

function bool Server_FixCurrentMap_ONP_map22Disposal()
{
	local Trigger Trigger;

	LoadLevelMover("Mover34").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger31");

	MakeEventRepeater('gloop', 1.0);
	foreach AllActors(class'Trigger', Trigger)
		if (Trigger.Event == 'gloop')
			Trigger.RepeatTriggerTime = 0;

	return true;
}

function bool Server_FixCurrentMap_ONP_map23Newfoe()
{
	LoadLevelMusicEvent("MusicEvent0").bOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent2").bOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger21");

	return true;
}

function bool Server_FixCurrentMap_ONP_map24Agenda()
{
	LoadLevelMusicEvent("MusicEvent0").bOnceOnly = true;

	return true;
}

function bool Server_FixCurrentMap_ONP_map25Communications()
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

	return true;
}

function bool Server_FixCurrentMap_ONP_map26EBE()
{
	MakeDecorationUnmovable("SteelBox7");

	Common_FixCurrentMap_ONP_map26EBE();

	SetNamedTriggerPawnClassProximity("Trigger0");

	MakeMessageEventFor("SpecialEvent0");

	return true;
}

simulated function bool Client_FixCurrentMap_ONP_map26EBE()
{
	Common_FixCurrentMap_ONP_map26EBE();

	return true;
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

function bool Server_FixCurrentMap_ONP_map27Entrance()
{
	SetEventTriggersPawnClassProximity('burnbaby');

	return true;
}

function bool Server_FixCurrentMap_ONP_map28Bellyofthebeast()
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

	return true;
}

function bool Server_FixCurrentMap_ONP_map30Ruins()
{
	local ONPSurfaceDamageTrigger DamageTrigger;

	LoadLevelActor("SpecialEvent2").Tag = '';
	DamageTrigger = Spawn(class'ONPSurfaceDamageTrigger',, 'lavakill');
	DamageTrigger.TextureName = 'Lava1';
	DamageTrigger.DamagePerSec = 50;
	DamageTrigger.DamageType = 'Burned';

	LoadLevelTrigger("Trigger19").bTriggerOnceOnly = true;
	MakeMessageEventFor("SpecialEvent45");

	return true;
}

function bool Server_FixCurrentMap_ONP_map31Dogsofwar()
{
	LoadLevelTrigger("Trigger2").bTriggerOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent1").bOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent3").bOnceOnly = true;
	MakeMessageEventFor("SpecialEvent29");

	return true;
}

function bool Server_FixCurrentMap_ONP_map32Gauntlet()
{
	MakeFallingMoverController("Mover0");

	return true;
}

function bool Server_FixCurrentMap_ONP_map35Genetics()
{
	SetEventTriggersPawnClassProximity('fallwaste');
	MakeFallingMoverController("Mover0");

	return true;
}

function bool Server_FixCurrentMap_ONP_map36Birthing()
{
	LoadLevelMusicEvent("MusicEvent2").bOnceOnly = true;
	SetEventTriggersPawnClassProximity('Death');
	SetNamedTriggerPawnClassProximity("Trigger11");
	MakeMessageEventFor("SpecialEvent5");

	return true;
}

function bool Server_FixCurrentMap_ONP_map37Halted()
{
	SetNamedTriggerPawnClassProximity("Trigger14");
	MakeMessageEventFor("SpecialEvent11");
	MakeMessageEventFor("SpecialEvent13");

	return true;
}

function bool Server_FixCurrentMap_ONP_map38Tothecore()
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

	return true;
}

function bool Server_FixCurrentMap_ONP_map39Escape()
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

	return true;
}

function Server_ModifyCurrentMap_ONP_map40Boss()
{
	MutatorPtr.SetNextLevel(MutatorPtr.PX0GameEndURL);

	if (MutatorPtr.bDiscardItemsOnGameEnd)
		Spawn(class'ONPDiscardItemsOnLevelEnd');
}

function bool Server_FixCurrentMap_ONP_map40Boss()
{
	AssignInitialState(LoadLevelActor("Trigger4"), 'NormalTrigger');
	Teleporter(LoadLevelActor("fadeoutTeleporter0")).URL = MutatorPtr.PX0GameEndURL;
	SetEventTriggersPawnClassProximity('pitofdeath');

	return true;
}


function bool Server_FixCurrentMap_ONP_map01FirstDayX()
{
	if (CurrentMapGUID != "FE2B8F0A4D37F886262C339DF583FC7E" && CurrentMapGUID != "FDA5C4D4478A990A9E846BA610AC4F4F")
		return false;
	LoadLevelActor("Trigger12").Tag = '';
	MakeFallingMoverController("Mover6");
	MakeFallingMoverController("Mover41");
	SetEventTriggersPawnClassProximity('arhh');
	SetNamedTriggerPawnClassProximity("Trigger52");

	return true;
}

function bool Server_FixCurrentMap_ONP_map02LinesofCommX()
{
	if (CurrentMapGUID != "A535A8AD4E4DB0B7823776BCF5BECE0D" && CurrentMapGUID != "38373B8745DF6728864BF98DEE472879")
		return false;

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map03oppressivemetalX()
{
	if (CurrentMapGUID != "80A1C89C44245A7ABA561E9094F46A9B" && CurrentMapGUID != "05B0AB4346791538A3AF24A13C70BF5C")
		return false;

	SetNamedTriggerPawnClassProximity("Trigger4");
	SetNamedTriggerPawnClassProximity("Trigger8");
	SetNamedTriggerPawnClassProximity("Trigger47");
	SetEventTriggersPawnClassProximity('felldoom');

	return true;
}

function bool Server_FixCurrentMap_ONP_map04StaticX()
{
	local Actor Dispatcher;

	if (CurrentMapGUID != "C74FF7C44D623196D2518EA10B071167" && CurrentMapGUID != "8C0FD67B419D9CF8F105DF951FFEC49D")
		return false;

	Dispatcher = LoadLevelActor("Dispatcher7", true);
	if (Dispatcher != none)
		Dispatcher.Tag = ''; // PlayerStart8 -> PlayerStart9
	MakeMessageEventFor("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent11");
	MakeMessageEventFor("SpecialEvent14");
	MakeMessageEventFor("SpecialEvent17");
	MakeMessageEventFor("SpecialEvent25");
	MakeMessageEventFor("SpecialEvent27");

	return true;
}

function bool Server_FixCurrentMap_ONP_map05SourWaterX()
{
	if (CurrentMapGUID != "214CF63D4140C5A5F34D98ABB497B810" && CurrentMapGUID != "9905324C4235A2F028F9539BFECF35EE")
		return false;

	SetNamedTriggerPosition("Trigger55", vect(-2335, -325, -80), 256); // PlayerStart6 -> PlayerStart7

	return true;
}

function bool Server_FixCurrentMap_ONP_map06ProcessingX()
{
	local Trigger Trigger;

	if (CurrentMapGUID != "FB988867435548523BBF1F99CA71AA7B" && CurrentMapGUID != "E99535CE4BC88E37FF61E39B350944E4")
		return false;

	foreach AllActors(class'Trigger', Trigger)
		if (StrStartsWith(Trigger.Event, "splash", true))
			SetTriggerPawnClassProximity(Trigger);

	AssignInitialState(LoadLevelActor("Trigger58"), 'NormalTrigger');
	LoadLevelTrigger("Trigger64").bTriggerOnceOnly = true;
	SetTriggerPawnClassProximity(LoadLevelTrigger("Trigger5"));

	MakeMessageEventFor("SpecialEvent1");
	MakeMessageEventFor("SpecialEvent5");

	return true;
}

function bool Server_FixCurrentMap_ONP_map07PlanningX()
{
	if (CurrentMapGUID != "59A4816B4A4FDB513A64199B11F1DA3C" && CurrentMapGUID != "77D0702F4A5C4B361BCBA799D64FB579")
		return false;

	LoadLevelMover("Mover0").StayOpenTime = 4.0;
	LoadLevelTrigger("Trigger82").bTriggerOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger23");
	MakeFallingMoverController("Mover65");
	MakeFallingMoverController("Mover83");
	MakeFallingMoverController("Mover98");

	return true;
}

function bool Server_FixCurrentMap_ONP_map08DisposalX()
{
	local Trigger Trigger;

	if (CurrentMapGUID != "BBCF815044BF4EE9442356AFC7369016" && CurrentMapGUID != "5CD9805A4271E4C5C00CFFB87F8254DE")
		return false;

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map09SurfaceX()
{
	local TeamCannon Cannon;

	if (CurrentMapGUID != "6E2E4CF745755C6AE0243AB880A4B18A" &&
		CurrentMapGUID != "561236C34F338407E657AB8F831577F3" &&
		CurrentMapGUID != "3FAC633048F58AEFD50E73A56FEAAF53")
	{
		return false;
	}

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map10AmbushX()
{
	local Mover Mover;
	local ONPPlayerRelocation PlayerRelocation;

	if (CurrentMapGUID != "9FCDA97143AB11356A7CD2AB57A8B429")
		return false;

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map11CobaltX()
{
	if (CurrentMapGUID != "B61CD5D54E60CF72D9E495BAEBFD9374")
		return false;

	LoadLevelTrigger("Trigger8").bTriggerOnceOnly = true;

	MakeMessageEventFor("SpecialEvent10");
	MakeMessageEventFor("SpecialEvent30");
	MakeMessageEventFor("SpecialEvent56");
	MakeMessageEventFor("SpecialEvent58");
	MakeMessageEventFor("SpecialEvent69");
	MakeMessageEventFor("SpecialEvent87");

	return true;
}

function bool Server_FixCurrentMap_ONP_map12DamX()
{
	if (CurrentMapGUID != "E053772E41AF1FDA1E026F9F4F83ABBA")
		return false;

	SetEventTriggersPawnClassProximity('choppedup');
	MakeMessageEventFor("SpecialEvent30");

	FixatePlayerStarts();

	return true;
}

function bool Server_FixCurrentMap_ONP_map13SignsX()
{
	if (CurrentMapGUID != "FDCE00284C9CB54CCD161F8A30523EA5")
		return false;

	LoadLevelActor("Trigger71").Tag = 'ambush';
	LoadLevelActor("SpecialEvent8").Tag = '';
	SetNamedTriggerPawnClassProximity("Trigger30");

	LoadLevelTrigger("Trigger11").bTriggerOnceOnly = true; // MusicEvent5

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light43", 3000, 2000);     // WarpZoneInfo1
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "ZoneInfo2", 1000, 1000);   // WarpZoneInfo2
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "PathNode285", 6000, 6000); // WarpZoneInfo3
	MakeNetVisibilityCylinderAt('NetVisCylinder_2', "Light199", 2000, 1000);    // WarpZoneInfo4

	return true;
}

function bool Server_FixCurrentMap_ONP_map14SoothsayerX()
{
	local Teleporter Telep;
	local ONPPawnDestructionEvent NaliDestructionEvent;

	if (CurrentMapGUID != "2A8C3EC646660121E48798A7984E3982")
		return false;

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map15RevelationX()
{
	if (CurrentMapGUID != "DC4DFD5D409D3B9A54C32787FD974450")
		return false;
	SetNamedTriggerPawnClassProximity("Trigger62");

	return true;
}

function bool Server_FixCurrentMap_ONP_map16BoldX()
{
	if (CurrentMapGUID != "91AC1E444C0EAFE94FCC3C9E40E5B5BD")
		return false;

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map17SiteBX()
{
	if (CurrentMapGUID != "7947651442DBBECB8AF15EB3E4ADEB64")
		return false;

	LoadLevelTrigger("Trigger66").Event = '';
	DisablePlayerStart("PlayerStart0");
	DisablePlayerStart("PlayerStart7");
	DisablePlayerStart("PlayerStart14");
	SetNamedTriggerPosition("Trigger69", vect(12535, 9217, -5656), 256);
	SetNamedTriggerPosition("Trigger70", vect(16615, 635, -5646), 512);
	LoadLevelTrigger("Trigger71").Event = '';
	MakeMessageEventFor("SpecialEvent8");

	return true;
}

function bool Server_FixCurrentMap_ONP_map18FriendX()
{
	local Trigger Tr;
	local ONPPawnDestructionEvent NaliDestructionEvent;

	if (CurrentMapGUID != "F34156D74FF7E885A25EB6A8C326E2DD")
		return false;

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map19IceX()
{
	if (CurrentMapGUID != "BCC5E2F942112160570832B801539D54")
		return false;

	LoadLevelTrigger("Trigger49").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger68").bTriggerOnceOnly = true; // MusicEvent5
	LoadLevelTrigger("Trigger82").bTriggerOnceOnly = true; // MusicEvent1
	LoadLevelTrigger("Trigger87").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger88").bTriggerOnceOnly = true; // MusicEvent5
	LoadLevelMover("Mover120").StayOpenTime = 4;
	MakeMessageEventFor("SpecialEvent25");
	SetNamedTriggerPawnClassProximity("Trigger73");
	FixatePlayerStarts();

	return true;
}

function bool Server_FixCurrentMap_ONP_map20InterloperX()
{
	if (CurrentMapGUID != "B397DC73494B5E58D272A9BF8D67D8A2")
		return false;

	LoadLevelMover("Mover97").StayOpenTime = 4;
	MakeMessageEventFor("SpecialEvent25");
	SetEventTriggersPawnClassProximity('Death');
	SetEventTriggersPawnClassProximity('ohdearyoufell');

	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Trigger47", 1500, 256); // WarpZoneInfo0
	MakeNetVisibilityCylinderAt('NetVisCylinder_1', "Light1653", 400, 128);  // WarpZoneInfo1

	return true;
}

function bool Server_FixCurrentMap_ONP_map21NestX()
{
	if (CurrentMapGUID != "6C804A76467A50BE41AC9F90D1FAC747")
		return false;

	LoadLevelMover("RotatingMover0").Tag = 'hiveoff_stop_rotating';
	Spawn(class'ONPEventUntrigger',, 'hiveoff').Event = 'hiveoff_stop_rotating';

	DisablePlayerStart("PlayerStart0");
	DisablePlayerStart("PlayerStart10");
	LoadLevelActor("PlayerStart14").Tag = 'PlayerStart8';
	LoadLevelTrigger("Trigger93").Event = '';
	EventToEvent('Shield', 'players8', true);

	MakeMessageEventFor("SpecialEvent2");
	SetEventTriggersPawnClassProximity('wasted');

	return true;
}

function bool Server_FixCurrentMap_ONP_map22TransferX()
{
	local Dispatcher Dispatcher;

	if (CurrentMapGUID != "8B9B48AD46F5041B1904B3B5D3535274")
		return false;

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

	return true;
}

simulated function bool Client_FixCurrentMap_ONP_map22TransferX()
{
	LoadLevelMover("Mover26").bDynamicLightMover = false;

	return true;
}

function bool Server_FixCurrentMap_ONP_map23PowerPlayX()
{
	if (CurrentMapGUID != "63FF7CF34C90A653752E1681AA7AB207")
		return false;

	FixatePlayerStarts();
	SetEventTriggersPawnClassProximity('wasted');

	MakeMessageEventFor("SpecialEvent25");
	MakeMessageEventFor("SpecialEvent27");
	MakeMessageEventFor("SpecialEvent30");
	MakeMessageEventFor("SpecialEvent34");
	MakeMessageEventFor("SpecialEvent38");
	MakeMessageEventFor("SpecialEvent45");
	MakeMessageEventFor("SpecialEvent62");

	return true;
}

function Server_ModifyCurrentMap_ONP_map24CoreX()
{
	MutatorPtr.SetNextLevel(MutatorPtr.PXGameEndURL);

	if (MutatorPtr.bDiscardItemsOnGameEnd)
		Spawn(class'ONPDiscardItemsOnLevelEnd');
}

function bool Server_FixCurrentMap_ONP_map24CoreX()
{
	local PlayerStart PlayerStart;
	local Trigger Trigger;
	local Dispatcher Dispatcher;

	if (!(CurrentMapGUID ~= "D76ED2954B15CC67FCCBE5B1269EEF30"))
		return false;

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

	return true;
}

simulated function bool Client_FixCurrentMap_ONP_map24CoreX()
{
	Common_FixCurrentMap_ONP_map24CoreX();

	return true;
}

simulated function Common_FixCurrentMap_ONP_map24CoreX()
{
	LoadLevelActor("BlockAll4").SetCollisionSize(256, 20);
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

function FixNPCNetFilter()
{
	local ScriptedPawn ScriptedPawn;

	foreach AllActors(class'ScriptedPawn', ScriptedPawn)
		if (ScriptedPawn.bSinglePlayer && !ScriptedPawn.bNet)
			ScriptedPawn.bNet = true;
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

function string GetCurrentMapGUID()
{
	local name PackageName;
	local string FileName;
	local string GUID;
	local int NmCount, ImpCount, ExpCount, FileSize;

	foreach AllLinkers(PackageName, FileName, GUID, NmCount, ImpCount, ExpCount, FileSize)
		if (PackageName == Outer.Name)
			return GUID;
	return "";
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
