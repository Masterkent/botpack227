class ONPPlayerRelocation expands Info;

struct Sphere
{
	var vector Location;
	var float Radius;
};

var array<ZoneInfo> RelocateFromZones;
var array<Sphere> ExcludingAreas;
var float MaxRelocationZ;

function Trigger(Actor A, Pawn EventInstigator)
{
	GotoState('Relocation');
}

function AddZone(string ZoneName)
{
	local ZoneInfo Zone;

	Zone = ZoneInfo(LoadLevelActor(ZoneName));
	if (Zone != none)
		RelocateFromZones[Array_Size(RelocateFromZones)] = Zone;
}

function ExcludeArea(vector SphereCenter, float SphereRadius)
{
	local int i;

	i = Array_Size(ExcludingAreas);
	ExcludingAreas[i].Location = SphereCenter;
	ExcludingAreas[i].Radius = SphereRadius;
}

function CheckRelocation()
{
	local PlayerPawn PP;

	foreach AllActors(class'PlayerPawn', PP)
		if (ShouldRelocate(PP))
			RelocatePlayer(PP);
}

function bool ShouldRelocate(PlayerPawn PP)
{
	local int i;

	if (PP.Region.ZoneNumber == 0 || !PP.bCollideWorld)
		return false;

	if (PP.Location.Z > MaxRelocationZ)
		return false;

	for (i = 0; i < Array_Size(ExcludingAreas); ++i)
		if (VSize(PP.Location - ExcludingAreas[i].Location) <= ExcludingAreas[i].Radius)
			return false;

	for (i = 0; i < Array_Size(RelocateFromZones); ++i)
		if (PP.Region.Zone == RelocateFromZones[i])
			return true;

	return false;
}

function RelocatePlayer(PlayerPawn PP)
{
	local bool bCollideActors;
	local bool bBlockActors;
	local bool bBlockPlayers;

	bCollideActors = PP.bCollideActors;
	bBlockActors = PP.bBlockActors;
	bBlockPlayers = PP.bBlockPlayers;
	PP.SetCollision(false, false, false);
	PP.SetLocation(Location);
	PP.SetCollision(bCollideActors, bBlockActors, bBlockPlayers);
}

function Actor LoadLevelActor(string ActorName, optional bool bMayFail)
{
	return Actor(DynamicLoadObject(outer.name $ "." $ ActorName, class'Actor', bMayFail));
}

state Relocation
{
	event BeginState()
	{
		CheckRelocation();
	}

	event Tick(float DeltaTime)
	{
		CheckRelocation();
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
}
