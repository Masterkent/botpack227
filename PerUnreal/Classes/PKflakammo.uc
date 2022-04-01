//=============================================================================
// PKFlakAmmo.
//=============================================================================
class PKFlakAmmo extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=50
     UsedInWeaponSlot(8)=1
     PickupMessage="You picked up 10 Flak Shells."
     ItemName="Flak Shells"
     PickupViewMesh=LodMesh'Botpack.FlakAmmoM'
     MaxDesireability=0.320000
     PickupSound=Sound'PerUnreal.flak.PKflakammo'
     Mesh=LodMesh'Botpack.FlakAmmoM'
     CollisionRadius=16.000000
     CollisionHeight=11.000000
     bCollideActors=True
     Icon=Texture'Botpack.Icons.B227_I_FlakAmmo'
}
