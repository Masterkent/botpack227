//=============================================================================
// SeekingRocket.
//=============================================================================
class PKSeekingRocket extends PKRocketMk2;

var Actor Seeking;
var vector InitialDir;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority )
		Seeking, InitialDir;
}

simulated function Timer()
{
	local ut_SpriteSmokePuff b;
	local vector SeekingDir;
	local float MagnitudeVel;

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);

	if ( (Seeking != None) && (Seeking != Instigator) )
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
	if ( bHitWater || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( (Level.bHighDetailMode && !Level.bDropDetail) || (FRand() < 0.5) )
	{
		b = Spawn(class'ut_SpriteSmokePuff');
		b.RemoteRole = ROLE_None;
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.1, true);
}

defaultproperties
{
     LifeSpan=16.000000
}
