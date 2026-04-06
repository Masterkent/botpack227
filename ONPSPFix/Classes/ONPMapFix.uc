class ONPMapFix expands Info;

#exec obj load file="Botpack.u"

var bool bModified;
var ONPSPFix MutatorPtr;
var string CurrentMap;
var string CurrentMapGUID;

function PostBeginPlay()
{
	MutatorPtr = ONPSPFix(Owner);
	if (bModified || MutatorPtr == none)
		return;
	bModified = true;

	if (Server_FixCurrentMap())
		Client_FixCurrentMap();
}

function bool Server_FixCurrentMap()
{
	CurrentMap = string(Outer.Name);

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
	if (CurrentMap ~= "NP13DrPest")
		return Server_FixCurrentMap_NP13DrPest();
	if (CurrentMap ~= "NP14MClaneDrPest")
		return Server_FixCurrentMap_NP14MClaneDrPest();
	if (CurrentMap ~= "NP15Chico")
		return Server_FixCurrentMap_NP15Chico();
	if (CurrentMap ~= "NP16Chico")
		return Server_FixCurrentMap_NP16Chico();
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
	if (CurrentMap ~= "NP27DavidM")
		return Server_FixCurrentMap_NP27DavidM();
	if (CurrentMap ~= "NP29DavidM")
		return Server_FixCurrentMap_NP29DavidM();
	if (CurrentMap ~= "NP31DavidM")
		return Server_FixCurrentMap_NP31DavidM();
	if (CurrentMap ~= "NP32Strogg")
		return Server_FixCurrentMap_NP32Strogg();
}

function bool Server_FixCurrentMap_Xenome()
{
	CurrentMapGUID = Caps(GetCurrentMapGUID());

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
		if (CurrentMap ~= "ONP-map13Processing")
			return Server_FixCurrentMap_ONP_map13Processing();
		if (CurrentMap ~= "ONP-map14Mine")
			return Server_FixCurrentMap_ONP_map14Mine();
		if (CurrentMap ~= "ONP-map15CrossCountry")
			return Server_FixCurrentMap_ONP_map15CrossCountry();
		if (CurrentMap ~= "ONP-map16Dam")
			return Server_FixCurrentMap_ONP_map16Dam();
		if (CurrentMap ~= "ONP-map19Teleporter")
			return Server_FixCurrentMap_ONP_map19Teleporter();
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

function bool Server_FixCurrentMap_NP02DavidM()
{
	local ScriptedPawn ScriptedPawn;
	local Pawn P;
	local Trigger Trigger;
	local ONPPlayerMoveTrigger MoveTrigger;
	local Carcass Carc;
	local ONPGibInstigator ONPGibInstigator;

	ScriptedPawn = ScriptedPawn(LoadLevelActor("SkaarjScout0"));
	ScriptedPawn.AttitudeToPlayer = ATTITUDE_Ignore;
	ScriptedPawn.bHateWhenTriggered = true;

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

	Trigger = LoadLevelTrigger("Trigger3");
	MoveTrigger = class'ONPPlayerMoveTrigger'.static.StaticReplaceTrigger(Trigger);
	MoveTrigger.bNoReenter = true;

	LoadLevelMover("Mover48").MoverEncroachType = ME_IgnoreWhenEncroach;

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

	return true;
}

function bool Server_FixCurrentMap_NP06Heiko()
{
	LoadLevelTrigger("Trigger33").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger35").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger61").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger62").bTriggerOnceOnly = true;

	return true;
}

function bool Server_FixCurrentMap_NP08Hourences()
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

	return true;
}

function bool Server_FixCurrentMap_NP09Silver()
{
	LoadLevelDispatcher("Dispatcher4").OutEvents[4] = '';
	LoadLevelMover("Mover7").MoverEncroachType = ME_IgnoreWhenEncroach; // ME_CrushWhenEncroach may kill the Titan
	EliminateStaticActor("BlockAll10");

	return true;
}

function bool Server_FixCurrentMap_NP11Tonnberry()
{
	local Mover m;

	m = LoadLevelMover("Mover6");
	m.PlayerBumpEvent = m.Tag;

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

	return true;
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

function bool Server_FixCurrentMap_NP14MClaneDrPest()
{
	local Pawn P;

	LoadLevelActor("PlayerStart0").Tag = 'sp1';

	P = Pawn(LoadLevelActor("NaliTrooper1", true));
	if (P != none)
		Spawn(class'ONPPhantomPawnAdjustment').ControlledPawn = P;

	return true;
}

function bool Server_FixCurrentMap_NP15Chico()
{
	LoadLevelTrigger("Trigger112").bTriggerOnceOnly = true;

	return true;
}

function bool Server_FixCurrentMap_NP16Chico()
{
	ZoneInfo(LoadLevelActor("ZoneInfo0")).ZoneVelocity = vect(0, 0, 0);

	return true;
}

function bool Server_FixCurrentMap_NP19Part2Chico()
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

	return true;
}

