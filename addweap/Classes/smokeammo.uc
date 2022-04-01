//=============================================================================
// smoke ammo
//
//
//=============================================================================
class smokeammo extends TournamentAmmo;

defaultproperties
{
     AmmoAmount=16
     MaxAmmo=48
     PickupMessage="You got gas clip."
     ItemName="gas clip"
     PickupViewMesh=LodMesh'addweap.smokeammobox'
     MaxDesireability=0.240000
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'addweap.smokeammobox'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     UsedInWeaponSlot(6)=1
}
