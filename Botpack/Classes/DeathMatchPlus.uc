//=============================================================================
// DeathMatchPlus.
//=============================================================================
class DeathMatchPlus extends TournamentGameInfo
	config;

// Sounds
#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var() globalconfig int  MinPlayers;		// bots fill in to guarantee this level in net game
var() globalconfig float AirControl;
var() config int	FragLimit;
var() config int	TimeLimit; // time limit in minutes
var() globalconfig bool bChangeLevels;
var() globalconfig bool bHardCoreMode;
var   bool			    bChallengeMode;
var() globalconfig bool bMegaSpeed;
var() globalconfig bool	bAltScoring;
var() config bool	bMultiWeaponStay;
var() config bool	bForceRespawn;
var		bool	bAlwaysForceRespawn;
var		bool	bDontRestart;
var		bool	bAlreadyChanged;
var		bool	bFirstBlood;

var() globalconfig bool bTournament;
var  bool bRequireReady;
var() bool bNoviceMode;
var() globalconfig int NetWait; // time to wait for players in netgames w/ bNetReady (typically team games)
var() globalconfig int RestartWait;
var config bool bUseTranslocator;
var bool bJumpMatch;
var bool bThreePlus;
var bool bFulfilledSpecial;
var bool	bNetReady;
var bool bRatedTranslocator;
var bool bStartMatch;

var	int RemainingTime, ElapsedTime;
var int CountDown, StartCount;
var localized string StartUpMessage;
var localized string TourneyMessage;
var localized string WaitingMessage1;
var localized string WaitingMessage2;
var localized string ReadyMessage;
var localized string NotReadyMessage;
var localized string CountDownMessage;
var localized string StartMessage;
var localized string GameEndedMessage;
var localized string SingleWaitingMessage;
var localized string gamegoal;

var float LastTauntTime;
var NavigationPoint LastStartSpot;
var() config int	MaxCommanders;
var int   NumCommanders;

var bool bTutorialGame;

// Bot related info
var   int				NumBots;
var	  int				RemainingBots;
var	  int				LastTaunt[4];
var() globalconfig int	InitialBots;
var	ChallengeBotInfo	BotConfig;
var localized string	NoNameChange, OvertimeMessage;
var class<ChallengeBotInfo>		BotConfigType;

// Player rating variables for single player rated games
var float PlayerRating, AvgOpponentRating;
var int NumOpp, WinCount, LoseCount;
var PlayerPawn RatedPlayer;
var int IDnum;
var RatedMatchInfo RatedMatchConfig;
var float EndTime;
var int LadderTypeIndex;

var LadderInventory RatedGameLadderObj;

var globalconfig bool B227_bFixedBotCount;
var globalconfig bool B227_bMapFixMutator;

var int B227_ElapsedTime; // Actual match time without waiting at startup phase
var bool B227_bGenderedMessagesSupported;
var bool B227_bGivePendingWeapons;

function PostBeginPlay()
{
	if ( bAlternateMode )
	{
		bVeryLowGore = true;
		bLowGore = true;
	}
	BotConfig = spawn(BotConfigType);
	if ( Level.NetMode == NM_Standalone )
		RemainingBots = InitialBots;
	else
		RemainingBots = 0;
	Super.PostBeginPlay();
	GameReplicationInfo.RemainingTime = RemainingTime;
	B227_bGenderedMessagesSupported = DynamicLoadObject("Engine.GameInfo.FemEnteredMessage", class'Property', true) != none;
}

function PreCacheReferences()
{
	//never called - here to force precaching of meshes
	spawn(class'TMale1');
	spawn(class'TMale2');
	spawn(class'TFemale1');
	spawn(class'TFemale2');
	spawn(class'ImpactHammer');
	spawn(class'Translocator');
	spawn(class'Enforcer');
	spawn(class'UT_Biorifle');
	spawn(class'ShockRifle');
	spawn(class'PulseGun');
	spawn(class'Ripper');
	spawn(class'Minigun2');
	spawn(class'UT_FlakCannon');
	spawn(class'UT_Eightball');
	spawn(class'SniperRifle');
}

function CheckReady()
{
	if ( (FragLimit == 0) && (TimeLimit == 0) )
	{
		TimeLimit = 20;
		RemainingTime = 60 * TimeLimit;
	}
}

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
	GameSpeed = FMax(T, 0.1);
	if ( bHardCoreMode )
	{
		if ( bChallengeMode )
			Level.TimeDilation = 1.25 * GameSpeed;
		else
			Level.TimeDilation = 1.1 * GameSpeed;
	}
	else
		Level.TimeDilation = GameSpeed;
	SaveConfig();
	SetTimer(Level.TimeDilation, true);
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
	local UTTeleportEffect PTE;

	if ( bRequireReady && (Countdown > 0) )
		return;

	if ( Incoming.bIsPawn && (Incoming.Mesh != None) )
	{
		if ( bSound )
		{
			PTE = Spawn(class'UTTeleportEffect',Incoming,, Incoming.Location, Incoming.Rotation);
			PTE.Initialize(Pawn(Incoming), bOut);
			PTE.PlaySound(sound'Resp2A',, 10.0);
		}
	}
}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;

	Super.InitGame(Options, Error);

	RemainingTime = 60 * TimeLimit;
	SetGameSpeed(GameSpeed);
	FragLimit = GetIntOption( Options, "FragLimit", FragLimit );
	TimeLimit = GetIntOption( Options, "TimeLimit", TimeLimit );
	MaxCommanders = GetIntOption( Options, "MaxCommanders", MaxCommanders );

	InOpt = ParseOption( Options, "CoopWeaponMode");
	if ( InOpt != "" )
	{
		log("CoopWeaponMode: "$bool(InOpt));
		bCoopWeaponMode = bool(InOpt);
	}

	IDnum = -1;
	IDnum = GetIntOption( Options, "Tournament", IDnum );
	if ( IDnum > 0 )
	{
		bRatedGame = true;
		TimeLimit = 0;
		RemainingTime = 0;
	}
	if ( bTournament )
	{
		bRequireReady = true;
		CheckReady();
	}
	if ( Level.NetMode == NM_StandAlone )
	{
		bRequireReady = true;
		CountDown = 1;
	}
	if ( !bRequireReady && (Level.NetMode != NM_Standalone) )
	{
		bRequireReady = true;
		bNetReady = true;
	}

	if (B227_bMapFixMutator)
		B227_AddMapFixMutator();
}

