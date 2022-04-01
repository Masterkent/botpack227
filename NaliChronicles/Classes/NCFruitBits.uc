// Same healing as Nali fruit, more suitable for kitchens and tables
// Code by Sergey 'Eater' Levin

class NCFruitBits extends Health;

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

defaultproperties
{
     HealingAmount=25
     PickupMessage="You picked up some Nali Healing Fruit +"
     RespawnTime=5.000000
     PickupViewMesh=LodMesh'NaliChronicles.fruitbits'
     Skin=Texture'UnrealShare.Skins.JNaliFruit1'
     Mesh=LodMesh'NaliChronicles.fruitbits'
     CollisionHeight=6.000000
}
