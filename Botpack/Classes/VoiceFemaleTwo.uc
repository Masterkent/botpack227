//=============================================================================
// VoiceFemaleTwo.
//=============================================================================
class VoiceFemaleTwo extends VoiceFemale;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec OBJ LOAD FILE="Female2Voice.uax"

function SetOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	if ( messageIndex == 3 )
	{
		if ( FRand() < 0.4 )
			messageIndex = 7;
	}
	else if ( messageIndex == 4 )
	{
		if ( FRand() < 0.3 )
			messageIndex = 6;
		else if ( FRand() < 0.5 )
			messageIndex = 13;
	}
	else if ( messageIndex == 10 )
	{
		SetTimer(3 + FRand(), false); // wait for initial request to be spoken
		if ( FRand() < 0.5 )
		{
			DelayedResponse = AckString[2]$CommaText$GetCallSign(recipient);
			Phrase[0] = AckSound[2];
			PhraseTime[0] = AckTime[2];
			if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) )
			{
				Phrase[1] = NameSound[recipient.Team];
				PhraseTime[1] = NameTime[recipient.Team];
			}
			return;
		}
	}
	Super.SetOtherMessage(messageIndex, Recipient, MessageSound, MessageTime);
}

defaultproperties
{
	NameSound(0)=Sound'Female2Voice.F2redleader'
	NameSound(1)=Sound'Female2Voice.F2blueleader'
	NameSound(2)=Sound'Female2Voice.F2greenleader'
	NameSound(3)=Sound'Female2Voice.F2goldleader'
	NameTime(0)=0.890000
	NameTime(1)=0.940000
	NameTime(2)=0.810000
	NameTime(3)=0.930000
	AckSound(0)=Sound'Female2Voice.F2gotit'
	AckSound(1)=Sound'Female2Voice.F2roger'
	AckSound(2)=Sound'Female2Voice.F2onmyway'
	AckString(0)="Got it"
	AckString(1)="Roger that"
	AckString(2)="On my way"
	AckTime(0)=0.520000
	AckTime(1)=0.750000
	AckTime(2)=0.930000
	numAcks=3
	FFireSound(0)=Sound'Female2Voice.F2sameteam'
	FFireSound(1)=Sound'Female2Voice.F2idiot'
	FFireString(0)="Same team!"
	FFireString(1)="I'm on your team!"
	FFireAbbrev(1)="On your team!"
	numFFires=2
	TauntSound(0)=Sound'Female2Voice.F2eatthat'
	TauntSound(1)=Sound'Female2Voice.F2sucker'
	TauntSound(2)=Sound'Female2Voice.F2gotim'
	TauntSound(3)=Sound'Female2Voice.F2hadtohurt'
	TauntSound(4)=Sound'Female2Voice.F2biggergun'
	TauntSound(5)=Sound'Female2Voice.F2boom'
	TauntSound(6)=Sound'Female2Voice.F2burnbaby'
	TauntSound(7)=Sound'Female2Voice.F2diebitch'
	TauntSound(8)=Sound'Female2Voice.F2toeasy'
	TauntSound(9)=Sound'Female2Voice.F2youlikethat'
	TauntSound(10)=Sound'Female2Voice.F2yousuck'
	TauntSound(11)=Sound'Female2Voice.F2loser'
	TauntSound(12)=Sound'Female2Voice.F2ohyeah'
	TauntSound(13)=Sound'Female2Voice.F2safety'
	TauntSound(14)=Sound'Female2Voice.F2yeehaw'
	TauntSound(15)=Sound'Female2Voice.F2sweet'
	TauntSound(16)=Sound'Female2Voice.F2wantsome'
	TauntSound(17)=Sound'Female2Voice.F2sucker'
	TauntSound(18)=Sound'Female2Voice.F2staydown'
	TauntSound(19)=Sound'Female2Voice.F2aim'
	TauntSound(20)=Sound'Female2Voice.F2die'
	TauntSound(21)=Sound'Female2Voice.F2dirtbag'
	TauntSound(22)=Sound'Female2Voice.F2next'
	TauntSound(23)=Sound'Female2Voice.F2seeya'
	TauntSound(24)=Sound'Female2Voice.F2myhouse'
	TauntSound(25)=Sound'Female2Voice.F2target'
	TauntSound(26)=Sound'Female2Voice.F2useless'
	TauntString(0)="Eat that!"
	TauntString(1)="Sucker!"
	TauntString(2)="Got him!"
	TauntString(3)="That had to hurt!"
	TauntString(4)="Try a bigger gun."
	TauntString(5)="Boom!"
	TauntString(6)="Burn, baby!"
	TauntString(7)="Die, bitch."
	TauntString(8)="Too easy!"
	TauntString(9)="You like that?"
	TauntString(10)="You suck!"
	TauntString(11)="Loser!"
	TauntString(12)="Oh yeah!"
	TauntString(13)="Try turning the safety off."
	TauntString(14)="Yeehaw!"
	TauntString(15)="Sweet!"
	TauntString(16)="Anyone else want some?"
	TauntString(17)="Sucker!"
	TauntString(18)="And stay down!"
	TauntString(19)="Learn how to aim!"
	TauntString(20)="Die!"
	TauntString(21)="Dirt bag!"
	TauntString(22)="Next!"
	TauntString(23)="See ya!"
	TauntString(24)="My house!"
	TauntString(25)="Target eliminated."
	TauntString(26)="Useless!"
	TauntAbbrev(13)="Turn the safety off."
	TauntAbbrev(16)="Anyone else?"
	numTaunts=27
	MatureTaunt(7)=1
	OrderSound(0)=Sound'Female2Voice.F2defend'
	OrderSound(1)=Sound'Female2Voice.F2hold'
	OrderSound(2)=Sound'Female2Voice.F2assault'
	OrderSound(3)=Sound'Female2Voice.F2coverme'
	OrderSound(4)=Sound'Female2Voice.F2engage'
	OrderSound(10)=Sound'Female2Voice.F2takeflag'
	OrderSound(11)=Sound'Female2Voice.F2destroy'
	OrderString(0)="Defend the base."
	OrderString(1)="Hold this position."
	OrderString(2)="Assault the base."
	OrderString(3)="Cover me."
	OrderString(4)="Engage according to operational parameters."
	OrderString(10)="Take their flag."
	OrderString(11)="Search and destroy."
	OrderAbbrev(0)="Defend"
	OrderAbbrev(2)="Attack"
	OrderAbbrev(4)="Freelance."
	OtherSound(0)=Sound'Female2Voice.F2baseunc'
	OtherSound(1)=Sound'Female2Voice.F2getflag'
	OtherSound(2)=Sound'Female2Voice.F2gotflag'
	OtherSound(3)=Sound'Female2Voice.F2gotyourb'
	OtherSound(4)=Sound'Female2Voice.F2imhit'
	OtherSound(5)=Sound'Female2Voice.F2mandown'
	OtherSound(6)=Sound'Female2Voice.F2underatt'
	OtherSound(7)=Sound'Female2Voice.F2yougotpoint'
	OtherSound(8)=Sound'Female2Voice.F2gotourflag'
	OtherSound(9)=Sound'Female2Voice.F2inposition'
	OtherSound(10)=Sound'Female2Voice.F2hanginthere'
	OtherSound(11)=Sound'Female2Voice.F2pointsecure'
	OtherSound(12)=Sound'Female2Voice.F2enemyhere'
	OtherSound(13)=Sound'Female2Voice.F2backup'
	OtherSound(14)=Sound'Female2Voice.F2incoming'
	OtherSound(15)=Sound'Female2Voice.F2gotyourb'
	OtherSound(16)=Sound'Female2Voice.F2objectivedest'
	otherstring(0)="Base is uncovered!"
	otherstring(1)="Somebody get our flag back!"
	otherstring(2)="I've got the flag."
	otherstring(3)="I've got your back."
	otherstring(4)="I'm hit! I'm hit!"
	otherstring(5)="Man down!"
	otherstring(6)="I'm under heavy attack!"
	otherstring(7)="You got point."
	otherstring(8)="I've got our flag."
	otherstring(9)="I'm in position."
	otherstring(10)="Hang in there."
	otherstring(11)="Control point is secure."
	otherstring(12)="Enemy flag carrier is here."
	otherstring(13)="I need some backup."
	otherstring(14)="Incoming!"
	otherstring(15)="I've got your back."
	otherstring(16)="Objective is destroyed."
	OtherAbbrev(1)="Get our flag!"
	OtherAbbrev(2)="Got the flag."
	OtherAbbrev(3)="Got your back."
	OtherAbbrev(6)="Under attack!"
	OtherAbbrev(8)="Got our flag."
	OtherAbbrev(9)="In position."
	OtherAbbrev(11)="Point is secure."
	OtherAbbrev(12)="Enemy carrier here."
	OtherAbbrev(15)="Got your back."
}
