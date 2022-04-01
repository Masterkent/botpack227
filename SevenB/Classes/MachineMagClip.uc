// ===============================================================
// SevenB.MachineMagClip: ammo for Machine Mag
// ===============================================================

class MachineMagClip extends Miniammo;

defaultproperties
{
     AmmoAmount=35
     MaxAmmo=350
     UsedInWeaponSlot(7)=0
     PickupMessage="You picked up 35 bullets."
     PickupViewMesh=LodMesh'Botpack.EClipM'
     Mesh=LodMesh'Botpack.EClipM'
     CollisionRadius=20.000000
     CollisionHeight=4.000000
     Icon=Texture'Botpack.Icons.B227_I_EClip'
}
