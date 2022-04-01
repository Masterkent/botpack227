// A book with alchemical recipes
// Code by Sergey 'Eater' Levin, 2002

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCAlchBook extends NCPickup;

var travel string entries[25];
var int viewmode; // which entry is being viewed
var bool bCurrentlyActivated; // activated

state Activated
{
	function Activate() {
		viewmode+=2;
		Owner.PlaySound(Sound'NaliChronicles.pageturn');
		if (entries[viewmode] == "") {
			GoToState('DeActivated');
		}
	}

	function BeginState()
	{
		bActive = true;
		bCurrentlyActivated = true;
	}

	function EndState()
	{
		bActive = false;
		bCurrentlyActivated = false;
	}
}

function Activate()
{
	GoToState('Activated');
	viewmode = 0;
}

defaultproperties
{
     entries(0)="For potions of healing, to restore wounded flesh, use three parts healing fruit essence and one part DaStook leaves. For a small vial, use 4 measures of leaves and 11 measures of fruit. For a larger bottle, use 6 measures of the leaves and 19 measures of fruit."
     entries(1)="To restore mana, use leaves and serpent eggs. For a vial, use 4 measures of leaves and 11 measures of eggs, or use 9 measures of eggs and 2 measures of holy water to purify the potion. For bottles, 6 measures of leaves, 16 or 19 of eggs, and 3 (or none) of holy water."
     entries(2)="To increase one's speed, use DaStook leaves, fruit essence, and the heart of demon. For vials, use 7 measures of fruit, 3 measures of the heart, 5 measures of leaves. For a bottle, use 12 measures of fruit, 4 measures of the heart, and 9 measures of leaves."
     entries(3)="For a potion of vitality, leaves, fruit essence, holy water, and demon hearts are needed. For vials, use 5 measures of fruit, 5 measures of holy water, 3 measures of leaves, and 2 measures of the heart. For bottles, 8 fruit, 8 holy water, 6 leaf, and 2 measures of the heart."
     entries(4)="For a potion of bloodlust, leaves, demon hearts, fruit essence, and cursed water is needed. For vials, use 3 leaf, 3 heart, 4 fruit essence, and 5 measures of the cursed water. For bottles, 5 leaf, 5 heart, 7 fruit, and 8 measures of the cursed water."
     entries(5)="To increase one's ability to cast spells, mix serpent eggs, demon heart, cursed water, and leaves. For vials, use 3 leaf, 2 heart, 5 cursed water, and 5 measures of the eggs. For a bottle, 5 leaf, 8 cursed water, 8 measures of eggs, and 4 measures of the heart."
     infotex=Texture'NaliChronicles.Icons.alchbookInfo'
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You picked up an alchemy book"
     ItemName="Alchemy Book"
     PickupViewMesh=LodMesh'UnrealShare.BookM'
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     Icon=Texture'NaliChronicles.Icons.alchbookIcon'
     Mesh=LodMesh'UnrealShare.BookM'
     CollisionRadius=12.000000
     CollisionHeight=4.000000
}
