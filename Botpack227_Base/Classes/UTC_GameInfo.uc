class UTC_GameInfo expands GameInfo;

var UTC_Mutator DamageMutator;	// linked list of mutators which affect damage
var UTC_Mutator MessageMutator; // linked list of mutators which get localized message queries

var class<LocalMessage> DeathMessageClass;
var class<LocalMessage> DMMessageClass;

var localized bool bAlternateMode;

var() globalconfig int B227_WeaponDeathMessagesMode;

var() class<LocalMessage> B227_KillerMessageClass;

// Auxiliary
// public:
var Pawn B227_Player; // is used as the first argument for UTF_FindPlayerStart
var class<Weapon> B227_DamageWeaponClass;
var B227_PendingWeaponSwitcher B227_PendingWeaponSwitcher;

// private:
var private bool B227_bFindPlayerStart_Default;


function bool IsRelevant(Actor Other)
{
	if (Other.bIsPawn && Pawn(Other).PlayerReplicationInfoClass == class'PlayerReplicationInfo')
		Pawn(Other).PlayerReplicationInfoClass = class'UTC_PlayerReplicationInfo';

	if (BaseMutator != none && class'UTC_Mutator'.static.UTSF_AlwaysKeep(BaseMutator, Other))
		return true;
	return super.IsRelevant(Other);
}

function InitGameReplicationInfo()
{
	super.InitGameReplicationInfo();
	if (B227_GRI() != none)
	{
		B227_GRI().GameClass = string(Class);
		B227_GRI().bClassicDeathmessages = bClassicDeathmessages;
	}
}

event PlayerPawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<PlayerPawn> SpawnClass)
{
	local PlayerPawn NewPlayer;

	NewPlayer = super.Login(Portal, Options, Error, SpawnClass);

	if (NewPlayer != none && class'UTC_Pawn'.static.B227_GetPRI(NewPlayer) != none)
		class'UTC_Pawn'.static.B227_GetPRI(NewPlayer).PlayerID = NewPlayer.PlayerReplicationInfo.PlayerID;

	return NewPlayer;
}

function AdminLogin(UTC_PlayerPawn P, string Password)
{
	local string AdminPassword;
	local string LoginMessage;

	if (P == none || P.PlayerReplicationInfo == none)
		return;

	if (P.B227_LastAdminLoginTimestamp > 0 && Level.TimeSeconds - P.B227_LastAdminLoginTimestamp < 1)
	{
		P.ClientMessage("You couldn't log in, because not enough time passed since the last login attempt.");
		return;
	}

	AdminPassword = ConsoleCommand("get Engine.GameInfo AdminPassword");
	if (AdminPassword == "")
	{
		P.ClientMessage("Admin password is not available on this server.");
		return;
	}

	if (Password == AdminPassword)
	{
		P.bAdmin = True;
		if (B227_PRI(P) != none)
			B227_PRI(P).bAdmin = P.bAdmin;
		GetAccessManager().AdminLogin(P);
		LoginMessage = P.PlayerReplicationInfo.PlayerName @ "became a server administrator.";
		BroadcastMessage(LoginMessage);
	}
	else
	{
		P.ClientMessage("Invalid password");
		P.B227_LastAdminLoginTimestamp = Level.TimeSeconds;
	}
}

function AdminLogout(UTC_PlayerPawn P)
{
	local string LogoutMessage;

	if (P.bAdmin)
	{
		GetAccessManager().AdminLogout(P);
		P.bAdmin = False;
		if (B227_PRI(P) != none)
			B227_PRI(P).bAdmin = P.bAdmin;
		if ( P.ReducedDamageType == 'All' )
			P.ReducedDamageType = '';
		if (P.IsInState('CheatFlying'))
			P.StartWalk();
		LogoutMessage = P.PlayerReplicationInfo.PlayerName @ "gave up administrator abilities.";
		BroadcastMessage(LogoutMessage);
	}
}

