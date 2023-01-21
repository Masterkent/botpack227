//=============================================================================
// TournamentGameInfo.
//
// default game info is normal single player
//
//=============================================================================
class TournamentGameInfo extends UTC_GameInfo
	config;

#exec AUDIO IMPORT FILE="Sounds\Generic\Resp2a.wav" NAME="Resp2A" GROUP="General"

var(DeathMessage) localized string DeathMessage[32];    // Player name, or blank if none.
var(DeathMessage) localized string DeathModifier[5];
var(DeathMessage) localized string MajorDeathMessage[8];
var(DeathMessage) localized string HeadLossMessage[2];
var(DeathMessage) localized string DeathVerb;
var(DeathMessage) localized string DeathPrep;
var(DeathMessage) localized string DeathTerm;
var(DeathMessage) localized string ExplodeMessage;
var(DeathMessage) localized string SuicideMessage;
var(DeathMessage) localized string FallMessage;
var(DeathMessage) localized string DrownedMessage;
var(DeathMessage) localized string BurnedMessage;
var(DeathMessage) localized string CorrodedMessage;
var(DeathMessage) localized string HackedMessage;
var(DeathMessage) localized string MortarMessage;
var(DeathMessage) localized string MaleSuicideMessage;
var(DeathMessage) localized string FemaleSuicideMessage;

var bool bRatedGame;

var class<Weapon> RedeemerClass;
var class<EndStats> EndStatsClass;

var int TotalGames;
var int TotalFrags;
var int TotalDeaths;
var int TotalFlags;

var string BestPlayers[3];
var int BestFPHs[3];
var string BestRecordDate[3];
var bool bDisallowOverride;

var() config bool B227_bAllowUnrealIPlayers;

var transient B227_PermissiveAccessManager B227_PermissiveAccessManager;

function bool AtCapacity(string Options)
{
	local string OverrideClass;

	OverrideClass = ParseOption ( Options, "OverrideClass" );
	if ( OverrideClass != "" )
		return ( (NumSpectators >= MaxSpectators)
				|| ((Level.Netmode == NM_ListenServer) && (NumPlayers == 0)) );
	return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}


event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	local string OverrideClass;
	local class<PlayerPawn> SpecClass;
	local string InVoice;
	local string InSkin, InFace;
	local byte InTeam;

	if ( !bRatedGame )
	{
		if ( !bDisallowOverride )
		{
			OverrideClass = ParseOption ( Options, "OverrideClass" );
			if ( OverrideClass != "" )
			{
				SpecClass = class<PlayerPawn>(DynamicLoadObject(OverrideClass,class'Class'));
				if ( (SpecClass != None) && ClassIsChildOf( SpecClass, class'CHSpectator') )
					SpawnClass = SpecClass;
			}
		}
		if ( ClassIsChildOf(SpawnClass, class'Spectator') )
		{
			if ( !ClassIsChildOf( SpawnClass, class'CHSpectator') )
				SpawnClass = class'CHSpectator';
		}
		else if ( !ClassIsChildOf(SpawnClass, class'TournamentPlayer') )
			SpawnClass = B227_TransformPlayerClass(SpawnClass);
	}
	else if ( !ClassIsChildOf(SpawnClass, class'TournamentPlayer') )
		SpawnClass = B227_TransformPlayerClass(SpawnClass);

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);

	if ( NewPlayer != None )
	{
		if ( !NewPlayer.IsA('Spectator') )
		{
			InVoice = ParseOption ( Options, "Voice" );
			if (InVoice != "")
				NewPlayer.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(InVoice, class'Class'));
			if (NewPlayer.PlayerReplicationInfo.VoiceType == none)
				NewPlayer.PlayerReplicationInfo.VoiceType = class'UTC_PlayerPawn'.static.B227_GetVoiceType(NewPlayer);
			if (NewPlayer.PlayerReplicationInfo.VoiceType == none)
				NewPlayer.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject("Botpack.VoiceMaleOne", class'Class'));

			InSkin = ParseOption(Options, "Skin");
			if (InSkin == "")
			{
				InTeam = GetIntOption(Options, "Team", 255 );
				InFace = ParseOption(Options, "Face");
				// super.Login skips calling SetMultiSkin when InSkin is empty,
				// but the skin must be set properly anyway
				NewPlayer.static.SetMultiSkin(NewPlayer, InSkin, InFace, InTeam);
			}
		}
	}

	return NewPlayer;
}


function float PlaySpawnEffect(inventory Inv)
{
	spawn( class 'EnhancedReSpawn',Inv,, Inv.Location );
	return 0.3;
}

function bool ShouldRespawn(Actor Other)
{
	return false;
}

