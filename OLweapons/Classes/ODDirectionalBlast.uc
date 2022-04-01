// ============================================================
// OLweapons.ODDirectionalBlast
// This is the weapons pack.
// Holds the network/decal compatible unreal I weapons, projectiles and effects to spawn decals, UT weapons with new ammo, // and new ammo that has icons and goes in the right slot....
// ============================================================

class ODDirectionalBlast expands DirectionalBlast;
simulated function DirectionalAttach(vector Dir, vector Norm)    //fog zone hack (note that this code cannot be compiled normaly)
{
	Super.DirectionalAttach(Dir,Norm);
}

defaultproperties
{
}
