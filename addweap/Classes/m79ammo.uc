//=============================================================================
//
//
//
//=============================================================================
class m79ammo extends TournamentAmmo;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

defaultproperties
{
     AmmoAmount=1
     MaxAmmo=2
     PickupMessage="You got one HEAP rocket."
     ItemName="Rocket"
     PickupViewMesh=LodMesh'Botpack.missile'
     PickupViewScale=0.400000
     MaxDesireability=0.240000
     Icon=Texture'UnrealI.Icons.I_RIFLEAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'Botpack.missile'
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
     UsedInWeaponSlot(9)=1
}
