// ===============================================================
// SevenB.SBGrenadeAmmo: Grenade Launcher Ammo
// ===============================================================

class SBGrenadeAmmo extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=8
     MaxAmmo=32
     UsedInWeaponSlot(9)=1
     PickupMessage="You picked up some grenades."
     PickupViewMesh=LodMesh'Botpack.RocketPackMesh'
     MaxDesireability=0.300000
     Physics=PHYS_Falling
     Mesh=LodMesh'Botpack.RocketPackMesh'
     CollisionRadius=27.000000
     CollisionHeight=12.000000
     bCollideActors=True
     Icon=Texture'Botpack.Icons.B227_I_RocketPack'
}
