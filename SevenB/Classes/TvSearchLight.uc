// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvSearchLight : client-updated search light
// note: probably doesn't work correctly with changed super class
// ===============================================================

class TvSearchLight expands TvFlashLight;

defaultproperties
{
     RealClass=Class'UnrealI.SearchLight'
     RespawnTime=300.000000
     PickupViewMesh=LodMesh'UnrealI.BigFlash'
     Icon=Texture'UnrealI.Icons.I_BigFlash'
     Mesh=LodMesh'UnrealI.BigFlash'
     CollisionHeight=12.000000
     LightHue=167
     LightRadius=13
}
