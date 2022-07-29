//=============================================================================
// RingExplosion4.
//=============================================================================
class UT_RingExplosion4 extends ut_ComboRing;

simulated function SpawnExtraEffects()
{
	bExtraEffectsSpawned = true;
	if (Owner != none)
		SetRotation(Owner.Rotation);
}

simulated function SpawnEffects()
{
}

defaultproperties
{
	bExtraEffectsSpawned=False
}
