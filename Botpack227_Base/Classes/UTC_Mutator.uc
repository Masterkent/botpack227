class UTC_Mutator expands Mutator;

var UTC_Mutator NextDamageMutator;
var UTC_Mutator NextMessageMutator;
var UTC_Mutator NextHUDMutator;

var bool bHUDMutator;

var Actor B227_ReplacingActor;
var private transient UTC_Mutator B227_BaseMutator;

event PreBeginPlay()
{
	if (Level.NetMode != NM_Client) // Note: HUD mutators can be spawned client-side with Role == ROLE_Authority
		class'B227_MutatorGR'.static.WrapMutator(self);
}

simulated function PostRender(Canvas Canvas);

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	local bool bResult;

	if (UTC_GameInfo(Level.Game) == none)
	{
		if (class'UTC_Mutator'.default.B227_BaseMutator == none)
		{
			if (AlwaysKeep(Other))
				return true;

			class'UTC_Mutator'.default.B227_BaseMutator = self; // Prevents other mutators in the chain from calling AlwaysKeep again
			bResult = CheckReplacement(Other, bSuperRelevant) && (NextMutator == none || NextMutator.IsRelevant(Other, bSuperRelevant));
			class'UTC_Mutator'.default.B227_BaseMutator = none;

			return bResult;
		}
		if (class'UTC_Mutator'.default.B227_BaseMutator == self && AlwaysKeep(Other)) // May be evaluated for actors spawned by CheckReplacement
			return true;
	}
	return CheckReplacement(Other, bSuperRelevant) && (NextMutator == none || NextMutator.IsRelevant(Other, bSuperRelevant));
}

function bool ReplaceWith(Actor Other, string ClassName)
{
	local class<Actor> aClass;

	if (Inventory(Other) != none && (!bool(Other.Location) || Pawn(Other.Owner) != none))
		return false;

	aClass = class<Actor>(DynamicLoadObject(ClassName, class'Class'));
	if (aClass == none)
		return false;

	return B227_ReplaceWith(Other, aClass);
}

function ModifyPlayer(Pawn Other)
{
	if (NextMutator != none)
		UTSF_ModifyPlayer(NextMutator, Other);
}

static function UTSF_ModifyPlayer(Mutator this, Pawn Other)
{
	if (UTC_Mutator(this) != none)
		UTC_Mutator(this).ModifyPlayer(Other);
	else if (this.NextMutator != none)
		UTSF_ModifyPlayer(this.NextMutator, Other);
}

// Can only disallow picking up in this port
function bool HandlePickupQuery(Pawn Other, Inventory item, out byte bAllowPickup)
{
	if (NextMutator != none)
		return UTSF_HandlePickupQuery(NextMutator, Other, item, bAllowPickup);
	return false;
}

static function bool UTSF_HandlePickupQuery(Mutator this, Pawn Other, Inventory Item, out byte bAllowPickup)
{
	if (UTC_Mutator(this) != none)
		return UTC_Mutator(this).HandlePickupQuery(Other, Item, bAllowPickup);
	if (this.NextMutator != none)
		return UTSF_HandlePickupQuery(this.NextMutator, Other, Item, bAllowPickup);
	return false;
}

function bool PreventDeath(Pawn Killed, Pawn Killer, name damageType, vector HitLocation)
{
	if (NextMutator != none)
		return UTSF_PreventDeath(NextMutator, Killed, Killer, damageType, HitLocation);
	return false;
}

static function bool UTSF_PreventDeath(Mutator this, Pawn Killed, Pawn Killer, name damageType, vector HitLocation)
{
	if (UTC_Mutator(this) != none)
		return UTC_Mutator(this).PreventDeath(Killed, Killer, damageType, HitLocation);
	if (this.NextMutator != none)
		return UTSF_PreventDeath(this.NextMutator, Killed, Killer, damageType, HitLocation);
	return false;
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	if (NextMutator != none)
		UTSF_Mutate(NextMutator, MutateString, Sender);
}

static function UTSF_Mutate(Mutator this, string MutateString, PlayerPawn Sender)
{
	if (UTC_Mutator(this) != none)
		UTC_Mutator(this).Mutate(MutateString, Sender);
	else if (this.NextMutator != none)
		UTSF_Mutate(this.NextMutator, MutateString, Sender);
}

function MutatorTakeDamage(
	out int ActualDamage,
	Pawn Victim,
	Pawn InstigatedBy,
	out Vector HitLocation, 
	out Vector Momentum,
	name DamageType)
{
	if (NextDamageMutator != none)
		NextDamageMutator.MutatorTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}

