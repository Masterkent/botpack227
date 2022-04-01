class B227_SyncedProjectile expands B227_Projectile;

struct B227_ReplicatedVector
{
	var float X, Y, Z;
};

var B227_ReplicatedVector B227_SyncLocation;
var vector B227_SyncVelocity;
var float B227_SyncTimestamp;
var float B227_ClientServerTimestampDiff;
var float B227_NextFullSyncTimestamp;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_SyncTimestamp;

	reliable if (Role == ROLE_Authority && !bNetInitial)
		B227_SyncLocation,
		B227_SyncVelocity;
}

simulated event PostNetBeginPlay()
{
	B227_SyncTimestamp = 0;
}

function B227_SyncMovement()
{
	B227_SyncLocation = B227_ConvertToReplicatedVector(Location);
	B227_SyncVelocity = Velocity;

	B227_SyncTimestamp = Level.TimeSeconds;
}

simulated function bool B227_ClientSyncMovement()
{
	local float TimestampDiff;

	if (Level.NetMode != NM_Client || B227_SyncTimestamp == 0)
		return false;

	SetLocation(B227_ConvertReplicatedVector(B227_SyncLocation));
	Velocity = B227_SyncVelocity;
	B227_ClientAdjustMovement();

	TimestampDiff = Level.TimeSeconds - B227_SyncTimestamp;

	if (Level.TimeSeconds >= B227_NextFullSyncTimestamp)
	{
		B227_ClientServerTimestampDiff = TimestampDiff;
		B227_NextFullSyncTimestamp = Level.TimeSeconds + 10;
	}
	else if (B227_ClientServerTimestampDiff > TimestampDiff)
		B227_ClientServerTimestampDiff = TimestampDiff;
	else if (B227_ClientServerTimestampDiff < TimestampDiff)
		AutonomousPhysics(TimestampDiff - B227_ClientServerTimestampDiff);

	B227_SyncTimestamp = 0;
	return true;
}

static function B227_ReplicatedVector B227_ConvertToReplicatedVector(vector pos)
{
	local B227_ReplicatedVector Result;
	Result.X = pos.X;
	Result.Y = pos.Y;
	Result.Z = pos.Z;
	return Result;
}

static function vector B227_ConvertReplicatedVector(B227_ReplicatedVector pos)
{
	local vector Result;
	Result.X = pos.X;
	Result.Y = pos.Y;
	Result.Z = pos.Z;
	return Result;
}

simulated function B227_ClientAdjustMovement();
