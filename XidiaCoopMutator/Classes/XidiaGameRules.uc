class XidiaGameRules expands GameRules;

var XidiaCoopMutator MutatorPtr;
var XidiaLevelInfo LInfo;

function PostBeginPlay()
{
	if (XidiaCoopMutator(Owner) == none)
	{
		log("WARNING: XidiaCoopMutator failed to create XidiaGameRules");
		Destroy();
		return;
	}
	MutatorPtr = XidiaCoopMutator(Owner);
}

function ModifyPlayer(Pawn Player)
{
	local int i;

	ModifyPlayerVoicePack(Player);
	GiveXidiaPlayerInteraction(Player);
	GiveXidiaUserUtils(Player);

	for (i = 0; i < ArrayCount(LInfo.DefaultInventory); ++i)
	{
		if (LInfo.DefaultInventory[i] == none)
			continue;
		if (LInfo.DefaultInventory[i] == class'Translator')
			continue;
		if (classisChildOf(LInfo.DefaultInventory[i], class'Weapon'))
		{
			if (MutatorPtr.bUseXidiaWeaponsSupply)
				GiveWeapon(class<Weapon>(LInfo.DefaultInventory[i]), Player);
		}
		else if (classisChildOf(LInfo.DefaultInventory[i], class'Pickup'))
			GivePickup(class<pickup>(LInfo.DefaultInventory[i]), Player);
	}

	for (i = 0; i < ArrayCount(LInfo.InventoryToDestroy); ++i)
		if (LInfo.InventoryToDestroy[i] != none)
			DestroyPlayerInventory(Player, LInfo.InventoryToDestroy[i]);

	if (MutatorPtr.bGiveXidiaJumpBoots)
		GiveXidiaJumpBoots(Player);
}

function GiveXidiaJumpBoots(Pawn Player)
{
	local Pickup JumpBoots;

	JumpBoots = GivePickup(class'XidiaJumpBoots', Player);
	if (JumpBoots != none)
		JumpBoots.bTravel = false;
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
				Player.PlayerReplicationInfo.VoiceType = class'XidiaNaliVoice';
			else if (Player.Mesh.Name == 'sktrooper' || Player.Mesh.Name == 'TSkM')
				Player.PlayerReplicationInfo.VoiceType = class'XidiaSkaarjVoice';
			else if (Player.Mesh.Name == 'Male1' || Player.Mesh.Name == 'Commando')
				Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleOne';
			else
				Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleTwo';
		}
	}
}

function GiveXidiaPlayerInteraction(Pawn Player)
{
	local XidiaPlayerInteraction PlayerInteraction;

	foreach Player.ChildActors(class'XidiaPlayerInteraction', PlayerInteraction)
		break;
	if (PlayerInteraction == none)
		PlayerInteraction = Player.Spawn(class'XidiaPlayerInteraction', Player);
}

function GiveXidiaUserUtils(Pawn Player)
{
	local Inventory Inv;

	if (!MutatorPtr.bUseSpeechMenuForU1Players ||
		PlayerPawn(Player) == none)
	{
		return;
	}

	for (Inv = Player.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.Class == class'XidiaUserUtils' && !Inv.bDeleteMe)
			return;
	Inv = Spawn(class'XidiaUserUtils', Player);
	if (Inv != none)
		Inv.GiveTo(Player);
}

function Pickup GivePickup(class<Pickup> PickupClass, Pawn Player)
{
	local Pickup Pickup;

	if (FindInventoryType(Player, PickupClass) != none)
		return none;
	Pickup = Player.Spawn(PickupClass);
	if (Pickup == none)
		return none;
	Pickup.bHeldItem = true;
	Pickup.GiveTo(Player);
	if (Pickup.bActivatable && Player.SelectedItem == none)
		Player.SelectedItem = Pickup;
	Pickup.PickupFunction(Player);
	if (Pickup.bActivatable && PlayerPawn(Player) == none)
		Pickup.Activate();
	return Pickup;
}

function GiveWeapon(class<Weapon> WeapClass, Pawn PlayerPawn)
{
	local Weapon Weapon;

	Weapon = Weapon(FindInventoryType(PlayerPawn, WeapClass));
	if (Weapon != none)
	{
		if (WeapClass == class'XidiaAutoMag' && LInfo.bAkimboMags)
			XidiaAutoMag(Weapon).HasTwoMag = true;
		return;
	}

	Weapon = PlayerPawn.Spawn(WeapClass,,, PlayerPawn.Location);
	if (Weapon == None)
		return;
	Weapon.Instigator = PlayerPawn;
	Weapon.BecomeItem();

	if (Weapon.AmmoName != none && Weapon.AmmoName.default.AmmoAmount > 0)
		Weapon.PickupAmmoCount += Weapon.AmmoName.default.AmmoAmount;

	PlayerPawn.AddInventory(Weapon);
	if (Weapon.IsA('XidiaAutoMag') && LInfo.bAkimboMags)
	{
		XidiaAutoMag(Weapon).HasTwoMag = true;
		Weapon.TravelPostAccept();
	}
	Weapon.BringUp();
	Weapon.GiveAmmo(PlayerPawn);
	Weapon.SetSwitchPriority(PlayerPawn);
	Weapon.WeaponSet(PlayerPawn);
}

function DestroyPlayerInventory(Pawn P, class<Inventory> InvClass)
{
	local Inventory Inv;

	Inv = FindInventoryType(P, InvClass);
	if (Inv != none)
		Inv.Destroy();
}

function Inventory FindInventoryType(Pawn P, class<Inventory> DesiredClass)
{
	local Inventory Inv;

	for (Inv = P.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.Class == DesiredClass)
			return Inv;
	return none;
}

function ModifyDamage(Pawn Injured, Pawn EventInstigator, out int Damage, vector HitLocation, name DamageType, out vector Momentum)
{
	local XidiaSafeFall XidiaSafeFall;

	if (DamageType != 'fell')
		return;
	foreach Injured.TouchingActors(class'XidiaSafeFall', XidiaSafeFall)
	{
		Damage = 0;
		return;
	}
}

function float PlayerJumpZScaling()
{
	return Level.Game.PlayerJumpZScaling();
}

defaultproperties
{
	bModifyDamage=True
	bNotifyLogin=True
	bNotifySpawnPoint=True
}
