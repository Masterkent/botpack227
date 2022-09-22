//=============================================================================
// VoiceBoss.
//=============================================================================
class VoiceBoss extends ChallengeVoicePack;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack
#exec OBJ LOAD FILE="BossVoice.uax"

function SetOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound, out Float MessageTime)
{
	if ( messageIndex == 3 )
	{
		if ( FRand() < 0.3 )
			messageIndex = 7;
		else if ( FRand() < 0.5 )
			messageIndex = 15;
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
			DelayedResponse = AckString[2]$CommaText$GetCallSign(Recipient);
			Phrase[0] = AckSound[2];
			PhraseTime[0] = AckTime[2];
			if (Level.NetMode == NM_Standalone && Recipient.TeamID == 0 && Recipient.Team < 4)
			{
				Phrase[1] = NameSound[Recipient.Team];
				PhraseTime[1] = NameTime[Recipient.Team];
			}
			return;
		}
	}
	Super.SetOtherMessage(messageIndex, Recipient, MessageSound, MessageTime);
}

defaultproperties
{
	NameSound(0)=Sound'BossVoice.Bredleader'
	NameSound(1)=Sound'BossVoice.Bblueleader'
	NameSound(2)=Sound'BossVoice.Bgreenleader'
	NameSound(3)=Sound'BossVoice.Bgoldleader'
	NameTime(0)=0.960000
	NameTime(1)=1.100000
	NameTime(2)=1.020000
	NameTime(3)=0.990000
	AckSound(0)=Sound'BossVoice.Bgotit'
	AckSound(1)=Sound'BossVoice.Broger'
	AckSound(2)=Sound'BossVoice.Bonmyway'
	AckString(0)="Got it"
	AckString(1)="Roger"
	AckString(2)="On my way"
	AckTime(0)=0.780000
	AckTime(1)=0.810000
	AckTime(2)=0.980000
	numAcks=3
	FFireSound(0)=Sound'BossVoice.Bonyourteam'
	FFireSound(1)=Sound'BossVoice.Bsameteam'
	FFireString(0)="I'm on your team!"
	FFireString(1)="Same team!"
	FFireAbbrev(0)="On your team!"
	numFFires=2
	TauntSound(0)=Sound'BossVoice.Bbowdown'
	TauntSound(1)=Sound'BossVoice.Bdiehuman'
	TauntSound(2)=Sound'BossVoice.Beliminated'
	TauntSound(3)=Sound'BossVoice.Byoudie'
	TauntSound(4)=Sound'BossVoice.Buseless'
	TauntSound(5)=Sound'BossVoice.Bfearme'
	TauntSound(6)=Sound'BossVoice.Binferior'
	TauntSound(7)=Sound'BossVoice.Bobsolete'
	TauntSound(8)=Sound'BossVoice.Bomega'
	TauntSound(9)=Sound'BossVoice.Brunhuman'
	TauntSound(10)=Sound'BossVoice.Bstepaside'
	TauntSound(11)=Sound'BossVoice.Bsuperior'
	TauntSound(12)=Sound'BossVoice.Bperfection'
	TauntSound(13)=Sound'BossVoice.Bboom'
	TauntSound(14)=Sound'BossVoice.Bmyhouse'
	TauntSound(15)=Sound'BossVoice.Bnext'
	TauntSound(16)=Sound'BossVoice.Bburnbaby'
	TauntSound(17)=Sound'BossVoice.Bwantsome'
	TauntSound(18)=Sound'BossVoice.Bhadtohurt'
	TauntSound(19)=Sound'BossVoice.Bimonfire'
	TauntString(0)="Bow down!"
	TauntString(1)="Die, human."
	TauntString(2)="Target lifeform eliminated."
	TauntString(3)="You die too easily."
	TauntString(4)="Useless."
	TauntString(5)="Fear me."
	TauntString(6)="You are inferior."
	TauntString(7)="You are obsolete."
	TauntString(8)="I am the alpha and the omega."
	TauntString(9)="Run, human."
	TauntString(10)="Step aside."
	TauntString(11)="I am superior."
	TauntString(12)="Witness my perfection."
	TauntString(13)="Boom!"
	TauntString(14)="My house."
	TauntString(15)="Next."
	TauntString(16)="Burn, baby"
	TauntString(17)="Anyone else want some?"
	TauntString(18)="That had to hurt."
	TauntString(19)="I'm on fire"
	TauntAbbrev(2)="Target lifeform."
	TauntAbbrev(8)="Alpha/Omega"
	numTaunts=20
	OrderSound(0)=Sound'BossVoice.Bdefendthebase'
	OrderSound(1)=Sound'BossVoice.Bholdposit'
	OrderSound(2)=Sound'BossVoice.Bassaultbase'
	OrderSound(3)=Sound'BossVoice.Bcoverme'
	OrderSound(4)=Sound'BossVoice.Bengage'
	OrderSound(10)=Sound'BossVoice.Btaketheirflag'
	OrderSound(11)=Sound'BossVoice.Bsandd'
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
	OtherSound(0)=Sound'BossVoice.Bbaseunc'
	OtherSound(1)=Sound'BossVoice.Bgetourflag'
	OtherSound(2)=Sound'BossVoice.Bgottheflag'
	OtherSound(3)=Sound'BossVoice.Bgotyourback'
	OtherSound(4)=Sound'BossVoice.BImhit'
	OtherSound(5)=Sound'BossVoice.Bmandown'
	OtherSound(6)=Sound'BossVoice.Bunderattack'
	OtherSound(7)=Sound'BossVoice.Byougotpoint'
	OtherSound(8)=Sound'BossVoice.Bgotourflag'
	OtherSound(9)=Sound'BossVoice.Binposition'
	OtherSound(10)=Sound'BossVoice.Bhanginthere'
	OtherSound(11)=Sound'BossVoice.Bconpointsecure'
	OtherSound(12)=Sound'BossVoice.Bflagcarrierher'
	OtherSound(13)=Sound'BossVoice.Bbackup'
	OtherSound(14)=Sound'BossVoice.Bincoming'
	OtherSound(15)=Sound'BossVoice.Bgotyourback'
	OtherSound(16)=Sound'BossVoice.Bobjectivedest'
	otherstring(0)="Base is uncovered!"
	otherstring(1)="Get our flag back!"
	otherstring(2)="I've got the flag."
	otherstring(3)="I've got your back."
	otherstring(4)="I'm hit!"
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
	otherstring(16)="Objective destroyed."
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
