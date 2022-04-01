//=============================================================================
// PKSuperRing2.
//=============================================================================
class PKSuperRing2 extends PKSuperRing;

simulated function SpawnExtraEffects()
{
	local actor a;

	bExtraEffectsSpawned = true;
	a = Spawn(class'PKSuperShockExplo');
	a.RemoteRole = ROLE_None;

	Spawn(class'EnergyImpact');

	if ( Level.bHighDetailMode && !Level.bDropDetail )
	{
		a = Spawn(class'PKSuperring');
		a.RemoteRole = ROLE_None;
	}
}

defaultproperties
{
     bExtraEffectsSpawned=False
}
