// A potion ingredient
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCFruitEssence extends NCPotionIngredient;

function PostBeginPlay() {
	Super.PostBeginPlay();
	LoopAnim('Still');
}

defaultproperties
{
     IngredientColor=(R=192,G=32,B=32)
     powers(0)=-0.100000
     powers(1)=-0.050000
     powers(3)=1.000000
     powers(4)=0.100000
     ExpireMessage="This portion of essence has been used up"
     PickupMessage="You got some healing fruit essence"
     ItemName="Healing fruit essence"
     PickupViewMesh=LodMesh'NaliChronicles.fruitessence'
     Charge=6
     ActivateSound=Sound'UnrealShare.Tentacle.waver1tn'
     Icon=Texture'NaliChronicles.Icons.fruitessence'
     Mesh=LodMesh'NaliChronicles.fruitessence'
     CollisionHeight=10.000000
}
