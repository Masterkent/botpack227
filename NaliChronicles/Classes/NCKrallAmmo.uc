// Ammo used in the Krall staff
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCKrallAmmo extends Ammo;

defaultproperties
{
     AmmoAmount=30
     MaxAmmo=150
     UsedInWeaponSlot(4)=1
     bAmbientGlow=False
     PickupMessage="You picked up 30 Krall staff charges"
     PickupViewMesh=LodMesh'NaliChronicles.KrallAmmo'
     PickupViewScale=1.400000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'NaliChronicles.Icons.KrallAmmo'
     Mesh=LodMesh'NaliChronicles.KrallAmmo'
     DrawScale=1.400000
     AmbientGlow=0
     CollisionRadius=22.000000
     CollisionHeight=6.000000
     bCollideActors=True
}
