//=============================================================================
// asm4ammo.
//=============================================================================
class asm4ammo expands Tournamentammo;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX
#exec TEXTURE IMPORT NAME=I_asm4ammo FILE=Textures\i_asm4ammo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
     AmmoAmount=24
     MaxAmmo=48
     UsedInWeaponSlot(7)=1
     PickupMessage="You got an M4 Assault rifle clip."
     ItemName="M4 Assault Rifle clip"
     PickupViewMesh=LodMesh'AX.asm4ammo'
     PickupViewScale=0.250000
     MaxDesireability=0.240000
     Icon=Texture'AX.Icons.I_asm4ammo'
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.asm4ammo'
     DrawScale=0.100000
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
}
