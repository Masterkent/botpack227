// Same healing as Nali fruit, more suitable for kitchens and tables
// Code by Sergey 'Eater' Levin

class NCWine extends Health;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

defaultproperties
{
     HealingAmount=15
     PickupMessage="You picked up some Nali Wine +"
     RespawnTime=5.000000
     PickupViewMesh=LodMesh'NaliChronicles.wine'
     Mesh=LodMesh'NaliChronicles.wine'
     DrawScale=0.800000
     CollisionHeight=20.000000
}
