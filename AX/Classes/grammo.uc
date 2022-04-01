//=============================================================================
// temp.
//=============================================================================
class grammo extends TournamentAmmo;

#exec TEXTURE IMPORT NAME=I_grammo FILE=Textures\i_grammo.pcx GROUP="Icons" MIPS=OFF

defaultproperties
{
     AmmoAmount=1
     MaxAmmo=5
     UsedInWeaponSlot(8)=1
     PickupMessage="You picked up a grenade."
     PickupViewMesh=LodMesh'AX.Grenade'
     PickupViewScale=0.200000
     StatusIcon=Texture'Botpack.Icons.Use8ball'
     MaxDesireability=0.300000
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.Grenade'
     DrawScale=0.100000
     CollisionRadius=27.000000
     CollisionHeight=12.000000
     bCollideActors=True
     Icon=Texture'AX.Icons.I_grammo'
}
