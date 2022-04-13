class SpeedShell expands RelicShell;

simulated function PostBeginPlay()
{
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

defaultproperties
{
}
