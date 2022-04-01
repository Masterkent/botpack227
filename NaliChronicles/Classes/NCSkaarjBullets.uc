// Bullets used in the Skaarj gun
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSkaarjBullets extends Ammo;

defaultproperties
{
     AmmoAmount=25
     MaxAmmo=200
     UsedInWeaponSlot(3)=1
     UsedInWeaponSlot(9)=1
     bAmbientGlow=False
     PickupMessage="You picked up 25 Skaarj pistol charges"
     PickupViewMesh=LodMesh'NaliChronicles.SkaarjBullets'
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'NaliChronicles.Icons.SkaarjBullets'
     Mesh=LodMesh'NaliChronicles.SkaarjBullets'
     AmbientGlow=0
     CollisionRadius=15.000000
     CollisionHeight=10.000000
     bCollideActors=True
}