static function string UTF_KillMessage(name damageType, pawn Other)
{
	local string message;

	if (damageType == 'Exploded')
		message = Default.ExplodeMessage;
	else if ( damageType == 'Eradicated' )
		message = Default.ExplodeMessage;
	else if (damageType == 'Suicided')
		message = Default.SuicideMessage;
	else if ( damageType == 'Fell' )
		message = Default.FallMessage;
	else if ( damageType == 'Drowned' )
		message = Default.DrownedMessage;
	else if ( damageType == 'Burned' )
		message = Default.BurnedMessage;
	else if ( damageType == 'Corroded' )
		message = Default.CorrodedMessage;
	else if ( damageType == 'Mortared' )
		message = Default.MortarMessage;
	else
		message = Default.DeathVerb$Default.DeathTerm;

	return message;
}

static function string UTF_CreatureKillMessage(name damageType, pawn Other)
{
	local string message;

	if (damageType == 'exploded')
		message = Default.ExplodeMessage;
	else if ( damageType == 'Eradicated' )
		message = Default.ExplodeMessage;
	else if ( damageType == 'Burned' )
		message = Default.BurnedMessage;
	else if ( damageType == 'Corroded' )
		message = Default.CorrodedMessage;
	else if ( damageType == 'Hacked' )
		message = Default.HackedMessage;
	else
		message = Default.DeathVerb$Default.DeathTerm;

	return ( message$Default.DeathPrep );
}

static function string UTF_PlayerKillMessage(name damageType, PlayerReplicationInfo Other)
{
	local string message;
	local float decision;

	decision = FRand();

	if ( decision < 0.2 )
		message = Default.MajorDeathMessage[Rand(3)];
	else
	{
		if ( DamageType == 'Decapitated' )
			message = Default.HeadLossMessage[Rand(2)];
		else 
			message = Default.DeathMessage[Rand(32)];

		if ( decision < 0.75 )
			message = Default.DeathModifier[Rand(5)]$message;
	}

	return ( Default.DeathVerb$message$Default.DeathPrep );
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
	local UTTeleportEffect PTE;

	if ( Incoming.bIsPawn && (Incoming.Mesh != None) )
	{
		if ( bSound )
		{
			PTE = Spawn(class'UTTeleportEffect',,, Incoming.Location, Incoming.Rotation);
			PTE.Initialize(Pawn(Incoming), bOut);
			Incoming.PlaySound(sound'Resp2A',, 10.0);
		}
	}
}

function BroadcastRegularDeathMessage(pawn Killer, pawn Other, name damageType)
{
	if (damageType == 'RedeemerDeath')
	{
		if ( RedeemerClass == None )
			RedeemerClass = class<Weapon>(DynamicLoadObject("Botpack.Warheadlauncher", class'Class'));
		BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, RedeemerClass);
	}
	else if (damageType == 'Eradicated')
		BroadcastLocalizedMessage(class'EradicatedDeathMessage', 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, None);
	else if ((damageType == 'RocketDeath') || (damageType == 'GrenadeDeath'))
		BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, class'UT_Eightball');
	else if (damageType == 'Gibbed')
		BroadcastLocalizedMessage(DeathMessageClass, 8, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, None);
	else {
		if (Killer.Weapon != None)
			BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, Killer.Weapon.Class);
		else
			BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, None);
	}
}

//
// Discard a player's inventory after he dies.
//
function DiscardInventory( Pawn Other )
{
	local actor dropped;
	local inventory Inv, NextInv;
	local weapon weap;
	local float speed;
	local LadderInventory MainLadderInventory;

	if( Other.DropWhenKilled != None )
	{
		dropped = Spawn(Other.DropWhenKilled,,,Other.Location);
		Inv = Inventory(dropped);
		if ( Inv != None )
		{ 
			Inv.RespawnTime = 0.0; //don't respawn
			Inv.BecomePickup();
		}
		if ( dropped != None )
		{
			dropped.RemoteRole = ROLE_DumbProxy;
			dropped.SetPhysics(PHYS_Falling);
			dropped.bCollideWorld = true;
			dropped.Velocity = Other.Velocity + VRand() * 280;
		}
		if ( Inv != None )
			Inv.GotoState('PickUp', 'Dropped');
	}
	if( (Other.Weapon!=None) && (Other.Weapon.Class!=BaseMutator.MutatedDefaultWeapon()) 
		&& ((Other.Weapon.Ammotype == None) || (Other.Weapon.Ammotype.AmmoAmount > 0))
		&& Other.Weapon.bCanThrow )
	{
		speed = VSize(Other.Velocity);
		weap = Other.Weapon;
		if (speed != 0)
			weap.Velocity = Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280);
		else {
			weap.Velocity.X = 0;
			weap.Velocity.Y = 0;
			weap.Velocity.Z = 0;
		}
		Other.TossWeapon();
	}
	Other.Weapon = None;
	Other.SelectedItem = None;

	// Destroy the inventory list.
	Inv = Other.Inventory;
	while (Inv != None)
	{
		NextInv = Inv.Inventory;
		if (!Inv.IsA('LadderInventory'))
			Inv.Destroy();
		else
			MainLadderInventory = LadderInventory(Inv);
		Inv = NextInv;
	}
	if (MainLadderInventory != None)
	{
		Other.Inventory = MainLadderInventory;
		MainLadderInventory = None;
	}
}

