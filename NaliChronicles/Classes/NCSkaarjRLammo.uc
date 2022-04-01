// Bullets used in the Skaarj rocket launcher
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSkaarjRLammo extends Ammo;

defaultproperties
{
     AmmoAmount=16
     MaxAmmo=64
     UsedInWeaponSlot(8)=1
     bAmbientGlow=False
     PickupMessage="You picked up 10 Skaarj rockets"
     PickupViewMesh=LodMesh'NaliChronicles.SkaarjRLammo'
     PickupViewScale=1.250000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'NaliChronicles.Icons.SkaarjRLammoIcon'
     Mesh=LodMesh'NaliChronicles.SkaarjRLammo'
     DrawScale=1.250000
     AmbientGlow=0
     CollisionRadius=17.000000
     CollisionHeight=13.000000
     bCollideActors=True
}
