//=============================================================================
// AXSgunammo.
//=============================================================================
class AXSgunammo expands Tournamentammo;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX
#exec TEXTURE IMPORT NAME=I_AXSgunammo FILE=Textures\i_AXSgunammo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
     AmmoAmount=18
     MaxAmmo=36
     UsedInWeaponSlot(5)=1
     PickupMessage="You got a box of shotgun shells."
     ItemName="Box of shotgun Rounds"
     PickupViewMesh=LodMesh'AX.AXSgunammo'
     PickupViewScale=0.310000
     MaxDesireability=0.240000
     Icon=Texture'AX.Icons.I_AXSgunammo'
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.AXSgunammo'
     DrawScale=0.100000
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
}
