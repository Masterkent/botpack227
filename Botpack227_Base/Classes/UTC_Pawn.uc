class UTC_Pawn expands Pawn
	abstract;

var() string SelectionMesh;
var() string SpecialMesh;
var() string VoiceType; //for speech

var bool bAdvancedTactics;	// used during movement between pathnodes


function PlayHit(float Damage, vector HitLocation, name damageType, float MomentumZ)
{
	UTF_PlayHit(Damage, HitLocation, damageType, B227_DamageMomentum(self, MomentumZ));
}

function UTF_PlayHit(float Damage, vector HitLocation, name damageType, vector Momentum);

function PlayDeathHit(float Damage, vector HitLocation, name damageType)
{
	UTF_PlayDeathHit(Damage, HitLocation, damageType, B227_DamageMomentum(self, 0));
}

function UTF_PlayDeathHit(float Damage, vector HitLocation, name damageType, vector Momentum);

static function UTSF_TeamMessage(Pawn this, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	if (UTC_PlayerPawn(this) != none)
		UTC_PlayerPawn(this).UTF_TeamMessage(PRI, S, Type, bBeep);
	else
		this.TeamMessage(PRI, S, Type);
}

static function UTSF_ReceiveLocalizedMessage(
	Pawn this,
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	if (UTC_PlayerPawn(this) != none)
		UTC_PlayerPawn(this).ReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	else if (PlayerPawn(this) != none)
		this.ClientMessage(
			Message.static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject),
			Message.default.B227_MessageName,
			Message.default.bBeep);
}

static function B227_StaticReceiveLocalizedMessage(
	Pawn this,
	class<LocalMessage> Message,
	optional int Switch,
	optional string RelatedPawnInfo_1,
	optional string RelatedPawnInfo_2,
	optional class<Object> RelatedClass,
	optional string RelatedInfo)
{
	if (UTC_PlayerPawn(this) != none)
		UTC_PlayerPawn(this).B227_ReceiveLocalizedMessage(
			Message,
			Switch,
			RelatedPawnInfo_1,
			RelatedPawnInfo_2,
			RelatedClass,
			RelatedInfo);
	else if (PlayerPawn(this) != none)
	{
		Message.default.B227_bHasRelatedContext = true;
		Message.default.B227_RelatedPawnInfo_1 = RelatedPawnInfo_1;
		Message.default.B227_RelatedPawnInfo_2 = RelatedPawnInfo_2;
		Message.default.B227_RelatedClass = RelatedClass;
		Message.default.B227_RelatedInfo = RelatedInfo;

		this.ClientMessage(
			Message.static.B227_GetString(Switch),
			Message.default.B227_MessageName,
			Message.default.bBeep);

		Message.default.B227_bHasRelatedContext = false;
		Message.default.B227_RelatedPawnInfo_1 = "";
		Message.default.B227_RelatedPawnInfo_2 = "";
		Message.default.B227_RelatedClass = none;
		Message.default.B227_RelatedInfo = "";
	}
}

function SendGlobalMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'GLOBAL');
}

static function UTSF_SendGlobalMessage(Pawn this, PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	if (UTC_Pawn(this) != none)
		UTC_Pawn(this).SendGlobalMessage(Recipient, MessageType, MessageID, Wait);
	else if (UTC_PlayerPawn(this) != none)
		UTC_PlayerPawn(this).SendGlobalMessage(Recipient, MessageType, MessageID, Wait);
	else
		this.SendVoiceMessage(this.PlayerReplicationInfo, Recipient, MessageType, MessageID, 'GLOBAL');
}

function SendTeamMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, 'TEAM');
}

static function UTSF_SendTeamMessage(Pawn this, PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait)
{
	if (UTC_Pawn(this) != none)
		UTC_Pawn(this).SendTeamMessage(Recipient, MessageType, MessageID, Wait);
	else if (UTC_PlayerPawn(this) != none)
		UTC_PlayerPawn(this).SendTeamMessage(Recipient, MessageType, MessageID, Wait);
	else
		this.SendVoiceMessage(this.PlayerReplicationInfo, Recipient, MessageType, MessageID, 'TEAM');
}

function ShakeView(float shaketime, float RollMag, float vertmag);

static function UTSF_ShakeView(Pawn this, float shaketime, float RollMag, float vertmag)
{
	local vector shake;

	if (UTC_Pawn(this) != none)
		UTC_Pawn(this).ShakeView(shaketime, RollMag, vertmag);
	else if (UTC_PlayerPawn(this) != none)
		UTC_PlayerPawn(this).ShakeView(shaketime, RollMag, vertmag);
	else if (PlayerPawn(this) != none)
	{
		shake.X = RollMag;
		shake.Y = 100 * shaketime;
		shake.Z = 100 * vertmag;
		PlayerPawn(this).ClientShake(shake);
	}
}