function AddDefaultInventory(Pawn Player)
{
	if (Spectator(Player) != none)
		return;
	Player.JumpZ = Player.default.JumpZ * PlayerJumpZScaling();
	B227_AddPlayerDefaultWeapon(Player);
	B227_ModifyPlayerWithGameRules(Player);
}

function B227_AddPlayerDefaultWeapon(Pawn Player)
{
	local Weapon NewWeapon, PendingWeapon;
	local class<Weapon> WeapClass;

	if (DefaultWeapon == none)
		return;

	WeapClass = BaseMutator.MutatedDefaultWeapon();
	if (WeapClass == none || Player.FindInventoryType(WeapClass) != none)
		return;
	NewWeapon = Spawn(WeapClass,,, Player.Location);
	if (NewWeapon == none)
		return;
	NewWeapon.LifeSpan = NewWeapon.default.LifeSpan; // prevents destruction when spawning in destructive zones
	NewWeapon.GiveTo(Player);
	NewWeapon.bHeldItem = true;
	NewWeapon.GiveAmmo(Player);
	NewWeapon.SetSwitchPriority(Player);
	if (B227_PendingWeaponSwitcher != none &&
		!B227_PendingWeaponSwitcher.bDeleteMe &&
		B227_PendingWeaponSwitcher.Instigator == Player)
	{
		if (Player.PendingWeapon != none && !Player.PendingWeapon.bDeleteMe)
		{
			PendingWeapon = Player.PendingWeapon;
			Player.Weapon = PendingWeapon;
			NewWeapon.WeaponSet(Player);
			PendingWeapon.bChangeWeapon = false;
			Player.Weapon = none;
		}
		else
		{
			NewWeapon.GotoState('');
			Player.PendingWeapon = NewWeapon;
		}
	}
	else
		NewWeapon.WeaponSet(Player);
}

function B227_ModifyPlayerWithGameRules(Pawn Player)
{
	local GameRules GR;

	for (GR = GameRules; GR != none; GR = GR.NextRules)
		if (GR.bNotifySpawnPoint)
			GR.ModifyPlayer(Player);
}

function string KillMessage(name damageType, pawn Other)
{
	return UTF_KillMessage(damageType, Other);
}

static function string UTF_KillMessage(name damageType, pawn Other)
{
	return " died.";
}

function string CreatureKillMessage(name damageType, pawn Other)
{
	return UTF_CreatureKillMessage(damageType, Other);
}

static function string UTF_CreatureKillMessage(name damageType, pawn Other)
{
	return " was killed by a ";
}

function string PlayerKillMessage(name damageType, pawn Other)
{
	return UTF_PlayerKillMessage(damageType, Other.PlayerReplicationInfo);
}

static function string UTF_PlayerKillMessage(name damageType, PlayerReplicationInfo Other)
{
	return " was killed by ";
}

static function string UTSF_PlayerKillMessage(GameInfo this, name damageType, PlayerReplicationInfo Other)
{
	if (UTC_GameInfo(this) != none)
		return UTC_GameInfo(this).UTF_PlayerKillMessage(damageType, Other);
	if (Other != none)
		return this.PlayerKillMessage(damageType, Pawn(Other.Owner));
	return this.PlayerKillMessage(damageType, none);
}

function NavigationPoint FindPlayerStart(byte Team, optional string incomingName)
{
	if (B227_bFindPlayerStart_Default)
		return super.FindPlayerStart(Team, incomingName);
	return UTF_FindPlayerStart(B227_Player, Team, incomingName);
}

function NavigationPoint UTF_FindPlayerStart(Pawn Player, optional byte InTeam, optional string incomingName)
{
	local NavigationPoint Result;

	B227_bFindPlayerStart_Default = true;
	Result = FindPlayerStart(InTeam, incomingName);
	B227_bFindPlayerStart_Default = false;

	return Result;
}

