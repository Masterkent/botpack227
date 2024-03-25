class ONPCoopMutator expands Mutator
	config(ONPCoopMutator);

var() const string VersionInfo;
var() const string Version;

struct Remapping
{
	var() config string OriginalMap;
	var() config string SubstituteMap;
	var() config bool bApplyMapFixes;
};

var() config bool bAdjustNPCFriendlyFire;
var() config bool bDisableFlashlightReplacement;
var() config bool bDiscardItemsOnGameEnd;
var() config bool bInfiniteSpecialItems;
var() config bool bPreventFallingOutOfWorld;
var() config bool bReplaceONPTranslocator;
var() config bool bUseAircraftLevels;
var() config bool bUseClassicUnrealTravellingPickups;
var() config bool bUseONPHUD;
var() config bool bUseONPPlayerPawnType;
var() config bool bUseONPSpeech;
var() config bool bUseONPWeaponsSupply;
var() config bool bUseRealCrouch;
var() config bool bUseSpeechMenuForU1Players;
var() config string WeaponReplacementMode; // possible values: "", "ONP", "ONP-Basic", "Unreal", "Advanced", "Powerful"
var() config string ONPGameEndURL;
var() config string PXGameEndURL;
var() config string PX0GameEndURL;
var() config array<Remapping> MapReplacements;
var() config bool bDebugMode;

var ONPGameRules GameRulesPtr;
var ONPLevelInfo LInfo;

event PostBeginPlay()
{
	if (RemoveDuplicatedMutator())
		return;

	if (bDebugMode)
		DebugChecks();
	//hacks to access projectiles:
	class'olSlithProjectile'.default.bGameRelevant = false;
	class'ExplosionChain'.default.bGameRelevant = false;

	LevelStartupAdjustments();
	AddGameRules();
	RegisterONPLevelInfo();
	RegisterClientPackage();
	ReplaceDefaultWeaponClass();

	SaveConfig();
}

function bool RemoveDuplicatedMutator()
{
	local Mutator Mutator;

	for (Mutator = Level.Game.BaseMutator; Mutator != none; Mutator = Mutator.NextMutator)
		if (Mutator.Class == Class && Mutator != self)
		{
			Destroy();
			return true;
		}
	return false;
}

function DebugChecks()
{
	if (Level.NetMode != NM_DedicatedServer)
		Log("WARNING: ONPCoopMutator: Level.NetMode is not NM_DedicatedServer!");
}

function RegisterClientPackage()
{
	if (!AddToPackagesMap())
		Log("CRITICAL ERROR: ONPCoopMutator: Failed to add" @ Class.Outer.Name @ "to the server packages map");
}

function LevelStartupAdjustments()
{
	class'olextras.SuperAmmoShockRifle'.default.bTravel = true; // always true except when map sets it to false
	class'BotPack.SuperShockCore'.default.bTravel = true; // always true except when map sets it to false
	class'olextras.TvTranslocator'.default.bTravel = false; // always false
	Level.bSupportsRealCrouching = bUseRealCrouch;

	Spawn(class'ONPClientAdjustments');
	AdjustSpecialerEvents();
	AdjustWaterToggleZones();
	AdjustThingFactories();
	AdjustThrowStuffDecorations();
	AdjustExplodingEffects();
	AdjustMusicEvents();
	AdjustTriggers();
	ReplaceCameraSpots();
	ReplaceMapInventory();
	ReplaceSpawnPoints();

	FixCurrentMap();
	AdjustNextLevel();

	ReplaceTeleporters(); // Called after any URL adjustments
}

function AdjustSpecialerEvents()
{
	local SpecialerEvent aSpecialerEvent;

	if (!bUseONPSpeech)
	{
		foreach AllActors(class'SpecialerEvent', aSpecialerEvent)
			if (aSpecialerEvent.MyMessageType == 'Say')
				aSpecialerEvent.Tag = '';
	}
}

function AdjustWaterToggleZones()
{
	local WaterToggleZone Zone;

	foreach AllActors(class'WaterToggleZone', Zone)
		Zone.Spawn(class'ONPWaterToggleZoneController').SetControlledZone(Zone);
}

function AdjustThingFactories()
{
	local ThingFactory Factory;

	foreach AllActors(class'ThingFactory', Factory)
		if (Factory.prototype != none &&
			Factory.bFalling &&
			ClassIsChildOf(Factory.prototype, class'Botpack.WarShell'))
		{
			Factory.prototype = class'ONPFallingWarShell';
		}
}

function AdjustThrowStuffDecorations()
{
	local ThrowStuff ThrowStuff;
	local Decoration Deco;

	foreach AllActors(class'ThrowStuff', ThrowStuff)
		if (ThrowStuff.Event != '')
			foreach AllActors(class'Decoration', Deco, ThrowStuff.Event)
				if (!Deco.bStatic)
					Deco.bSimulatedPawnRep = true;
}

function AdjustDecorations()
{
	local Decoration Deco;

	foreach AllActors(class'Decoration', Deco)
		if (Deco.Physics == PHYS_Falling && Deco.Region.ZoneNumber == 0)
		{
			Deco.bCollideWorld = false;
			Deco.bMovable = false;
			Deco.SetPhysics(PHYS_None);
		}
}

