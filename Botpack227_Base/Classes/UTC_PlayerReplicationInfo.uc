class UTC_PlayerReplicationInfo expands PlayerReplicationInfo;

var bool bAdmin;
var bool bIsFemale; // replicated
var bool bWaitingPlayer;
var float Deaths;
var string OldName;
var byte PacketLoss;
var int PlayerID; // replicated
var LocationID PlayerLocation;

// Time elapsed.
var int StartTime;
var int TimeAcc;

replication
{
	reliable if (Role == ROLE_Authority)
		bAdmin,
		bIsFemale,
		bWaitingPlayer,
		Deaths,
		OldName,
		PacketLoss,
		PlayerID,
		PlayerLocation,
		StartTime;
}

event PostBeginPlay()
{
	StartTime = Level.TimeSeconds;
	if (Owner != none)
		bIsFemale = Pawn(Owner).bIsFemale;
	super.PostBeginPlay();
}

static function bool B227_IsFemale(PlayerReplicationInfo PRI)
{
	if (UTC_PlayerReplicationInfo(PRI) != none)
		return UTC_PlayerReplicationInfo(PRI).bIsFemale;
	return PRI.bIsFemale;
}

function B227_SetPlayerID(int PlayerID)
{
	local PlayerReplicationInfo PRI;

	PRI = self;
	PRI.PlayerID = PlayerID;
	self.PlayerID = PlayerID;
}
