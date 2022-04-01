//=============================================================================
// 9MM
//
//
//=============================================================================
class mac10ammo extends TournamentAmmo;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

defaultproperties
{
     AmmoAmount=50
     MaxAmmo=300
     PickupMessage="You got 9mm clip"
     ItemName="9mm clip"
     PickupViewMesh=LodMesh'addweap.mac10ammobox'
     Physics=PHYS_Falling
     Mesh=LodMesh'addweap.mac10ammobox'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     UsedInWeaponSlot(7)=1
}
