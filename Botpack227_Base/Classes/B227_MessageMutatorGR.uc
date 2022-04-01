class B227_MessageMutatorGR expands GameRules;

var private UTC_Mutator MessageMutator;

static function bool WrapMutator(UTC_Mutator M)
{
	local B227_MessageMutatorGR GR;

	if (M == none || M.bDeleteMe)
		return false;

	foreach M.AllActors(class'B227_MessageMutatorGR', GR)
		break;
	if (GR == none)
	{
		GR = M.Spawn(class'B227_MessageMutatorGR');
		if (GR == none)
			return false;
	}

	if (UTC_GameInfo(M.Level.Game) != none)
	{
		M.NextMessageMutator = UTC_GameInfo(M.Level.Game).MessageMutator;
		UTC_GameInfo(M.Level.Game).MessageMutator = M;
	}
	else
		M.NextMessageMutator = GR.MessageMutator;
	GR.MessageMutator = M;
	return true;
}

event BeginPlay()
{
	if (Level.Game.GameRules == none)
		Level.Game.GameRules = self;
	else
		Level.Game.GameRules.AddRules(self);
}

function bool AllowBroadcast(Actor Sender, string Msg)
{
	local Pawn PotentialReceiver;

	if (MessageMutator != none)
	{
		PotentialReceiver = Pawn(Sender);
		if (PotentialReceiver == none)
			PotentialReceiver = Sender.Instigator;
		if (PotentialReceiver == none)
		{
			for (PotentialReceiver = Level.PawnList; PotentialReceiver != none; PotentialReceiver = PotentialReceiver.nextPawn)
				if (PotentialReceiver.bIsPlayer)
					break;
		}
		if (PotentialReceiver == none)
			return true;
		return MessageMutator.MutatorBroadcastMessage(Sender, PotentialReceiver, Msg);
	}
	return true;
}

function bool AllowChat(PlayerPawn Sender, out string Msg)
{
	if (MessageMutator != none)
		return MessageMutator.MutatorTeamMessage(Sender, Sender, Sender.PlayerReplicationInfo, Msg, '');
	return true;
}

function bool MutatorBroadcastMessage(Actor Sender, Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type)
{
	if (MessageMutator != none)
		return MessageMutator.MutatorBroadcastMessage(Sender, Receiver, Msg, bBeep, Type);
	return true;
}

function bool MutatorTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	if (MessageMutator != none)
		return MessageMutator.MutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
	return true;
}

function UTC_Mutator GetMutator()
{
	return MessageMutator;
}

defaultproperties
{
	bNotifyMessages=True
}
