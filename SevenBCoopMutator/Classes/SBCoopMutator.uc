class SBCoopMutator expands Mutator
	config(SevenBCoopMutator);

#exec obj load file="Botpack.u"

var() const string VersionInfo;
var() const string Version;

struct Remapping
{
	var() config string OriginalMap;
	var() config string SubstituteMap;
	var() config bool bApplyMapFixes;
};

var() config bool bModifyRogueScarredOne;
var() config bool bUseSpeech;
var() config bool bUseSpeechMenuForU1Players;
var() config bool bUseWeaponsSupply;
var() config string GameEndURL;
var() config array<Remapping> MapReplacements;

var string CurrentMap;
var SBGameRules GameRulesPtr;

function PostBeginPlay()
{
	LevelStartupAdjustments();
	AddGameRules();
	RegisterClientPackage();
}

function LevelStartupAdjustments()
{
	Level.bSupportsRealCrouching = true;
	AdjustPlantSpawners();
	AdjustSpeechEvents();
	DisableFadeViewTriggers();
	AdjustNextLevel();
	ModifyCurrentMap();
}

function AdjustPlantSpawners()
{
	local Actor A;

	foreach AllActors(class'Actor', A)
		if (A.IsA('UAplantspawner'))
			A.SetPropertyText("spreadintensity", "0");
}

function AdjustSpeechEvents()
{
	local SpecialEvent aSpecialEvent;
	local SpecialerEvent aSpecialerEvent;

	if (!bUseSpeech)
	{
		foreach AllActors(class'SpecialEvent', aSpecialEvent)
		{
			if ((aSpecialEvent.InitialState == 'PlaySoundEffect' || aSpecialEvent.InitialState == 'PlayersPlaySoundEffect') &&
				aSpecialEvent.sound != none &&
				(GetObjectPackageName(aSpecialEvent.sound) == '7BDialogue' || GetObjectPackageName(aSpecialEvent.sound) == '7BJonesSpeech'))
			{
				aSpecialEvent.Tag = '';
			}
		}
		foreach AllActors(class'SpecialerEvent', aSpecialerEvent)
			if (aSpecialerEvent.MyMessageType == 'Say')
				aSpecialerEvent.Tag = '';
	}
}

function DisableFadeViewTriggers()
{
	local FadeViewTrigger Tr;
	foreach AllActors(class'FadeViewTrigger', Tr)
		Tr.Tag = '';
}

function ModifyCurrentMap()
{
	local int i;
	local bool bApplyMapFixes;

	CurrentMap = string(Outer.Name);

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
	if (GameEndURL != "" && CurrentMap ~= "Jones-09-Scar")
		SetNextLevel(GameEndURL);
}

function FixCurrentMap(string CurrentMap)
{
	Spawn(class'SBMapFixServer', self).Init(CurrentMap);
	Spawn(class'SBMapFixClient', self).Init(CurrentMap);
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
	GameRulesPtr = Spawn(class'SBGameRules', self);

	if (Level.Game.GameRules == None)
		Level.Game.GameRules = GameRulesPtr;
	else if (GameRulesPtr != None)
		Level.Game.GameRules.AddRules(GameRulesPtr);
}
function RegisterClientPackage()
{
	local string ClientPackageName;

	ClientPackageName = string(class'SBPlayerInteraction'.outer.name);
	if (!AddToPackagesMap(ClientPackageName))
		log("CRITICAL ERROR: SBCoopMutator: Failed to add" @ ClientPackageName @ "to the server packages map");
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (!CheckSBReplacement(Other))
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

	if (Other.class == class'Botpack.SuperShockRifle')
	{
		Other.MultiSkins[1] = texture'Botpack.SASMD_t';
		Weapon(Other).bTravel = false;
		Weapon(Other).PickupAmmoCount = class'SuperShockCore'.default.MaxAmmo;
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

function bool CheckSBReplacement(Actor Other)
{
	if (Other.class == class'CodeConsole')
		return ReplaceCodeConsole(CodeConsole(Other));
	return true;
}

function bool ReplaceCodeConsole(CodeConsole Other)
{
	local SBCodeConsole A;
	A = Other.Spawn(class'SBCodeConsole', Other.Owner, Other.Tag);

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

	return InventoryClass;
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

function CheckSkaarjTrooperWeaponTypeReplacement(SkaarjTrooper A)
{
	A.WeaponType = class<Weapon>(InventoryClassReplacement(A.WeaponType));
}

function CheckWeaponHolderWeaponTypeReplacement(WeaponHolder A)
{
	local int i;
	for (i = 0; i < ArrayCount(A.WeaponType); ++i)
		A.WeaponType[i] = class<Weapon>(InventoryClassReplacement(A.WeaponType[i]));
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
	local SBTranslatorBook A;
	A = SBTranslatorBook(ReplaceNonInv(Other, class'SBTranslatorBook'));
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
	local SBTranslatorEvent A;
	A = SBTranslatorEvent(ReplaceNonInv(Other, class'SBTranslatorEvent'));
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
	local SBTranslatorEvent A;
	A = SBTranslatorEvent(ReplaceNonInv(Other, class'SBTranslatorEvent'));
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
	while (X.outer != none)
		X = X.outer;
	return X.name;
}

function string GetHumanName()
{
	return "SevenBCoopMutator v2.9";
}

defaultproperties
{
	VersionInfo="SevenBCoopMutator v2.9 [2022-09-23]"
	Version="2.9"
	bModifyRogueScarredOne=True
	bUseSpeech=False
	bUseSpeechMenuForU1Players=True
	bUseWeaponsSupply=True
}