function ReplaceMasterCreatureChunks()
{
	local MasterCreatureChunk Chunk;
	local CreatureChunks NewChunk;

	foreach AllActors(class'MasterCreatureChunk', Chunk)
		if (Chunk.RemoteRole == ROLE_SimulatedProxy && Chunk.bDecorative)
		{
			NewChunk = Chunk.Spawn(class'CreatureChunks',, Chunk.Tag);
			NewChunk.bDecorative = true;
			NewChunk.DrawScale = Chunk.DrawScale;
			NewChunk.Mesh = Chunk.Mesh;
			NewChunk.Skin = Chunk.Skin;
			Chunk.Destroy();
		}
}

function AdjustExplodingEffects()
{
	local ExplodingWall EW;
	local ExplosionChain EC;

	foreach AllActors(class'ExplodingWall', EW)
		EW.SetCollision(false);
	foreach AllActors(class'ExplosionChain', EC)
		EC.SetCollision(false);
}

function AdjustMusicEvents()
{
	local MusicEvent MusicEvent;

	foreach AllActors(class'MusicEvent', MusicEvent)
		if (MusicEvent.Song != none && MusicEvent.Song.Name == 'Null')
			MusicEvent.SongSection = 255; // silence
}

function AdjustTriggers()
{
	AdjustTriggersProximity();
}

function AdjustTriggersProximity()
{
	local Trigger Trigger;
	local Mover Mover;

	foreach AllActors(class'Trigger', Trigger)
		if (Trigger.TriggerType == TT_AnyProximity && Trigger.Event != '')
		{
			foreach AllActors(class'Mover', Mover, Trigger.Event)
				if (Mover.InitialState == 'TriggerControl')
				{
					Trigger.TriggerType = TT_PawnProximity;
					break;
				}
		}
}

function ReplaceCameraSpots()
{
	local KeyPoint CameraSpot;

	foreach AllActors(class'KeyPoint', CameraSpot)
		if (CameraSpot.Class.Name == 'CameraSpot' &&
			CameraSpot.Class.Outer == Outer &&
			DynamicLoadObject(Outer.Name $ ".CameraSpot.PlayerLocal", class'Object', true) != none)
		{
			class'ONPCameraSpot'.static.ReplaceCameraSpot(CameraSpot);
		}
}

function ReplaceMapInventory()
{
	local Inventory Inv;

	if (WeaponReplacementMode ~= "ONP-Basic" ||
		WeaponReplacementMode ~= "Powerful")
	{
		foreach AllActors(class'Inventory', Inv)
			if (!Inv.bScriptInitialized && !InventoryReplacement(Inv, true))
				Inv.Destroy();
	}
}

function ReplaceSpawnPoints()
{
	local SpawnPoint SpawnPoint;

	foreach AllActors(class'SpawnPoint', SpawnPoint)
		if (SpawnPoint.Class == class'SpawnPoint' && SpawnPoint.Tag != '')
		{
			SpawnPoint.Spawn(class'ONPSpawnPoint',, SpawnPoint.Tag);
			SpawnPoint.Tag = '';
		}
}

function ReplaceTeleporters()
{
	class'B227_SpawnableTeleporter'.static.ReplaceLevelTeleporters(Level);
}

function FixCurrentMap()
{
	Spawn(class'ONPMapFix', self);
}

function AddGameRules()
{
	GameRulesPtr = Spawn(class'ONPGameRules', self);

	if (Level.Game.GameRules == none)
		Level.Game.GameRules = GameRulesPtr;
	else if (GameRulesPtr != none)
		Level.Game.GameRules.AddRules(GameRulesPtr);
}

function bool IsAircraftLevel()
{
	return Level.outer.name == 'NP03Atje' || Level.outer.name == 'NP19Part3ChicoHour';
}

function AdjustNextLevel()
{
	local int i;
	local int SlashIndex, SharpIndex, QueryIndex;
	local Teleporter Telep;
	local string NextMap, NextMapURL;

	foreach AllActors(class'Teleporter', Telep)
		if (InStr(Telep.URL, "/") >= 0 || InStr(Telep.URL, "#") >= 0)
		{
			NextMapURL = Telep.URL;
			break;
		}
	if (NextMapURL == "")
		return;

	SlashIndex = InStr(NextMapURL, "/");
	SharpIndex = InStr(NextMapURL, "#");
	QueryIndex = InStr(NextMapURL, "?");

	i = 0;
	if (SlashIndex > 0)
		i = SlashIndex;
	if (i == 0 || SharpIndex > 0 && SharpIndex < i)
		i = SharpIndex;
	if (i == 0 || QueryIndex > 0 && QueryIndex < i)
		i = QueryIndex;

	NextMap = Left(NextMapURL, i);
	NextMapURL = Mid(NextMapURL, i);

	for (i = 0; i < Array_Size(MapReplacements); ++i)
		if (MapReplacements[i].OriginalMap ~= NextMap && MapReplacements[i].SubstituteMap != "")
		{
			NextMap = MapReplacements[i].SubstituteMap;
			break;
		}
	if (i == Array_Size(MapReplacements))
		return;

	NextMapURL = NextMap $ NextMapURL;

	foreach AllActors(class'Teleporter', Telep)
		if (InStr(Telep.URL, "/") >= 0 || InStr(Telep.URL, "#") >= 0)
			Telep.URL = NextMapURL;
}

