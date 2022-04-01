//=============================================================================
// SWATammo.
//=============================================================================
class SWATammo expands Tournamentammo;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX
#exec TEXTURE IMPORT NAME=I_SWATammo FILE=Textures\i_SWATammo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
     AmmoAmount=30
     MaxAmmo=90
     UsedInWeaponSlot(3)=1
     PickupMessage="You picke up a SWAT 551 clip."
     ItemName="MP-5 clip"
     PickupViewMesh=LodMesh'AX.SWATammo'
     PickupViewScale=0.250000
     MaxDesireability=0.240000
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.SWATammo'
     DrawScale=1.100000
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     Icon=Texture'AX.Icons.I_SWATammo'
}
