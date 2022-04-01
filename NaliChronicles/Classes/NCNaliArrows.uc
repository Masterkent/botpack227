// Arrows used by the quadbow
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCNaliArrows extends Ammo;

defaultproperties
{
     AmmoAmount=40
     MaxAmmo=240
     UsedInWeaponSlot(5)=1
     bAmbientGlow=False
     PickupMessage="You picked up 40 arrows"
     PickupViewMesh=LodMesh'NaliChronicles.QuadbowAmmo'
     PickupViewScale=1.200000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'NaliChronicles.Icons.QuadbowAmmoIcon'
     Mesh=LodMesh'NaliChronicles.QuadbowAmmo'
     DrawScale=1.200000
     AmbientGlow=0
     CollisionRadius=12.000000
     CollisionHeight=22.000000
     bCollideActors=True
}
