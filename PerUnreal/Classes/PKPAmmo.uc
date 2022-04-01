//=============================================================================
// PKPammo.
//=============================================================================
class PKPAmmo extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=25
     MaxAmmo=250
     UsedInWeaponSlot(5)=1
     PickupMessage="You picked up a Pulse Cell."
     ItemName="Pulse Cell"
     PickupViewMesh=LodMesh'Botpack.PAmmo'
     PickupSound=Sound'PerUnreal.ShockRifle.PKshockammo'
     Mesh=LodMesh'Botpack.PAmmo'
     CollisionRadius=20.000000
     CollisionHeight=12.000000
     Icon=Texture'Botpack.Icons.B227_I_PAmmo'
}
