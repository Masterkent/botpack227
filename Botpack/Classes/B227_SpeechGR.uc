class B227_SpeechGR expands GameRules;

event BeginPlay()
{
	if (Level.Game.GameRules == none)
		Level.Game.GameRules = self;
	else
		Level.Game.GameRules.AddRules(self);
}

function ModifyPlayer(Pawn Player)
{
	if (PlayerPawn(Player) == none || TournamentPlayer(Player) != none)
		return;
	SetVoicePack(Player);
	GiveUserUtils(Player);
}

function SetVoicePack(Pawn Player)
{
	if (Player.PlayerReplicationInfo.VoiceType != none)
		return;

	if (Player.PlayerReplicationInfo.bIsFemale)
	{
		if (Player.Mesh == mesh'UnrealShare.Female1')
			Player.PlayerReplicationInfo.VoiceType = class'VoiceFemaleOne';
		else
			Player.PlayerReplicationInfo.VoiceType = class'VoiceFemaleTwo';
	}
	else
	{
		if (Player.Mesh == mesh'UnrealI.Nali2')
			Player.PlayerReplicationInfo.VoiceType = LoadVoicePack("multimesh.NaliVoice");
		else if (Player.Mesh == mesh'UnrealI.sktrooper')
			Player.PlayerReplicationInfo.VoiceType = LoadVoicePack("multimesh.SkaarjVoice");
		else if (Player.Mesh == mesh'UnrealI.Male1')
			Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleOne';
		else
			Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleTwo';
	}
}

function GiveUserUtils(Pawn Player)
{
	local Inventory Inv;

	for (Inv = Player.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.Class == class'B227_BotpackUserUtils' && !Inv.bDeleteMe)
			return;
	Inv = Spawn(class'B227_BotpackUserUtils', Player);
	if (Inv != none)
		Inv.GiveTo(Player);
}

static function class<VoicePack> LoadVoicePack(string ClassName)
{
	local class<VoicePack> Result;

	Result = class<VoicePack>(DynamicLoadObject(ClassName, class'Class', true));
	if (Result != none)
		return Result;
	return class'VoiceMaleTwo';
}

defaultproperties
{
	bNotifySpawnPoint=True
}
