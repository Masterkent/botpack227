//=============================================================================
// AXSShell.
//=============================================================================
class AXSShell expands Projectile;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

defaultproperties
{
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.AXSShell'
}