// Set game settings based on ladder information.
// Called when RatedPlayer logs in.
function InitRatedGame(LadderInventory LadderObj, PlayerPawn LadderPlayer)
{
	local class<RatedMatchInfo> RMI;
	local Weapon W;

	FragLimit = LadderObj.CurrentLadder.Default.FragLimits[IDnum];
	RatedGameLadderObj = LadderObj;
	if (LadderObj.CurrentLadder.Default.TimeLimits[IDnum] > 0)
		TimeLimit = LadderObj.CurrentLadder.Default.TimeLimits[IDnum];
	bJumpMatch = false;
	bHardCoreMode = true;
	bRequireReady = true;
	bMegaSpeed = false;
	CountDown = 1;
	bRatedGame = true;
	bCoopWeaponMode = false;
	bUseTranslocator = bRatedTranslocator;
	ForEach AllActors(class'Weapon', W)
		W.bWeaponStay = false;

	RatedPlayer = LadderPlayer;

	// Set up RatedBotConfig for this game
	BotConfig.bAdjustSkill = false;
	RMI = LadderObj.CurrentLadder.Static.GetMatchConfigType(IDnum);
	RatedMatchConfig = spawn(RMI);
	RemainingBots = RatedMatchConfig.NumBots;
	Difficulty = LadderObj.TournamentDifficulty + RatedMatchConfig.ModifiedDifficulty;
	if ( Difficulty >= 4 )
	{
		bNoviceMode = false;
		Difficulty = Difficulty - 4;
	}
	else
	{
		if ( Difficulty > 3 )
		{
			Difficulty = 3;
			bThreePlus = true;
		}
		bNoviceMode = true;
	}

	// Update GRI
	InitGameReplicationInfo();

	// Update Logged Info
	if (bLocalLog && bLoggingGame)
	{
		LogGameParameters(LocalLog);
	}
	if (bWorldLog && bLoggingGame)
	{
		LogGameParameters(WorldLog);
	}

	PlayStartupMessage(LadderPlayer);
	LadderPlayer.SetProgressTime(6);
}

/* AcceptInventory()
Examine the passed player's inventory, and accept or discard each item
* AcceptInventory needs to gracefully handle the case of some inventory
being accepted but other inventory not being accepted (such as the default
weapon).  There are several things that can go wrong: A weapon's
AmmoType not being accepted but the weapon being accepted -- the weapon
should be killed off. Or the player's selected inventory item, active
weapon, etc. not being accepted, leaving the player weaponless or leaving
the HUD inventory rendering messed up (AcceptInventory should pick another
applicable weapon/item as current).
*/
function AcceptInventory(pawn PlayerPawn)
{
	local inventory Inv;
	local LadderInventory LadderObj;

	// DeathMatchPlus accepts LadderInventory
	for( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if (Inv.IsA('LadderInventory'))
		{
			LadderObj = LadderInventory(Inv);
		}
		else
			Inv.Destroy();
	}
	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
	AddDefaultInventory( PlayerPawn );
}

function bool SetEndCams(string Reason)
{
	local pawn P, Best;
	local PlayerPawn Player;

	// find individual winner
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.PlayerReplicationInfo != none && !P.IsA('Spectator') && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
			Best = P;

	// check for tie
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.PlayerReplicationInfo != none && (Best != P) && (P.PlayerReplicationInfo.Score == Best.PlayerReplicationInfo.Score) )
		{
			BroadcastLocalizedMessage( DMMessageClass, 0 );
			return false;
		}

	EndTime = Level.TimeSeconds + 3.0;
	if (Best != none)
		GameReplicationInfo.GameEndedComments = Best.PlayerReplicationInfo.PlayerName@GameEndedMessage;
	else
		GameReplicationInfo.GameEndedComments = "";
	log( "Game ended at "$EndTime);
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		Player = PlayerPawn(P);
		if ( Player != None )
		{
			if (!bTutorialGame)
				PlayWinMessage(Player, (Player == Best));
			Player.bBehindView = true;
			if ( Player == Best )
				Player.ViewTarget = None;
			else
				Player.ViewTarget = Best;
			Player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	CalcEndStats();
	return true;
}

function PlayWinMessage(PlayerPawn Player, bool bWinner)
{
	if ( Player.IsA('TournamentPlayer') )
		TournamentPlayer(Player).PlayWinMessage(bWinner);
}

function NotifySpree(Pawn Other, int num)
{
	local Pawn P;

	if ( num == 5 )
		num = 0;
	else if ( num == 10 )
		num = 1;
	else if ( num == 15 )
		num = 2;
	else if ( num == 20 )
		num = 3;
	else if ( num == 25 )
		num = 4;
	else
		return;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if (TournamentPlayer(P) != none)
			TournamentPlayer(P).ReceiveLocalizedMessage(class'KillingSpreeMessage', Num, Other.PlayerReplicationInfo);
}

function EndSpree(Pawn Killer, Pawn Other)
{
	local Pawn P;

	if (Other.PlayerReplicationInfo == none)
		return;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if (TournamentPlayer(P) != none)
		{
			if (Killer == None)
				TournamentPlayer(P).EndSpree(None, Other.PlayerReplicationInfo);
			else if (Killer.PlayerReplicationInfo != none)
				TournamentPlayer(P).EndSpree(Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo);
			else
				TournamentPlayer(P).B227_EndSpree(Killer, Other);
		}
}

function ScoreKill(pawn Killer, pawn Other)
{
	Super.ScoreKill(Killer, Other);

	if ( bAltScoring && (Killer != Other) && (killer != None) && Other.PlayerReplicationInfo != none )
		Other.PlayerReplicationInfo.Score -= 1;
}

