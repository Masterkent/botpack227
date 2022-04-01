// A nali that intiates a conversation
// Code by Sergey 'Eater' Levin, 2001

class NCTalkerNali extends Nali;

var(Conversation) bool bFearlessWhenTalking;
var(Conversation) bool bLogDiaryEntry;
var(Conversation) bool bTalkAfterTrigger;
var(Conversation) string NewDiaryEntry;
var(Conversation) float ConvSpeakTime[15]; // time each event lasts
var(Conversation) name ConvSpeakers[15]; // tags of speakers for each event
var(Conversation) name ConvEvents[15]; // events triggered by each event
var(Conversation) string ConvStrings[15]; // strings shown for each events
var(Conversation) sound ConvSounds[15]; // sounds played by speaker
var(Conversation) class<inventory> ConvGifts[15]; // items to give to player for each event
var(Conversation) bool bTalkOnlyWhenTouched; // only start conversation when touched by player
var(Conversation) float TalkRadius; // radius within which player must be to start conversation (bTalkOnlyWhenTouched must be false)
var(Conversation) float MaxTalkRadius; // radius at which to stop talking
var int leftoffpoint; // point at which player ended conversation (continued from this point later)
var playerpawn talkingto;
var float LastEventTime;
var playerpawn possiblepawn[20];
var float ScanTime;
var bool bPStart;

var int B227_LastConvEventIndex;

function ScanForPlayers() {
	local playerpawn pp;
	local int i;

	foreach allactors(Class'PlayerPawn', pp)
		if (pp.PlayerReplicationInfo != none && !pp.PlayerReplicationInfo.bIsSpectator) {
			possiblepawn[i] = pp;
			if (++i == ArrayCount(possiblepawn))
				break;
		}
}

function Tick(float deltatime) {
	local int i;

	Super.Tick(deltatime);
	if (leftoffpoint != 255) {
		ScanTime += DeltaTime;
		if (ScanTime >= 4.0) {
			ScanTime = 0;
			ScanForPlayers();
		}
		if (!bTalkOnlyWhenTouched && !bTalkAfterTrigger) {
			while (i < ArrayCount(possiblepawn) && possiblepawn[i] != none) {
				if ((VSize(location-possiblepawn[i].location) <= TalkRadius) && (FastTrace(location,possiblepawn[i].location))) {
					StartConversation(possiblepawn[i]);
					break;
				}
				i++;
			}
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	super.Trigger(other,eventinstigator);
	if (bTalkAfterTrigger)
		bTalkAfterTrigger = false;
}

State Patroling
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		super.Trigger(other,eventinstigator);
		if (bTalkAfterTrigger && bPStart)
			bTalkAfterTrigger = false;
		else if (!bPStart)
			bPStart = true;
	}
}

function pawn GetTagged(name inname) {
	local pawn p;

	if ((inname == 'Player') && (talkingto != none))
		return talkingto;

	if (tag == inname)
		return self;

	foreach allactors(Class'pawn',p) {
		if (p.tag == inname)
			return p;
	}

	return self;
}

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	bQuiet = false;
	Enemy = None;
	if ( OldEnemy != None )
	{
		Enemy = OldEnemy;
		OldEnemy = None;
		GotoState('Attacking');
	}
	else if (Orders == 'Patroling')
		GotoState('Patroling');
	else if (Orders == 'Guarding')
		GotoState('Guarding');
	else if ( Orders == 'Ambushing' )
		GotoState('Ambushing','FindAmbushSpot');
	else if ( (LikelyState != '') && (FRand() < 0.35) )
		GotoState(LikelyState, LikelyLabel);
	else
		GotoState('Waiting');
}

