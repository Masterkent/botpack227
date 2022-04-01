// Ammo for shock rifle
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCShockCore extends Ammo;

defaultproperties
{
     AmmoAmount=20
     MaxAmmo=80
     UsedInWeaponSlot(7)=1
     bAmbientGlow=False
     PickupMessage="You picked up a Shock Core."
     ItemName="Shock Core"
     PickupViewMesh=LodMesh'Botpack.ShockCoreM'
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'NaliChronicles.Icons.ShockAmmo'
     Physics=PHYS_Falling
     Mesh=LodMesh'Botpack.ShockCoreM'
     AmbientGlow=0
     CollisionRadius=14.000000
     CollisionHeight=20.000000
     bCollideActors=True
}
