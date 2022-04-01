//=============================================================================
// Sniperammo.
//=============================================================================
class Sniperammo expands Tournamentammo;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX
#exec TEXTURE IMPORT NAME=I_Sniperammo FILE=Textures\i_Sniperammo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=50
     UsedInWeaponSlot(9)=1
     PickupMessage="You picked up ammo for the Sniperrifle."
     PickupViewMesh=LodMesh'AX.Sniperammo'
     PickupViewScale=0.250000
     StatusIcon=Texture'Botpack.Icons.Use8ball'
     MaxDesireability=0.300000
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.Sniperammo'
     CollisionRadius=27.000000
     CollisionHeight=12.000000
     bCollideActors=True
     Icon=Texture'AX.Icons.I_Sniperammo'
}
