class UTC_PlayerPawn expands PlayerPawn;

var() string SelectionMesh;
var() string SpecialMesh;
var() string VoiceType; //for speech

var float LandBob, AppliedBob;
var float LastPlaySound;
var	bool bUpdating;
var bool bCheatsEnabled;

var SavedMove PendingMove;

// NOTE: Ported code should use bPressedJump instead of bJumpStatus (according to the meaning of ServerMove's NewbPressedJump)

replication
{
	reliable if (Role == ROLE_Authority)
		ClientReliablePlaySound, ClientReplicateSkins, ClientChangeTeam;
	unreliable if (Role == ROLE_Authority && !bDemoRecording)
		UTF_ClientPlaySound;
	reliable if (Role == ROLE_Authority && !bDemoRecording)
		ReceiveLocalizedMessage;
	reliable if (Role < ROLE_Authority)
		B227_GetWeapon;
}

simulated function UTF_ClientPlaySound(
	sound ASound,
	optional bool bInterrupt,
	optional bool bVolumeControl)
{
	local Actor SoundPlayer;

	LastPlaySound = Level.TimeSeconds;	// so voice messages won't overlap
	if (ViewTarget != none)
		SoundPlayer = ViewTarget;
	else
		SoundPlayer = self;

	SoundPlayer.PlaySound(ASound, SLOT_None, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Interface, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Misc, 16.0, bInterrupt);
	SoundPlayer.PlaySound(ASound, SLOT_Talk, 16.0, bInterrupt);
}

static function UTSF_ClientPlaySound(
	PlayerPawn this,
	sound ASound,
	optional bool bInterrupt,
	optional bool bVolumeControl)
{
	local B227_PlayerPawnRepInfo APPRI;

	if (UTC_PlayerPawn(this) != none)
		UTC_PlayerPawn(this).UTF_ClientPlaySound(ASound, bInterrupt, bVolumeControl);
	else if (class'B227_PlayerPawnRepInfo'.static.GetInstance(this, APPRI))
		APPRI.ClientPlaySound(ASound, bInterrupt);
}

simulated function ClientReliablePlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl)
{
	UTF_ClientPlaySound(ASound, bInterrupt, bVolumeControl);
}

static function UTSF_ClientReliablePlaySound(
	PlayerPawn this,
	sound ASound,
	optional bool bInterrupt,
	optional bool bVolumeControl)
{
	local B227_PlayerPawnRepInfo APPRI;

	if (UTC_PlayerPawn(this) != none)
		UTC_PlayerPawn(this).ClientReliablePlaySound(ASound, bInterrupt, bVolumeControl);
	else if (class'B227_PlayerPawnRepInfo'.static.GetInstance(this, APPRI))
		APPRI.ClientReliablePlaySound(ASound, bInterrupt);
}

function ClientReplicateSkins(texture Skin1, optional texture Skin2, optional texture Skin3, optional texture Skin4);

function ClientChangeTeam(int N)
{
	local Pawn P;

	if (PlayerReplicationInfo != none)
		PlayerReplicationInfo.Team = N;

	// if listen server, this may be called for non-local players that are logging in
	// if so, don't update URL
	if (Level.NetMode == NM_ListenServer && Player == none)
	{
		// check if any other players exist
		for (P = Level.PawnList; P != none; P = P.NextPawn )
			if (PlayerPawn(P) != none && ViewPort(PlayerPawn(P).Player) != none)
				return;
	}

	UpdateURL("Team", string(N), true);	
}

function PlayHit(float Damage, vector HitLocation, name damageType, float MomentumZ)
{
	UTF_PlayHit(Damage, HitLocation, damageType, class'UTC_Pawn'.static.B227_DamageMomentum(self, MomentumZ));
}

function UTF_PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum);

function PlayDeathHit(float Damage, vector HitLocation, name damageType)
{
	UTF_PlayDeathHit(Damage, HitLocation, damageType, class'UTC_Pawn'.static.B227_DamageMomentum(self, 0));
}

function UTF_PlayDeathHit(float Damage, vector HitLocation, name damageType, vector Momentum);

function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
	local float OldBobTime;

	OldBobTime = BobTime;
	if ( Speed2D < 10 )
		BobTime += 0.2 * DeltaTime;
	else
		BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
	WalkBob = Y * 0.65 * Bob * Speed2D * sin(6 * BobTime);
	AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
	if ( LandBob > 0.01 )
	{
		AppliedBob += FMin(1, 16 * deltatime) * LandBob;
		LandBob *= (1 - 8*Deltatime);
	}
	if ( Speed2D < 10 )
		WalkBob.Z = AppliedBob + Bob * 30 * sin(12 * BobTime);
	else
		WalkBob.Z = AppliedBob + Bob * Speed2D * sin(12 * BobTime);
}

event UTF_TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	class'GameInfo'.static.StripColorCodes(S);
	if (Player.Console != none)
		Player.Console.Message(PRI, S, Type);
	if (bBeep && bMessageBeep)
		PlayBeepSound();
	if (myHUD != none)
		myHUD.Message(PRI, S, Type);
}

function ReceiveLocalizedMessage(
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

function SendGlobalMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'GLOBAL');
}

function SendTeamMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'TEAM');
}

static function UTSF_ClientWeaponEvent(PlayerPawn this, name EventType)
{
	if (UTC_Weapon(this.Weapon) != none)
		UTC_Weapon(this.Weapon).ClientWeaponEvent(EventType);
}

