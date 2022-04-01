// A larger potion container
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCEmptyBottle extends NCEmptyVial;

defaultproperties
{
     MixingClass=Class'NaliChronicles.NCMixingBottle'
     infotex=Texture'NaliChronicles.Icons.EmptyBottleInfo'
     ExpireMessage="This bottle has been used up"
     PickupMessage="You got an empty bottle"
     ItemName="Empty bottle"
     PickupViewMesh=LodMesh'NaliChronicles.EmptyBottle'
     Icon=Texture'NaliChronicles.Icons.EmptyBottle'
     Skin=Texture'NaliChronicles.Skins.JemptyBottle'
     Mesh=LodMesh'NaliChronicles.EmptyBottle'
}
