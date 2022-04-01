//=============================================================================
//
//=============================================================================
class CombatZoneCTF extends CTFGame;

var int    RegularKillScore;
var int    RegularDeathScore;
var int    FlagKillScore;
var int    FlagDeathScore;
var int    FlagCaptureScore;
var int    FlagReturnScore;



function PreCacheReferences()
{
	//never called - here to force precaching of meshes

	spawn(class'ADTMale2');
	spawn(class'ADTmale1');
	spawn(class'ADTFemale1');
	spawn(class'ADTFemale2');
}


function bool RestartPlayer( pawn aPlayer )
{
	local Bot B;
	local bool bResult;

        bResult = Super.RestartPlayer(aPlayer);
	aPlayer.GroundSpeed = aPlayer.Default.GroundSpeed;
        If(aPlayer.isa('CombatFemale')) CombatFemale(aPlayer).WeaponAccuracyIndex=CombatFemale(aPlayer).Default.WeaponAccuracyIndex;
        If( aPlayer.isa('Combatmale')) Combatmale(aPlayer).WeaponAccuracyIndex=Combatmale(aPlayer).Default.WeaponAccuracyIndex;
        If( aPlayer.isa('CombatFemaleBotPlus')) CombatFemaleBotPlus(aPlayer).WeaponAccuracyIndex=CombatFemaleBotPlus(aPlayer).Default.WeaponAccuracyIndex;
        If( aPlayer.isa('CombatmaleBotPlus')) CombatmaleBotPlus(aPlayer).WeaponAccuracyIndex=CombatmaleBotPlus(aPlayer).Default.WeaponAccuracyIndex;

	return bResult;

}


function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;

        if ( ClassIsChildOf(SpawnClass, class'TFemale2') )
         {
	  SpawnClass=class'addweap.ADTfemale2';
	  Log("female2 replaced");
	 }

        else if ( ClassIsChildOf(SpawnClass, class'TFemale1') )
         {
	  SpawnClass=class'addweap.ADTfemale1';
	  Log("female1 replaced");

	 }
        else if ( ClassIsChildOf(SpawnClass, class'TMale1') )
         {
	  SpawnClass=class'addweap.ADTMale1';
	  Log("male1 replaced");

	 }
	else if ( ClassIsChildOf(SpawnClass, class'TMale2') )
         {
	  SpawnClass=class'addweap.ADTMale2';
	  Log("male2 replaced");

	 }
	else SpawnClass=class'addweap.ADTMale2';

        newPlayer = Super.Login(Portal, Options, Error, SpawnClass);
        Return NewPlayer;

}


function Bot SpawnBot(out NavigationPoint StartSpot)
{
	local bot NewBot;
	local int BotN;
	local Pawn P;
        local class<bot> OverClass;

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

	Overclass=BotConfig.CHGetBotClass(BotN);
	log(String(Overclass));
	log(" ^-- trying to spawn this bot class");


	if ( ClassIsChildOf(OverClass, class'TFemale2Bot') )
         {
	  OverClass=class'addweap.ADTfemale2Bot';
	  Log("bot female2 replaced");
	 }

        else if ( ClassIsChildOf(OverClass, class'TFemale1Bot') )
         {
	  OverClass=class'addweap.ADTfemale1Bot';
	  Log("bot female1 replaced");

	 }
        else if ( ClassIsChildOf(OverClass, class'TMale1Bot') )
         {
	  OverClass=class'addweap.ADTMale1Bot';
	  Log("bot male1 replaced");

	 }
	else if ( ClassIsChildOf(OverClass, class'TMale2Bot') )
         {
	  OverClass=class'addweap.ADTMale2Bot';
	  Log("bot male2 replaced");

	 }
        else OverClass=class'addweap.ADTMale2Bot';

	NewBot = Spawn(OverClass,,,StartSpot.Location,StartSpot.Rotation);
	log(string(NewBot));
        log(" ^-- this class was spawned");



	if ( NewBot == None )
		log("Couldn't spawn player at "$StartSpot);

	if ( (bHumansOnly || Level.bHumansOnly) && !NewBot.bIsHuman )
	{
		log("can't add non-human bot to this game");
		NewBot.Destroy();
		NewBot = None;
	}

	if ( NewBot == None )

		{
		NewBot = Spawn(BotConfig.CHGetBotClass(0),,,StartSpot.Location,StartSpot.Rotation);
		log(String(BotConfig.CHGetBotClass(0)));
		Log("Second spawning Botclass(0) in progress");
		}


	if ( NewBot != None )
	{
		// Set the player's ID.
		NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;

		NewBot.PlayerReplicationInfo.Team = BotConfig.GetBotTeam(BotN);
		BotConfig.CHIndividualize(NewBot, BotN, NumBots);
		NewBot.ViewRotation = StartSpot.Rotation;
		// broadcast a welcome message.
		BroadcastMessage( NewBot.PlayerReplicationInfo.PlayerName$EnteredMessage, false );

		ModifyBehaviour(NewBot);
		AddDefaultInventory( NewBot );
		NumBots++;
		if ( bRequireReady && (CountDown > 0) )
			NewBot.GotoState('Dying', 'WaitingForStart');
		NewBot.AirControl = AirControl;

		if ( (Level.NetMode != NM_Standalone) && (bNetReady || bRequireReady) )
		{
			// replicate skins
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if (P.bIsPlayer &&
					UTC_PlayerReplicationInfo(P.PlayerReplicationInfo) != none &&
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

defaultproperties
{
     DefaultPlayerClass=Class'addweap.ADTFemale2'
     HUDType=Class'addweap.ADCTFHUD'
     GameName="CombatZone CTF"
     MutatorClass=Class'addweap.addweap'
}
