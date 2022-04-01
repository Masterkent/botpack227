// The logbook, logs everything the player reads
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCLogbook extends NCPickup;

var travel string entries[500]; // can support up to 100 entries
var travel string mapnames[500]; // names of places for each entry
var travel string entrytitles[500]; // sources of each entry
var travel int lastentry; // where to record next entry
var int viewmode; // which entry is being viewed
var bool bCurrentlyActivated; // activated

function AddMessage(string newmessage, string source) {
	entrytitles[lastentry] = source;
	entries[lastentry] = newmessage;
	mapnames[lastentry] = Level.Title;
	lastentry++;
}

function CycleEntry(int i) {
	if (!bCurrentlyActivated)
		return;
	viewmode += i;
	if (viewmode < 0)
		viewmode = lastentry-1;
	if (viewmode >= lastentry)
		viewmode = 0;
	Owner.PlaySound(Sound'NaliChronicles.pageturn');
}

state Activated
{
	function Activate() {
		GoToState('DeActivated');
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

state DeActivated
{
Begin:
}

function Activate()
{
	local NCDiary diary;

	diary = NCdiary(Pawn(Owner).FindInventoryType(Class'NCdiary'));
	if ((lastentry > 0) && (!diary.bCurrentlyActivated)) {
		GoToState('Activated');
		viewmode = lastentry-1;
	}
}

defaultproperties
{
     infotex=Texture'NaliChronicles.Icons.LogbookInfo'
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="Logbook"
     ItemName="Logbook"
     PickupViewMesh=LodMesh'UnrealShare.BookM'
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     Icon=Texture'NaliChronicles.Icons.LogbookIcon'
     Mesh=LodMesh'UnrealShare.BookM'
     CollisionRadius=12.000000
     CollisionHeight=4.000000
}
