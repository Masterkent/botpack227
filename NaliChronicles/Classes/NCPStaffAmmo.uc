// Ammo used by prophet staff
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCPStaffAmmo extends Ammo;

defaultproperties
{
     AmmoAmount=5
     MaxAmmo=100
     UsedInWeaponSlot(0)=1
     bAmbientGlow=False
     PickupMessage="You picked up 5 spiritual forces"
     PickupViewMesh=LodMesh'NaliChronicles.PStaffAmmo'
     PickupViewScale=1.200000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'NaliChronicles.Icons.PStaffAmmoIcon'
     Mesh=LodMesh'NaliChronicles.PStaffAmmo'
     DrawScale=1.200000
     AmbientGlow=0
     CollisionRadius=10.000000
     CollisionHeight=12.000000
     bCollideActors=True
}
