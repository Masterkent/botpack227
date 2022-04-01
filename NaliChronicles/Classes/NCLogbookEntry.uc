// Adds a new logbook entry
// Code by Sergey 'Eater' Levin

class NCLogbookEntry extends Triggers;

var() bool bNewDiaryEntry;
var() string DiaryEntry;
var() bool bDoNotLog;
var() localized string Message;
var() localized string Title;
var() bool bTriggerOnly;
var bool bHitOnce, bHitDelay, bDiaryOnce;
var() float ReTriggerDelay; //minimum time before trigger can be triggered again
var	  float TriggerTime;
var() name bookTag;
var actor myBook;

var NCLogbook logbook;
var NCDiary diary;

function PostBeginPlay() {
	local actor a;

	Super.PostBeginPlay();
	if ( bookTag != '' ) {
		foreach allactors(Class'actor',a,bookTag) {
			if (a.tag == bookTag)
				myBook = a;
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	Touch(Other);
}

function UnTrigger( actor Other, pawn EventInstigator )
{
	UnTouch(Other);
}


function Timer()
{
	bHitDelay=False;
}

function Touch( actor Other )
{
	local inventory Inv;

	if (PlayerPawn(Other)==None || bHitDelay) Return;

	if ((Message=="") && (DiaryEntry=="")) Return;

	if ( ReTriggerDelay > 0 )
	{
		if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
			return;
		TriggerTime = Level.TimeSeconds;
	}

	if ((!bHitOnce) && (!bDoNotLog)) {
		for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if (NCLogbook(Inv)!=None) {
				if ((Message=="") && (DiaryEntry=="")) Return;
				logbook = NCLogbook(Inv);

				NCLogbook(Inv).AddMessage(Message,title);
				if (!bNewDiaryEntry)
					Pawn(Other).ClientMessage("New logbook entry added",'Pickup');

				bHitOnce = True;
				SetTimer(0.3,False);
				bHitDelay = True;
				Break;
			}
		}
	}
	if ((!bDiaryOnce) && (bNewDiaryEntry)) {
		for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory ) {
			if (NCDiary(Inv)!=None) {
				if ((Message=="") && (DiaryEntry=="")) Return;
				diary = NCDiary(Inv);

				NCDiary(Inv).AddMessage(DiaryEntry);
				Pawn(Other).ClientMessage("New diary entry added! Open diary to read",'Pickup');
				if (!NCDiary(Inv).isInState('Activated') && PlayerPawn(Other).bFire == 0 && PlayerPawn(Other).bAltFire == 0) {
					NCDiary(Inv).bTempAct = true;
					NCDiary(Inv).OpenUp();
				}

				bDiaryOnce = True;
				Break;
			}
		}
	}
	if (NaliMage(Other) != none) {
		NaliMage(Other).ReadableStart = Level.TimeSeconds;
		NaliMage(Other).ReadableEntry = message;
		NaliMage(Other).ReadableTitle = title;
		NaliMage(Other).logbookevent = self;
	}
}

function UnTouch( actor Other )
{
	if ((NaliMage(Other) != none) && (NaliMage(Other).ReadableEntry == message) && (VSize(location-other.location) > fMax(CollisionHeight,CollisionRadius)+fMax(other.CollisionHeight,other.CollisionRadius))) {
		NaliMage(Other).ReadableEntry = "";
		NaliMage(Other).ReadableTitle = "";
		NaliMage(Other).logbookevent = none;
	}
	bHitDelay=False;
}

function Tick(float DeltaTime) {
	Super.Tick(DeltaTime);
	if (myBook != none) {
		setLocation(myBook.location);
	}
}

defaultproperties
{
     ReTriggerDelay=0.250000
     Texture=Texture'UnrealShare.S_Message'
}
