//=============================================================================
// 9MM Rounds
//
//
//=============================================================================
class h21ammo extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=50
     MaxAmmo=200
     PickupMessage="You got 7.62 Ammo belt."
     ItemName="7.62 Ammo belt"
     PickupViewMesh=LodMesh'addweap.h21ammobox'
     MaxDesireability=0.240000
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'addweap.h21ammobox'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     UsedInWeaponSlot(3)=1
}
