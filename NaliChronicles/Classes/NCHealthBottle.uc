// A larger health source that can be carried around
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCHealthBottle extends NCHealthVial;

defaultproperties
{
     maxcount=5
     infotex=Texture'NaliChronicles.Icons.HealthBottleInfo'
     ExpireMessage="This bottle is empty"
     PickupMessage="You got a health potion bottle"
     ItemName="health potion bottle"
     PickupViewMesh=LodMesh'NaliChronicles.manabottle'
     Charge=25
     Icon=Texture'NaliChronicles.Icons.HealthBottle'
     Skin=Texture'NaliChronicles.Skins.JHealthBottle'
     Mesh=LodMesh'NaliChronicles.manabottle'
}
