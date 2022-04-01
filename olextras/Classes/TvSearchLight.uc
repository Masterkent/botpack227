// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvSearchLight : client-updated search light
// ===============================================================

class TvSearchLight expands TvFlashLight;

defaultproperties
{
     bUsesCharge=True
     RealClass=Class'UnrealI.SearchLight'
     RespawnTime=300.000000
     PickupViewMesh=LodMesh'UnrealI.BigFlash'
     StatusIcon=Texture'olextras.Icons.SearchLightI'
     Charge=20000
     Icon=Texture'UnrealI.Icons.I_BigFlash'
     Mesh=LodMesh'UnrealI.BigFlash'
     CollisionHeight=12.000000
     LightHue=167
     LightRadius=13
}
