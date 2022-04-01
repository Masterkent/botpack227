//=============================================================================
// temp.
//=============================================================================
class rlammo extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=1
     MaxAmmo=4
     UsedInWeaponSlot(0)=1
     PickupMessage="You picked up a Rocket."
     PickupViewMesh=LodMesh'Botpack.RocketPackMesh'
     PickupViewScale=0.300000
     StatusIcon=Texture'Botpack.Icons.Use8ball'
     MaxDesireability=0.300000
     Physics=PHYS_Falling
     Mesh=LodMesh'Botpack.RocketPackMesh'
     DrawScale=0.100000
     CollisionRadius=27.000000
     CollisionHeight=12.000000
     bCollideActors=True
     Icon=Texture'Botpack.Icons.B227_I_RocketPack'
}
