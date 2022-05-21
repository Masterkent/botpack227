class UTC_GameInfo expands GameInfo;

var UTC_Mutator DamageMutator;	// linked list of mutators which affect damage
var UTC_Mutator MessageMutator; // linked list of mutators which get localized message queries

var class<LocalMessage> DeathMessageClass;
var class<LocalMessage> DMMessageClass;

var localized bool bAlternateMode;

// Auxiliary
// public:
var Pawn B227_Player; // is used as the first argument for UTF_FindPlayerStart

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

	if (Other.bIsPlayer)
	{
		if ( (Killer != None) && (!Killer.bIsPlayer) )
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
				BroadcastMessage( ParseKillMessage(
						Killer.GetHumanName(),
						Other.GetHumanName(),
						KillerWeapon,
						SpecialDamageString
						),
					false, 'DeathMessage');
			}
			else
			{
				if (Other.Weapon != none)
					OtherWeapon = Other.Weapon.ItemName;
				BroadcastMessage( ParseKillMessage(
						Other.GetHumanName(),
						Other.GetHumanName(),
						OtherWeapon,
						ReplaceStr(SpecialDamageString, "%o", "%k")
						),
					false, 'DeathMessage');
			}
			bSpecialDamage = True;
		}
		if (UTC_PlayerReplicationInfo(Other.PlayerReplicationInfo) != none)
			UTC_PlayerReplicationInfo(Other.PlayerReplicationInfo).Deaths += 1;
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
			if ( Killer.bIsPlayer )
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
				{
					if (Killer.Weapon != none)
						BroadcastRegularDeathMessage(Killer, Other, damageType);
					else
					{
						super.Killed(Killer, Other, damageType);
						return;
					}
				}
			}
		}
	}
	ScoreKill(Killer, Other);
}

function BroadcastRegularDeathMessage(pawn Killer, pawn Other, name damageType)
{
	BroadcastLocalizedMessage(DeathMessageClass, 0, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo, Killer.Weapon.Class);
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

defaultproperties
{
	DeathMessageClass=Class'Engine.LocalMessage'
	GameReplicationInfoClass=Class'UTC_GameReplicationInfo'
}