state Conversing // new talking state
{
	ignores EnemyNotVisible;

	function SpeakPrayer() { }

	function PlayFearSound() { }

	function PlayWaiting()
	{
		local float decision;
		local float animspeed;

		if (Region.Zone.bWaterZone)
		{
			PlaySwimming();
			return;
		}

		animspeed = 0.4 + 0.6 * FRand();
		decision = FRand();
		if ( AnimSequence == 'Breath' )
		{
			return;
		}
		else if ( AnimSequence == 'Pray' )
		{
			PlayAnim('Breath', animspeed, 0.3);
			return;
		}
 		LoopAnim('Breath', animspeed);
	}

	function PlayThreatening()
	{
		if (Region.Zone.bWaterZone)
		{
			PlaySwimming();
			return;
		}
		Acceleration = vect(0,0,0);
		if (AnimSequence == 'Backup')
		{
			LoopAnim('Cringe', 0.4 + 0.7 * FRand(), 0.4);
		}
		else if (AnimSequence == 'Cringe')
		{
			LoopAnim('Cringe', 0.4 + 0.7 * FRand());
		}
		else if (AnimSequence == 'Bowing')
		{
			LoopAnim('Bowing', 0.4 + 0.7 * FRand());
		}
		else if (FRand() < 0.4)
			LoopAnim('Bowing', 0.4 + 0.7 * FRand(), 0.5);
		else
			PlayRetreating();
	}

	function PlayRetreating()
	{
		if (Region.Zone.bWaterZone)
		{
			PlaySwimming();
			return;
		}
		bAvoidLedges = true;
		DesiredRotation = Rotator(Enemy.Location - Location);
		DesiredSpeed = WalkingSpeed;
		Acceleration = AccelRate * Normal(Location - Enemy.Location);
		LoopAnim('Backup');
	}

	function damageAttitudeTo(pawn Other)
	{
		local eAttitude OldAttitude;

		if ((Other == Self) || (Other == None) || (FlockPawn(Other) != None) || (NaliWarrior(Other) != None))
			return;
		if (!bFearlessWhenTalking) {
			if( Other.bIsPlayer ) {//change attitude to player
				AttitudeToPlayer = ATTITUDE_Fear;
				WhatToDoNext('','');
			}
			else {
				if ( ScriptedPawn(Other) == None )
					Hated = Other;
			}
			SetEnemy(Other);
		}
	}

	function eAttitude AttitudeToCreature(Pawn Other)
	{
		if (!bFearlessWhenTalking)
			return Global.AttitudeToCreature(Other);
		else
			return ATTITUDE_Ignore;
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, name damageType)
	{
		if (!bFearlessWhenTalking) { // don't take damage if talking and bFearlessWhenTalking is true
			Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
			if ( health <= 0 )
				return;
			if ( Enemy != None )
				LastSeenPos = Enemy.Location;
			if (NextState == 'TakeHit')
			{
				NextState = 'Attacking';
				NextLabel = 'Begin';
				GotoState('TakeHit');
			}
			else if ( Enemy != None )
				GotoState('Attacking');
		}
	}

	function Bump(actor Other)
	{
		//log(Other.class$" bumped "$class);
		if (Pawn(Other) != None)
		{
			if (Enemy == Other)
				bReadyToAttack = True; //can melee right away
			SetEnemy(Pawn(Other));
		}
		if ( TimerRate <= 0 )
			setTimer(1.5, false);
		Disable('Bump');
	}

	function Timer()
	{
		Enable('Bump');
	}

	function EnemyAcquired()
	{
		if (!bFearlessWhenTalking)
			GotoState('Acquisition', 'PlayOut');
	}

	function AnimEnd()
	{
		PlayWaiting();
		bStasis = true;
	}

	function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		if (talkingto != none)
			Focus = talkingto.Location;
		Enemy = None;
		bStasis = false;
		Acceleration = vect(0,0,0);
		SetAlertness(0.0);
		if (LastEventTime == 0)
			LastEventTime = Level.TimeSeconds;
	}

	function Tick(float DeltaTime) {
		local int timepoint;
		local inventory inv;
		local actor A;
		local NCDiary diary;
		local float realspeaktime;

		if (talkingto == none || talkingto.bDeleteMe || talkingto.Health <= 0) {
			WhatToDoNext('', '');
			return;
		}

		DesiredRotation = rotator(location-talkingto.location);
		DesiredRotation.yaw += 32768;
		DesiredRotation.pitch = 0;
		DesiredRotation.roll = 0;
		SetRotation(DesiredRotation);

		timepoint = leftoffpoint - 1;
		if (timepoint < 0)
			timepoint = 0;

		if (leftoffpoint <= 0) {
			realspeaktime = 0;
		}
		else if (Level.NetMode == NM_Standalone &&
			NaliMage(talkingto) != none &&
			NCHUD(NaliMage(talkingto).myHUD) != none
		) {
			realspeaktime = NCHUD(NaliMage(talkingto).myHUD).modifySpeakTime(convspeaktime[timepoint]);
		}
		else
			realspeaktime = class'NCHUD'.static.B227_modifySpeakTime(convspeaktime[timepoint]);

		if ( (Level.TimeSeconds-LastEventTime) >= realspeaktime) {
			GoToState('Conversing','Begin');
			LastEventTime = Level.TimeSeconds;
			if (leftoffpoint < ArrayCount(convspeakers) && convspeakers[leftoffpoint] != '') {
				if (NaliMage(talkingto) != none) {
					NaliMage(talkingto).ConvString = convstrings[leftoffpoint];
					NaliMage(talkingto).CurrentTalker = gettagged(convspeakers[leftoffpoint]);
					NaliMage(talkingto).TalkBegin = Level.TimeSeconds;
					if (Level.NetMode == NM_Standalone && NCHUD(NaliMage(talkingto).myHUD) != none)
						NaliMage(talkingto).TalkLast = NCHUD(NaliMage(talkingto).myHUD).modifySpeakTime(convspeaktime[leftoffpoint]);
					else
						NaliMage(talkingto).TalkLast = class'NCHUD'.static.B227_modifySpeakTime(convspeaktime[leftoffpoint]);
				}
				else
					B227_SendConversationMessage();
				gettagged(convspeakers[leftoffpoint]).PlaySound(convsounds[leftoffpoint],Slot_Talk);
				if (convgifts[leftoffpoint] != none) {
					inv = Spawn(convgifts[leftoffpoint],,,location);
					if (inv != none) {
						inv.RespawnTime = 0.0;
						inv.Touch(talkingto);
					}
				}
				if (leftoffpoint >= B227_LastConvEventIndex && convevents[leftoffpoint] != '') {
					foreach AllActors( class 'Actor', A, convevents[leftoffpoint] )
						A.Trigger( talkingto, talkingto.Instigator );
				}
				leftoffpoint++;
				B227_LastConvEventIndex = leftoffpoint;
				if ((convspeakers[leftoffpoint] == 'None') && (bLogDiaryEntry)) {
					diary = NCDiary(talkingto.FindInventoryType(Class'NCDiary'));
					if (diary != none) {
						diary.AddMessage(NewDiaryEntry);
						talkingto.ClientMessage("New diary entry added! Open diary to read",'Pickup');
						if (!diary.isInState('Activated') && talkingto.bFire == 0 && talkingto.bAltFire == 0) {
							diary.bTempAct = true;
							diary.OpenUp();
						}
					}
				}
			}
			else {
				if (NaliMage(talkingto) != none) {
					NaliMage(talkingto).ConvString = "";
					NaliMage(talkingto).CurrentTalker = none;
				}
				leftoffpoint = 255;
				B227_LastConvEventIndex = leftoffpoint;
				WhatToDoNext('','');
			}
		}
		if ((VSize(location - talkingto.location) > MaxTalkRadius) || (!FastTrace(talkingto.location,location))) {
			WhatToDoNext('','');
		}
	}

	function Killed(pawn Killer, pawn Other, name damageType)
	{
		if (!bFearlessWhenTalking)
			Global.Killed(Killer, Other, damageType);
	}

	function eAttitude AttitudeWithFear()
	{
		if (!bFearlessWhenTalking)
			return ATTITUDE_Fear;
		else
			return ATTITUDE_Ignore;
	}

