class UTC_PlayerReplicationInfo expands PlayerReplicationInfo;

var bool bAdmin;
var bool bWaitingPlayer;
var float Deaths;
var string OldName;
var byte PacketLoss;
var LocationID PlayerLocation;

// Time elapsed.
var int StartTime;
var int TimeAcc;

replication
{
	reliable if (Role == ROLE_Authority)
		bAdmin,
		bWaitingPlayer,
		Deaths,
		OldName,
		PacketLoss,
		PlayerLocation,
		StartTime;
}

event PostBeginPlay()
{
	StartTime = Level.TimeSeconds;
	super.PostBeginPlay();
}