function bool MutatorTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	if (NextMessageMutator != none)
		return NextMessageMutator.MutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
	return true;
}

function bool MutatorBroadcastMessage(Actor Sender, Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type)
{
	if (NextMessageMutator != none)
		return NextMessageMutator.MutatorBroadcastMessage(Sender, Receiver, Msg, bBeep, Type);
	return true;
}

function bool MutatorBroadcastLocalizedMessage(
	Actor Sender,
	Pawn Receiver,
	out class<LocalMessage> Message,
	out optional int Switch,
	out optional PlayerReplicationInfo RelatedPRI_1,
	out optional PlayerReplicationInfo RelatedPRI_2,
	out optional Object OptionalObject)
{
	if (NextMessageMutator != none)
		return NextMessageMutator.MutatorBroadcastLocalizedMessage(Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	return true;
}

function ScoreKill(Pawn Killer, Pawn Other)
{
	if (NextMutator != none)
		UTSF_ScoreKill(NextMutator, Killer, Other);
}

static function UTSF_ScoreKill(Mutator this, Pawn Killer, Pawn Other)
{
	if (UTC_Mutator(this) != none)
		UTC_Mutator(this).ScoreKill(Killer, Other);
	else if (this.NextMutator != none)
		UTSF_ScoreKill(this.NextMutator, Killer, Other);
}

function bool AlwaysKeep(Actor Other)
{
	if (NextMutator != none)
		return UTSF_AlwaysKeep(NextMutator, Other);
	return false;
}

static function bool UTSF_AlwaysKeep(Mutator this, Actor Other)
{
	if (UTC_Mutator(this) != none)
		return UTC_Mutator(this).AlwaysKeep(Other);
	if (this.NextMutator != none)
		return UTSF_AlwaysKeep(this.NextMutator, Other);
	return false;
}

function bool HandleEndGame()
{
	if (NextMutator != none)
		return UTSF_HandleEndGame(NextMutator);
	return false;
}

static function bool UTSF_HandleEndGame(Mutator this)
{
	if (UTC_Mutator(this) != none)
		return UTC_Mutator(this).HandleEndGame();
	if (this.NextMutator != none)
		return UTSF_HandleEndGame(this.NextMutator);
	return false;
}

// Registers the current mutator on the client to receive PostRender calls.
function RegisterHUDMutator()
{
	local PlayerPawn Player;

	Player = Level.GetLocalPlayerPawn();

	// If a HUD modifier is supposed to be used with HUD classes that are not derived from ChallengeHUD,
	// it should use HUDOverlay.
	if (Player == none || UTC_HUD(Player.myHUD) == none || Player.myHUD.bDeleteMe)
		return;

	NextHUDMutator = UTC_HUD(Player.myHUD).HUDMutator;
	UTC_HUD(Player.myHUD).HUDMutator = self;
	bHUDMutator = true;
}

function bool B227_ReplaceWith(Actor Actor, class<Actor> NewActorClass)
{
	local Actor A;

	A = Actor.Spawn(NewActorClass, Actor.Owner, Actor.Tag);
	B227_ReplacingActor = A;
	if (A == none)
		return false;

	if (Inventory(Actor) != none)
	{
		if (Inventory(Actor).MyMarker != none)
		{
			Inventory(Actor).MyMarker.markedItem = Inventory(A);
			if (Inventory(A) != none)
				Inventory(A).MyMarker = Inventory(Actor).MyMarker;
			Inventory(Actor).MyMarker = none;
		}

		if (Inventory(A) != none)
		{
			if (Actor.CollisionRadius != Actor.default.CollisionRadius)
				A.SetCollisionSize(Actor.CollisionRadius, A.CollisionHeight);

			if (Actor.CollisionHeight != Actor.default.CollisionHeight)
				A.SetCollisionSize(A.CollisionRadius, Actor.CollisionHeight);
			else
				A.Move((A.CollisionHeight - Actor.CollisionHeight) * vect(0, 0, 1));

			if (Inventory(Actor).bHeldItem)
			{
				Inventory(A).bHeldItem = true;
				Inventory(A).RespawnTime = 0.0;
			}
			else if (Inventory(Actor).RespawnTime == 0.0)
				Inventory(A).RespawnTime = 0.0;
		}
	}

	A.Event = Actor.Event;
	A.Tag = Actor.Tag;

	return true;
}
