// A potion ingredient
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCHolyWater extends NCPotionIngredient;

defaultproperties
{
     IngredientColor=(R=255,G=255,B=255)
     powers(0)=-0.100000
     powers(1)=-0.050000
     powers(4)=1.000000
     powers(5)=-0.100000
     ExpireMessage="This bottle of holy water has been used up"
     PickupMessage="You got some holy water"
     ItemName="Holy water"
     PickupViewMesh=LodMesh'NaliChronicles.waterbottle'
     PickupViewScale=0.500000
     Charge=6
     ActivateSound=Sound'UnrealShare.Tentacle.waver1tn'
     Icon=Texture'NaliChronicles.Icons.holywater'
     Style=STY_Masked
     Skin=Texture'NaliChronicles.Skins.Jholywater'
     Mesh=LodMesh'NaliChronicles.waterbottle'
     DrawScale=0.500000
     CollisionHeight=7.500000
}
