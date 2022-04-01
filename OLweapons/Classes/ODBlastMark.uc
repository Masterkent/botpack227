// ============================================================
// OLweapons.ODBlastMark
// This is the weapons pack.
// Holds the network/decal compatible unreal I weapons, projectiles and effects to spawn decals, UT weapons with new ammo, // and new ammo that has icons and goes in the right slot....
// ============================================================

class ODBlastMark expands BlastMark;

event BeginPlay() {}

simulated function AttachToSurface()    //fog zone hack (note that this code cannot be compiled normaly)
{
	super.AttachToSurface();
}

defaultproperties
{
	Texture=Texture'UnrealShare.RocketBlast6'
}