// Monitor killed messages for fraglimit
function Killed(pawn killer, pawn Other, name damageType)
{
	local int NextTaunt, i;
	local bool bAutoTaunt, bEndOverTime;
	local Pawn P, Best;

	if ( (damageType == 'Decapitated') && (Killer != Other) && (Killer != None) && Killer.PlayerReplicationInfo != none )
	{
		if (Other.PlayerReplicationInfo != none)
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("headshot", Killer.PlayerReplicationInfo.PlayerID, Other.PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("headshot", Killer.PlayerReplicationInfo.PlayerID, Other.PlayerReplicationInfo.PlayerID);
		}
		class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Killer, class'DecapitationMessage');
	}

	Super.Killed(killer, Other, damageType);

	if ( Other.Spree > 4 )
		EndSpree(Killer, Other);
	Other.Spree = 0;

	if ( !bTeamGame )
	{
		if ( bOverTime )
		{
			bEndOverTime = true;
			//check for clear winner now
			// find individual winner
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.PlayerReplicationInfo != none && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
					Best = P;

			// check for tie
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.PlayerReplicationInfo != none && (Best != P) && (P.PlayerReplicationInfo.Score == Best.PlayerReplicationInfo.Score) )
				{
					bEndOverTime = false;
					break;
				}

			if ( bEndOverTime )
			{
				if ( (FragLimit > 0) && (Best != none && Best.PlayerReplicationInfo.Score >= FragLimit) )
					EndGame("fraglimit");
				else
					EndGame("timelimit");
			}
		}
		else if ( (FragLimit > 0) && (killer != None) && (killer.PlayerReplicationInfo != None)
				&& (killer.PlayerReplicationInfo.Score >= FragLimit) )
			EndGame("fraglimit");
	}

	if ( (killer == None) || (Other == None) )
		return;
	if ( !bFirstBlood )
		if ( Killer.PlayerReplicationInfo != none && (Killer != Other) )
			if (!Self.IsA('TrainingDM'))
			{
				bFirstBlood = True;
				BroadcastLocalizedMessage( class'FirstBloodMessage', 0, Killer.PlayerReplicationInfo );
			}

	if ( BotConfig.bAdjustSkill && (killer.IsA('PlayerPawn') || Other.IsA('PlayerPawn')) )
	{
		if ( Bot(killer) != none )
			BotConfig.AdjustSkill(Bot(killer),true);
		if ( Bot(Other) != none )
			BotConfig.AdjustSkill(Bot(Other),false);
	}

	if ( Other.PlayerReplicationInfo != none && (Killer != None) && Killer.PlayerReplicationInfo != none && (Killer != Other)
		&& (!bTeamGame || (Other.PlayerReplicationInfo.Team != Killer.PlayerReplicationInfo.Team)) )
	{
		Killer.Spree++;
		if ( Killer.Spree > 4 )
			NotifySpree(Killer, Killer.Spree);
	}

	bAutoTaunt = ((TournamentPlayer(Killer) != None) && TournamentPlayer(Killer).bAutoTaunt);
	if ( ((Bot(Killer) != None && !class'TournamentPlayer'.default.bNoAutoTaunts) || bAutoTaunt)
		&& (Killer != Other) && (DamageType != 'gibbed') && (Killer.Health > 0)
		&& Killer.PlayerReplicationInfo != none
		&& (Level.TimeSeconds - LastTauntTime > 3) )
	{
		LastTauntTime = Level.TimeSeconds;
		NextTaunt = Rand(class<ChallengeVoicePack>(Killer.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
		for ( i=0; i<4; i++ )
		{
			if ( NextTaunt == LastTaunt[i] )
				NextTaunt = Rand(class<ChallengeVoicePack>(Killer.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
			if ( i > 0 )
				LastTaunt[i-1] = LastTaunt[i];
		}
		LastTaunt[3] = NextTaunt;
		class'UTC_Pawn'.static.UTSF_SendGlobalMessage(killer, none, 'AUTOTAUNT', NextTaunt, 5);
	}
	if ( bRatedGame )
		RateVs(Other, Killer);
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local playerpawn NewPlayer;

	if ( (Level.NetMode != NM_Standalone) && (NumCommanders >= MaxCommanders) && ClassIsChildOf(SpawnClass, class'Commander') )
	{
		Error="Max commanders "$MaxCommanders$" exceeded";
		return None;
	}

	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);

	if ( NewPlayer != None )
	{
		if ( bRatedGame )
			NewPlayer.AirControl = 0.35;
		else
			NewPlayer.AirControl = AirControl;
		if ( Left(NewPlayer.PlayerReplicationInfo.PlayerName, 6) == DefaultPlayerName )
		{
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("forced_name_change", NewPlayer.PlayerReplicationInfo.PlayerName, NewPlayer.PlayerReplicationInfo.PlayerID, DefaultPlayerName$NumPlayers);
			ChangeName( NewPlayer, (DefaultPlayerName$NumPlayers), false );
		}
		NewPlayer.bAutoActivate = true;
		if ( (bGameEnded || (bRequireReady && (CountDown > 0))) && !NewPlayer.IsA('Spectator') )
			NewPlayer.PlayerRestartState = 'PlayerWaiting';
		else
			NewPlayer.PlayerRestartState = NewPlayer.Default.PlayerRestartState;

		if ( NewPlayer.IsA('TournamentPlayer') )
		{
			TournamentPlayer(NewPlayer).StartSpot = LastStartSpot;
			if ( NewPlayer.IsA('Commander') )
				NumCommanders++;
		}
	}
	return NewPlayer;
}

event PostLogin( playerpawn NewPlayer )
{
	Super.PostLogin(NewPlayer);
	if ( Level.NetMode == NM_Standalone )
	{
		while ( (RemainingBots > 0) && AddBot() )
			RemainingBots--;
	}
	else
		RemainingBots = 0;

	if ( !bRatedGame )
	{
		PlayStartUpMessage(NewPlayer);
		NewPlayer.SetProgressTime(6);
	}
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if (injured.Region.Zone.bNeutralZone)
		return 0;

	if ( instigatedBy == None)
		return Damage;

	if ( bHardCoreMode )
		Damage *= 1.5;
	if ( bNoviceMode && !bThreePlus )
	{
		if ( instigatedBy.PlayerReplicationInfo != none && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
			Damage *= 0.5;

		//skill level modification
		if ( Bot(instigatedBy) != none && PlayerPawn(injured) != none )
		{
			if ( ((instigatedBy.Weapon != None) && instigatedBy.Weapon.bMeleeWeapon)
				|| ((injured.Weapon != None) && injured.Weapon.bMeleeWeapon && (VSize(injured.location - instigatedBy.Location) < 600)) )
				Damage = Damage * (0.76 + 0.08 * instigatedBy.skill);
			else
				Damage = Damage * (0.25 + 0.15 * instigatedBy.skill);
		}
	}
	return (Damage * instigatedBy.DamageScaling);
}

function StartMatch()
{
	local Pawn P;
	local TimedTrigger T;

	if (LocalLog != None)
		LocalLog.LogGameStart();
	if (WorldLog != None)
		WorldLog.LogGameStart();

	ForEach AllActors(class'TimedTrigger', T)
		T.SetTimer(T.DelaySeconds, T.bRepeating);
	if ( Level.NetMode != NM_Standalone )
		RemainingBots = 0;
	if (B227_GRI() != none)
		B227_GRI().RemainingMinute = RemainingTime;
	bStartMatch = true;

	// start players first (in their current startspots)
	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
		if (PlayerPawn(P) != none)
		{
			if ( bGameEnded ) return; // telefrag ended the game with ridiculous frag limit
			else if ( !P.IsA('Spectator')  )
			{
				P.PlayerRestartState = P.Default.PlayerRestartState;
				P.GotoState(P.Default.PlayerRestartState);
				if ( !P.IsA('Commander') )
				{
					if ( !RestartPlayer(P) )
						P.GotoState('Dying'); //failed to restart player, so let him try to respawn again
				}
			}
			SendStartMessage(PlayerPawn(P));
		}


	for ( P = Level.PawnList; P!=None; P=P.nextPawn )
		if (P.PlayerReplicationInfo != none && PlayerPawn(P) == none)
		{
			P.RestartPlayer();
			if (Bot(P) != none)
				Bot(P).StartMatch();
		}
	bStartMatch = false;
}


function Timer()
{
	local Pawn P;
	local bool bReady;

	Super.Timer();
	if (B227_GRI() == none)
		return;

	B227_UpdateGRILimits();

	if ( bNetReady )
	{
		if ( NumPlayers > 0 )
			ElapsedTime++;
		else
			ElapsedTime = 0;
		if ( ElapsedTime > NetWait )
		{
			if ( (NumPlayers + NumBots < 4) && NeedPlayers() )
				AddBot();
			else if ( (NumPlayers + NumBots > 1) || ((NumPlayers > 0) && (ElapsedTime > 2 * NetWait)) )
				bNetReady = false;
		}

		if ( bNetReady )
		{
			for (P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('PlayerPawn') )
					PlayerPawn(P).SetProgressTime(2);
			B227_UpdateGRITime();
			return;
		}
		else
		{
			while ( NeedPlayers() )
				AddBot();
			bRequireReady = false;
			StartMatch();
		}
	}

	if ( bRequireReady && (CountDown > 0) )
	{
		while ( (RemainingBots > 0) && AddBot() )
			RemainingBots--;
		for (P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( P.IsA('PlayerPawn') )
				PlayerPawn(P).SetProgressTime(2);
		if ( ((NumPlayers == MaxPlayers) || (Level.NetMode == NM_Standalone))
				&& (RemainingBots <= 0) )
		{
			bReady = true;
			for (P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('PlayerPawn') && !P.IsA('Spectator')
					&& !PlayerPawn(P).bReadyToPlay )
					bReady = false;

			if ( bReady )
			{
				StartCount = 30;
				CountDown--;
				if ( CountDown <= 0 )
					StartMatch();
				else
				{
					for ( P = Level.PawnList; P!=None; P=P.nextPawn )
						if ( P.IsA('PlayerPawn') )
						{
							PlayerPawn(P).ClearProgressMessages();
							if ( (CountDown < 11) && P.IsA('TournamentPlayer') )
								TournamentPlayer(P).TimeMessage(CountDown);
							else
								PlayerPawn(P).SetProgressMessage(CountDown$CountDownMessage, 0);
						}
				}
			}
			else if ( StartCount > 8 )
			{
				for ( P = Level.PawnList; P!=None; P=P.nextPawn )
					if ( P.IsA('PlayerPawn') )
					{
						PlayerPawn(P).ClearProgressMessages();
						PlayerPawn(P).SetProgressTime(2);
						PlayerPawn(P).SetProgressMessage(WaitingMessage1, 0);
						PlayerPawn(P).SetProgressMessage(WaitingMessage2, 1);
						if ( PlayerPawn(P).bReadyToPlay )
							PlayerPawn(P).SetProgressMessage(ReadyMessage, 2);
						else
							PlayerPawn(P).SetProgressMessage(NotReadyMessage, 2);
					}
			}
			else
			{
				StartCount++;
				if ( Level.NetMode != NM_Standalone )
					StartCount = 30;
			}
		}
		else
		{
			for ( P = Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.IsA('PlayerPawn') )
					PlayStartupMessage(PlayerPawn(P));
		}
	}
	else
	{
		if ( bAlwaysForceRespawn || (bForceRespawn && (Level.NetMode != NM_Standalone)) )
			For ( P=Level.PawnList; P!=None; P=P.NextPawn )
			{
				if ( P.IsInState('Dying') && P.IsA('PlayerPawn') && P.bHidden )
					PlayerPawn(P).ServerReStartPlayer();
			}
		if ( Level.NetMode != NM_Standalone )
		{
			if ( NeedPlayers() )
				AddBot();
		}
		else
			while ( (RemainingBots > 0) && AddBot() )
				RemainingBots--;
		if ( bGameEnded )
		{
			if ( Level.TimeSeconds > EndTime + RestartWait )
				RestartGame();
		}
		else
		{
			B227_ElapsedTime++;
			if ( !bOverTime && (B227_TimeLimitSeconds() > 0) )
			{
				B227_GRI().bStopCountDown = false;
				RemainingTime = B227_TimeLimitSeconds() - B227_ElapsedTime;
				if ( RemainingTime % 60 == 0 )
					B227_GRI().RemainingMinute = RemainingTime;
				if ( RemainingTime <= 0 )
					EndGame("timelimit");
			}
			else
			{
				ElapsedTime++;
				B227_GRI().ElapsedTime = B227_ElapsedTime;
				if (TimeLimit > 0)
					RemainingTime = 0;
			}
		}
	}

	B227_UpdateGRITime();
}

function bool TooManyBots()
{
	return !B227_bFixedBotCount && (NumBots + NumPlayers > MinPlayers);
}

function bool RestartPlayer( pawn aPlayer )
{
	local Bot B;
	local bool bResult;

	aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
	B = Bot(aPlayer);
	if ( (B != None)
		&& (Level.NetMode != NM_Standalone)
		&& TooManyBots() )
	{
		aPlayer.Destroy();
		return false;
	}

	if (aPlayer.Weapon != none && !aPlayer.Weapon.bDeleteMe)
	{
		aPlayer.Weapon.GotoState('');
		aPlayer.Weapon = none;
	}

	B227_Player = aPlayer;
	bResult = Super.RestartPlayer(aPlayer);
	B227_Player = none;

	if ( aPlayer.IsA('TournamentPlayer') )
		TournamentPlayer(aPlayer).StartSpot = LastStartSpot;
	return bResult;
}

function SendStartMessage(PlayerPawn P)
{
	P.ClearProgressMessages();
	P.SetProgressMessage(StartMessage, 0);
}

function Bot SpawnBot(out NavigationPoint StartSpot)
{
	local bot NewBot;
	local int BotN;
	local Pawn P;

	if ( bRatedGame )
		return SpawnRatedBot(StartSpot);

	Difficulty = BotConfig.Difficulty;

	if ( Difficulty >= 4 )
	{
		bNoviceMode = false;
		Difficulty = Difficulty - 4;
	}
	else
	{
		if ( Difficulty > 3 )
		{
			Difficulty = 3;
			bThreePlus = true;
		}
		bNoviceMode = true;
	}
	BotN = BotConfig.ChooseBotInfo();

	// Find a start spot.
	StartSpot = UTF_FindPlayerStart(None, 255);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return None;
	}

	// Try to spawn the bot.
	NewBot = Spawn(BotConfig.CHGetBotClass(BotN),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot == None )
		log("Couldn't spawn player at " $ StartSpot);
	else if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		log("can't add non-human bot to this game");
		NewBot.Destroy();
		NewBot = None;
	}

	if ( NewBot == None )
		NewBot = Spawn(BotConfig.CHGetBotClass(0),,,StartSpot.Location,StartSpot.Rotation);

	if ( NewBot != None )
	{
		if (class'UTC_Pawn'.static.B227_GetPRI(NewBot) == none)
		{
			NewBot.Destroy();
			return none;
		}
		// Set the player's ID.
		class'UTC_Pawn'.static.B227_GetPRI(NewBot).B227_SetPlayerID(CurrentID++);

		NewBot.PlayerReplicationInfo.Team = BotConfig.GetBotTeam(BotN);
		BotConfig.CHIndividualize(NewBot, BotN, NumBots);
		NewBot.ViewRotation = StartSpot.Rotation;
		// broadcast a welcome message.
		BroadcastMessage(B227_PlayerEnteredMessage(NewBot), false);

		ModifyBehaviour(NewBot);
		AddDefaultInventory( NewBot );
		NumBots++;
		if ( bRequireReady && (CountDown > 0) )
		{
			NewBot.GotoState('Dying', 'WaitingForStart');
			NewBot.SetCollision(false, false, false);
			NewBot.SetPhysics(PHYS_None);
		}
		NewBot.AirControl = AirControl;

		if ( (Level.NetMode != NM_Standalone) && (bNetReady || bRequireReady) )
		{
			// replicate skins
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if (UTC_PlayerReplicationInfo(P.PlayerReplicationInfo) != none &&
					UTC_PlayerReplicationInfo(P.PlayerReplicationInfo).bWaitingPlayer &&
					UTC_PlayerPawn(P) != none)
				{
					if (NewBot.bIsMultiSkinned)
						UTC_PlayerPawn(P).ClientReplicateSkins(NewBot.MultiSkins[0], NewBot.MultiSkins[1], NewBot.MultiSkins[2], NewBot.MultiSkins[3]);
					else
						UTC_PlayerPawn(P).ClientReplicateSkins(NewBot.Skin);
				}
		}
	}

	return NewBot;
}

function Bot SpawnRatedBot(out NavigationPoint StartSpot)
{
	local bot NewBot;
	local int BotN;
	local bool bEnemy;

	if (RemainingBots > RatedMatchConfig.NumAllies)
		bEnemy = True;

	BotN = RatedMatchConfig.ChooseBotInfo(bTeamGame, bEnemy);

	// Find a start spot.
	StartSpot = UTF_FindPlayerStart(None, 255);
	if( StartSpot == None )
	{
		log("Could not find starting spot for Bot");
		return None;
	}

	// Try to spawn the bot.
	NewBot = Spawn(RatedMatchConfig.GetBotClass(BotN, bTeamGame, bEnemy, RatedPlayer),,,StartSpot.Location,StartSpot.Rotation);
	if ( NewBot == None )
	{
		if ( (RatedMatchConfig.EnemyTeam == class'RatedTeamInfo7')
			|| (RatedMatchConfig.EnemyTeam == class'RatedTeamInfo8') )
			RatedMatchConfig.EnemyTeam = class'RatedTeamInfo3';
		log("Couldn't spawn player at "$StartSpot);
	}

	if ( NewBot != None )
	{
		// Set the player's ID.
		NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;

		RatedMatchConfig.Individualize(NewBot, BotN, NumBots, bTeamGame, bEnemy);
		NewBot.ViewRotation = StartSpot.Rotation;
		// broadcast a welcome message.
		BroadcastMessage(B227_PlayerEnteredMessage(NewBot), false);

		ModifyBehaviour(NewBot);
		AddDefaultInventory( NewBot );
		NumBots++;
		if ( bRequireReady && (CountDown > 0) )
		{
			NewBot.GotoState('Dying', 'WaitingForStart');
			NewBot.SetCollision(false, false, false);
			NewBot.SetPhysics(PHYS_None);
		}
		NewBot.AirControl = 0.35;
	}

	return NewBot;
}

function bool ForceAddBot()
{
	// add bot during gameplay
	if ( Level.NetMode != NM_Standalone )
		MinPlayers = Max(MinPlayers+1, NumPlayers + NumBots + 1);
	return AddBot();
}

function bool AddBot()
{
	local bot NewBot;
	local NavigationPoint StartSpot;

	NewBot = SpawnBot(StartSpot);
	if ( NewBot == None )
	{
		log("Failed to spawn bot.");
		return false;
	}

	StartSpot.PlayTeleportEffect(NewBot, true);

	NewBot.PlayerReplicationInfo.bIsABot = True;

	// Log it.
	if (LocalLog != None)
	{
		LocalLog.LogPlayerConnect(NewBot);
		LocalLog.FlushLog();
	}
	if (WorldLog != None)
	{
		WorldLog.LogPlayerConnect(NewBot);
		WorldLog.FlushLog();
	}

	return true;
}

function ModifyBehaviour(Bot NewBot);

function PlayStartUpMessage(PlayerPawn NewPlayer)
{
	local int i;

	NewPlayer.ClearProgressMessages();

	// Game Name
	NewPlayer.SetProgressMessage(GameName, i++);

	// Optional FragLimit
	if ( fraglimit > 0 )
		NewPlayer.SetProgressMessage(FragLimit@GameGoal, i++);

	if ( Level.NetMode == NM_Standalone )
		NewPlayer.SetProgressMessage(SingleWaitingMessage, i++);
	else if ( bRequireReady )
		NewPlayer.SetProgressMessage(TourneyMessage, i++);
}

function float PlayerJumpZScaling()
{
	if ( bJumpMatch )
		return 3;
	else if ( bMegaSpeed )
		return 1.2;
	else if ( bHardCoreMode )
		return 1.1;
	else
		return 1.0;
}

function AddDefaultInventory( pawn PlayerPawn )
{
	local Bot B;

	if ( PlayerPawn.IsA('Spectator') || (bRequireReady && (CountDown > 0)) )
		return;

	// Spawn Automag
	B227_GiveWeapon(PlayerPawn, class'Enforcer');

	B227_PendingWeaponSwitcher = PlayerPawn.Spawn(class'B227_PendingWeaponSwitcher');
	super.AddDefaultInventory(PlayerPawn);
	B227_PendingWeaponSwitcher = none;

	if ( bUseTranslocator && (!bRatedGame || bRatedTranslocator) )
		B227_GiveWeapon(PlayerPawn, class'Translocator', true);

	B = Bot(PlayerPawn);
	if ( B != None )
		B.bHasImpactHammer = (B.FindInventoryType(class'ImpactHammer') != None);
}

function GiveWeapon(Pawn PlayerPawn, string aClassName)
{
	local class<Weapon> WeaponClass;
	local Weapon newWeapon;

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	if (B227_bGivePendingWeapons)
	{
		B227_GiveWeapon(PlayerPawn, WeaponClass);
		return;
	}

	if (WeaponClass == none || PlayerPawn.FindInventoryType(WeaponClass) != none)
		return;
	newWeapon = Spawn(WeaponClass);
	if( newWeapon != None )
	{
		newWeapon.LifeSpan = newWeapon.default.LifeSpan; // prevents destruction when spawning in destructive zones
		newWeapon.RespawnTime = 0.0;
		newWeapon.GiveTo(PlayerPawn);
		newWeapon.bHeldItem = true;
		newWeapon.GiveAmmo(PlayerPawn);
		newWeapon.SetSwitchPriority(PlayerPawn);
		newWeapon.WeaponSet(PlayerPawn);
		newWeapon.AmbientGlow = 0;
		if ( PlayerPawn.IsA('PlayerPawn') )
			newWeapon.SetHand(PlayerPawn(PlayerPawn).Handedness);
		else
			newWeapon.GotoState('Idle');
		PlayerPawn.Weapon.GotoState('DownWeapon');
		PlayerPawn.PendingWeapon = None;
		PlayerPawn.Weapon = newWeapon;
	}
}

function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	local float skillmod;

	if ( bNoviceMode )
		skillmod = 0.3;
	else
		skillmod = 0.2 - aBot.skill * 0.06;
	if ( aBot.bKamikaze )
		return 1;
	else if ( Other.IsA('TeamCannon')
		|| (aBot.RelativeStrength(Other) > aBot.Aggressiveness + skillmod) )
		return 0;
	else
		return 1;
}

function float GameThreatAdd(Bot aBot, Pawn Other)
{
	return 0;
}

// AllowTranslocation - return true if Other can teleport to Dest
function bool AllowTranslocation(Pawn Other, vector Dest )
{
	return true;
}

function bool CanTranslocate(Bot aBot)
{
	if ( !bUseTranslocator || (bRatedGame && !bRatedTranslocator) )
		return false;
	return ( (aBot.MyTranslocator != None) && (aBot.MyTranslocator.TTarget == None) );
}

function PickAmbushSpotFor(Bot aBot)
{
	local NavigationPoint N;

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('Ambushpoint') && !N.taken
			&& ((aBot.AmbushSpot == None)
				|| (VSize(aBot.Location - aBot.Ambushspot.Location)
					 > VSize(aBot.Location - N.Location))) )
				aBot.Ambushspot = Ambushpoint(N);
}