function CalcEndStats()
{
	local int i, j;
	local float FPH;
	local float CurrentSeconds, CurrentMinutes;
	local UTC_PlayerReplicationInfo PRI;

	for (i=0; i<3; i++)
	{
		BestPlayers[i] = EndStatsClass.Default.BestPlayers[i];
		BestFPHs[i] = EndStatsClass.Default.BestFPHs[i];
		BestRecordDate[i] = EndStatsClass.Default.BestRecordDate[i];
	}

	Log("!!!!!!!!!!!!!!! CALC END STATS");
	foreach AllActors(class'UTC_PlayerReplicationInfo', PRI)
	{
		if (PRI != None)
		{
			TotalFrags += PRI.Score;
			TotalDeaths += PRI.Deaths;
			CurrentSeconds = Level.TimeSeconds - PRI.StartTime;
			CurrentMinutes = CurrentSeconds / 60;
			FPH = PRI.Score / (CurrentMinutes / 60);
			for (j=2; j>=0; j--)
			{
				if (FPH > BestFPHs[j])
				{
					EmptyBestSlot(j);
					BestFPHs[j] = FPH;
					BestPlayers[j] = PRI.PlayerName;
					GetTimeStamp(BestRecordDate[j]);
					j = -1; // break.
				}
			}
		}
	}

	for (i=0; i<3; i++)
	{
		EndStatsClass.Default.BestPlayers[i] = BestPlayers[i];
		EndStatsClass.Default.BestFPHs[i] = BestFPHs[i];
		EndStatsClass.Default.BestRecordDate[i] = BestRecordDate[i];
	}
	EndStatsClass.Default.TotalFrags = TotalFrags;
	EndStatsClass.Default.TotalDeaths = TotalDeaths;
	EndStatsClass.Default.TotalGames++;
	EndStatsClass.Static.StaticSaveConfig();
}

function EmptyBestSlot(int Slot)
{
	if (Slot == 2)
	{
		BestFPHs[0] = BestFPHs[1];
		BestPlayers[0] = BestPlayers[1];
		BestRecordDate[0] = BestRecordDate[1];

		BestFPHs[1] = BestFPHs[2];
		BestPlayers[1] = BestPlayers[2];
		BestRecordDate[1] = BestRecordDate[2];
	} else if (Slot == 1) {
		BestFPHs[0] = BestFPHs[1];
		BestPlayers[0] = BestPlayers[1];
		BestRecordDate[0] = BestRecordDate[1];
	}
}

function GetTimeStamp(out string AbsoluteTime)
{
	if (Level.Month < 10)
		AbsoluteTime = "0"$Level.Month;
	else
		AbsoluteTime = string(Level.Month);

	if (Level.Day < 10)
		AbsoluteTime = AbsoluteTime$"/0"$Level.Day;
	else
		AbsoluteTime = AbsoluteTime$"/"$Level.Day;

	AbsoluteTime = AbsoluteTime$"/"$Level.Year;

	if (Level.Hour < 10)
		AbsoluteTime = AbsoluteTime$" 0"$Level.Hour;
	else
		AbsoluteTime = AbsoluteTime$" "$Level.Hour;

	if (Level.Minute < 10)
		AbsoluteTime = AbsoluteTime$":0"$Level.Minute;
	else
		AbsoluteTime = AbsoluteTime$":"$Level.Minute;

	if (Level.Second < 10)
		AbsoluteTime = AbsoluteTime$":0"$Level.Second;
	else
		AbsoluteTime = AbsoluteTime$":"$Level.Second;
}


event InitGame(string Options, out string Error)
{
	super.InitGame(Options, Error);
	if (Level.NetMode != NM_Standalone && class'B227_Config'.default.bEnableExtras)
		AddToPackagesMap("Botpack227_Extras");
}

