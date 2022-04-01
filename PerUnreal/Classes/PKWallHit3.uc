//=============================================================================
// PKWallHit3.
//=============================================================================
class PKWallHit3 extends BulletImpact;

var int MaxChips, MaxSparks;
var float ChipOdds;
var rotator RealRotation;
var(Sounds) sound 	Ric[4];

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		RealRotation;
}

simulated function SpawnSound()
{
	local int rnd;

	rnd = Rand(4);
	PlaySound(Ric[rnd],,,,1000, Frand()*0.15+0.9);
}

simulated function SpawnEffects()
{
	local Actor A;
	local int j;
	local int NumSparks;

	SpawnSound();

	NumSparks = rand(MaxSparks);
	if ( !Level.bDropDetail )
		for ( j=0; j<MaxChips; j++ )
			if ( FRand() < ChipOdds )
			{
				NumSparks--;
				A = spawn(class'Chip');
				if ( A != None )
					A.RemoteRole = ROLE_None;
			}

	if ( !Level.bHighDetailMode )
		return;

	Spawn(class'Pock');
	if ( Level.bDropDetail )
		return;

	A = Spawn(class'PKSpriteSmokePuff');
	A.RemoteRole = ROLE_None;
	if ( !Region.Zone.bWaterZone && (NumSparks > 0) )
		for (j=0; j<NumSparks; j++)
			spawn(class'PKSpark',,,Location + 8 * Vector(Rotation));
}

Auto State StartUp
{
	simulated function Tick(float DeltaTime)
	{
		if ( Instigator != None )
			MakeNoise(0.3);
		if ( Role == ROLE_Authority )
			RealRotation = Rotation;
		else
			SetRotation(RealRotation);

		if ( Level.NetMode != NM_DedicatedServer )
			SpawnEffects();
		Disable('Tick');
	}
}

defaultproperties
{
     MaxChips=2
     MaxSparks=3
     ChipOdds=0.200000
     Ric(0)=Sound'PerUnreal.Misc.PKric5'
     Ric(1)=Sound'PerUnreal.Misc.PKric6'
     Ric(2)=Sound'PerUnreal.Misc.PKric7'
     Ric(3)=Sound'PerUnreal.Sniper.PKsniperric'
     bNetOptional=True
     RemoteRole=ROLE_SimulatedProxy
}
