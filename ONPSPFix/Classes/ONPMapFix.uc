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
	if (CurrentMap ~= "ONP-map02LinesofCommX")
		Server_FixCurrentMap_ONP_map02LinesofCommX();
	else if (CurrentMap ~= "ONP-map06ProcessingX")
		Server_FixCurrentMap_ONP_map06ProcessingX();
	else if (CurrentMap ~= "ONP-map08DisposalX")
		Server_FixCurrentMap_ONP_map08DisposalX();
	else if (CurrentMap ~= "ONP-map09SurfaceX")
		Server_FixCurrentMap_ONP_map09SurfaceX();
	else if (CurrentMap ~= "ONP-map18FriendX")
		Server_FixCurrentMap_ONP_map18FriendX();
	else if (CurrentMap ~= "ONP-map22TransferX")
		Server_FixCurrentMap_ONP_map22TransferX();

	// non-X series
	else if (CurrentMap ~= "ONP-map02Detour")
		Server_FixCurrentMap_ONP_map02Detour();
	else if (CurrentMap ~= "ONP-map04LabEntrance")
		Server_FixCurrentMap_ONP_map04LabEntrance();
	else if (CurrentMap ~= "ONP-map05FriendlyFire")
		Server_FixCurrentMap_ONP_map05FriendlyFire();
	else if (CurrentMap ~= "ONP-map14Mine")
		Server_FixCurrentMap_ONP_map14Mine();
	else if (CurrentMap ~= "ONP-map21Welcome")
		Server_FixCurrentMap_ONP_map21Welcome();
	else if (CurrentMap ~= "ONP-map22Disposal")
		Server_FixCurrentMap_ONP_map22Disposal();
	else if (CurrentMap ~= "ONP-map39Escape")
		Server_FixCurrentMap_ONP_map39Escape();
}

simulated function Client_FixCurrentMap()
{
	FixLightEffects();

	CurrentMap = string(Outer.Name);

	if (CurrentMap ~= "ONP-map22TransferX")
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
	local Trigger Trigger;
	local ONPPlayerMoveTrigger MoveTrigger;

	Trigger = LoadLevelTrigger("Trigger3");
	MoveTrigger = class'ONPPlayerMoveTrigger'.static.StaticReplaceTrigger(Trigger);
	MoveTrigger.bNoReenter = true;

	LoadLevelMover("Mover48").MoverEncroachType = ME_IgnoreWhenEncroach;
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

	P = Pawn(LoadLevelActor("SkaarjTrooper0", true));
	if (P != none)
	{
		P.Health = P.default.Health;
		Spawn(class'ONPPhantomPawnAdjustment').ControlledPawn = P;
	}
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

	zone = ZoneInfo(LoadLevelActor("ZoneInfo8"));
	zone.ZoneVelocity = vect(0, 0, 0);
	zone.ZoneGravity = vect(0, 0, 0);

	pr_zone = PressureZone(LoadLevelActor("PressureZone0"));
	pr_zone.DieDrawScale = 1;
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


function Server_FixCurrentMap_ONP_map02LinesofCommX()
{
	CreatureFactory(LoadLevelActor("CreatureFactory3")).prototype =
		CreatureFactory(LoadLevelActor("CreatureFactory2")).prototype;

	LoadLevelTrigger("Trigger13").bTriggerOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map06ProcessingX()
{
	local Trigger Tr;

	foreach AllActors(class'Trigger', Tr)
		if (StrStartsWith(Tr.Event, "splash", true))
		{
			Tr.TriggerType = TT_ClassProximity;
			Tr.ClassProximityType = class'Pawn';
		}

	LoadLevelTrigger("Trigger64").bTriggerOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map08DisposalX()
{
	LoadLevelTrigger("Trigger58").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger72").bTriggerOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map09SurfaceX()
{
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;
	CreatureFactory(LoadLevelActor("CreatureFactory0")).bCovert = false;
	CreatureFactory(LoadLevelActor("CreatureFactory1")).bCovert = false;
	CreatureFactory(LoadLevelActor("CreatureFactory2")).bCovert = false;
}

function Server_FixCurrentMap_ONP_map18FriendX()
{
	LoadLevelTrigger("Trigger15").bTriggerOnceOnly = true;
}

function Server_FixCurrentMap_ONP_map22TransferX()
{
	LoadLevelTrigger("Trigger29").bTriggerOnceOnly = true;
	LoadLevelMover("Mover56").MoverEncroachType = ME_IgnoreWhenEncroach;
}

simulated function Client_FixCurrentMap_ONP_map22TransferX()
{
	LoadLevelMover("Mover26").bDynamicLightMover = false;
}


function Server_FixCurrentMap_ONP_map02Detour()
{
	DisableTeleporter("fadeoutTeleporter3");
}

function Server_FixCurrentMap_ONP_map04LabEntrance()
{
	LoadLevelTrigger("Trigger51").bTriggerOnceOnly = false;
	LoadLevelMover("Mover79").StayOpenTime = 4;
}

function Server_FixCurrentMap_ONP_map05FriendlyFire()
{
	DisableTeleporter("fadeoutTeleporter1");
}

function Server_FixCurrentMap_ONP_map14Mine()
{
	LoadLevelMover("Mover1").StayOpenTime = 4;
}

function Server_FixCurrentMap_ONP_map21Welcome()
{
	LoadLevelMover("Mover0").StayOpenTime = 4;
}

function Server_FixCurrentMap_ONP_map22Disposal()
{
	LoadLevelMover("Mover34").StayOpenTime = 4;
}

function Server_FixCurrentMap_ONP_map39Escape()
{
	local EarthQuake EQ;

	foreach AllActors(class'EarthQuake', EQ)
		EQ.bThrowPlayer = false;
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

function SetMoverTriggerableOnceOnly(Mover m)
{
	m.bTriggerOnceOnly = True;
	AssignInitialState(m, 'TriggerOpenTimed');
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

simulated function EliminateStaticActor(string ActorName)
{
	local Actor A;
	A = LoadLevelActor(ActorName);
	A.SetCollision(false);
	A.bProjTarget = false;
	A.DrawType = DT_None;
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
