// ============================================================
// OLweapons.ODBigEnergyImpact
// This is the weapons pack.
// Holds the network/decal compatible unreal I weapons, projectiles and effects to spawn decals, UT weapons with new ammo, // and new ammo that has icons and goes in the right slot....
// ============================================================

class ODBigEnergyImpact expands BigEnergyImpact;
simulated function AttachToSurface()    //fog zone hack (note that this code cannot be compiled normaly)
{
	super.AttachToSurface();
}

defaultproperties
{
}
