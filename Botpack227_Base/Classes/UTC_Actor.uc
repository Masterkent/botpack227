class UTC_Actor expands Actor
	abstract;

static function UTSF_BroadcastLocalizedMessage(
	Actor this,
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
	local LevelInfo Level;
	local GameRules GR;
	local Pawn P;
	local string Msg;
	local bool bSkip;

	if (this == none)
		return;
	Level = this.Level;

	Msg = Message.static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (Level.Game != none)
	{
		if (Level.Game.GameRules != none)
			for (GR = Level.Game.GameRules; GR != none; GR = GR.NextRules)
				if (GR.bNotifyMessages && B227_MessageMutatorGR(GR) == none && !GR.AllowBroadcast(this, Msg))
					return;
		if (!Level.Game.AllowsBroadcast(this, Len(Msg)))
			return;
	}

	for (P = Level.PawnList; P != None; P = P.nextPawn)
		if (P.bIsPlayer || P.IsA('MessagingSpectator'))
		{
			if (UTC_GameInfo(Level.Game) != none)
			{
				if (UTC_GameInfo(Level.Game).MessageMutator != none)
				{
					if (!UTC_GameInfo(Level.Game).MessageMutator.MutatorBroadcastLocalizedMessage(
						this, P, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject))
					{
						continue;
					}
				}
			}
			else if (Level.Game.GameRules != none)
			{
				bSkip = false;
				for (GR = Level.Game.GameRules; GR != none; GR = GR.NextRules)
					if (B227_MessageMutatorGR(GR) != none && B227_MessageMutatorGR(GR).GetMutator() != none &&
						!B227_MessageMutatorGR(GR).GetMutator().MutatorBroadcastLocalizedMessage(
							this, P, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject))
					{
						bSkip = true;
						break;
					}
				if (bSkip)
					continue;
			}
			class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}
}

static function B227_StaticBroadcastLocalizedMessage(
	Actor this,
	class<LocalMessage> Message,
	optional int Switch,
	optional string RelatedPawnInfo_1,
	optional string RelatedPawnInfo_2,
	optional class<Object> RelatedClass,
	optional string RelatedInfo)
{
	local LevelInfo Level;
	local GameRules GR;
	local Pawn P;
	local string Msg;

	if (this == none)
		return;
	Level = this.Level;

	Message.default.B227_bHasRelatedContext = true;
	Message.default.B227_RelatedPawnInfo_1 = RelatedPawnInfo_1;
	Message.default.B227_RelatedPawnInfo_2 = RelatedPawnInfo_2;
	Message.default.B227_RelatedClass = RelatedClass;
	Message.default.B227_RelatedInfo = RelatedInfo;

	Msg = Message.static.B227_GetString(Switch);

	Message.default.B227_bHasRelatedContext = false;
	Message.default.B227_RelatedPawnInfo_1 = "";
	Message.default.B227_RelatedPawnInfo_2 = "";
	Message.default.B227_RelatedClass = none;
	Message.default.B227_RelatedInfo = "";

	if (Level.Game != none)
	{
		if (Level.Game.GameRules != none)
			for (GR = Level.Game.GameRules; GR != none; GR = GR.NextRules)
				if (GR.bNotifyMessages && B227_MessageMutatorGR(GR) == none && !GR.AllowBroadcast(this, Msg))
					return;
		if (!Level.Game.AllowsBroadcast(this, Len(Msg)))
			return;
	}
	for (P = Level.PawnList; P != None; P = P.nextPawn)
		if (P.bIsPlayer || P.IsA('MessagingSpectator'))
			class'UTC_Pawn'.static.B227_StaticReceiveLocalizedMessage(P, Message, Switch, RelatedPawnInfo_1, RelatedPawnInfo_2, RelatedClass, RelatedInfo);
}

// Play sound only with Role == ROLE_Authority
static function B227_PlaySound(
	Actor this,
	sound Sound,
	optional ESoundSlot Slot,
	optional float Volume,
	optional bool bNoOverride,
	optional float Radius,
	optional float Pitch)
{
	if (this.Role != ROLE_Authority)
		return;

	if (Volume == 0)
		Volume = this.TransientSoundVolume;

	if (Radius == 0)
		Radius = this.TransientSoundRadius;

	if (Pitch == 0)
		Pitch = 1.f;
	this.PlaySound(Sound, Slot, Volume, bNoOverride, Radius, Pitch);
}

static function B227_PlayVoice(Actor this, sound Sound, optional float Volume)
{
	if (Volume == 0)
		Volume = 1;
	this.PlaySound(Sound, SLOT_Interface, Volume);
}

static function bool B227_WarpActor(Actor A)
{
	local WarpZoneInfo WarpZone;
	local vector Loc, Dir;
	local rotator R;

	WarpZone = WarpZoneInfo(A.Region.Zone);
	if (WarpZone == none)
		return false;
	WarpZone.Generate();
	if (WarpZone.OtherSideActor == none)
		return false;

	Loc = A.Location;
	R = A.Rotation;
	WarpZone.UnWarp(Loc, Dir, R);
	WarpZone.OtherSideActor.Warp(Loc, Dir, R);
	if (!A.SetLocation(Loc))
		return false;
	A.SetRotation(R);
	return true;
}