TurnFromWall:
	if ( NearWall(2 * CollisionRadius + 50) )
	{
		PlayTurning();
		TurnTo(Focus);
		//TurnToward(talkingto);
	}
Begin:
	//TurnToward(talkingto);
	TweenToWaiting(0.4);
	DesiredRotation = rotator(location-talkingto.location);
	DesiredRotation.yaw += 32768;
	DesiredRotation.pitch = 0;
	DesiredRotation.roll = 0;
	SetRotation(DesiredRotation);
	bReadyToAttack = false;
	if (Physics != PHYS_Falling)
		SetPhysics(PHYS_None);
KeepWaiting:
	NextAnim = '';
}

function damageAttitudeTo(pawn Other)
{
	if (NaliWarrior(Other) != None)
		return;
	super.damageAttitudeTo(Other);
}

function Bump(actor Other) {
	Super.Bump(other);
	if ((PlayerPawn(Other) != none) && (leftoffpoint != 255) && !bTalkAfterTrigger)
		StartConversation(PlayerPawn(Other));
}

state TriggerAlarm
{
	ignores HearNoise, SeePlayer;

	function Bump(actor Other)
	{
		local vector VelDir, OtherDir;
		local float speed;

		if ( (Pawn(Other) != None) && Pawn(Other).bIsPlayer
			&& (AttitudeToPlayer == ATTITUDE_Friendly) )
			return;

		Super.Bump(Other);
		if ((PlayerPawn(Other) != none) && (leftoffpoint != 255) && !bTalkAfterTrigger)
			StartConversation(PlayerPawn(Other));
	}
}

