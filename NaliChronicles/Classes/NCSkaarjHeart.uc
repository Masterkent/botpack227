// A potion ingredient
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSkaarjHeart extends NCPotionIngredient;

function PostBeginPlay() {
	Super.PostBeginPlay();
	LoopAnim('Still');
}

defaultproperties
{
     IngredientColor=(R=255,G=200)
     powers(1)=1.000000
     powers(2)=-0.100000
     powers(3)=-0.100000
     powers(4)=-0.100000
     powers(5)=-0.100000
     ExpireMessage="This Skaarj Heart of Power has been used up"
     PickupMessage="You got a Skaarj Heart of Power"
     ItemName="Skaarj Heart of Power"
     PickupViewMesh=LodMesh'NaliChronicles.skaarjheart'
     PickupViewScale=0.300000
     Charge=5
     ActivateSound=Sound'UnrealShare.Gibs.gibP6'
     Icon=Texture'NaliChronicles.Icons.skaarjheart'
     Skin=Texture'NaliChronicles.Skins.Jskaarjheart'
     Mesh=LodMesh'NaliChronicles.skaarjheart'
     DrawScale=0.300000
     CollisionHeight=7.500000
}
