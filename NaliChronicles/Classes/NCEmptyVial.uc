// The base of potion containers - this needs to be activated to mix a potion
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCEmptyVial extends NCPickup;

var() class<NCMixingVial> MixingClass;

function Activate()
{
	local Inventory Copy;
	local Pawn p;

	Pawn(Owner).ClientMessage(ItemName $ " selected for use in a potion");
	if (NaliMage(Owner).CurrentVial != none) {
		NaliMage(Owner).CurrentVial.Activate();
	}
	Copy = spawn(MixingClass,Owner,,,rot(0,0,0));
	Copy.charge = 0;
	Copy.RespawnTime = 0.0;
	Copy.bHeldItem = true;
	Copy.GiveTo(Pawn(Owner));
	Copy.GotoState('Activated');
	Pawn(Owner).SelectedItem = Copy;
	NumCopies -= 1;
	if (NumCopies < 0) {
		bActivatable = false;
		p = Pawn(Owner);
		Pawn(Owner).DeleteInventory(Self);
		p.SelectedItem = Copy;
		destroy();
	}
}

defaultproperties
{
     MixingClass=Class'NaliChronicles.NCMixingVial'
     infotex=Texture'NaliChronicles.Icons.EmptyVialInfo'
     bCanHaveMultipleCopies=True
     ExpireMessage="This vial has been used up"
     bActivatable=True
     bDisplayableInv=True
     bAmbientGlow=False
     PickupMessage="You got an empty vial"
     ItemName="Empty vial"
     PickupViewMesh=LodMesh'NaliChronicles.EmptyVial'
     PickupViewScale=0.300000
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     Icon=Texture'NaliChronicles.Icons.EmptyVial'
     Skin=Texture'NaliChronicles.Skins.Jemptyvial'
     Mesh=LodMesh'NaliChronicles.EmptyVial'
     DrawScale=0.300000
     AmbientGlow=0
     CollisionRadius=6.000000
     CollisionHeight=10.000000
}
