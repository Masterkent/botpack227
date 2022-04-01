//=============================================================================
// SeekingRocket.
//=============================================================================
class UT_SeekingRocket extends RocketMk2;

var Actor Seeking;
var vector InitialDir;
var bool B227_bSpawnedSmoke;

simulated function Timer()
{
	local ut_SpriteSmokePuff b;
	local vector SeekingDir;
	local float MagnitudeVel;

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);

	if (Level.NetMode != NM_Client)
	{
		if (Seeking != none && !Seeking.bDeleteMe && Seeking != Instigator) 
		{
			SeekingDir = Normal(Seeking.Location - Location);
			if ( (SeekingDir Dot InitialDir) > 0 )
			{
				MagnitudeVel = VSize(Velocity);
				SeekingDir = Normal(SeekingDir * 0.5 * MagnitudeVel + Velocity);
				Velocity =  MagnitudeVel * SeekingDir;
				Acceleration = 25 * SeekingDir;
				SetRotation(rotator(Velocity));
			}
		}
		B227_SyncMovement();
	}
	if (Level.NetMode == NM_DedicatedServer || Region.Zone.bWaterZone)
		return;

	if (Level.bHighDetailMode)
	{
		B227_SetRocketTrail(Region.Zone);
		if (!class'UTSmokeTrail'.default.B227_bReplaceWithEmitter)
		{
			b = Spawn(class'ut_SpriteSmokePuff');
			if (b != none)
				b.RemoteRole = ROLE_None;
		}
	}
	else 
	{
		B227_StopSmokeTrail();

		if (B227_bSpawnedSmoke)
			B227_bSpawnedSmoke = false;
		else
		{
			b = Spawn(class'ut_SpriteSmokePuff');
			if (b != none)
				b.RemoteRole = ROLE_None;
			B227_bSpawnedSmoke = true;
		}
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.1, true);
}

defaultproperties
{
	LifeSpan=10.000000
}