function bool RestartPlayer(Pawn aPlayer)
{
	local NavigationPoint startSpot;
	local GameRules GR;

	if ( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		return true;

	startSpot = FindPlayerStart(aPlayer.PlayerReplicationInfo.Team);

	for (GR = GameRules; GR != none; GR = GR.NextRules)
		if (GR.bNotifySpawnPoint)
			GR.ModifyPlayerStart(aPlayer, startSpot, aPlayer.PlayerReplicationInfo.Team);

	if (startSpot == none)
		return false;

	if (!aPlayer.SetLocation(startSpot.Location))
		return false;

	startSpot.PlayTeleportEffect(aPlayer, true);
	aPlayer.SetRotation(startSpot.Rotation);
	aPlayer.ViewRotation = aPlayer.Rotation;
	aPlayer.Acceleration = vect(0,0,0);
	aPlayer.Velocity = vect(0,0,0);
	aPlayer.ClientSetLocation(startSpot.Location, startSpot.Rotation); // Don't let touch anything before enabling collision
	aPlayer.Health = aPlayer.default.Health;
	aPlayer.SetCollision(true, true, true);
	aPlayer.bCollideWorld = true;
	aPlayer.bHidden = false;
	aPlayer.DamageScaling = aPlayer.default.DamageScaling;
	aPlayer.SoundDampening = aPlayer.default.SoundDampening;
	if (aPlayer.FootRegion.Zone.bPainZone)
		aPlayer.PainTime = 1;
	else if (aPlayer.HeadRegion.Zone.bWaterZone)
		aPlayer.PainTime = aPlayer.UnderwaterTime;
	AddDefaultInventory(aPlayer);
	return true;
}

function bool ForceAddBot();

static function bool UTSF_ForceAddBot(GameInfo this)
{
	if (UTC_GameInfo(this) != none)
		return UTC_GameInfo(this).ForceAddBot();
	return false;
}

function RegisterDamageMutator(UTC_Mutator M)
{
	class'B227_DamageMutatorGR'.static.WrapMutator(M);
}

static function UTSF_RegisterDamageMutator(UTC_Mutator M)
{
	class'B227_DamageMutatorGR'.static.WrapMutator(M);
}

function RegisterMessageMutator(UTC_Mutator M)
{
	class'B227_MessageMutatorGR'.static.WrapMutator(M);
}

static function UTSF_RegisterMessageMutator(UTC_Mutator M)
{
	class'B227_MessageMutatorGR'.static.WrapMutator(M);
}

function Killed(Pawn Killer, Pawn Other, name damageType)
{
	local string Message, KillerWeapon, OtherWeapon;
	local bool bSpecialDamage;

	if (Other.PlayerReplicationInfo != none)
	{
		if (UTC_PlayerReplicationInfo(Other.PlayerReplicationInfo) != none)
			UTC_PlayerReplicationInfo(Other.PlayerReplicationInfo).Deaths += 1;
		if (Killer != none && Killer.PlayerReplicationInfo == none)
		{
			Message = Killer.KillMessage(damageType, Other);
			BroadcastMessage(Other.GetHumanName() $ Message, false, 'DeathMessage');
			return;
		}
		if ( (DamageType == 'SpecialDamage') && (SpecialDamageString != "") )
		{
			if (Killer != none && Killer != Other)
			{
				if (Killer.Weapon != none)
					KillerWeapon = Killer.Weapon.ItemName;
				BroadcastMessage( B227_ParseKillMessage(
						Killer.GetHumanName(),
						Other.GetHumanName(),
						KillerWeapon,
						SpecialDamageString
						),
					false, 'DeathMessage');
				if (B227_KillerMessageClass != none)
					class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(
						Killer,
						B227_KillerMessageClass,
						0,
						Killer.PlayerReplicationInfo,
						Other.PlayerReplicationInfo);
			}
			else
			{
				if (Other.Weapon != none)
					OtherWeapon = Other.Weapon.ItemName;
				BroadcastMessage( B227_ParseKillMessage(
						Other.GetHumanName(),
						Other.GetHumanName(),
						OtherWeapon,
						SpecialDamageString
						),
					false, 'DeathMessage');
			}
			bSpecialDamage = True;
		}
		if ( (Killer == Other) || (Killer == None) )
		{
			// Suicide
			if (damageType == '')
			{
				if ( LocalLog != None )
					LocalLog.LogSuicide(Other, 'Unknown');
				if ( WorldLog != None )
					WorldLog.LogSuicide(Other, 'Unknown');
			} else {
				if ( LocalLog != None )
					LocalLog.LogSuicide(Other, damageType);
				if ( WorldLog != None )
					WorldLog.LogSuicide(Other, damageType);
			}
			if (!bSpecialDamage)
			{
				if ( damageType == 'Fell' )
					BroadcastLocalizedMessage(DeathMessageClass, 2, Other.PlayerReplicationInfo, None);
				else if ( damageType == 'Eradicated' )
					BroadcastLocalizedMessage(DeathMessageClass, 3, Other.PlayerReplicationInfo, None);
				else if ( damageType == 'Drowned' )
					BroadcastLocalizedMessage(DeathMessageClass, 4, Other.PlayerReplicationInfo, None);
				else if ( damageType == 'Burned' )
					BroadcastLocalizedMessage(DeathMessageClass, 5, Other.PlayerReplicationInfo, None);
				else if ( damageType == 'Corroded' )
					BroadcastLocalizedMessage(DeathMessageClass, 6, Other.PlayerReplicationInfo, None);
				else if ( damageType == 'Mortared' )
					BroadcastLocalizedMessage(DeathMessageClass, 7, Other.PlayerReplicationInfo, None);
				else if (Other.FootRegion.Zone.DamageType == damageType && Len(Other.FootRegion.Zone.DamageString) > 0)
				{
					Message = B227_ZoneDeathMessage(Other);
					if (Len(Message) > 0)
						BroadcastMessage(Message, false, 'DeathMessage');
					else
						BroadcastLocalizedMessage(DeathMessageClass, 1, Other.PlayerReplicationInfo, none);
				}
				else
					BroadcastLocalizedMessage(DeathMessageClass, 1, Other.PlayerReplicationInfo, None);
			}
		}
		else
		{
			if (Killer.PlayerReplicationInfo != none)
			{
				KillerWeapon = "None";
				if (Killer.Weapon != None)
					KillerWeapon = Killer.Weapon.ItemName;
				OtherWeapon = "None";
				if (Other.Weapon != None)
					OtherWeapon = Other.Weapon.ItemName;
				if ( Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team )
				{
					if ( LocalLog != None )
						LocalLog.LogTeamKill(
							Killer.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
					if ( WorldLog != None )
						WorldLog.LogTeamKill(
							Killer.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
				} else {
					if ( LocalLog != None )
						LocalLog.LogKill(
							Killer.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
					if ( WorldLog != None )
						WorldLog.LogKill(
							Killer.PlayerReplicationInfo.PlayerID,
							Other.PlayerReplicationInfo.PlayerID,
							KillerWeapon,
							OtherWeapon,
							damageType
						);
				}
				if (!bSpecialDamage && (Other != None))
					BroadcastRegularDeathMessage(Killer, Other, damageType);
			}
		}
	}
	ScoreKill(Killer, Other);
}

function BroadcastRegularDeathMessage(pawn Killer, pawn Other, name damageType)
{
	if (B227_WeaponDeathMessagesMode == 2 && B227_DamageWeaponClass != none && B227_DamageWeaponClass != class'Weapon')
		BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, B227_DamageWeaponClass);
	else if (
		(B227_WeaponDeathMessagesMode == 1 || B227_WeaponDeathMessagesMode == 2 && B227_DamageWeaponClass == class'Weapon') &&
		Killer.Weapon != none)
	{
		BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, Killer.Weapon.Class);
	}
	else
		BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, none);
}

static function UTSF_BroadcastRegularDeathMessage(
	GameInfo this,
	class<LocalMessage> DeathMessageClass,
	Pawn Killer,
	Pawn Other,
	name damageType)
{
	if (DeathMessageClass == none)
		DeathMessageClass = class'UTC_GameInfo'.default.DeathMessageClass;
	class'UTC_Actor'.static.UTSF_BroadcastLocalizedMessage(
		this, DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, Killer.Weapon.Class);
}

function BroadcastLocalizedMessage(
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	class'UTC_Actor'.static.UTSF_BroadcastLocalizedMessage(self, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

function EndGame(string Reason)
{
	local Actor A;

	// don't end game if not really ready
	// mutator can set bOverTime if doesn't want game to end

	if (!class'UTC_Mutator'.static.UTSF_HandleEndGame(BaseMutator) && !SetEndCams(Reason) )
	{
		bOverTime = true;
		return;
	}

	bGameEnded = true;
	foreach AllActors(class'Actor', A, 'EndGame')
		A.trigger(self, none);

	if (LocalLog != None)
	{
		LocalLog.LogGameEnd(Reason);
		LocalLog.StopLog();
		LocalLog.Destroy();
		LocalLog = None;
	}
	if (WorldLog != None)
	{
		WorldLog.LogGameEnd(Reason);
		WorldLog.StopLog();
		WorldLog.Destroy();
		WorldLog = None;
	}
}


// Auxiliary
function UTC_GameReplicationInfo B227_GRI()
{
	return UTC_GameReplicationInfo(GameReplicationInfo);
}

static function UTC_PlayerReplicationInfo B227_PRI(Pawn P)
{
	return UTC_PlayerReplicationInfo(P.PlayerReplicationInfo);
}

// Tries to load the object only if its package is in the package map or the game is standalone;
// otherwise returns none
static function Object B227_DynamicLoadSharedObject(
	LevelInfo Level,
	string ObjectName,
	class ObjectClass,
	optional bool MayFail)
{
	local int i;

	i = InStr(ObjectName, ".");
	if (i <= 0)
	{
		if (!MayFail)
			Log("B227_DynamicLoadSharedObject: Invalid ObjectName:" $ ObjectName);
		return none;
	}
	if (Level.NetMode != NM_Standalone && !Level.IsInPackageMap(Left(ObjectName, i)))
	{
		if (!MayFail)
			Log("B227_DynamicLoadSharedObject: Failed to load" @ ObjectName $ ": " @ Left(ObjectName, i) @ "is not in the package map");
		return none;
	}
	return DynamicLoadObject(ObjectName, ObjectClass, MayFail);
}

static function string B227_ParseKillMessage(string KillerName, string VictimName, string WeaponName, string DeathMessage)
{
	if (InStr(DeathMessage, "%k") >= 0)
		DeathMessage = ReplaceStr(DeathMessage, "%k", KillerName);
	if (InStr(DeathMessage, "%o") >= 0)
		DeathMessage = ReplaceStr(DeathMessage, "%o", VictimName);
	if (InStr(DeathMessage, "%w") >= 0)
		DeathMessage = ReplaceStr(DeathMessage, "%w", WeaponName);
	return DeathMessage;
}

function string B227_ZoneDeathMessage(Pawn Victim)
{
	local string DamageString;

	DamageString = Victim.FootRegion.Zone.DamageString;

	if (InStr(DamageString, "%w") >= 0)
		return "";

	if (InStr(DamageString, "%k") >= 0)
	{
		if (InStr(DamageString, "%o") < 0)
			return ReplaceStr(DamageString, "%k", Victim.GetHumanName());
	}
	else if (InStr(DamageString, "%o") >= 0)
		return ReplaceStr(DamageString, "%o", Victim.GetHumanName());

	return "";
}

static function bool B227_MutatorTeamMessage(
	Actor Sender,
	Pawn Receiver,
	PlayerReplicationInfo PRI,
	coerce string Msg,
	name Type,
	optional bool bBeep)
{
	local GameRules GR;

	if (Sender == none)
		return false;
	if (Sender.Level.Game == none)
		return true;

	for (GR = Sender.Level.Game.GameRules; GR != none; GR = GR.NextRules)
		if (GR.bNotifyMessages)
		{
			if (B227_MessageMutatorGR(GR) != none)
			{
				if (!B227_MessageMutatorGR(GR).MutatorTeamMessage(Sender, Receiver, PRI, Msg, Type, bBeep))
					return false;
			}
			else if (PlayerPawn(Sender) != none && !GR.AllowChat(PlayerPawn(Sender), Msg))
				return false;
		}
	return true;
}

static function bool B227_MutatorBroadcastMessage(
	Actor Sender,
	Pawn Receiver,
	out coerce string Msg,
	optional bool bBeep,
	out optional name Type)
{
	local GameRules GR;

	if (Sender == none)
		return false;
	if (Sender.Level.Game == none)
		return true;

	for (GR = Sender.Level.Game.GameRules; GR != none; GR = GR.NextRules)
		if (GR.bNotifyMessages)
		{
			if (B227_MessageMutatorGR(GR) != none)
			{
				if (!B227_MessageMutatorGR(GR).MutatorBroadcastMessage(Sender, Receiver, Msg, bBeep, Type))
					return false;
			}
			else if (!GR.AllowBroadcast(Sender, Msg))
				return false;
		}
	return true;
}

static function bool B227_AllowChat(PlayerPawn Sender, out string Msg)
{
	local GameRules GR;

	if (Sender == none)
		return false;
	if (Sender.Level.Game == none)
		return true;

	for (GR = Sender.Level.Game.GameRules; GR != none; GR = GR.NextRules)
		if (GR.bNotifyMessages && !GR.AllowChat(Sender, Msg))
			return false;
	return true;
}

static function bool B227_AllowBroadcast(Actor Sender, string Msg)
{
	local GameRules GR;

	if (Sender == none)
		return false;
	if (Sender.Level.Game == none)
		return true;

	for (GR = Sender.Level.Game.GameRules; GR != none; GR = GR.NextRules)
		if (GR.bNotifyMessages && !GR.AllowBroadcast(Sender, Msg))
			return false;
	return true;
}

static function B227_ModifyDamage(Pawn Victim, Pawn DamageInstigator, out int Damage, vector HitLocation, name DamageType, out vector Momentum)
{
	local GameRules GR;

	if (Victim == none)
		return; 

	for (GR = Victim.Level.Game.GameRules; GR != none; GR = GR.NextRules)
		if (GR.bModifyDamage)
			GR.ModifyDamage(Victim, DamageInstigator, Damage, HitLocation, DamageType, Momentum);
}

static function bool B227_PreventDeath(Pawn Victim, Pawn Killer, name DamageType)
{
	local GameRules GR;

	if (Victim == none)
		return false;
	for (GR = Victim.Level.Game.GameRules; GR != none; GR = GR.NextRules)
		if (GR.bHandleDeaths && GR.PreventDeath(Victim, Killer, DamageType))
			return true;
	return false;
}

static function B227_BroadcastLocalizedDeathMessage(
	GameInfo this,
	optional class<LocalMessage> DeathMessageClass,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	if (DeathMessageClass == none)
		DeathMessageClass = class'UTC_GameInfo'.default.DeathMessageClass;
	class'UTC_Actor'.static.UTSF_BroadcastLocalizedMessage(this, DeathMessageClass, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

static function B227_SetDamageWeaponClass(LevelInfo Level, class<Weapon> WeaponClass)
{
	if (UTC_GameInfo(Level.Game) != none)
		UTC_GameInfo(Level.Game).B227_DamageWeaponClass = WeaponClass;
}

static function B227_ResetDamageWeaponClass(LevelInfo Level)
{
	if (UTC_GameInfo(Level.Game) != none)
		UTC_GameInfo(Level.Game).B227_DamageWeaponClass = class'Weapon';
}

defaultproperties
{
	DeathMessageClass=Class'Engine.LocalMessage'
	GameReplicationInfoClass=Class'UTC_GameReplicationInfo'
	B227_DamageWeaponClass=Class'Weapon'
	B227_WeaponDeathMessagesMode=2
}
