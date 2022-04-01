// Leather armor
// Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCArmor extends Pickup;

defaultproperties
{
     bDisplayableInv=True
     bAmbientGlow=False
     PickupMessage="You got an armored leather vest"
     RespawnTime=30.000000
     PickupViewMesh=LodMesh'NaliChronicles.leatherarm'
     Charge=50
     ArmorAbsorption=90
     bIsAnArmor=True
     AbsorptionPriority=7
     MaxDesireability=1.800000
     PickupSound=Sound'UnrealShare.Pickups.ArmorSnd'
     Icon=Texture'NaliChronicles.Icons.leatherarmicon'
     Mesh=LodMesh'NaliChronicles.leatherarm'
     AmbientGlow=0
     CollisionHeight=11.000000
}
