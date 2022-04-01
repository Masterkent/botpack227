// A larger mana sources that can be carried around
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDarkManaBottle extends NCDarkManaVial;

defaultproperties
{
     maxcount=5
     infotex=Texture'NaliChronicles.Icons.dmanabottleInfo'
     ExpireMessage="This bottle is empty"
     PickupMessage="You got a dark mana bottle"
     ItemName="dark mana bottle"
     PickupViewMesh=LodMesh'NaliChronicles.manabottle'
     Charge=25
     Icon=Texture'NaliChronicles.Icons.dmanabottle'
     Skin=Texture'NaliChronicles.Skins.Jdmanabottle'
     Mesh=LodMesh'NaliChronicles.manabottle'
}
