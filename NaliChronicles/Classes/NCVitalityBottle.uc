// A larger speed source
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCVitalityBottle extends NCVitalityVial;

defaultproperties
{
     maxcount=5
     infotex=Texture'NaliChronicles.Icons.VitalitybottleInfo'
     ExpireMessage="This bottle is empty"
     PickupMessage="You got a vitality potion bottle"
     ItemName="vitality potion bottle"
     PickupViewMesh=LodMesh'NaliChronicles.manabottle'
     Charge=25
     Icon=Texture'NaliChronicles.Icons.Vitalitybottle'
     Skin=Texture'NaliChronicles.Skins.JVitalitybottle'
     Mesh=LodMesh'NaliChronicles.manabottle'
}
