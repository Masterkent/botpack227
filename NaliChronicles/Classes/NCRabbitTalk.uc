// Adds a new logbook entry
// Code by Sergey 'Eater' Levin

class NCRabbitTalk extends Triggers;

var() bool bNewDiaryEntry;
var() string DiaryEntry;
var() bool bPlayOnceOnly;
var bool bHitOnce, bHitDelay, bDiaryOnce, bPlayNoMore;
var() float ReTriggerDelay; //minimum time before trigger can be triggered again
var	  float TriggerTime;
var() string ConvStrings[20];
var() sound ConvSounds[20];
var() float ConvSpeakTime[20];
var() int PlayerSpeaks[20];

var NCCompanionRabbit rabbit;
var NCDiary diary;

function Trigger( actor Other, pawn EventInstigator )
{
	Touch(EventInstigator);
}

function UnTrigger( actor Other, pawn EventInstigator )
{
	UnTouch(EventInstigator);
}


function Timer()
{
	bHitDelay=False;
}

function Touch( actor Other )
{
	local inventory Inv;
	local int i;

	if (NaliMage(Other)==None || bHitDelay || bPlayNoMore || (Pawn(Other).FindInventoryType(Class'NCCompanionRabbit') == none) || ( !NCCompanionRabbit( Pawn(Other).FindInventoryType(Class'NCCompanionRabbit') ).ConvDone )) Return;

	if (bPlayOnceOnly)
		bPlayNoMore = true;

	if ( ReTriggerDelay > 0 )
	{
		if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
			return;
		TriggerTime = Level.TimeSeconds;
	}


	for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory ) {
		if (NCCompanionRabbit(Inv)!=None) {
			rabbit = NCCompanionRabbit(Inv);
			while (i<20) {
				rabbit.ConvStrings[i] = ConvStrings[i];
				rabbit.ConvSounds[i] = ConvSounds[i];
				rabbit.ConvSpeakTime[i] = ConvSpeakTime[i];
				rabbit.PlayerSpeaks[i] = PlayerSpeaks[i];
				i++;
			}
			if ((!bDiaryOnce) && (bNewDiaryEntry)) {
				rabbit.bNewDiary = true;
				rabbit.DiaryMsg = DiaryEntry;
				bDiaryOnce = true;
			}
			rabbit.conversenum = 0;
			rabbit.convdone = false;
			rabbit.NewConversation();
		}
	}
}

function UnTouch( actor Other )
{
	bHitDelay=False;
}

defaultproperties
{
     ReTriggerDelay=0.250000
     Texture=Texture'UnrealShare.S_Message'
}