function SetNextLevel(string MapName)
{
	local int i;
	local Teleporter telep;

	if (Len(MapName) == 0)
		return;

	for (i = 0; i < Array_Size(MapReplacements); ++i)
		if (MapReplacements[i].OriginalMap ~= MapName && MapReplacements[i].SubstituteMap != "")
		{
			MapName = MapReplacements[i].SubstituteMap;
			break;
		}

	foreach AllActors(class'Teleporter', telep)
		if (InStr(telep.URL, "/") >= 0 || InStr(telep.URL, "#") >= 0)
			telep.URL = MapName $ "#?peer";
}

// For setting heads to green.  Assumes only 1 unique texture has been set!
function MinipulateSkin (actor Other, actor In){
  local int i, j;
  for (i=0;i<8;i++)
    if (in.multiskins[i]!=none){
      for (j=0;j<8;j++)
        Other.multiskins[j]=in.multiskins[i];
      Other.Skin=in.multiskins[i];
      return;
    }
  if (in.skin==none)
    return;
  other.skin=in.skin;
  for (j=0;j<8;j++)
    Other.multiskins[j]=in.skin;
}
//convert explosion chains to the UT style one
function actor ReplaceNonInv(Actor other,class<actor> NewC)
{
  	local actor A;
  	if (level.game.Difficulty == 0 && !Other.bDifficulty0 ||
		level.game.Difficulty == 1 && !Other.bDifficulty1 ||
		level.game.Difficulty == 2 && !Other.bDifficulty2 ||
		level.game.Difficulty >= 3 && !Other.bDifficulty3 ||
		!Other.bSinglePlayer && Level.NetMode == NM_Standalone || 
		!Other.bNet && (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer))
	{
		return none;
	}

	if (FRand() > Other.OddsOfAppearing)
		return none;

	A = Spawn(NewC, other.owner, Other.tag, Other.Location, Other.Rotation);

	if (A != None)
	{
		A.event = Other.event;
		A.tag = Other.tag;
		A.SetCollision(Other.bCollideActors, Other.bBlockActors, Other.bBlockPlayers);
		A.bCollideWorld = Other.bCollideWorld;
		A.bProjTarget = Other.bProjTarget;
		A.SetCollisionSize(Other.CollisionRadius, Other.CollisionHeight);
	}
  	return A;
}

function ReplaceExploChain(ExplosionChain other)
{
	local TVExplosionChain A;
	A = TVExplosionChain(ReplaceNonInv(Other, class'TvExplosionChain'));
	if (A == none)
		return;

	A.MomentumTransfer = Other.MomentumTransfer;
	A.Damage = Other.Damage;
	A.Size = Other.Size;
	A.Delaytime = Other.Delaytime;
	A.bOnlyTriggerable = Other.bOnlyTriggerable;
}

function ReplaceTransBook(TranslatorBook Other)
{
	local ONPTranslatorBook A;
	A = ONPTranslatorBook(ReplaceNonInv(Other, class'ONPTranslatorBook'));
	if (A == none)
		return;

	A.Message = Other.Message;
	A.AltMessage = Other.AltMessage;
	A.NewMessageSound = Other.NewMessageSound;
	A.bTriggerAltMessage = Other.bTriggerAltMessage;
	A.ReTriggerDelay = Other.ReTriggerDelay;
	A.M_NewMessage = Other.M_NewMessage;
	A.M_TransMessage = Other.M_TransMessage;

	A.Initialize();
}

function ReplaceTransEvent(TranslatorEvent Other)
{
	local TranslatorEvent ONPTE;
	local TvTranslatorEvent TvTE;

	if (!bUseONPHUD)
	{
		ONPTE = TranslatorEvent(ReplaceNonInv(Other, class'ONPTranslatorEvent'));
		if (ONPTE == none)
			return;

		ONPTE.Message = Other.Message;
		ONPTE.AltMessage = Other.AltMessage;
		ONPTE.NewMessageSound = Other.NewMessageSound;
		ONPTE.bTriggerAltMessage = Other.bTriggerAltMessage;
		ONPTE.ReTriggerDelay = Other.ReTriggerDelay;
	}
	else
	{
		TvTE = TvTranslatorEvent(ReplaceNonInv(Other, class'TvTranslatorEvent'));
		if (TvTE == none)
			return;

		TvTE.Message = Other.Message;
		TvTE.AltMessage = Other.AltMessage;
		TvTE.NewMessageSound = Other.NewMessageSound;
		TvTE.bTriggerAltMessage = Other.bTriggerAltMessage;
		TvTE.ReTriggerDelay = Other.ReTriggerDelay;
	}
}

function ReplaceTvTransEvent(TvTranslatorEvent Other)
{
	local TranslatorEvent A;
	A = TranslatorEvent(ReplaceNonInv(Other, class'ONPTranslatorEvent'));
	if (A == none)
		return;

	A.Message = Other.Message;
	A.AltMessage = Other.AltMessage;
	A.NewMessageSound = Other.NewMessageSound;
	A.bTriggerAltMessage = Other.bTriggerAltMessage;
	A.ReTriggerDelay = Other.ReTriggerDelay;
}