function bool Server_FixCurrentMap_NP19Part3ChicoHour()
{
	LoadLevelTrigger("Trigger22").TriggerType = TT_PlayerProximity;

	return true;
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

	return true;
}

function bool Server_FixCurrentMap_NP27DavidM()
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
	LoadLevelActor("skaarjeyes0").Style = STY_Translucent;

	return true;
}

function bool Server_FixCurrentMap_NP32Strogg()
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

	return true;
}

function bool Server_FixCurrentMap_ONP_map05FriendlyFire()
{
	DisableTeleporter("fadeoutTeleporter1");
	SetNamedTriggerPawnClassProximity("Trigger1");
	MakeFallingMoverController("Mover79");

	return true;
}

function bool Server_FixCurrentMap_ONP_map06PowerPlay()
{
	SetEventTriggersPawnClassProximity('ouch');

	return true;
}

function bool Server_FixCurrentMap_ONP_map07Questionableethics()
{
	SetEventTriggersPawnClassProximity('aarrhh');

	return true;
}

function bool Server_FixCurrentMap_ONP_map09ComplexSituation()
{
	SetEventTriggersPawnClassProximity('aarrhh');
	LoadLevelMusicEvent("MusicEvent2").bOnceOnly = true;

	return true;
}

function bool Server_FixCurrentMap_ONP_map13Processing()
{
	SetNamedTriggerPawnClassProximity("Trigger29");

	return true;
}

function bool Server_FixCurrentMap_ONP_map14Mine()
{
	LoadLevelMover("Mover1").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger2");
	SetNamedTriggerPawnClassProximity("Trigger16");
	InterpolateSpecialEvent("SpecialEvent10");

	return true;
}