state Retreating
{
	ignores HearNoise, Bump, AnimEnd;

	function ReachedHome()
	{
		if (Homebase(home) != None)
		{
			MoveTarget = None;
			health = Min(default.health, health+10);
			MakeNoise(1.0);
		}
		else
			ChangeDestination();
	}
}

state AlarmPaused
{
	ignores HearNoise, Bump;

	function Bump(actor Other)
	{
		Super.Bump(Other);
		if ((PlayerPawn(Other) != none) && (leftoffpoint != 255) && !bTalkAfterTrigger)
			StartConversation(PlayerPawn(Other));
	}
}

state Guarding
{
	function Bump(actor Other)
	{
		Super.Bump(Other);
		if ((PlayerPawn(Other) != none) && (leftoffpoint != 255) && !bTalkAfterTrigger)
			StartConversation(PlayerPawn(Other));
	}
}

state Waiting
{
	function Bump(actor Other)
	{
		Super.Bump(Other);
		if ((PlayerPawn(Other) != none) && (leftoffpoint != 255) && !bTalkAfterTrigger)
			StartConversation(PlayerPawn(Other));
	}
}

state FadeOut
{
	ignores HitWall, EnemyNotVisible, HearNoise, SeePlayer;

	function Tick(float DeltaTime)
	{
	}

	function BeginState()
	{
		bFading = false;
		Disable('Tick');
		WhatToDoNext('','');
	}
}

state Roaming
{
	ignores EnemyNotVisible;

	function PickDestination()
	{
		Super.PickDestination();
		bHasWandered = true;
	}

	function Bump(actor Other)
	{
		Super.Bump(Other);
		if ((PlayerPawn(Other) != none) && (leftoffpoint != 255) && !bTalkAfterTrigger)
			StartConversation(PlayerPawn(Other));
	}
}

state Wandering
{
	ignores EnemyNotVisible;

	function PickDestination()
	{
		Super.PickDestination();
		bHasWandered = true;
	}

	function Bump(actor Other)
	{
		Super.Bump(Other);
		if ((PlayerPawn(Other) != none) && (leftoffpoint != 255) && !bTalkAfterTrigger)
			StartConversation(PlayerPawn(Other));
	}
}

function StartConversation(PlayerPawn player) {
	if (AttitudeToPlayer != ATTITUDE_Fear) {
		talkingto = player;
		GoToState('Conversing');
	}
}

event Destroyed()
{
	if (Level.NetMode != NM_Standalone)
		B227_CauseRemainingConvEvents();
	super.Destroyed();
}

function B227_CauseRemainingConvEvents()
{
	local Actor A;

	while (B227_LastConvEventIndex < ArrayCount(convspeakers) && convspeakers[B227_LastConvEventIndex] != '')
	{
		if (convevents[B227_LastConvEventIndex] != '')
		{
			foreach AllActors(class'Actor', A, convevents[B227_LastConvEventIndex])
				A.Trigger(self, self);
		}
		++B227_LastConvEventIndex;
	}
	B227_LastConvEventIndex = 255;
}

function B227_SkipRemainingConversations()
{
	B227_CauseRemainingConvEvents();
	leftoffpoint = 255;
}

function B227_SendConversationMessage()
{
	local Pawn Speaker;
	local string SpeakerName;

	Speaker = GetTagged(convspeakers[leftoffpoint]);
	if (Speaker.PlayerReplicationInfo != none)
		SpeakerName = Speaker.PlayerReplicationInfo.PlayerName;
	else
		SpeakerName = Speaker.MenuName;

	talkingto.ClientMessage(SpeakerName $ ":" @ convstrings[leftoffpoint]);
}

defaultproperties
{
}