function class<PlayerPawn> B227_TransformPlayerClass(class<PlayerPawn> PlayerClass)
{
	if (!class'B227_Config'.default.bEnableExtras ||
		!B227_bAllowUnrealIPlayers ||
		PlayerClass == none ||
		!ClassIsChildOf(PlayerClass, class'UnrealIPlayer') ||
		!ClassIsChildOf(PlayerClass, class'Human') && (bHumansOnly || Level.bHumansOnly) ||
		Level.NetMode != NM_Standalone && !IsInPackageMap("Botpack227_Extras"))
	{
		return DefaultPlayerClass;
	}

	if (!B227_ReplaceUnrealIPlayerClass(PlayerClass))
		return DefaultPlayerClass;

	if (class<TournamentPlayer>(PlayerClass) != none)
		return PlayerClass;

	B227_bAllowUnrealIPlayers = false;
	return DefaultPlayerClass;
}

static function bool B227_ReplaceUnrealIPlayerClass(out class<PlayerPawn> PlayerClass)
{
	switch (PlayerClass.default.Mesh)
	{
		case Mesh'UnrealShare.Female1':
			PlayerClass = B227_LoadPlayerClass("Botpack227_Extras.UT_FemaleOne");
			break;

		case Mesh'UnrealI.Female2':
			PlayerClass = B227_LoadPlayerClass("Botpack227_Extras.UT_FemaleTwo");
			break;

		case Mesh'UnrealI.Male1':
			PlayerClass = B227_LoadPlayerClass("Botpack227_Extras.UT_MaleOne");
			break;

		case Mesh'UnrealI.Male2':
			PlayerClass = B227_LoadPlayerClass("Botpack227_Extras.UT_MaleTwo");
			break;

		case Mesh'UnrealShare.Male3':
			PlayerClass = B227_LoadPlayerClass("Botpack227_Extras.UT_MaleThree");
			break;

		case Mesh'UnrealI.Nali2':
			PlayerClass = B227_LoadPlayerClass("Botpack227_Extras.UT_NaliPlayerA");
			break;

		case Mesh'UnrealI.sktrooper':
			PlayerClass = B227_LoadPlayerClass("Botpack227_Extras.UT_SkaarjPlayerA");
			break;

		default:
			return false;
	}

	return true;
}

static function class<PlayerPawn> B227_LoadPlayerClass(string PlayerClassName)
{
	return class<PlayerPawn>(DynamicLoadObject(PlayerClassName, class'Class', true));
}

defaultproperties
{
	DeathMessage(0)="killed"
	DeathMessage(1)="ruled"
	DeathMessage(2)="smoked"
	DeathMessage(3)="slaughtered"
	DeathMessage(4)="annihilated"
	DeathMessage(5)="put down"
	DeathMessage(6)="splooged"
	DeathMessage(7)="perforated"
	DeathMessage(8)="shredded"
	DeathMessage(9)="destroyed"
	DeathMessage(10)="whacked"
	DeathMessage(11)="canned"
	DeathMessage(12)="busted"
	DeathMessage(13)="creamed"
	DeathMessage(14)="smeared"
	DeathMessage(15)="shut out"
	DeathMessage(16)="beaten down"
	DeathMessage(17)="smacked down"
	DeathMessage(18)="pureed"
	DeathMessage(19)="sliced"
	DeathMessage(20)="diced"
	DeathMessage(21)="ripped"
	DeathMessage(22)="blasted"
	DeathMessage(23)="torn up"
	DeathMessage(24)="spanked"
	DeathMessage(25)="eviscerated"
	DeathMessage(26)="neutered"
	DeathMessage(27)="whipped"
	DeathMessage(28)="shafted"
	DeathMessage(29)="trashed"
	DeathMessage(30)="smashed"
	DeathMessage(31)="trounced"
	DeathModifier(0)="thoroughly "
	DeathModifier(1)="completely "
	DeathModifier(2)="absolutely "
	DeathModifier(3)="totally "
	DeathModifier(4)="utterly "
	MajorDeathMessage(0)="ripped a new one"
	MajorDeathMessage(1)="messed up real bad"
	MajorDeathMessage(2)="given a new definition of pain"
	HeadLossMessage(0)="decapitated"
	HeadLossMessage(1)="beheaded"
	DeathVerb=" was "
	DeathPrep=" by "
	DeathTerm="killed"
	ExplodeMessage=" was blown up."
	SuicideMessage=" had a sudden heart attack."
	FallMessage=" left a small crater."
	DrownedMessage=" forgot to come up for air."
	BurnedMessage=" was incinerated."
	CorrodedMessage=" was slimed."
	HackedMessage=" was hacked."
	MortarMessage=" was blown up by a mortar."
	MaleSuicideMessage=" killed his own dumb self."
	FemaleSuicideMessage=" killed her own dumb self."
	EndStatsClass=Class'Botpack.EndStats'
	DefaultPlayerClass=Class'Botpack.TMale1'
	DefaultWeapon=Class'Botpack.ImpactHammer'
	WaterZoneType=Class'UnrealShare.WaterZone'
	B227_bAllowUnrealIPlayers=True
}
