// Spawns next ShockBeams after WarpZones
class B227_ShockBeamExtension expands Effects;

var class<ShockRifle> ShockRifleClass;
var float Delay;
var vector MoveAmount;
var int NumPuffs;

static function B227_ShockBeamExtension Make(
	Actor Spawner,
	class<ShockRifle> ShockRifleClass,
	vector BeamLocation,
	rotator BeamRotation,
	float Delay,
	vector MoveAmount,
	int NumPuffs)
{
	local B227_ShockBeamExtension BeamExtension;

	BeamExtension = Spawner.Spawn(class'B227_ShockBeamExtension',,, BeamLocation, BeamRotation);
	if (BeamExtension != none)
	{
		BeamExtension.ShockRifleClass = ShockRifleClass;
		BeamExtension.MoveAmount = MoveAmount;
		BeamExtension.NumPuffs = NumPuffs;
		BeamExtension.Delay = Delay;
		BeamExtension.GotoState('Active');
	}
	return BeamExtension;
}

function SpawnShockBeam()
{
	if (ShockRifleClass != none)
		ShockRifleClass.static.B227_SpawnShockBeam(self, Location, Rotation, MoveAmount, NumPuffs);
}

auto state Idle
{
	event Tick(float DeltaTime)
	{
		Destroy();
	}
}

state Active
{
Begin:
	Sleep(Delay);
	SpawnShockBeam();
	Destroy();
}

defaultproperties
{
	RemoteRole=ROLE_None
}
