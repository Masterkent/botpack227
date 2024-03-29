class XidiaCoopMutator expands Mutator
	config(XidiaCoopMutator);

#exec obj load file="Botpack.u"
#exec obj load file="Xidia.u"

var() const string VersionInfo;
var() const string Version;

struct Remapping
{
	var() config string OriginalMap;
	var() config string SubstituteMap;
	var() config bool bApplyMapFixes;
};

var() config bool bReplaceUnrealWeapons;
var() config bool bUseXidiaJumpBoots; // Give XidiaJumpBoots to players on level XidiaES-Map6-BlackWidow
var() config bool bUseXidiaWeaponsSupply;
var() config bool bUseSpeechMenuForU1Players;
var() config string GameEndURL;
var() config array<Remapping> MapReplacements;

var XidiaGameRules GameRulesPtr;
var bool bGiveXidiaJumpBoots;

function PostBeginPlay()
{
	if (RemoveDuplicatedMutator())
		return;
	LevelStartupAdjustments();
	AddGameRules();
	RegisterXidiaLevelInfo();
	RegisterClientPackages();
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

function LevelStartupAdjustments()
{
	Level.bLonePlayer = false;
	Level.bSupportsRealCrouching = true;
	AdjustExplodingEffects();
	AdjustSpeechEvents();
	DeleteIrrelevantActors();
	DeleteRemovableMovers();
	DisableFadeViewTriggers();
	AdjustNextLevel();
	ReplaceMapInventory();
	ModifyCurrentMap();
	ReplaceTeleporters(); // Called after any URL adjustments
}

function AdjustLInfo(XidiaLevelInfo LInfo)
{
	local int i;

	for (i = 0; i < ArrayCount(LInfo.DefaultInventory); ++i)
		AdjustInventoryClass(LInfo.DefaultInventory[i]);
	for (i = 0; i < ArrayCount(LInfo.TriggeredInv); ++i)
		AdjustInventoryClass(LInfo.TriggeredInv[i]);
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

function AdjustSpeechEvents()
{
	local SpecialEvent aSpecialEvent;
	local SpecialerEvent aSpecialerEvent;

	foreach AllActors(class'SpecialEvent', aSpecialEvent)
	{
		if ((aSpecialEvent.InitialState == 'PlaySoundEffect' || aSpecialEvent.InitialState == 'PlayersPlaySoundEffect') &&
			aSpecialEvent.Sound != none &&
			IsXidiaSpeechSound(aSpecialEvent.Sound))
		{
			aSpecialEvent.Tag = '';
		}
	}
	foreach AllActors(class'SpecialerEvent', aSpecialerEvent)
		if (aSpecialerEvent.MyMessageType == 'Say')
			aSpecialerEvent.Tag = '';
}

function DeleteIrrelevantActors()
{
	local Actor A;

	foreach AllActors(class'Actor', A)
		if (A.bGameRelevant && !A.bNet)
			A.Destroy();
}

function DeleteRemovableMovers()
{
	local Mover Mover;

	foreach AllActors(class'Mover', Mover)
		if (!Mover.bStatic && !Mover.bNoDelete)
			Mover.Destroy();
}

function bool IsXidiaSpeechSound(Sound Sound)
{
	local name PackageName;

	PackageName = GetObjectPackageName(Sound);
	return
		PackageName == 'CrayLines1' ||
		PackageName == 'CrayLines2' ||
		PackageName == 'CrayLines3' ||
		PackageName == 'SpencerGameLines' ||
		PackageName == 'SpencerGenericLines';
}

function DisableFadeViewTriggers()
{
	local FadeViewTrigger Tr;
	foreach AllActors(class'FadeViewTrigger', Tr)
		Tr.Tag = '';
}

function ReplaceMapInventory()
{
	local Inventory Inv;

	foreach AllActors(class'Inventory', Inv)
		if (!Inv.bScriptInitialized && !InventoryReplacement(Inv))
			Inv.Destroy();
}

function AdjustInventoryClass(out class<Inventory> InventoryClass)
{
	InventoryClass = InventoryClassReplacement(InventoryClass);
}

function bool InventoryReplacement(Actor Other)
{
	local class<Inventory> NewInventoryType;

	if (Inventory(Other) != none)
	{
		NewInventoryType = InventoryClassReplacement(class<Inventory>(Other.class));
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

function class<Weapon> ToXidiaWeaponType(class<Weapon> WeaponClass)
{
	if (WeaponClass == class'Automag' || WeaponClass == class'olautomag')
		return class'XidiaAutomag';
	if (WeaponClass == class'ShockRifle' || WeaponClass == class'osShockRifle')
		return class'XidiaShockRifle';
	if (WeaponClass == class'PulseGun' || WeaponClass == class'osPulseGun')
		return class'TVPulsegun';
	if (WeaponClass == class'OLeightball')
		return class'Eightball';
	if (WeaponClass == class'UT_Eightball')
		return class'TVEightball';
	if (WeaponClass == class'SniperRifle')
		return class'XidiaSniperRifle';

	if (bReplaceUnrealWeapons)
	{
		if (WeaponClass == class'Stinger')
			return class'Xidia.MiningTool';
		if (WeaponClass == class'ASMD')
			return class'XidiaShockRifle';
		if (WeaponClass == class'FlakCannon')
			return class'UT_FlakCannon';
		if (WeaponClass == class'RazorJack')
			return class'Ripper';
		if (WeaponClass == class'GesBioRifle')
			return class'UT_BioRifle';
		if (WeaponClass == class'Rifle')
			return class'XidiaSniperRifle';
	}

	return WeaponClass;
}

function class<Ammo> ToXidiaAmmoType(class<Ammo> AmmoClass)
{
	if (AmmoClass == class'StingerAmmo')
		return class'Xidia.TarydiumAmmo';
	if (AmmoClass == class'ASMDAmmo')
		return class'ShockCore';
	if (AmmoClass == class'FlakBox')
		return class'FlakAmmo';
	if (AmmoClass == class'RazorAmmo')
		return class'BladeHopper';
	if (AmmoClass == class'Sludge')
		return class'BioAmmo';
	if (AmmoClass == class'RifleAmmo')
		return class'BulletBox';

	return AmmoClass;
}

function ModifyCurrentMap()
{
	local int i;
	local string CurrentMap;
	local bool bApplyMapFixes;

	CurrentMap = string(outer.name);

	bApplyMapFixes = true;
	for (i = 0; i < Array_Size(MapReplacements); ++i)
		if (MapReplacements[i].SubstituteMap ~= CurrentMap)
		{
			CurrentMap = MapReplacements[i].OriginalMap;
			bApplyMapFixes = MapReplacements[i].bApplyMapFixes;
			break;
		}
	if (CurrentMap == "")
		return;
	if (bApplyMapFixes)
		FixCurrentMap(CurrentMap);
	if (GameEndURL != "" && CurrentMap ~= "XidiaES-Map7-Beacon")
		SetNextLevel(GameEndURL);
}

function FixCurrentMap(string CurrentMap)
{
	Spawn(class'XidiaMapFixServer', self).Init(CurrentMap);
	Spawn(class'XidiaMapFixClient', self).Init(CurrentMap);
}

function ReplaceTeleporters()
{
	class'B227_SpawnableTeleporter'.static.ReplaceLevelTeleporters(Level);
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

function AddGameRules()
{
	GameRulesPtr = Spawn(class'XidiaGameRules', self);

	if (Level.Game.GameRules == None)
		Level.Game.GameRules = GameRulesPtr;
	else if (GameRulesPtr != None)
		Level.Game.GameRules.AddRules(GameRulesPtr);
}

function RegisterXidiaLevelInfo()
{
	local XidiaLevelInfo LInfo;

	foreach AllActors(class'XidiaLevelInfo', LInfo)
	{
		GameRulesPtr.LInfo = LInfo;
		AdjustLInfo(LInfo);
		return;
	}
}

function RegisterClientPackages()
{
	local string ClientPackageName;

	ClientPackageName = string(class'XidiaPlayerInteraction'.Outer.Name);
	if (!AddToPackagesMap(ClientPackageName))
		log("CRITICAL ERROR: XidiaCoopMutator: Failed to add" @ ClientPackageName @ "to the server packages map");
	AddToPackagesMap("Xidia");
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (!CheckXidiaReplacement(Other))
		return false;

	if (Inventory(Other) != none && Inventory(Other).bHeldItem)
		return true;

	if (!InventoryReplacement(Other))
		return false;

	if (other.class == class'ExplosionChain')
	{
		ReplaceExploChain(ExplosionChain(other));
		return false;
	}
	if (other.class == class'TranslatorBook')
	{
		ReplaceTransBook(TranslatorBook(other));
		return false;
	}
	if (other.class == class'TranslatorEvent')
	{
		ReplaceTransEvent(TranslatorEvent(Other));
		return false;
	}
	if (other.class == class'TvTranslatorEvent')
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
		Pawn(Other).DropWhenKilled = InventoryClassReplacement(Pawn(Other).DropWhenKilled);
	}
	else if (Decoration(Other) != none)
		DecorationContentReplacement(Decoration(Other));
	else if (Other.IsA('RealCrouchInfo'))
		AdjustRealCrouchInfo(Other);

	return true;
}

function bool CheckXidiaReplacement(Actor Other)
{
	if (Other.class == class'CodeConsole')
		return ReplaceCodeConsole(CodeConsole(Other));
	return true;
}

function bool ReplaceCodeConsole(CodeConsole Other)
{
	local XidiaCodeConsole A;
	A = Other.Spawn(class'XidiaCodeConsole', Other.Owner, Other.Tag);

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

function class<Inventory> InventoryClassReplacement(class<Inventory> InventoryClass)
{
	if (InventoryClass == none)
		return none;

	if (InventoryClass == class'TvTranslator')
		return class'Translator';

	if (ClassIsChildOf(InventoryClass, class'OLDpistol'))
		return class'DispersionPistol';
	if (ClassIsChildOf(InventoryClass, class'osDispersionPowerup'))
		return class'WeaponPowerUp';

	if (ClassIsChildOf(InventoryClass, class'Weapon'))
		return ToXidiaWeaponType(class<Weapon>(InventoryClass));
	if (bReplaceUnrealWeapons && ClassIsChildOf(InventoryClass, class'Ammo'))
		return ToXidiaAmmoType(class<Ammo>(InventoryClass));

	if (InventoryClass == class'UT_ShieldBelt')
		return class'olWeapons.ospowershield';

	return InventoryClass;
}

function CheckSkaarjTrooperWeaponTypeReplacement(SkaarjTrooper A)
{
	A.WeaponType = class<Weapon>(InventoryClassReplacement(A.WeaponType));
}

function CheckWeaponHolderWeaponTypeReplacement(WeaponHolder A)
{
	A.WeaponType = class<Weapon>(InventoryClassReplacement(A.WeaponType));
}

function ScriptedPawnAdjustment(ScriptedPawn A)
{
	if (SkaarjTrooper(A) != none)
		CheckSkaarjTrooperWeaponTypeReplacement(SkaarjTrooper(A));
	else if (WeaponHolder(A) != none)
		CheckWeaponHolderWeaponTypeReplacement(WeaponHolder(A));
}

function DecorationContentReplacement(Decoration A)
{
	if (CastToInventoryClass(A.contents) != none)
		A.contents = InventoryClassReplacement(CastToInventoryClass(A.contents));
	if (CastToInventoryClass(A.content2) != none)
		A.content2 = InventoryClassReplacement(CastToInventoryClass(A.content2));
	if (CastToInventoryClass(A.content3) != none)
		A.content3 = InventoryClassReplacement(CastToInventoryClass(A.content3));
}

function AdjustRealCrouchInfo(Actor A)
{
	A.SetPropertyText("bCanCrouchInAir", "false");
	A.SetPropertyText("bCanCrouchWhenSwimming", "false");
	A.SetPropertyText("bCanCrouchWhenFlying", "false");
	A.SetPropertyText("bCanCrouchToCeiling", "false");
	A.RemoteRole = ROLE_SimulatedProxy;
}

static function class<Inventory> CastToInventoryClass(class<Actor> aClass)
{
	return class<Inventory>(aClass);
}

function Actor ReplaceNonInv(Actor Other, class<actor> NewC)
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
	local XidiaTranslatorBook A;
	A = XidiaTranslatorBook(ReplaceNonInv(Other, class'XidiaTranslatorBook'));
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
	local XidiaTranslatorEvent A;
	A = XidiaTranslatorEvent(ReplaceNonInv(Other, class'XidiaTranslatorEvent'));
	if (A == none)
		return;

	A.Message = Other.Message;
	A.AltMessage = Other.AltMessage;
	A.NewMessageSound = Other.NewMessageSound;
	A.bTriggerAltMessage = Other.bTriggerAltMessage;
	A.ReTriggerDelay = Other.ReTriggerDelay;
}

function ReplaceTvTransEvent(TvTranslatorEvent Other)
{
	local XidiaTranslatorEvent A;
	A = XidiaTranslatorEvent(ReplaceNonInv(Other, class'XidiaTranslatorEvent'));
	if (A == none)
		return;

	A.Message = Other.Message;
	A.AltMessage = Other.AltMessage;
	A.NewMessageSound = Other.NewMessageSound;
	A.bTriggerAltMessage = Other.bTriggerAltMessage;
	A.ReTriggerDelay = Other.ReTriggerDelay;
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
		return false;
	}
	if (FRand() > Other.OddsOfAppearing)
	{
		return false;
	}
	if (Other.IsA('Inventory') && Other.Location == vect(0,0,0))
	{
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
		A.event = Other.event;
		A.tag = Other.tag;
		A.RotationRate = Other.RotationRate;
		return true;
	}
	return false;
}

function bool ReplaceWithFC(Actor Other, class<Actor> aClass)
{
	ReplaceWithC(Other, aClass);
	return false;
}

static function name GetObjectPackageName(Object X)
{
	while (X.Outer != none)
		X = X.Outer;
	return X.Name;
}

function string GetHumanName()
{
	return "XidiaCoopMutator v2.2";
}

defaultproperties
{
	VersionInfo="XidiaCoopMutator v2.2 [2024-03-26]"
	Version="2.2"
	bReplaceUnrealWeapons=False
	bUseXidiaJumpBoots=True
	bUseXidiaWeaponsSupply=True
	bUseSpeechMenuForU1Players=True
}