function RateVs(Pawn Other, Pawn Killer)
{
	local int numopp, Win;
	local float oppRating, K, We;
	Local PlayerPawn P;
	Local Bot B;

	if ( Killer.IsA('PlayerPawn') )
	{
		P = PlayerPawn(Killer);
		B = Bot(Other);
		Win = 1;
		WinCount++;
	}
	else if ( Other.IsA('PlayerPawn') )
	{
		LoseCount++;
		P = PlayerPawn(Other);
		B = Bot(Killer);
	}
	else
		return;

	if ( B == None )
		oppRating = PlayerRating - 400;
	else
		oppRating = FMin(B.GetRating(), PlayerRating + 400);

	numopp++;
	AvgOpponentRating = (AvgOpponentRating * (numopp - 1) + oppRating)/numopp;
	if ( numopp < 20 )
	{
		PlayerRating = AvgOpponentRating + 400 * (WinCount - LoseCount)/numopp;
	}
	else
	{
		if ( oppRating < PlayerRating - 400 )
			return;

		if ( PlayerRating < 2100 )
			K = 32;
		else if ( PlayerRating < 2400 )
			K = 24;
		else
			K = 16;

		We = 1/(10^((PlayerRating - opprating)/400) + 1);
		PlayerRating = PlayerRating + K * (Win - We);

		/* FOLLOWING NOT DONE - do at end of level FIXME
		Pre-tournament Rating Post-tournament Rating
		0-2099  2100-2399 Ra = 2100 + (Rn-2100) x 0.75
		2100-2399 0-2099  Ra = 2100 + (Rn-2100) x 1.33
		2100-2399 2400-3000 Ra = 2400 + (Rn-2400) x 0.66
		2400-3000  2100-2399  Ra = 2400 + (Rn-2400) x 1.50
		*/
	}
}

