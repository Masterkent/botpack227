// Quickly regenerates health but causes bloodlust
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCBloodlustBottle extends NCBloodlustVial;

defaultproperties
{
     maxcount=5
     infotex=Texture'NaliChronicles.Icons.BloodlustbottleInfo'
     ExpireMessage="This bottle is empty"
     PickupMessage="You got a bloodlust potion bottle"
     ItemName="bloodlust potion bottle"
     PickupViewMesh=LodMesh'NaliChronicles.manabottle'
     Charge=25
     Icon=Texture'NaliChronicles.Icons.Bloodlustbottle'
     Skin=Texture'NaliChronicles.Skins.JBloodlustbottle'
     Mesh=LodMesh'NaliChronicles.manabottle'
}
