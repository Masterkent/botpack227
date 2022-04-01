// Bullets used in the Nali gun
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCNaliBullets extends Ammo;

defaultproperties
{
     AmmoAmount=25
     MaxAmmo=200
     UsedInWeaponSlot(2)=1
     PickupMessage="You picked up 25 Tarydium Nali bullets"
     PickupViewMesh=LodMesh'NaliChronicles.NaliBullets'
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'NaliChronicles.Icons.NaliBullets'
     Mesh=LodMesh'NaliChronicles.NaliBullets'
     CollisionRadius=22.000000
     CollisionHeight=6.000000
     bCollideActors=True
}