function bool SuccessfulGame()
{
	local Pawn P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( P.PlayerReplicationInfo != none && (P != RatedPlayer) )
			if ( P.PlayerReplicationInfo.Score >= RatedPlayer.PlayerReplicationInfo.Score )
				return false;

	return true;
}


// Commented out for release version.
function Skip()
{
	if (bRatedGame)
	{
		RatedGameLadderObj.LastMatchType = LadderTypeIndex;
		RatedGameLadderObj.PendingChange = LadderTypeIndex;
		if (IDnum < RatedGameLadderObj.CurrentLadder.Default.Matches-1)
			RatedGameLadderObj.PendingPosition = IDnum+1;
		RatedGameLadderObj.PendingRank = RatedGameLadderObj.CurrentLadder.Default.RankedGame[IDnum];

		RatedPlayer.ClientTravel("UT-Logo-Map.unr"$"?Game=Botpack.LadderTransition", TRAVEL_Absolute, True);
		return;
	}
}

function SkipAll()
{
	if (bRatedGame)
	{
		RatedGameLadderObj.DMPosition = class'LadderDMGOTY'.Default.Matches - 1;
		RatedGameLadderObj.DMRank = 6;
		RatedGameLadderObj.DOMPosition = class'LadderDOM'.Default.Matches - 1;
		RatedGameLadderObj.DOMRank = 6;
		RatedGameLadderObj.CTFPosition = class'LadderCTFGOTY'.Default.Matches - 1;
		RatedGameLadderObj.CTFRank = 6;
		RatedGameLadderObj.ASPosition = class'LadderAS'.Default.Matches - 1;
		RatedGameLadderObj.ASRank = 6;
		RatedGameLadderObj.ChalPosition = class'LadderChal'.Default.Matches - 1;
		RatedGameLadderObj.ChalRank = 6;

		RatedGameLadderObj.LastMatchType = LadderTypeIndex;
		RatedGameLadderObj.PendingChange = LadderTypeIndex;
		RatedGameLadderObj.PendingPosition = 0;
		RatedGameLadderObj.PendingRank = 0;

		RatedPlayer.ClientTravel("UT-Logo-Map.unr"$"?Game=Botpack.LadderTransition", TRAVEL_Absolute, True);
		return;
	}
}

