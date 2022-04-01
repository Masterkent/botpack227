// A potion ingredient
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCSlithEggs extends NCPotionIngredient;

state Activated
{
	function Activate() {
		if (charge < default.charge)
			UsedUp();
		Super.Activate();
	}
}

defaultproperties
{
     IngredientColor=(R=32,G=160,B=128)
     powers(0)=-0.100000
     powers(1)=-0.050000
     powers(2)=1.000000
     powers(3)=-0.100000
     powers(4)=-0.100000
     powers(5)=0.100000
     ExpireMessage="This egg has been used up"
     PickupMessage="You got some slith eggs"
     ItemName="Slith eggs"
     PickupViewMesh=LodMesh'NaliChronicles.slitheggs'
     Charge=5
     ActivateSound=Sound'UnrealShare.Gibs.gibP6'
     Icon=Texture'NaliChronicles.Icons.slitheggs'
     Mesh=LodMesh'NaliChronicles.slitheggs'
     CollisionHeight=7.500000
}
