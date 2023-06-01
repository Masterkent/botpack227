class ONPLandedWarShellExplosion expands Info;

event BeginPlay()
{
	local vector HitLocation, HitNormal, TraceEnd;

	TraceEnd = Location - vect(0, 0, 10000);
	if (Trace(HitLocation, HitNormal, TraceEnd, Location, false) == none)
	{
		HitLocation = Location;
		HitNormal = vect(0, 0, 1);
	}
	Explode(HitLocation, HitNormal);

	if (Level.NetMode != NM_DedicatedServer)
		SpawnDecal();
}

simulated event PostNetBeginPlay()
{
	if (Level.NetMode == NM_Client)
		SpawnDecal();
}

function Explode(vector HitLocation, vector HitNormal)
{
	SetLocation(HitLocation);

	HurtRadius(
		class'WarShell'.default.Damage,
		300.0,
		class'WarShell'.default.MyDamageType,
		class'WarShell'.default.MomentumTransfer,
		HitLocation);
	Spawn(class'ShockWave',,, HitLocation + HitNormal*16);
}

simulated function SpawnDecal()
{
	Spawn(class'Botpack.NuclearMark', self,, Location + vect(0, 0, 8), rotator(vect(0, 0, 1)));
}

defaultproperties
{
	bAlwaysRelevant=True
	LifeSpan=2
	RemoteRole=ROLE_SimulatedProxy
}