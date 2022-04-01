// A larger speed source
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSpeedBottle extends NCSpeedVial;

defaultproperties
{
     maxcount=5
     infotex=Texture'NaliChronicles.Icons.speedbottleInfo'
     ExpireMessage="This bottle is empty"
     PickupMessage="You got a speed potion bottle"
     ItemName="speed potion bottle"
     PickupViewMesh=LodMesh'NaliChronicles.manabottle'
     Charge=25
     Icon=Texture'NaliChronicles.Icons.speedbottle'
     Skin=Texture'NaliChronicles.Skins.Jspeedbottle'
     Mesh=LodMesh'NaliChronicles.manabottle'
}