function RegisterONPLevelInfo()
{
	foreach AllActors(class'ONPLevelInfo', LInfo)
	{
		if (bDebugMode)
			Log("ONPCoopMutator: RegisterONPLevelInfo" @ LInfo);

		AdjustONPLevelInfo();

		GameRulesPtr.LInfo = LInfo;
		return;
	}
}

function AdjustONPLevelInfo()
{
	local int i;

	for (i = 0; i < ArrayCount(LInfo.DefaultInventory); ++i)
		AdjustONPLevelInfoInventory(LInfo.DefaultInventory[i]);
	for (i = 0; i < ArrayCount(LInfo.TriggeredInv); ++i)
		AdjustONPLevelInfoInventory(LInfo.TriggeredInv[i]);
}

function AdjustONPLevelInfoInventory(out class<Inventory> InventoryClass)
{
	InventoryClass = InventoryClassReplacement(InventoryClass, true);
}

function ReplaceDefaultWeaponClass()
{
	if (LInfo == none)
		return;

	if (Level.Game.DefaultWeapon == class'DispersionPistol' ||
		Level.Game.DefaultWeapon == class'oldpistol')
	{
		if (WeaponReplacementMode ~= "ONP" ||
			WeaponReplacementMode ~= "ONP-Basic" ||
			WeaponReplacementMode ~= "Powerful")
		{
			if (LInfo.DefaultWeapon <= 2)
				Level.Game.DefaultWeapon = class'olextras.NoammoDpistol';
			else
				Level.Game.DefaultWeapon = none;
		}
	}
}

