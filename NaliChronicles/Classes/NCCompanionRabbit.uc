// The player's best friend...
// Code by Sergey 'Eater' Levin, 2001

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCCompanionRabbit extends NCPickup;

var NaliMage potentialuser;
var int conversenum;
var string ConvStrings[20];
var sound ConvSounds[20];
var float ConvSpeakTime[20];
var int PlayerSpeaks[20];
var float LastEventTime;
var travel bool convdone;
var bool bNewDiary;
var string DiaryMsg;

function NewConversation() {
	if (Owner == none) Return;
	NaliMage(Owner).ConvString = ConvStrings[conversenum];
	if (PlayerSpeaks[conversenum] > 0)
		NaliMage(Owner).CurrentTalker = Owner;
	else
		NaliMage(Owner).CurrentTalker = self;
	Owner.PlaySound(ConvSounds[conversenum]);
	NaliMage(Owner).TalkBegin = Level.TimeSeconds;
	NaliMage(Owner).TalkLast = NCHUD(NaliMage(Owner).myHUD).modifySpeakTime(convspeaktime[conversenum]);
	SetTimer(NCHUD(NaliMage(Owner).myHUD).modifySpeakTime(convspeaktime[conversenum]),false);
	conversenum++;
}

function Timer() {
	local NCDiary diary;
	local Inventory Inv;

	if (Owner == none) Return;
	NaliMage(Owner).ConvString = ConvStrings[conversenum];
	if (PlayerSpeaks[conversenum] > 0)
		NaliMage(Owner).CurrentTalker = Owner;
	else
		NaliMage(Owner).CurrentTalker = self;
	Owner.PlaySound(ConvSounds[conversenum],Slot_Talk);
	NaliMage(Owner).TalkBegin = Level.TimeSeconds;
	NaliMage(Owner).TalkLast = NCHUD(NaliMage(Owner).myHUD).modifySpeakTime(convspeaktime[conversenum]);
	if (ConvSounds[conversenum] != None) {
		SetTimer(NCHUD(NaliMage(Owner).myHUD).modifySpeakTime(convspeaktime[conversenum]),false);
		conversenum++;
	}
	else {
		if (bNewDiary) {
			bNewDiary = false;
			for( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) {
				if (NCDiary(Inv)!=None) {
					diary = NCDiary(Inv);
					NCDiary(Inv).AddMessage(DiaryMsg);
					Pawn(Owner).ClientMessage("New diary entry added! Open diary to read",'Pickup');
					if (!NCDiary(Inv).isInState('Activated') && PlayerPawn(Owner).bFire == 0 && PlayerPawn(Owner).bAltFire == 0) {
						NCDiary(Inv).bTempAct = true;
						NCDiary(Inv).OpenUp();
					}
					Break;
				}
			}
		}
		convdone = true;
	}
}

auto state Pickup
{
	function Tick(float DeltaTime) {
		local NaliMage NM;

		Global.Tick(DeltaTime);
		if (potentialuser == none) {
			foreach allactors(Class'NaliMage',NM) {
				potentialuser = NM;
			}
		}
		else {
			if ((VSize(location - potentialuser.location) < 600) && (!convdone) && (FastTrace(potentialuser.location,location))) {
				if (conversenum <= 0) {
					potentialuser.ConvString = convstrings[conversenum];
					potentialuser.CurrentTalker = self;
					potentialuser.TalkBegin = Level.TimeSeconds;
					potentialuser.TalkLast = NCHUD(potentialuser.myHUD).modifySpeakTime(convspeaktime[conversenum]);
					PlaySound(convsounds[conversenum]);
					LastEventTime = Level.TimeSeconds;
					conversenum++;
				}
				else {
					if ((Level.TimeSeconds - LastEventTime) >= (NCHUD(potentialuser.myHUD).modifySpeakTime(convspeaktime[conversenum-1]))) {
						potentialuser.ConvString = convstrings[conversenum];
						if (PlayerSpeaks[conversenum] == 1) {
							potentialuser.CurrentTalker = potentialuser;
							potentialuser.PlaySound(convsounds[conversenum]);
						}
						else {
							potentialuser.CurrentTalker = self;
							PlaySound(convsounds[conversenum]);
						}
						potentialuser.TalkBegin = Level.TimeSeconds;
						potentialuser.TalkLast = NCHUD(potentialuser.myHUD).modifySpeakTime(convspeaktime[conversenum]);
						LastEventTime = Level.TimeSeconds;
						if (ConvSounds[conversenum] == None) {
							convdone = true;
							if (VSize(location - potentialuser.location) < 100) {
								Touch(potentialuser);
							}
						}
						conversenum++;
					}
				}
			}
		}
	}
	function Touch( actor Other )
	{
		local actor a;

		if (convdone) {
			foreach allactors(class'actor',a,'rabbitpick') {
				a.Trigger(potentialuser,potentialuser);
			}
			Super.Touch(Other);
		}
	}
}

