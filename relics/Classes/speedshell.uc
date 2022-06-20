class SpeedShell expands RelicShell;

var vector B227_Location;

replication
{
	reliable if (Role == ROLE_Authority && !bNetOwner)
		B227_Location;
}

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_Client && Owner != none)
		SoundVolume = Pawn(Owner).default.SoundVolume;

	if (Level.NetMode != NM_DedicatedServer && Level.bHighDetailMode)
	{
		DrawType = DT_None;
		SetTimer(0.2, True);
	}
}

simulated function Timer()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

	if ( !Level.bDropDetail && (Owner != None) && (Owner.Velocity != vect(0, 0, 0)) )
		Spawn(class'SpeedShadow', Owner, , Owner.Location, Owner.Rotation);

	if ( Level.bDropDetail )
		SetTimer(0.5, true);
	else
		SetTimer(0.2, True);
}

simulated event Tick(float DeltaTime)
{
	if (Level.NetMode == NM_Client)
		B227_ClientUpdateLocation();
	else
		B227_Location = Location;
}

simulated function B227_ClientUpdateLocation()
{
	if (Owner == none)
		SetLocation(B227_Location);
}

defaultproperties
{
	AmbientSound=Sound'relics.SpeedWind'
	SoundRadius=64
	B227_Location=(X=0,Y=0,Z=-1000000)
}
