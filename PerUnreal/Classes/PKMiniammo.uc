//=============================================================================
// PKMiniammo.
//=============================================================================
class PKMiniAmmo extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=60
     MaxAmmo=400
     UsedInWeaponSlot(2)=1
     UsedInWeaponSlot(7)=1
     PickupMessage="You picked up 60 bullets."
     ItemName="Large Bullets"
     PickupViewMesh=LodMesh'Botpack.MiniAmmom'
     PickupSound=Sound'PerUnreal.Sixpack.PKMiniammo'
     Mesh=LodMesh'Botpack.MiniAmmom'
     CollisionRadius=22.000000
     CollisionHeight=11.000000
     bCollideActors=True
     Icon=Texture'Botpack.Icons.B227_I_MiniAmmo'
}