function bool CanSpectate( pawn Viewer, actor ViewTarget )
{
	if ( ViewTarget.bIsPawn && (Pawn(ViewTarget).PlayerReplicationInfo != None)
		&& Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator )
		return false;
	return ( (!bRatedGame && (Level.NetMode == NM_Standalone)) || Viewer.PlayerReplicationInfo.bIsSpectator );
}

function bool ShouldRespawn(Actor Other)
{
	return ( (Inventory(Other) != None) && (Inventory(Other).ReSpawnTime!=0.0) );
}

function ChangeName(Pawn Other, string S, bool bNameChange)
{
	local pawn APlayer;
	local UTC_PlayerReplicationInfo PRI;

	if ( S == "" )
		return;

	S = left(S,24);
	if (Other.PlayerReplicationInfo.PlayerName~=S)
		return;

	APlayer = Level.PawnList;

	While ( APlayer != None )
	{
		if ( APlayer.PlayerReplicationInfo != none && (APlayer.PlayerReplicationInfo.PlayerName~=S) )
		{
			Other.ClientMessage(S$NoNameChange);
			return;
		}
		APlayer = APlayer.NextPawn;
	}

	PRI = UTC_PlayerReplicationInfo(Other.PlayerReplicationInfo);
	if (PRI != none)
	{
		PRI.OldName = PRI.PlayerName;
		PRI.PlayerName = S;
	}
	if (bNameChange && !Other.IsA('Spectator'))
		class'UTC_Actor'.static.B227_StaticBroadcastLocalizedMessage(self, DMMessageClass, 2, PRI.OldName, PRI.PlayerName);

/// [U227] Excluded
///	if (LocalLog != None)
///		LocalLog.LogNameChange(Other);
///	if (WorldLog != None)
///		WorldLog.LogNameChange(Other);
}

/* FindPlayerStart()
returns the 'best' player start for this player to start from.
Re-implement for each game type
*/
function NavigationPoint UTF_FindPlayerStart(Pawn Player, optional byte InTeam, optional string incomingName)
{
	local array<PlayerStart> Candidate;
	local array<float> Score;
	local array<Pawn> Players;
	local int PlayerCount;
	local PlayerStart Dest, Best;
	local float BestScore, NextDist;
	local Pawn OtherPlayer;
	local int i, j, num;
	local Teleporter Tel;
	local NavigationPoint LastPlayerStartSpot;
	local bool bHasEnabledStartSpot;
	local float DistScore, NarrowScore, TelefragScore;

	if (bStartMatch && TournamentPlayer(Player) != none &&
		Level.NetMode == NM_Standalone &&
		TournamentPlayer(Player).StartSpot != none)
	{
		return TournamentPlayer(Player).StartSpot;
	}

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	// choose candidates
	foreach AllActors(class'PlayerStart', Dest)
	{
		if (Dest.bEnabled && !Dest.Region.Zone.bWaterZone )
		{
			if (!bHasEnabledStartSpot)
			{
				num = 0;
				bHasEnabledStartSpot = true;
			}
		}
		else if (bHasEnabledStartSpot)
			continue;

		Candidate[num++] = Dest;
	}

	if (num == 0)
		return none;

	if (TournamentPlayer(Player) != none && TournamentPlayer(Player).StartSpot != none)
		LastPlayerStartSpot = TournamentPlayer(Player).StartSpot;

	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)
		if (OtherPlayer.PlayerReplicationInfo != none &&
			OtherPlayer.Health > 0 &&
			!OtherPlayer.IsInState('Dying') &&
			!OtherPlayer.IsA('Spectator') &&
			!OtherPlayer.PlayerReplicationInfo.bIsSpectator)
		{
			Players[PlayerCount++] = OtherPlayer;
		}

	for (i = 0; i < num; ++i)
	{
		if ( (Candidate[i] == LastStartSpot) || (Candidate[i] == LastPlayerStartSpot) )
			Score[i] = -10000.0;
		else
			Score[i] = 3000 * FRand(); // randomize

		DistScore = 0;
		NarrowScore = 0;
		TelefragScore = 0;

		for (j = 0; j < PlayerCount; ++j)
		{
			OtherPlayer = Players[j];

			if (B227_ShouldModifyPlayerStartLookup())
				B227_EvaluatePlayerStartScore(
					Player,
					OtherPlayer,
					Candidate[i].Location,
					Score[i],
					DistScore,
					NarrowScore,
					TelefragScore);
			else
			{
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					Score[i] -= 1500;
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if ( NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight )
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && FastTrace(Candidate[i].Location, OtherPlayer.Location) )
						Score[i] -= (10000.0 - NextDist);
				}
				else if ( NumPlayers + NumBots == 2 )
				{
					Score[i] += 2 * VSize(OtherPlayer.Location - Candidate[i].Location);
					if ( FastTrace(Candidate[i].Location, OtherPlayer.Location) )
						Score[i] -= 10000;
				}
			}
		}
		Score[i] += DistScore + NarrowScore + TelefragScore;

		if (i == 0 || Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	}

	LastStartSpot = Best;
	return Best;
}

