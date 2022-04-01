//=============================================================================
// 4.7MM Rounds
//
//
//=============================================================================
class msgammo extends TournamentAmmo;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

defaultproperties
{
     AmmoAmount=10
     MaxAmmo=51
     PickupMessage="You got 7.62 NATO rounds."
     ItemName="7.62 rounds"
     PickupViewMesh=LodMesh'addweap.msgammobox'
     MaxDesireability=0.240000
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'addweap.msgammobox'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     UsedInWeaponSlot(5)=1
}
