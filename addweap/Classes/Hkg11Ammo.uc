//=============================================================================
// 4.7MM Rounds
//
//
//=============================================================================
class hkg11ammo extends TournamentAmmo;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

defaultproperties
{
     AmmoAmount=33
     MaxAmmo=200
     PickupMessage="You got 4.7mm caseless."
     ItemName="Box of 4.7mm Rounds"
     PickupViewMesh=LodMesh'addweap.hkg11ammobox'
     MaxDesireability=0.240000
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'addweap.hkg11ammobox'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     UsedInWeaponSlot(0)=1
}