function bool Server_FixCurrentMap_ONP_map15CrossCountry()
{
	LoadLevelTrigger("Trigger6").bTriggerOnceOnly = true; // MusicEvent0

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

function bool Server_FixCurrentMap_ONP_map19Teleporter()
{
	LoadLevelTrigger("Trigger32").bTriggerOnceOnly = true;
	SetEventTriggersPawnClassProximity('killkill');
	SetEventTriggersPawnClassProximity('killkill2');
	MakeFallingMoverController("Mover0");

	return true;
}

function bool Server_FixCurrentMap_ONP_map21Welcome()
{
	LoadLevelMover("Mover0").StayOpenTime = 4;
	SetNamedTriggerPawnClassProximity("Trigger23");
	MakeFallingMoverController("Mover65");

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map26EBE()
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

	return true;
}

function bool Server_FixCurrentMap_ONP_map27Entrance()
{
	SetEventTriggersPawnClassProximity('burnbaby');

	return true;
}

function bool Server_FixCurrentMap_ONP_map28Bellyofthebeast()
{
	SetEventTriggersPawnClassProximity('zapped');
	SetNamedTriggerPawnClassProximity("Trigger5");
	SetNamedTriggerPawnClassProximity("Trigger40");

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map31Dogsofwar()
{
	LoadLevelTrigger("Trigger2").bTriggerOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent1").bOnceOnly = true;
	LoadLevelMusicEvent("MusicEvent3").bOnceOnly = true;

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map37Halted()
{
	SetNamedTriggerPawnClassProximity("Trigger14");

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map39Escape()
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

	return true;
}

function bool Server_FixCurrentMap_ONP_map40Boss()
{
	SetEventTriggersPawnClassProximity('pitofdeath');

	return true;
}


function bool Server_FixCurrentMap_ONP_map01FirstDayX()
{
	if (CurrentMapGUID != "FE2B8F0A4D37F886262C339DF583FC7E" && CurrentMapGUID != "FDA5C4D4478A990A9E846BA610AC4F4F")
		return false;

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
	EarthQuake(LoadLevelActor("Earthquake1")).bThrowPlayer = false;
	EarthQuake(LoadLevelActor("Earthquake2")).bThrowPlayer = false;

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

function bool Server_FixCurrentMap_ONP_map06ProcessingX()
{
	local Trigger Trigger;

	if (CurrentMapGUID != "FB988867435548523BBF1F99CA71AA7B" && CurrentMapGUID != "E99535CE4BC88E37FF61E39B350944E4")
		return false;

	foreach AllActors(class'Trigger', Trigger)
		if (StrStartsWith(Trigger.Event, "splash", true))
			SetTriggerPawnClassProximity(Trigger);

	LoadLevelTrigger("Trigger64").bTriggerOnceOnly = true;
	SetTriggerPawnClassProximity(LoadLevelTrigger("Trigger5"));

	return true;
}

function bool Server_FixCurrentMap_ONP_map07PlanningX()
{
	if (CurrentMapGUID != "59A4816B4A4FDB513A64199B11F1DA3C" && CurrentMapGUID != "77D0702F4A5C4B361BCBA799D64FB579")
		return false;

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
	if (Level.Game.Difficulty >= 3)
	{
		CreatureFactory(LoadLevelActor("CreatureFactory0")).bCovert = false;
		CreatureFactory(LoadLevelActor("CreatureFactory1")).bCovert = false;
		CreatureFactory(LoadLevelActor("CreatureFactory2")).bCovert = false;
	}

	return true;
}

function bool Server_FixCurrentMap_ONP_map10AmbushX()
{
	if (CurrentMapGUID != "9FCDA97143AB11356A7CD2AB57A8B429")
		return false;

	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;

	return true;
}

function bool Server_FixCurrentMap_ONP_map11CobaltX()
{
	if (CurrentMapGUID != "B61CD5D54E60CF72D9E495BAEBFD9374")
		return false;

	LoadLevelTrigger("Trigger8").bTriggerOnceOnly = true;

	return true;
}

function bool Server_FixCurrentMap_ONP_map12DamX()
{
	if (CurrentMapGUID != "E053772E41AF1FDA1E026F9F4F83ABBA")
		return false;

	SetEventTriggersPawnClassProximity('choppedup');

	return true;
}

function bool Server_FixCurrentMap_ONP_map13SignsX()
{
	if (CurrentMapGUID != "FDCE00284C9CB54CCD161F8A30523EA5")
		return false;

	LoadLevelTrigger("Trigger11").bTriggerOnceOnly = true; // MusicEvent5
	SetNamedTriggerPawnClassProximity("Trigger30");

	return true;
}

function bool Server_FixCurrentMap_ONP_map14SoothsayerX()
{
	local Teleporter Telep;

	if (CurrentMapGUID != "2A8C3EC646660121E48798A7984E3982")
		return false;

	Telep = Teleporter(LoadLevelActor("Teleporter0"));
	Telep.bEnabled = false;
	Telep.Tag = 'TeleporterEnergyUp';

	EventToEvent('energyup', 'TeleporterEnergyUp', true);

	SetNamedTriggerPawnClassProximity("Trigger64");

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

	return true;
}

function bool Server_FixCurrentMap_ONP_map18FriendX()
{
	if (CurrentMapGUID != "F34156D74FF7E885A25EB6A8C326E2DD")
		return false;

	LoadLevelTrigger("Trigger15").bTriggerOnceOnly = true;
	SetNamedTriggerPawnClassProximity("Trigger11");
	EarthQuake(LoadLevelActor("Earthquake0")).bThrowPlayer = false;

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
	SetNamedTriggerPawnClassProximity("Trigger73");

	return true;
}

function bool Server_FixCurrentMap_ONP_map20InterloperX()
{
	if (CurrentMapGUID != "B397DC73494B5E58D272A9BF8D67D8A2")
		return false;

	SetEventTriggersPawnClassProximity('Death');
	SetEventTriggersPawnClassProximity('ohdearyoufell');

	return true;
}

function bool Server_FixCurrentMap_ONP_map21NestX()
{
	if (CurrentMapGUID != "6C804A76467A50BE41AC9F90D1FAC747")
		return false;

	LoadLevelMover("RotatingMover0").Tag = 'hiveoff_stop_rotating';
	Spawn(class'ONPEventUntrigger',, 'hiveoff').Event = 'hiveoff_stop_rotating';

	SetEventTriggersPawnClassProximity('wasted');

	return true;
}

function bool Server_FixCurrentMap_ONP_map22TransferX()
{
	if (CurrentMapGUID != "8B9B48AD46F5041B1904B3B5D3535274")
		return false;

	LoadLevelTrigger("Trigger29").bTriggerOnceOnly = true;
	LoadLevelTrigger("Trigger51").bTriggerOnceOnly = true;
	LoadLevelMover("Mover56").MoverEncroachType = ME_IgnoreWhenEncroach;

	SetNamedTriggerPawnClassProximity("Trigger46");
	SetEventTriggersPawnClassProximity('chopped');
	SetEventTriggersPawnClassProximity('ohdearyoufell');

	return true;
}

simulated function Client_FixCurrentMap_ONP_map22TransferX()
{
	LoadLevelMover("Mover26").bDynamicLightMover = false;
}

function bool Server_FixCurrentMap_ONP_map23PowerPlayX()
{
	if (CurrentMapGUID != "63FF7CF34C90A653752E1681AA7AB207")
		return false;

	SetEventTriggersPawnClassProximity('wasted');

	return true;
}

function bool Server_FixCurrentMap_ONP_map24CoreX()
{
	if (CurrentMapGUID != "D76ED2954B15CC67FCCBE5B1269EEF30")
		return false;

	LoadLevelTrigger("Trigger95").bTriggerOnceOnly = true; // MusicEvent2
	LoadLevelTrigger("Trigger96").bTriggerOnceOnly = true; // MusicEvent3
	LoadLevelTrigger("Trigger110").bTriggerOnceOnly = true;
	SetEventTriggersPawnClassProximity('Death');
	SetEventTriggersPawnClassProximity('electric');
	SetNamedTriggerPawnClassProximity("Trigger56");
	LoadLevelActor("BlockAll4").SetCollisionSize(256, 20);

	return true;
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