function Landed(vector HitNormal)
{
	//Note - physics changes type to PHYS_Walking by default for landed pawns
	if (bUpdating)
		return;
	PlayLanded(Velocity.Z);
	LandBob = FMin(50, 0.055 * Velocity.Z); 
	TakeFallingDamage();
	bJustLanded = true;
}

function ClientUpdatePosition()
{
	bUpdating = true;
	super.ClientUpdatePosition();
	bUpdating = false;
}

function TakeFallingDamage()
{
	class'UTC_Pawn'.static.UTSF_TakeFallingDamage(self);
}

function ShakeView(float shaketime, float RollMag, float vertmag)
{
	local vector shake;

	shake.X = RollMag;
	shake.Y = 100 * shaketime;
	shake.Z = 100 * vertmag;
	ClientShake(shake);
}

function int CompressAccel(int C)
{
	if ( C >= 0 )
		C = Min(C, 127);
	else
		C = Min(abs(C), 127) + 128;
	return C;
}

exec function GetWeapon(class<Weapon> NewWeaponClass)
{
	if (Level.NetMode == NM_Client)
		B227_GetWeapon(NewWeaponClass);
	else
		super.GetWeapon(NewWeaponClass);
}

exec function Speech(int Type, int Index, int Callsign)
{
	local VoicePack V;

	V = Spawn(PlayerReplicationInfo.VoiceType, self);
	if (V != none)
	{
		V.PlayerSpeech(Type, Index, Callsign);
		V.Destroy();
	}
}

exec function Mutate(string MutateString)
{
	if (Level.NetMode == NM_Client)
		return;
	class'UTC_Mutator'.static.UTSF_Mutate(Level.Game.BaseMutator, MutateString, self);
}

state FeigningDeath
{
	ignores SeePlayer, HearNoise, Bump, Fire, AltFire, StartClimbing;

	function Landed(vector HitNormal)
	{
		if (Role == ROLE_Authority)
			PlaySound(Land, SLOT_Interact, 0.3, false, 800, 1.0);
		if (bUpdating)
			return;
		TakeFallingDamage();
		bJustLanded = true;
	}
}

state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

	function Landed(vector HitNormal)
	{
		if (!bUpdating)
		{
			//log(class$" Landed while swimming");
			PlayLanded(Velocity.Z);
			TakeFallingDamage();
			bJustLanded = true;
		}
		if (Region.Zone.bWaterZone)
			SetPhysics(PHYS_Swimming);
		else
		{
			GotoState('PlayerWalking');
			AnimEnd();
		}
	}
}

state PlayerWaiting
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, ZoneChange, FootZoneChange;

	exec function Jump( optional float F )
	{
	}

	exec function Suicide()
	{
	}

	function ChangeTeam( int N )
	{
		Level.Game.ChangeTeam(self, N);
	}

	exec function Fire(optional float F)
	{
		bReadyToPlay = true;
	}
	
	exec function AltFire(optional float F)
	{
		bReadyToPlay = true;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	function PlayWaiting() {}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function EndState()
	{
		SetMesh();
		if (PlayerReplicationInfo != none)
		{
			PlayerReplicationInfo.bIsSpectator = false;
			if (B227_PRI() != none)
				B227_PRI().bWaitingPlayer = false;
		}
		SetCollision(true,true,true);
	}

	function BeginState()
	{
		Mesh = None;
		if ( PlayerReplicationInfo != None )
		{
			PlayerReplicationInfo.bIsSpectator = true;
			if (B227_PRI() != none)
				B227_PRI().bWaitingPlayer = true;
		}
		SetCollision(false,false,false);
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
	}
}

function B227_PlaySound(
	sound Sound,
	optional ESoundSlot Slot,
	optional float Volume,
	optional bool bNoOverride,
	optional float Radius,
	optional float Pitch)
{
	class'UTC_Actor'.static.B227_PlaySound(self, Sound, Slot, Volume, bNoOverride, Radius, Pitch);
}

simulated function SetMesh()
{
	Mesh = default.Mesh;
}

// Auxiliary

simulated function UTC_PlayerReplicationInfo B227_PRI()
{
	return UTC_PlayerReplicationInfo(PlayerReplicationInfo);
}

static function float B227_LastPlaySound(PlayerPawn this)
{
	local B227_PlayerPawnRepInfo APPRI;

	if (UTC_PlayerPawn(this) != none)
		return UTC_PlayerPawn(this).LastPlaySound;
	if (class'B227_PlayerPawnRepInfo'.static.GetInstance(this, APPRI))
		return APPRI.LastPlaySound;
	return 0;
}

static function class<VoicePack> B227_GetVoiceType(PlayerPawn this)
{
	local class<VoicePack> Result;

	if (UTC_PlayerPawn(this) != none)
	{
		Result = class<VoicePack>(DynamicLoadObject(UTC_PlayerPawn(this).VoiceType, class'Class'));
		if (Result != none)
			return Result;
	}
	return this.VoiceType;
}

static function B227_ClientPlayVoice(
	PlayerPawn this,
	sound ASound,
	optional bool bInterrupt,
	optional bool bVolumeControl)
{
	UTSF_ClientPlaySound(this, ASound, bInterrupt, bVolumeControl);
}

function B227_GetWeapon(class<Weapon> NewWeaponClass)
{
	if (Level.NetMode != NM_Client)
		GetWeapon(NewWeaponClass);
}

defaultproperties
{
	bCheatsEnabled=True
	PlayerReplicationInfoClass=Class'Botpack227_Base.UTC_PlayerReplicationInfo'
}
