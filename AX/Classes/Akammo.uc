//=============================================================================
// Akammo.
//=============================================================================
class Akammo expands TournamentAmmo;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX
#exec TEXTURE IMPORT NAME=I_Akammo FILE=Textures\i_Akammo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
     AmmoAmount=24
     MaxAmmo=48
     UsedInWeaponSlot(6)=1
     PickupMessage="You got an AK-47 clip."
     ItemName="AK-47 clip"
     PickupViewMesh=LodMesh'AX.Akammo'
     PickupViewScale=0.250000
     MaxDesireability=0.240000
     Icon=Texture'AX.Icons.I_Akammo'
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.Akammo'
     DrawScale=0.900000
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
}
