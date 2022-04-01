//=============================================================================
// Famasammo.
//=============================================================================
class Famasammo expands Tournamentammo;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX
#exec TEXTURE IMPORT NAME=I_Famasammo FILE=Textures\i_Famasammo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
     AmmoAmount=30
     MaxAmmo=90
     UsedInWeaponSlot(2)=1
     UsedInWeaponSlot(4)=1
     PickupMessage="You got an FAMAS G2 clip."
     ItemName="MP-5 clip"
     PickupViewMesh=LodMesh'AX.Famasammo'
     PickupViewScale=0.250000
     MaxDesireability=0.240000
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.Famasammo'
     DrawScale=1.100000
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     Icon=Texture'AX.Icons.I_Famasammo'
}
