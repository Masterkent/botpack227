class SBGameRules expands GameRules;

#exec OBJ LOAD FILE="multimesh.u"

var SBCoopMutator MutatorPtr;

///var SevenLevelInfo LInfo; //info for some options

function PostBeginPlay()
{
	if (SBCoopMutator(Owner) == none)
	{
		log("WARNING: SBCoopMutator failed to create SBGameRules");
		Destroy();
		return;
	}
	MutatorPtr = SBCoopMutator(Owner);
}

function ModifyPlayer(Pawn Player)
{
	ModifyPlayerVoicePack(Player);
	GiveSBPlayerInteraction(Player);
	GiveSBUserUtils(Player);
	GiveSBFlashlight(Player);
}

function ModifyPlayerVoicePack(Pawn Player)
{
	if (Player.PlayerReplicationInfo.VoiceType == None)
		Player.PlayerReplicationInfo.VoiceType = Player.VoiceType;

	if (Player.PlayerReplicationInfo.VoiceType == None)
	{
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
				Player.PlayerReplicationInfo.VoiceType = class'NaliVoice';
			else if (Player.Mesh == mesh'UnrealI.sktrooper')
				Player.PlayerReplicationInfo.VoiceType = class'SkaarjVoice';
			else if (Player.Mesh == mesh'UnrealI.Male1')
				Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleOne';
			else
				Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleTwo';
		}
	}
}

function GiveSBPlayerInteraction(Pawn Player)
{
	local SBPlayerInteraction PlayerInteraction;

	foreach Player.ChildActors(class'SBPlayerInteraction', PlayerInteraction)
		break;
	if (PlayerInteraction == none)
		PlayerInteraction = Player.Spawn(class'SBPlayerInteraction', Player);
}

function GiveSBUserUtils(Pawn Player)
{
	local Inventory Inv;

	if (!MutatorPtr.bUseSpeechMenuForU1Players ||
		PlayerPawn(Player) == none)
	{
		return;
	}

	for (Inv = Player.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.Class == class'SBUserUtils' && !Inv.bDeleteMe)
			return;
	Inv = Spawn(class'SBUserUtils', Player);
	if (Inv != none)
		Inv.GiveTo(Player);
}

function GiveSBFlashlight(Pawn Player)
{
	if (Player.FindInventoryType(class'SevenB.TvFlashLight') == none)
		GivePickup(class'SevenB.TvFlashLight', Player);
}

//gives a pickup to a pawn.
function GivePickup(class<pickup> PickupClass, Pawn Player)
{
	local Pickup Pickup;

	Pickup = Player.Spawn(PickupClass);
	if (Pickup == none)
		return;
	Pickup.bHeldItem = true;
	Pickup.GiveTo(Player);
	if (Pickup.bActivatable && Player.SelectedItem == none)
		Player.SelectedItem = Pickup;
	Pickup.PickupFunction(Player);
	if (Pickup.bActivatable && PlayerPawn(Player) == none)
		Pickup.Activate();
}

function float PlayerJumpZScaling()
{
	return Level.Game.PlayerJumpZScaling();
}

defaultproperties
{
	bNotifyLogin=True
	bNotifySpawnPoint=True
}
