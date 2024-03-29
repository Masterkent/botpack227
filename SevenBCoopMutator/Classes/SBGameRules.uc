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
	GiveWeaponsSupply(Player);
}

function ModifyPlayerVoicePack(Pawn Player)
{
	if (Player.PlayerReplicationInfo.VoiceType == None)
		Player.PlayerReplicationInfo.VoiceType = Player.VoiceType;

	if (Player.PlayerReplicationInfo.VoiceType == None)
	{
		if (UTC_PlayerPawn(Player) != none)
		{
			Player.PlayerReplicationInfo.VoiceType = class'UTC_PlayerPawn'.static.B227_GetVoiceType(PlayerPawn(Player));
			if (Player.PlayerReplicationInfo.VoiceType != none)
				return;
		}
		if (Player.PlayerReplicationInfo.bIsFemale)
		{
			if (Player.Mesh == none)
				Player.PlayerReplicationInfo.VoiceType = class'VoiceFemaleTwo';
			else if (Player.Mesh.Name == 'Female1' || Player.Mesh.Name == 'FCommando')
				Player.PlayerReplicationInfo.VoiceType = class'VoiceFemaleOne';
			else
				Player.PlayerReplicationInfo.VoiceType = class'VoiceFemaleTwo';
		}
		else
		{
			if (Player.Mesh == none)
				Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleTwo';
			else if (Player.Mesh.Name == 'Nali2' || Player.Mesh.Name == 'TNaliMesh')
				Player.PlayerReplicationInfo.VoiceType = class'NaliVoice';
			else if (Player.Mesh.Name == 'sktrooper' || Player.Mesh.Name == 'TSkM')
				Player.PlayerReplicationInfo.VoiceType = class'SkaarjVoice';
			else if (Player.Mesh.Name == 'Male1' || Player.Mesh.Name == 'Commando')
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

function GiveWeaponsSupply(Pawn Player)
{
	if (!MutatorPtr.bUseWeaponsSupply)
		return;

	if (MutatorPtr.CurrentMap ~= "Jones-02-Darkness")
		GiveNewWeapon(class'SevenB.SevenShockRifle', Player);
	else if (MutatorPtr.CurrentMap ~= "Jones-05-TemplePart2")
	{
		GiveNewWeapon(class'SevenB.SevenMachineMag', Player);
		GiveNewWeapon(class'SevenB.SevenPulseGun', Player);
	}
	else if (MutatorPtr.CurrentMap ~= "Jones-06-Vandora")
		GiveNewWeapon(class'SevenB.SevenShockRifle', Player);
	else if (MutatorPtr.CurrentMap ~= "Jones-07-Noork")
	{
		GiveNewWeapon(class'SevenB.SevenPulseGun', Player);
		GiveNewWeapon(class'SevenB.SBBloodRipper', Player);
	}
	else if (MutatorPtr.CurrentMap ~= "Jones-08-Pirate")
	{
		GiveNewWeapon(class'SevenB.SevenShockRifle', Player);
		GiveNewWeapon(class'SevenB.SBquadshot', Player);
		GiveNewWeapon(class'SevenB.SevenPulseGun', Player);
		GiveNewWeapon(class'SevenB.SevenSniperRifle', Player);
	}
	else if (MutatorPtr.CurrentMap ~= "Jones-08-Pirate2")
		GiveNewWeapon(class'SevenB.SevenSniperRifle', Player);
	else if (MutatorPtr.CurrentMap ~= "Jones-08-Pirate3")
		GiveNewWeapon(class'SevenB.SevenSniperRifle', Player);
}

function GiveNewWeapon(class<Weapon> WeapClass, Pawn Player)
{
	local Inventory Inv;

	for (Inv = Player.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.Class == WeapClass)
			return;
	GiveWeapon(WeapClass, Player);
}

function GiveWeapon(class<Weapon> WeapClass, Pawn Player)
{
	local Weapon NewWeapon;

	NewWeapon = Player.Spawn(WeapClass);
	if (NewWeapon == None)
		return;
	NewWeapon.Instigator = Player;
	NewWeapon.BecomeItem();

	if (NewWeapon.AmmoName != none && NewWeapon.AmmoName.default.AmmoAmount > 0)
		NewWeapon.PickupAmmoCount += NewWeapon.AmmoName.default.AmmoAmount;

	Player.AddInventory(NewWeapon);
	if (SevenMachineMag(NewWeapon) != none)
	{
		SevenMachineMag(NewWeapon).HasTwoMag = true;
		NewWeapon.TravelPostAccept();
	}
	NewWeapon.BringUp();
	NewWeapon.GiveAmmo(Player);
	NewWeapon.SetSwitchPriority(Player);
	NewWeapon.WeaponSet(Player);
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