function TakeFallingDamage()
{
	UTSF_TakeFallingDamage(self);
}

static function UTSF_TakeFallingDamage(Pawn this)
{
	if (this.Role != ROLE_Authority)
		return;
	if (this.Velocity.Z < -1.4 * this.JumpZ)
	{
		this.MakeNoise(-0.5 * this.Velocity.Z/(FMax(this.JumpZ, 150.0)));
		if (this.Velocity.Z <= -750 - this.JumpZ)
		{
			if (this.Velocity.Z < -1650 - this.JumpZ && this.ReducedDamageType != 'All')
				this.TakeDamage(1000, none, this.Location, vect(0,0,0), 'Fell');
			else
				this.TakeDamage(-0.15 * (this.Velocity.Z + 700 + this.JumpZ), none, this.Location, vect(0,0,0), 'Fell');
			UTSF_ShakeView(this, 0.175 - 0.00007 * this.Velocity.Z, -0.85 * this.Velocity.Z, -0.002 * this.Velocity.Z);
		}
	}
	else if (this.Velocity.Z > 0.5 * this.default.JumpZ)
		this.MakeNoise(0.35);
}

simulated function SetMesh()
{
	Mesh = default.Mesh;
}

exec function bool SwitchToBestWeapon()
{
	return UTSF_SwitchToBestWeapon(self);
}

static function bool UTSF_SwitchToBestWeapon(Pawn this)
{
	local float rating;
	local int usealt;

	if (this.Inventory == none)
		return false;

	this.PendingWeapon = this.Inventory.RecommendWeapon(rating, usealt);
	if (this.PendingWeapon == this.Weapon)
		this.PendingWeapon = none;
	if (this.PendingWeapon == none || this.PendingWeapon.bDeleteMe)
		return false;

	if (this.Weapon == none)
		this.ChangedWeapon();
	else if (this.Weapon != this.PendingWeapon)
		this.Weapon.PutDown();

	return usealt > 0;
}

// Auxiliary

/* 227j version
static function vector B227_DamageMomentum(Pawn this, float MomentumZ)
{
	local vector Momentum;

	if (this.LastDamageTime == this.Level.TimeSeconds)
	{
		Momentum = this.LastDamageMomentum;
		if (this.Physics == PHYS_Walking)
			Momentum.Z = FMax(Momentum.Z, 0.4 * VSize(Momentum));
		if (this.LastDamageInstigator == this)
			Momentum *= 0.6;
		Momentum = Momentum/this.Mass;
	}
	else
		Momentum.Z = MomentumZ;
	return Momentum;
}

static function vector B227_DamageHitLocation(Pawn this)
{
	if (this.LastDamageTime == this.Level.TimeSeconds)
		return this.LastDamageHitLocation;
	return this.Location;
}
*/

// 227i version
static function vector B227_DamageMomentum(Pawn this, float MomentumZ)
{
	return MomentumZ * vect(0, 0, 1);
}

// 227i version
static function vector B227_DamageHitLocation(Pawn this)
{
	return this.Location;
}

static function B227_InitPawnShadow(Pawn this)
{
	this.bNoDynamicShadowCast = false;

	if (class'GameInfo'.default.bCastShadow && this.Shadow == none)
	{
		if (class'GameInfo'.default.bCastProjectorShadows )
			this.Shadow = this.Spawn(Class'PawnShadowX', this);
		else
			this.Shadow = this.Spawn(Class'PawnShadow', this);
	}
}

function bool B227_HasAliveEnemy()
{
	return Enemy != none && !Enemy.bDeleteMe && Enemy.Health > 0;
}

function bool B227_EnemyNotVisible()
{
	// Unlike UT, in v227, event EnemyNotVisible is not called automatically
	// when the enemy goes out of the line of sight
	if (!B227_HasAliveEnemy() || !LineOfSightTo(Enemy))
	{
		EnemyNotVisible();
		return true;
	}
	return false;
}

static function UTC_PlayerReplicationInfo B227_GetPRI(Pawn this)
{
	return UTC_PlayerReplicationInfo(this.PlayerReplicationInfo);
}

defaultproperties
{
	PlayerReplicationInfoClass=Class'Botpack227_Base.UTC_PlayerReplicationInfo'
}
