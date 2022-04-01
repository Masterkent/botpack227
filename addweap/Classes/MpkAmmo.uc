//=============================================================================
// 9MM Rounds
//
//
//=============================================================================
class mpkammo extends TournamentAmmo;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

defaultproperties
{
     AmmoAmount=30
     MaxAmmo=200
     PickupMessage="You got 9mm clip."
     ItemName="9mm MP5K clip"
     PickupViewMesh=LodMesh'addweap.mpkammobox'
     MaxDesireability=0.240000
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'addweap.mpkammobox'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     UsedInWeaponSlot(4)=1
}
