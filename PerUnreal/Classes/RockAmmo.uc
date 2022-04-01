//=============================================================================
// RockAmmo.
//=============================================================================
class RockAmmo extends Ammo;

defaultproperties
{
     AmmoAmount=6
     MaxAmmo=28
     UsedInWeaponSlot(6)=1
     PickupMessage="You picked up 6 Rock shells"
     ItemName="Rock Shells"
     PickupViewMesh=LodMesh'UnrealI.flakboxMesh'
     MaxDesireability=0.320000
     PickupSound=Sound'PerUnreal.RockLobber.RockAmmo'
     Mesh=LodMesh'UnrealI.flakboxMesh'
     CollisionRadius=16.000000
     CollisionHeight=11.000000
     bCollideActors=True
     Icon=Texture'UnrealI.Icons.I_FlakAmmo'
}
