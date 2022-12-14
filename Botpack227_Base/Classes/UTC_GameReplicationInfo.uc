class UTC_GameReplicationInfo expands GameReplicationInfo;

var string GameClass;
var bool bClassicDeathMessages;
var bool bStopCountDown;
var int RemainingMinute;
var float SecondCount;

var int NumPlayers;
var int SumFrags;
var float UpdateTimer;

var UTC_PlayerReplicationInfo PRIArray[32];

var private string B227_GameEndedComments;
var int B227_ElapsedTime, B227_RemainingTime;
var bool B227_bSyncTime;

replication
{
	reliable if (Role == ROLE_Authority)
		RemainingMinute, bStopCountDown, NumPlayers;

	reliable if (bNetInitial && Role == ROLE_Authority)
		GameClass;

	reliable if (Role == ROLE_Authority)
		B227_GameEndedComments,
		B227_ElapsedTime,
		B227_RemainingTime;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SecondCount = Level.TimeSeconds;
	SetTimer(0.2, true);
}

simulated event Timer()
{
	local UTC_PlayerReplicationInfo PRI;
	local int i, FragAcc;

	if ( Level.NetMode == NM_Client )
	{
		if (B227_ElapsedTime >= 0)
		{
			ElapsedTime = B227_ElapsedTime;
			B227_bSyncTime = true;
		}
		if (B227_RemainingTime >= 0)
		{
			RemainingTime = B227_RemainingTime;
			B227_bSyncTime = true;
		}

		if (!B227_bSyncTime && Level.TimeSeconds - SecondCount >= Level.TimeDilation)
		{
			ElapsedTime++;
			if (RemainingMinute != 0)
			{
				RemainingTime = RemainingMinute;
				RemainingMinute = 0;
			}
			if (RemainingTime > 0 && !bStopCountDown)
				RemainingTime--;
			SecondCount += Level.TimeDilation;
		}
	}

	for (i=0; i<32; i++)
		PRIArray[i] = None;
	i=0;
	foreach AllActors(class'UTC_PlayerReplicationInfo', PRI)
	{
		if ( i < 32 )
			PRIArray[i++] = PRI;
	}

	// Update various information.
	UpdateTimer = 0;
	for (i=0; i<32; i++)
		if (PRIArray[i] != None)
			FragAcc += PRIArray[i].Score;
	SumFrags = FragAcc;

	if ( Level.Game != None )
		NumPlayers = Level.Game.NumPlayers;
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	if (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer)
	{
		if (B227_GameEndedComments != GameEndedComments)
			B227_GameEndedComments = GameEndedComments;
	}
}

simulated event PostNetReceive()
{
	super.PostNetReceive();
	if (GameEndedComments != B227_GameEndedComments)
		GameEndedComments = B227_GameEndedComments;
}

defaultproperties
{
	bNetNotify=True
	NetUpdateFrequency=20
	B227_ElapsedTime=-1
	B227_RemainingTime=-1
}
