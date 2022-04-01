// A potion ingredient
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDarkWater extends NCPotionIngredient;

defaultproperties
{
     IngredientColor=(R=32,G=32,B=32)
     powers(0)=-0.100000
     powers(1)=-0.050000
     powers(4)=-0.100000
     powers(5)=1.000000
     ExpireMessage="This bottle of cursed water has been used up"
     PickupMessage="You got some cursed water"
     ItemName="Cursed water"
     PickupViewMesh=LodMesh'NaliChronicles.waterbottle'
     PickupViewScale=0.500000
     Charge=6
     ActivateSound=Sound'UnrealShare.Tentacle.waver1tn'
     Icon=Texture'NaliChronicles.Icons.darkwater'
     Style=STY_Masked
     Skin=Texture'NaliChronicles.Skins.Jdarkwater'
     Mesh=LodMesh'NaliChronicles.waterbottle'
     DrawScale=0.500000
     CollisionHeight=7.500000
}
