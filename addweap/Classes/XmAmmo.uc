//=============================================================================
// 9MM Rounds
//
//
//=============================================================================
class xmammo extends TournamentAmmo;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

defaultproperties
{
     AmmoAmount=16
     MaxAmmo=48
     PickupMessage="You got full box of shells."
     ItemName="xm shells"
     PickupViewMesh=LodMesh'addweap.xmammobox'
     MaxDesireability=0.240000
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'addweap.xmammobox'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     UsedInWeaponSlot(8)=1
}
