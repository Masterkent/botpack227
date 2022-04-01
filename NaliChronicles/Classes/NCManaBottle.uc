// A larger mana sources that can be carried around
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

//#exec MESHMAP SETTEXTURE MESHMAP=manabottle NUM=1 TEXTURE=Jmanabottle

class NCManaBottle extends NCManaVial;

defaultproperties
{
     maxcount=5
     infotex=Texture'NaliChronicles.Icons.manabottleInfo'
     ExpireMessage="This bottle is empty"
     PickupMessage="You got a mana bottle"
     ItemName="mana bottle"
     PickupViewMesh=LodMesh'NaliChronicles.manabottle'
     Charge=25
     Icon=Texture'NaliChronicles.Icons.manabottle'
     Skin=Texture'NaliChronicles.Skins.Jmanabottle'
     Mesh=LodMesh'NaliChronicles.manabottle'
}