function Activate()
{
	local NCRabbitTalk RT;
	local NCRabbitTalk Candidates[64];
	local int i;

	if (convdone) {
		foreach allactors(Class'NCRabbitTalk',RT,Pawn(Owner).HeadRegion.Zone.Tag) {
			if (RT.tag == Pawn(Owner).HeadRegion.Zone.Tag) {
				Candidates[i] = RT;
				i++;
			}
		}
		Candidates[Rand(i+1)].Touch(Owner);
	}
}

defaultproperties
{
     ConvStrings(0)="Kind man, please help me, my master has died!"
     ConvStrings(1)="Who said that?"
     ConvStrings(2)="Here, down here!"
     ConvStrings(3)="A talking animal? What is a GaruNaak rabbit doing here?"
     ConvStrings(4)="My name is Rugaak and my master was killed by the flying demon as he was traveling to the village."
     ConvStrings(5)="Will you take me to Dranoo village?"
     ConvStrings(6)="I would do so, but I have lost my way and do not know how to get there."
     ConvStrings(7)="I know the way and will tell you if you bring me there."
     ConvStrings(8)="Very well then."
     ConvSounds(0)=Sound'NaliChronicles.RabbitConverse.RabbitConverse07'
     ConvSounds(1)=Sound'UnrealShare.Nali.backup2n'
     ConvSounds(2)=Sound'NaliChronicles.RabbitConverse.RabbitConverse01'
     ConvSounds(3)=Sound'NaliChronicles.ShortConverse.Converse05'
     ConvSounds(4)=Sound'NaliChronicles.RabbitConverse.RabbitConverse06'
     ConvSounds(5)=Sound'NaliChronicles.RabbitConverse.RabbitConverse03'
     ConvSounds(6)=Sound'NaliChronicles.ShortConverse.Converse02'
     ConvSounds(7)=Sound'NaliChronicles.RabbitConverse.RabbitConverse05'
     ConvSounds(8)=Sound'UnrealShare.Nali.contct1n'
     ConvSpeakTime(0)=3.000000
     ConvSpeakTime(1)=1.600000
     ConvSpeakTime(2)=2.700000
     ConvSpeakTime(3)=3.400000
     ConvSpeakTime(4)=5.400000
     ConvSpeakTime(5)=3.000000
     ConvSpeakTime(6)=3.200000
     ConvSpeakTime(7)=3.500000
     ConvSpeakTime(8)=2.500000
     PlayerSpeaks(1)=1
     PlayerSpeaks(3)=1
     PlayerSpeaks(6)=1
     PlayerSpeaks(8)=1
     infotex=Texture'NaliChronicles.Icons.RabbitInfo'
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You place the rabbit into your pack"
     ItemName="Rugaak the rabbit"
     PickupViewMesh=LodMesh'UnrealShare.Rabbit'
     PickupSound=Sound'UnrealShare.Rabbit.CallBn'
     Icon=Texture'NaliChronicles.Icons.RabbitIcon'
     Mesh=LodMesh'UnrealShare.Rabbit'
     CollisionRadius=100.000000
     CollisionHeight=100.000000
}