function Logout(pawn Exiting)
{
	Super.Logout(Exiting);
	if ( Bot(Exiting) != none )
		NumBots--;
	if ( Exiting.IsA('Commander') )
		NumCommanders--;
	if ( (Level.NetMode != NM_Standalone) && NeedPlayers() && !AddBot() )
		RemainingBots++;
}

function bool NeedPlayers()
{
	return !B227_bFixedBotCount && !bGameEnded && (NumPlayers + NumBots < MinPlayers);
}

function RestartGame()
{
	local string NextMap;
	local MapList myList;

	// multipurpose don't restart variable
	if ( bDontRestart )
		return;

	if ( EndTime > Level.TimeSeconds ) // still showing end screen
		return;

	// Evaluate a rated game.
	if ( bRatedGame )
	{
		// Clear out the advancement fields.
		RatedGameLadderObj.PendingPosition = 0;
		RatedGameLadderObj.PendingRank = 0;
		RatedGameLadderObj.PendingChange = 0;

		// Setup advancement.
		RatedGameLadderObj.LastMatchType = LadderTypeIndex;
		if ( SuccessfulGame() )
		{
			RatedGameLadderObj.PendingChange = LadderTypeIndex;
			if (IDnum < RatedGameLadderObj.CurrentLadder.Default.Matches-1)
				RatedGameLadderObj.PendingPosition = IDnum+1;	// We are advancing to the next match.
			RatedGameLadderObj.PendingRank = RatedGameLadderObj.CurrentLadder.Default.RankedGame[IDnum];
		}

		RatedPlayer.Health = RatedPlayer.Default.Health;
		RatedPlayer.ClientTravel("UT-Logo-Map.unr"$"?Game=Botpack.LadderTransition", TRAVEL_Absolute, True);
		return;
	}

	// these server travels should all be relative to the current URL
	if ( bChangeLevels && !bAlreadyChanged && (MapListType != None) )
	{
		// open a the nextmap actor for this game type and get the next map
		bAlreadyChanged = true;
		myList = spawn(MapListType);
		NextMap = myList.GetNextMap();
		myList.Destroy();
		if ( NextMap == "" )
			NextMap = GetMapName(MapPrefix, NextMap,1);

		if ( NextMap != "" )
		{
			Level.ServerTravel(NextMap, false);
			return;
		}
	}

	Level.ServerTravel("?Restart" , false);
}

function LogGameParameters(StatLog StatLog)
{
	local bool bTemp;

	if (StatLog == None)
		return;

	// hack to make sure weapon stay logging is correct for multiplayer games
	bTemp = bCoopWeaponMode;
	if ( Level.Netmode != NM_Standalone )
		bCoopWeaponMode = bMultiWeaponStay;
	Super.LogGameParameters(StatLog);
	bCoopWeaponMode = bTemp;

	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"FragLimit"$Chr(9)$FragLimit);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TimeLimit"$Chr(9)$TimeLimit);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MultiPlayerBots"$Chr(9)$(MinPlayers > 0));
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"HardCore"$Chr(9)$bHardCoreMode);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MegaSpeed"$Chr(9)$bMegaSpeed);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"AirControl"$Chr(9)$AirControl);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"JumpMatch"$Chr(9)$bJumpMatch);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"UseTranslocator"$Chr(9)$bUseTranslocator);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TournamentMode"$Chr(9)$bTournament);
	if (Level.NetMode == NM_DedicatedServer)
		StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NetMode"$Chr(9)$"DedicatedServer");
	else if (Level.NetMode == NM_ListenServer)
		StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NetMode"$Chr(9)$"ListenServer");
	else if (Level.NetMode == NM_Standalone)
	{
		if (bRatedGame)
			StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NetMode"$Chr(9)$"SinglePlayer");
		else
			StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NetMode"$Chr(9)$"PracticeMatch");
	}
}

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	local string ResultSet;
	ResultSet = Super.GetRules();

	ResultSet = ResultSet$"\\timelimit\\"$TimeLimit;
	ResultSet = ResultSet$"\\fraglimit\\"$FragLimit;
	Resultset = ResultSet$"\\minplayers\\"$MinPlayers;
	Resultset = ResultSet$"\\changelevels\\"$bChangeLevels;
	Resultset = ResultSet$"\\tournament\\"$bTournament;
	if(bMegaSpeed)
		Resultset = ResultSet$"\\gamestyle\\Turbo";
	else
	if(bHardcoreMode)
		Resultset = ResultSet$"\\gamestyle\\Hardcore";
	else
		Resultset = ResultSet$"\\gamestyle\\Classic";

	if(MinPlayers > 0)
		Resultset = ResultSet$"\\botskill\\"$class'ChallengeBotInfo'.static.B227_SkillString(BotConfig.Difficulty);

	return ResultSet;
}

function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();
	B227_UpdateGRILimits();
}

function bool CheckThisTranslocator(Bot aBot, TranslocatorTarget T)
{
	return false;
}

function bool OneOnOne()
{
	return ( NumPlayers + NumBots == 2 );
}

function float SpawnWait(bot B)
{
	if ( bRatedGame && bNoviceMode && !bTeamGame && (Difficulty <= 2)
		&& (NumBots > 1)
		&& (B.PlayerReplicationInfo.Score > RatedPlayer.PlayerReplicationInfo.Score) )
		return ( 7 + NumBots * FRand() );
	return ( NumBots * FRand() );
}

function bool NeverStakeOut(bot Other)
{
	return false;
}

function B227_AddMapFixMutator()
{
	local class<Mutator> MutatorClass;
	local Mutator Mutator;

	MutatorClass = class<Mutator>(DynamicLoadObject("B227_MapFix.B227_MapFix", class'Class', true));
	if (MutatorClass == none)
		return;

	foreach AllActors(class'Mutator', Mutator)
		if (Mutator.Class == MutatorClass)
			return;
	Mutator = Spawn(MutatorClass);
	if (Mutator != none)
		BaseMutator.AddMutator(Mutator);
}

static function bool B227_ShouldModifyPlayerStartLookup()
{
	return
		class'B227_Config'.default.bEnableExtensions &&
		class'B227_Config'.default.bModifyPlayerStartLookup;
}

