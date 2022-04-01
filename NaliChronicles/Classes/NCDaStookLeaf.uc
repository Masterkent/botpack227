// A potion ingredient
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDaStookLeaf extends NCPotionIngredient;

defaultproperties
{
     IngredientColor=(R=32,G=160,B=32)
     powers(0)=1.000000
     powers(1)=0.100000
     ExpireMessage="This DaStook leaf has been used up"
     PickupMessage="You got some DaStook leaves"
     ItemName="DaStook leaves"
     PickupViewMesh=LodMesh'NaliChronicles.dastookleaf'
     Charge=4
     ActivateSound=Sound'NaliChronicles.PickupSounds.leafsound'
     Icon=Texture'NaliChronicles.Icons.dastookleaf'
     Skin=Texture'UnrealShare.Skins.JNaliFruit1'
     Mesh=LodMesh'NaliChronicles.dastookleaf'
     CollisionHeight=6.000000
}
