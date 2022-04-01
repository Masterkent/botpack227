// The diary, logs important events
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCDiary extends NCPickup;

var travel string entries[100]; // can support up to 100 entries
var travel string mapnames[100]; // names of places for each entry
var travel int lastentry; // where to record next entry
var int viewmode; // which entry is being viewed
var bool bCurrentlyActivated; // activated
var() sound NewMessageSound;
var bool bTempAct;

function AddMessage(string newmessage) {
	Owner.PlaySound(NewMessageSound);
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
	function Tick(float DeltaTime) {
		if (PlayerPawn(Owner).SelectedItem != self && !bTempAct)
			GoToState('DeActivated');
	}

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
		bTempAct = false;
		bActive = false;
		bCurrentlyActivated = false;
	}
}

function Activate()
{
	OpenUp();
}

function OpenUp()
{
	local NClogbook logbook;

	if (lastentry > 0) {
		logbook = NClogbook(Pawn(Owner).FindInventoryType(Class'NCLogbook'));
		logbook.GotoState('Deactivated');
		GoToState('Activated');
		viewmode = lastentry-1;
	}
	if (bTempAct)
		SetTimer(15,false);
}

function Timer() {
	bTempAct = false;
}

defaultproperties
{
     NewMessageSound=Sound'UnrealI.Generic.Teleport2'
     infotex=Texture'NaliChronicles.Icons.DiaryInfo'
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="Diary"
     ItemName="Diary"
     PickupViewMesh=LodMesh'UnrealShare.BookM'
     PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
     Icon=Texture'NaliChronicles.Icons.DiaryIcon'
     Mesh=LodMesh'UnrealShare.BookM'
     CollisionRadius=12.000000
     CollisionHeight=4.000000
}