function B227_EvaluatePlayerStartScore(
	Pawn Player,
	Pawn OtherPlayer,
	vector PlayerStartLocation,
	out float Score,
	out float DistScore,
	out float NarrowScore,
	out float TelefragScore)
{
	local float CollisionDistXY, CollisionDistZ, NextDist, NextDistXY, NextDistZ;
	local vector NextOffset, NextOffsetXY;

	// B227 NOTE: Zone-dependent score may lead to odd selection of start spots.
	// F.e., on DM-ArcaneTemple, ZoneInfo0 would be preferred in most cases.
	// This is why Region.Zone is not checked here anymore.

	NextOffset = OtherPlayer.Location - PlayerStartLocation;
	NextDist = VSize(NextOffset);
	NextOffsetXY = NextOffset;
	NextOffsetXY.Z = 0;

	if (Player != none)
	{
		CollisionDistXY = Player.CollisionRadius + OtherPlayer.CollisionRadius;
		CollisionDistZ = Player.CollisionHeight + OtherPlayer.CollisionHeight;
	}
	else
	{
		CollisionDistXY = 2 * OtherPlayer.CollisionRadius;
		CollisionDistZ = 2 * OtherPlayer.CollisionHeight;
	}

	NextDistXY = VSize(NextOffsetXY) - CollisionDistXY;
	NextDistZ = Abs(NextOffset.Z) - CollisionDistZ;

	if (NextDist < CollisionDistXY + CollisionDistZ) // This spot is too close to some player
	{
		Score = 0;
		NarrowScore = -1000000.0;
		DistScore = FMin(DistScore, FMax(NextDistXY, NextDistZ) - 10000);
		if (NextDistXY < 0.1 && NextDistZ < 0.1) // Potential telefrag from this point
			TelefragScore -= 1000000.0; // The more players are under the risk of telefragging, the less the score is
	}
	else if (NarrowScore == 0)
	{
		if (B227_PlayerStartIsVisibleTo(PlayerStartLocation, OtherPlayer))
			Score -= 10000;
		if (NextDist < 2000)
			DistScore = FMin(DistScore, 2 * (NextDist - 2000));
	}
}

static function bool B227_PlayerStartIsVisibleTo(vector Pos, Pawn P)
{
	return
		P.FastTrace(Pos, P.Location) ||
		P.FastTrace(Pos + vect(0, 0, 1) * P.CollisionHeight, P.Location + vect(0, 0, 1) * P.CollisionHeight);
}

function B227_UpdateGRILimits()
{
	if (TournamentGameReplicationInfo(GameReplicationInfo) == none)
		return;
	TournamentGameReplicationInfo(GameReplicationInfo).FragLimit = FragLimit;
	TournamentGameReplicationInfo(GameReplicationInfo).TimeLimit = TimeLimit;
}

function B227_UpdateGRITime()
{
	if (TimeLimit > 0)
	{
		B227_GRI().B227_ElapsedTime = -1;
		B227_GRI().B227_RemainingTime = Max(0, RemainingTime);
		B227_GRI().RemainingTime = B227_GRI().B227_RemainingTime;
	}
	else
	{
		B227_GRI().B227_ElapsedTime = B227_ElapsedTime;
		B227_GRI().B227_RemainingTime = -1;
		B227_GRI().RemainingTime = 0;
	}
	B227_GRI().B227_bSyncTime = true;
}

function string B227_PlayerEnteredMessage(Pawn P)
{
	local string Message;

	if (P.bIsFemale && B227_bGenderedMessagesSupported)
	{
		Message = GetPropertyText("FemEnteredMessage");
		if (Len(Message) > 0)
			return P.PlayerReplicationInfo.PlayerName $ Message;
	}
	return P.PlayerReplicationInfo.PlayerName $ EnteredMessage;
}

function int B227_TimeLimitSeconds()
{
	return TimeLimit * 60;
}

function B227_GiveWeapon(Pawn Player, class<Weapon> WeaponClass, optional bool bSwitchIfBetter)
{
	local Weapon NewWeapon;
	local Weapon CurrentWeapon;

	if (WeaponClass == none || Player.FindInventoryType(WeaponClass) != none)
		return;
	NewWeapon = Spawn(WeaponClass);
	if (NewWeapon != none)
	{
		NewWeapon.LifeSpan = NewWeapon.default.LifeSpan; // prevents destruction when spawning in destructive zones
		NewWeapon.RespawnTime = 0.0;
		NewWeapon.GiveTo(Player);
		NewWeapon.bHeldItem = true;
		NewWeapon.GiveAmmo(Player);
		NewWeapon.SetSwitchPriority(Player);
		NewWeapon.AmbientGlow = 0;
		NewWeapon.GotoState('');

		if (Player.PendingWeapon != none && !Player.PendingWeapon.bDeleteMe)
			CurrentWeapon = Player.PendingWeapon;
		else
			CurrentWeapon = Player.Weapon;
		if (!bSwitchIfBetter || CurrentWeapon == none || CurrentWeapon.SwitchPriority() < NewWeapon.SwitchPriority())
			Player.PendingWeapon = NewWeapon;
	}
}

static function B227_SwitchToBestWeapon(Pawn Player)
{
	local float rating;
	local int usealt;
	local Weapon PendingWeapon;

	if (Player.Inventory == none)
		return;

	PendingWeapon = Player.Inventory.RecommendWeapon(rating, usealt);
	if (PendingWeapon != none)
		Player.PendingWeapon = PendingWeapon;
}

defaultproperties
{
	AirControl=0.350000
	FragLimit=30
	bChangeLevels=True
	bHardCoreMode=True
	bMultiWeaponStay=True
	NetWait=10
	RestartWait=15
	CountDown=10
	TourneyMessage="Waiting for other players."
	WaitingMessage1="Waiting for ready signals."
	WaitingMessage2="(Use your fire button to toggle ready!)"
	ReadyMessage="You are READY!"
	NotReadyMessage="You are NOT READY!"
	CountDownMessage=" seconds until play starts!"
	StartMessage="The match has begun!"
	GameEndedMessage="wins the match!"
	SingleWaitingMessage="Press Fire to start."
	gamegoal="frags wins the match."
	InitialBots=4
	NoNameChange=" is already in use."
	OvertimeMessage="Score tied at the end of regulation. Sudden Death Overtime!!!"
	BotConfigType=Class'Botpack.ChallengeBotInfo'
	LadderTypeIndex=1
	bRestartLevel=False
	bPauseable=False
	bDeathMatch=True
	ScoreBoardType=Class'Botpack.TournamentScoreBoard'
	BotMenuType="UTMenu.UTBotConfigSClient"
	RulesMenuType="UTMenu.UTRulesSClient"
	SettingsMenuType="UTMenu.UTSettingsSClient"
	GameUMenuType="UTMenu.UTGameMenu"
	MultiplayerUMenuType="UTMenu.UTMultiplayerMenu"
	GameOptionsMenuType="UTMenu.UTOptionsMenu"
	HUDType=Class'Botpack.ChallengeHUD'
	MapListType=Class'Botpack.TDMmaplist'
	MapPrefix="DM"
	BeaconName="DM"
	GameName="Tournament DeathMatch"
	DeathMessageClass=Class'Botpack.DeathMessagePlus'
	DMMessageClass=Class'Botpack.DeathMatchMessage'
	MutatorClass=Class'Botpack.DMMutator'
	GameReplicationInfoClass=Class'Botpack.TournamentGameReplicationInfo'
	bLoggingGame=True
	B227_KillerMessageClass=Class'Botpack.KillerMessagePlus'
	B227_bMapFixMutator=True
}