function bool ReplaceWithC(actor Other, class<Actor> aClass)
{
	local Actor A;

	if (level.game.Difficulty == 0 && !Other.bDifficulty0 ||
		level.game.Difficulty == 1 && !Other.bDifficulty1 ||
		level.game.Difficulty == 2 && !Other.bDifficulty2 ||
		level.game.Difficulty >= 3 && !Other.bDifficulty3 ||
		!Other.bSinglePlayer && Level.NetMode == NM_Standalone || 
		!Other.bNet && (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer))
	{
		if (bDebugMode)
			log("ONPCoopMutator: ReplaceWithC:" @ other @ "is an irrelevant actor");
		return false;
	}
	if (FRand() > Other.OddsOfAppearing)
	{
		if (bDebugMode)
			log("ONPCoopMutator: ReplaceWithC:" @ other @ "is an irrelevant actor due to OddsOfAppearing");
		return false;
	}
	if (Other.IsA('Inventory') && Other.Location == vect(0,0,0))
	{
		if (bDebugMode)
			log("ONPCoopMutator: ReplaceWithC:" @ other @ "is an Inventory at location (0,0,0), to be removed");
		return false;
	}

	A = Other.Spawn(aClass, Other.Owner, Other.tag, Other.Location, Other.Rotation);

	if (Other.IsA('Inventory'))
	{
		if (Inventory(Other).MyMarker != None)
		{
			Inventory(Other).MyMarker.markedItem = Inventory(A);
			if (Inventory(A) != None)
			{
				Inventory(A).MyMarker = Inventory(Other).MyMarker;
				A.SetLocation(A.Location + (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Inventory(Other).MyMarker = None;
		}
		else if (Inventory(A) != none && Inventory(Other).bhelditem)
		{
			Inventory(A).bHeldItem = true;
			Inventory(A).Respawntime = 0.0;
		}
	}
	if (A != None)
	{
		if (bDebugMode)
			log("ONPCoopMutator: ReplaceWithC:" @ other @ "was successfully replaced with" @ A);
		A.event = Other.event;
		A.tag = Other.tag;
		A.RotationRate = Other.RotationRate;
		return true;
	}
	if (bDebugMode)
		log("ONPCoopMutator: ReplaceWithC: Failed to replace" @ other @ "with an actor of type" @ aClass);
	return false;
}

function bool ReplaceWithFC(Actor Other, class<Actor> aClass)
{
	ReplaceWithC(Other, aClass);
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local float Dif;

	if (!CheckONPReplacement(Other))
		return false;

	if (Inventory(Other) != none && Inventory(Other).bHeldItem)
		return true;

	if (!InventoryReplacement(Other, false))
		return false;

	if (other.class == class'ExplosionChain')
	{
		ReplaceExploChain(ExplosionChain(other));
		return false;
	}
	if (other.class == class'TranslatorBook' && !bUseONPHUD)
	{
		ReplaceTransBook(TranslatorBook(other));
		return false;
	}
	if (other.class == class'TranslatorEvent')
	{
		ReplaceTransEvent(TranslatorEvent(other));
		return false;
	}
	if (other.class == class'TvTranslatorEvent' && !bUseONPHUD)
	{
		ReplaceTvTransEvent(TvTranslatorEvent(other));
		return false;
	}

	if (Level.NetMode != NM_Standalone &&
		(Other.IsA('PlayerMotionFreeze') || Other.IsA('ViewSpot') || Other.IsA('ViewSpotStop') || Other.IsA('NonBuggyViewSpot')))
	{
		return false; //no cutscenes in co-op!
	}

	if (Pawn(Other) != none)
	{
		if (ScriptedPawn(Other) != none)
			ScriptedPawnAdjustment(ScriptedPawn(Other));
		Pawn(Other).DropWhenKilled = InventoryClassReplacement(Pawn(Other).DropWhenKilled, true);
	}
	else if (false &&(other.class == class'tree5' || other.class == class'tree6'))
	{
		//replace palm trees w/ new mesh
		other.mesh = class'leetpalm'.default.mesh;
		other.prepivot.z-=16*other.drawscale;
		other.MultiSkins[0]=Texture'Jdmisgay12';
	//  other.MultiSkins[0].DrawScale=0.96;
		other.SetCollisionSize(0.8 * other.CollisionRadius, other.default.CollisionHeight * other.DrawScale);
		if (other.class == class'tree5')
			other.drawscale *= 3.3;
		else
			other.drawscale *= 3.85;
		///other.SetCollisionSize(0.8 * other.collisionradius, other.collisionheight);
	}
	else if ((other.IsA('SlithProjectile') || Other.IsA('bruteprojectile')) &&
		ScriptedPawn(other.instigator) != none)
	{   //projectile speed isn't used?
		Dif = FClamp(other.instigator.Skill+level.game.Difficulty, 0, 3);
		if (Dif > 1.0)
			Projectile(other).speed *= 0.9 + 0.1 * Dif;
		///Projectile(other).maxspeed=10000; // bad for multiplayer clients
	}
	//various hacks:
	else if (Other.IsA('CreatureChunks') && other.Instigator != none && Other.Instigator.Style == STY_Translucent)
	{
		Other.Style = STY_Translucent;
		CreatureChunks(Other).bGreenBlood=true;
		MinipulateSkin(Other, Other.Instigator);   //go greeb
	}
	else if (Other.IsA('olCreatureCarcass') && Other.Instigator != none)
	{
		if (Other.Instigator.IsA('Follower'))
			Carcass(Other).Rats = byte(Follower(Other.Instigator).IsFriend());
		else if (Other.Instigator.IsA('Nali') || Other.Instigator.IsA('cow'))
			Carcass(Other).Rats=2;
	}
	else if (Decoration(Other) != none)
		DecorationContentReplacement(Decoration(Other));
	else if (Other.IsA('RealCrouchInfo'))
		AdjustRealCrouchInfo(Other);

	return true;
}

function bool CheckONPReplacement(Actor Other)
{
	if (Other.class == class'CodeConsole')
		return ReplaceCodeConsole(CodeConsole(Other));
	return true;
}

function bool ReplaceCodeConsole(CodeConsole Other)
{
	local ONPCodeConsole A;
	A = Other.Spawn(class'ONPCodeConsole', Other.Owner, Other.Tag);

	A.Event = Other.Event;
	A.MinNumber = Other.MinNumber;
	A.MaxNumber = Other.MaxNumber;
	A.TranslatorTag = Other.TranslatorTag;
	A.ClearenceMessage = Other.ClearenceMessage;
	A.ClearenceSound = Other.ClearenceSound;
	A.FailureMessage = Other.FailureMessage;
	A.FailureSound = Other.FailureSound;
	A.SecurityPrompt = Other.SecurityPrompt;
	A.PromptSound = Other.PromptSound;
	A.KeyEnterSound = Other.KeyEnterSound;
	A.FailureEvent = Other.FailureEvent;
	A.bEnabled = Other.bEnabled;
	A.MessageType = Other.MessageType;
	A.LinkedTag = Other.LinkedTag;
	A.DisableOnCorrect = Other.DisableOnCorrect;

	A.Initialize();

	return false;
}

function class<Inventory> InventoryClassReplacement(class<Inventory> InventoryClass, bool bBasic)
{
	if (InventoryClass == none)
		return none;

	if (InventoryClass == class'TvTranslator' && !bUseONPHUD)
		InventoryClass = class'Translator';

	if (InventoryClass == class'TVTranslocator' && bReplaceONPTranslocator)
		return class'ONPTranslocator';

	if (WeaponReplacementMode ~= "Unreal")
	{
		if (ClassIsChildOf(InventoryClass, class'Weapon'))
			return ToClassicWeaponType(class<Weapon>(InventoryClass));
		if (ClassIsChildOf(InventoryClass, class'Ammo'))
			return ToClassicAmmoType(class<Ammo>(InventoryClass));
		if (InventoryClass == class'olWeapons.osDispersionpowerup')
			return class'WeaponPowerup';
	}
	else if (WeaponReplacementMode ~= "ONP")
	{
		if (ClassIsChildOf(InventoryClass, class'Weapon'))
			return ToONPWeaponType(class<Weapon>(InventoryClass));
		if (ClassIsChildOf(InventoryClass, class'Ammo'))
			return ToONPAmmoType(class<Ammo>(InventoryClass));
		if (InventoryClass == class'WeaponPowerup')
			return class'olWeapons.osDispersionpowerup';
	}
	else if (WeaponReplacementMode ~= "ONP-Basic")
	{
		if (bBasic)
		{
			if (ClassIsChildOf(InventoryClass, class'Weapon'))
				return ToONPWeaponType(class<Weapon>(InventoryClass));
			if (ClassIsChildOf(InventoryClass, class'Ammo'))
				return ToONPAmmoType(class<Ammo>(InventoryClass));
			if (InventoryClass == class'WeaponPowerup')
				return class'olWeapons.osDispersionpowerup';
		}
	}
	else if (WeaponReplacementMode ~= "Advanced")
	{
		if (ClassIsChildOf(InventoryClass, class'Weapon'))
			return ToAdvancedWeaponType(class<Weapon>(InventoryClass));
	}
	else if (WeaponReplacementMode ~= "Powerful")
	{
		if (bBasic)
		{
			if (ClassIsChildOf(InventoryClass, class'Weapon'))
				return ToPowerfulWeaponType(class<Weapon>(InventoryClass));
			if (ClassIsChildOf(InventoryClass, class'Ammo'))
				return ToPowerfulAmmoType(class<Ammo>(InventoryClass));
			if (InventoryClass == class'WeaponPowerup')
				return class'olWeapons.osDispersionpowerup';
		}
	}

	if (InventoryClass == class'translator' && bUseONPHUD)
		return class'olextras.TVtranslator';

	if (ClassIsChildOf(InventoryClass, class'Pickup'))
		return TravellingPickupTypeReplacement(class<Pickup>(InventoryClass));

	return InventoryClass;
}

static function class<Weapon> ToClassicWeaponType(class<Weapon> WeaponClass)
{
	if (WeaponClass == class'Oldpistol' || WeaponClass == class'olextras.NoammoDpistol')
		return class'DispersionPistol';
	if (WeaponClass == class'enforcer' || WeaponClass == class'olextras.SPEnf')
		return class'Automag';
	if (WeaponClass == class'PulseGun' || WeaponClass == class'ospulsegun' || WeaponClass == class'olextras.TVPulsegun')
		return class'Stinger';
	if (WeaponClass == class'ShockRifle' || WeaponClass == class'OSShockRifle')
		return class'ASMD';
	if (WeaponClass == class'UT_Eightball' || WeaponClass == class'olextras.TvEightBall')
		return class'EightBall';
	if (WeaponClass == class'UT_FlakCannon')
		return class'FlakCannon';
	if (WeaponClass == class'Ripper')
		return class'Razorjack';
	if (WeaponClass == class'UT_BioRifle')
		return class'GESBioRifle';
	if (WeaponClass == class'SniperRifle')
		return class'Rifle';
	if (WeaponClass == class'Minigun2')
		return class'Minigun';

	return WeaponClass;
}

static function class<Ammo> ToClassicAmmoType(class<Ammo> AmmoClass)
{
	if (AmmoClass == class'MiniAmmo')
		return class'ShellBox';
	if (AmmoClass == class'EClip')
		return class'Clip';
	if (AmmoClass == class'PAmmo')
		return class'StingerAmmo';
	if (AmmoClass == class'ShockCore')
		return class'ASMDAmmo';
	if (AmmoClass == class'RocketPack')
		return class'RocketCan';
	if (AmmoClass == class'FlakAmmo')
		return class'FlakBox';
	if (AmmoClass == class'olWeapons.osFlakShellAmmo')
		return class'FlakShellAmmo';
	if (AmmoClass == class'BladeHopper')
		return class'RazorAmmo';
	if (AmmoClass == class'BioAmmo')
		return class'Sludge';
	if (AmmoClass == class'BulletBox')
		return class'RifleAmmo';
	if (AmmoClass == class'RifleShell')
		return class'RifleRound';

	return AmmoClass;
}

static function class<Weapon> ToONPWeaponType(class<Weapon> WeaponClass)
{
	if (WeaponClass == class'DispersionPistol' || WeaponClass == class'oldpistol')
		return class'olextras.NoammoDpistol';
	if (WeaponClass == class'Automag' || WeaponClass == class'Enforcer')
		return class'olextras.SPEnf';
	if (WeaponClass == class'GesBioRifle')
		return class'Botpack.UT_BioRifle';
	if (WeaponClass == class'ASMD' || WeaponClass == class'ShockRifle')
		return class'olWeapons.OSShockRifle';
	if (WeaponClass == class'Stinger' || WeaponClass == class'PulseGun' || WeaponClass == class'ospulsegun')
		return class'olextras.TVPulsegun';
	if (WeaponClass == class'Razorjack')
		return class'Botpack.Ripper';
	if (WeaponClass == class'Minigun')
		return class'Botpack.Minigun2';
	if (WeaponClass == class'FlakCannon')
		return class'Botpack.UT_flakcannon';
	if (WeaponClass == class'Eightball' || WeaponClass == class'UT_Eightball')
		return class'TVEightball';
	if (WeaponClass == class'Rifle')
		return class'Botpack.SniperRifle';

	return WeaponClass;
}

static function class<Ammo> ToONPAmmoType(class<Ammo> AmmoClass)
{
	if (AmmoClass == class'ShellBox')
		return class'MiniAmmo';
	if (AmmoClass == class'Clip')
		return class'EClip';
	if (AmmoClass == class'StingerAmmo')
		return class'PAmmo';
	if (AmmoClass == class'ASMDAmmo')
		return class'ShockCore';
	if (AmmoClass == class'RocketCan')
		return class'RocketPack';
	if (AmmoClass == class'FlakBox')
		return class'FlakAmmo';
	if (AmmoClass == class'FlakShellAmmo')
		return class'olWeapons.osFlakShellAmmo';
	if (AmmoClass == class'RazorAmmo')
		return class'BladeHopper';
	if (AmmoClass == class'Sludge')
		return class'BioAmmo';
	if (AmmoClass == class'RifleAmmo')
		return class'BulletBox';
	if (AmmoClass == class'RifleRound')
		return class'RifleShell';

	return AmmoClass;
}

static function class<Weapon> ToAdvancedWeaponType(class<Weapon> WeaponClass)
{
	if (WeaponClass == class'Enforcer')
		return class'olextras.SPEnf';
	if (WeaponClass == class'ShockRifle')
		return class'olWeapons.OSShockRifle';
	if (WeaponClass == class'PulseGun')
		return class'olWeapons.OSPulseGun';
	if (WeaponClass == class'UT_Eightball')
		return class'TVEightball';

	return WeaponClass;
}

static function class<Weapon> ToPowerfulWeaponType(class<Weapon> WeaponClass)
{
	if (WeaponClass == class'DispersionPistol' || WeaponClass == class'oldpistol')
		return class'olextras.NoammoDpistol';
	if (WeaponClass == class'Automag' || WeaponClass == class'Enforcer')
		return class'olextras.SPEnf';
	if (WeaponClass == class'GesBioRifle')
		return class'Botpack.UT_BioRifle';
	if (WeaponClass == class'ShockRifle' || WeaponClass == class'OSShockRifle')
		return class'ASMD';
	if (WeaponClass == class'Stinger' || WeaponClass == class'PulseGun' || WeaponClass == class'ospulsegun')
		return class'olextras.TVPulsegun';
	if (WeaponClass == class'UT_Eightball' || WeaponClass == class'olextras.TvEightBall')
		return class'EightBall';
	if (WeaponClass == class'ShockRifle' || WeaponClass == class'OSShockRifle')
		return class'ASMD';
	if (WeaponClass == class'UT_Eightball' || WeaponClass == class'olextras.TvEightBall')
		return class'EightBall';
	if (WeaponClass == class'Razorjack')
		return class'Botpack.Ripper';
	if (WeaponClass == class'Minigun')
		return class'Botpack.Minigun2';
	if (WeaponClass == class'FlakCannon')
		return class'Botpack.UT_flakcannon';
	if (WeaponClass == class'SniperRifle')
		return class'Rifle';

	return WeaponClass;
}

static function class<Ammo> ToPowerfulAmmoType(class<Ammo> AmmoClass)
{
	if (AmmoClass == class'ShellBox')
		return class'MiniAmmo';
	if (AmmoClass == class'Clip')
		return class'EClip';
	if (AmmoClass == class'Sludge')
		return class'BioAmmo';
	if (AmmoClass == class'ShockCore')
		return class'ASMDAmmo';
	if (AmmoClass == class'StingerAmmo')
		return class'PAmmo';
	if (AmmoClass == class'RocketPack')
		return class'RocketCan';
	if (AmmoClass == class'RazorAmmo')
		return class'BladeHopper';
	if (AmmoClass == class'FlakBox')
		return class'FlakAmmo';
	if (AmmoClass == class'FlakShellAmmo')
		return class'olWeapons.osFlakShellAmmo';
	if (AmmoClass == class'BulletBox')
		return class'RifleAmmo';
	if (AmmoClass == class'RifleShell')
		return class'RifleRound';

	return AmmoClass;
}

function class<Pickup> TravellingPickupTypeReplacement(class<Pickup> PickupClass)
{
	if (bUseClassicUnrealTravellingPickups)
	{
		if (PickupClass == class'olextras.TvFlashlight')
			return class'Flashlight';

		if (PickupClass == class'olextras.TVSearchLight')
			return class'SearchLight';

		if (PickupClass == class'olWeapons.osShieldBelt' || PickupClass == class'olWeapons.osut_ShieldBelt')
			return class'ShieldBelt';

		if (PickupClass == class'UT_ShieldBelt' || PickupClass == class'olWeapons.osPowerShield' || PickupClass == class'olWeapons.ShieldBeltPower')
			return class'PowerShield';

		if (PickupClass == class'Armor2')
			return class'Armor';

		if (PickupClass == class'ThighPads')
			return class'KevlarSuit';

		if (PickupClass == class'UT_JumpBoots')
			return class'JumpBoots';

		if (PickupClass == class'UT_Invisibility')
			return class'Invisibility';

		if (PickupClass == class'UDamage')
			return class'Amplifier';
	}
	else
	{
		if (!bDisableFlashlightReplacement)
		{
			if (PickupClass == class'FlashLight')
				return class'olextras.TvFlashlight';

			if (PickupClass == class'SearchLight')
				return class'olextras.TVSearchLight';
		}

		if (PickupClass == class'UT_ShieldBelt')
			return class'olWeapons.ospowershield';
	}

	return PickupClass;
}

function bool InventoryReplacement(Actor Other, bool bBasic)
{
	local class<Inventory> NewInventoryType;
	if (Inventory(Other) != none)
	{
		NewInventoryType = InventoryClassReplacement(class<Inventory>(Other.class), bBasic);
		if (NewInventoryType == none)
			return false;
		if (NewInventoryType != Other.class)
		{
			if (Inventory(Other) != none && Other.Instigator != none && Other.Location == Other.Instigator.Location)
				return false;
			return ReplaceWithFC(Other, NewInventoryType);
		}
	}
	return true;
}

function CheckSkaarjTrooperWeaponTypeReplacement(SkaarjTrooper Other)
{
	Other.WeaponType = class<Weapon>(InventoryClassReplacement(Other.WeaponType, true));
}

function CheckWeaponHolderWeaponTypeReplacement(WeaponHolder Other)
{
	Other.WeaponType = class<Weapon>(InventoryClassReplacement(Other.WeaponType, true));
}

function ScriptedPawnAdjustment(ScriptedPawn A)
{
	local float Dif;

	ScriptedPawnRangedProjectileReplacement(A);

	if (ClassIsChildOf(A.CarcassType, class'CreatureCarcass') &&
		A.CarcassType == A.default.CarcassType)
	{
		if (A.style != STY_Translucent)
			A.CarcassType = class'olCreatureCarcass';
		else
		{
			A.CarcassType = class'TranslucentCreatureCarcass';
			A.bGreenBlood = true; //for MClane's green skaarj.  Will affect all translucent creatures however!
		}
	}
	if (!A.Isa('follower'))
	{ //projectile speed thing
		Dif = FClamp(A.Skill + Level.Game.Difficulty, 0, 3);
		if (Dif>1.0)
			A.projectilespeed*=0.9+0.1*Dif;
	}
	if (A.IsA('Nali') && A.bShadowCast && !bUseClassicUnrealTravellingPickups && GameRulesPtr != none)
		GameRulesPtr.GivePickup(class'Tvflashlight', A);

	if (A.IsA('SkaarjTrooper'))
		CheckSkaarjTrooperWeaponTypeReplacement(SkaarjTrooper(A));
	else if (WeaponHolder(A) != none)
		CheckWeaponHolderWeaponTypeReplacement(WeaponHolder(A));
}

function ScriptedPawnRangedProjectileReplacement(ScriptedPawn P)
{
	if (class'olweapons.uiweapons'.default.busedecals)
	{
		if (P.RangedProjectile == Class'UnrealShare.BruteProjectile')
			P.RangedProjectile = Class'ONPBruteProjectile';
		else if (P.RangedProjectile == Class'Unreali.mercrocket')
			P.RangedProjectile = Class'ONPMercRocket';
		else if (P.RangedProjectile == Class'UnrealI.GasBagBelch')
			P.RangedProjectile = Class'TvGasBagBelch';
		else if (P.RangedProjectile == Class'UnrealI.KraalBolt')
			P.RangedProjectile = Class'ONPKraalBolt';
		else if (P.RangedProjectile == Class'UnrealI.EliteKrallBolt')
			P.RangedProjectile = Class'ONPEliteKrallBolt';
		else if (P.RangedProjectile == Class'Unrealshare.skaarjprojectile')
			P.RangedProjectile = Class'olextras.TVSkaarjProjectile';
		else if (P.RangedProjectile == Class'Unreali.queenprojectile')
			P.RangedProjectile = Class'oldskool.olqueenprojectile';
		else if (P.RangedProjectile == Class'Unrealshare.tentacleprojectile')
			P.RangedProjectile=Class'oldskool.oltentacleprojectile';
		else if (P.RangedProjectile == Class'SlithProjectile')
			P.RangedProjectile = Class'olSlithProjectile';
		else if (P.RangedProjectile == Class'Unreali.warlordrocket')
			P.RangedProjectile = Class'Tvwarlordrocket';
	}
}

function DecorationContentReplacement(Decoration A)
{
	if (CastToInventoryClass(A.contents) != none)
		A.contents = InventoryClassReplacement(CastToInventoryClass(A.contents), true);
	if (CastToInventoryClass(A.content2) != none)
		A.content2 = InventoryClassReplacement(CastToInventoryClass(A.content2), true);
	if (CastToInventoryClass(A.content3) != none)
		A.content3 = InventoryClassReplacement(CastToInventoryClass(A.content3), true);
}

function class<Inventory> CastToInventoryClass(class<Actor> aClass)
{
	return class<Inventory>(aClass);
}

function AdjustRealCrouchInfo(Actor A)
{
	A.SetPropertyText("bCanCrouchInAir", "false");
	A.SetPropertyText("bCanCrouchWhenSwimming", "false");
	A.SetPropertyText("bCanCrouchWhenFlying", "false");
	A.SetPropertyText("bCanCrouchToCeiling", "false");
	A.RemoteRole = ROLE_SimulatedProxy;
}

auto state MutatorState
{
Begin:
	AdjustDecorations();
	ReplaceMasterCreatureChunks();
}

function string GetHumanName()
{
	return "ONPCoopMutator v6.9";
}

defaultproperties
{
	VersionInfo="ONPCoopMutator v6.9 [2024-03-25]"
	Version="6.9"
	bAdjustNPCFriendlyFire=True
	bDisableFlashlightReplacement=True
	bDiscardItemsOnGameEnd=True
	bInfiniteSpecialItems=True
	bPreventFallingOutOfWorld=True
	bReplaceONPTranslocator=True
	bUseAircraftLevels=True
	bUseClassicUnrealTravellingPickups=False
	bUseONPHUD=False
	bUseONPPlayerPawnType=False
	bUseONPSpeech=False
	bUseONPWeaponsSupply=True
	bUseRealCrouch=True
	bUseSpeechMenuForU1Players=True
	WeaponReplacementMode=ONP-Basic
	ONPGameEndURL="NP02DavidM#"
	PXGameEndURL="ONP-map01FirstDayX#"
	PX0GameEndURL="ONP-map01FirstDayX#"
}
