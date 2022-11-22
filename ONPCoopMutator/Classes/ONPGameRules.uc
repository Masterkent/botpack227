class ONPGameRules expands GameRules;

var ONPCoopMutator MutatorPtr;
var ONPLevelInfo LInfo;

function PostBeginPlay()
{
	if (ONPCoopMutator(Owner) == none)
	{
		log("WARNING: ONPCoopMutator failed to create ONPGameRules");
		Destroy();
		return;
	}
	MutatorPtr = ONPCoopMutator(Owner);

	if (MutatorPtr.WeaponReplacementMode ~= "ONP")
		Level.Game.DefaultWeapon = class'olextras.NoammoDpistol';
	if (MutatorPtr.bUseONPHUD)
		Level.Game.HUDType = class'olextras.TVHUD';
}

function ModifyPlayerSpawnClass(string Options, out Class<PlayerPawn> PlayerClass)
{
	if (ClassIsChildOf(PlayerClass, class'Spectator'))
		return;
	if (MutatorPtr.bUseONPPlayerPawnType || MutatorPtr.bUseAircraftLevels && MutatorPtr.IsAircraftLevel())
		PlayerClass = class'ONPPlayerPawn';
}

function ModifyPlayer(Pawn PlayerPawn)
{
	local inventory inv;
	local int i;
	local byte PlayerHas[20];

	if (MutatorPtr.bDebugMode)
		log("ONPGameRules: ModifyPlayer:" @ PlayerPawn);

	if (PlayerPawn.PlayerReplicationInfo == none || PlayerPawn.PlayerReplicationInfo.bIsSpectator)
		return;

	ModifyPlayerVoicePack(PlayerPawn);
	CreateONPPlayerController(PlayerPawn);
	GiveONPPlayerInteraction(PlayerPawn);
	GiveONPUserUtils(PlayerPawn);

	if (LInfo == none)
	{
		if (MutatorPtr.bDebugMode)
			log("WARNING: ONPGameRules: ModifyPlayer: LInfo == none, returing...");
		return;
	}

	if (PlayerPawn.IsA('Spectator'))
	{
		if (MutatorPtr.bDebugMode)
			log("ONPGameRules: ModifyPlayer:" @ PlayerPawn @ "is a spectator, returning...");
		return;
	}

	if (tvplayer(PlayerPawn) != none)
		tvplayer(PlayerPawn).Linfo = Linfo;

	if (MutatorPtr.bDebugMode)
		log("ONPGameRules: ModifyPlayer: modifying player inventory...");

	for (inv = PlayerPawn.inventory; inv != none; inv = inv.inventory)
		for (i = 0; i < ArrayCount(Linfo.DefaultInventory); ++i)
		{
			if (i > 7 && Linfo.DefaultInventory[i] == none)
				break;
			else if (Linfo.DefaultInventory[i] == inv.class)
			{
				PlayerHas[i] = 1;
				if (inv.class == class'spenf' && Linfo.bAkimboEnforcers)
					SpEnf(inv).hastwoenf = true; //post accept reads this :)
			}
		}

	for (i = 0; i < ArrayCount(LInfo.DefaultInventory); ++i)
	{     //add
		if (Linfo.DefaultInventory[i]==none)
			break;
		if (PlayerHas[i] == 1 || Linfo.NetOptions[i] % 2 == 1)
			continue;
		if (Linfo.DefaultInventory[i] == class'Translator' && !MutatorPtr.bUseONPHUD)
			continue;
		if (classisChildOf(LInfo.defaultInventory[i], class'weapon'))
		{
			if (MutatorPtr.bUseONPWeaponsSupply ||
				LInfo.defaultInventory[i] == class'olextras.TvTranslocator' ||
				LInfo.defaultInventory[i] == class'ONPTranslocator')
			{
				GiveWeapon(class<weapon>(LInfo.defaultInventory[i]), PlayerPawn);
			}
		}
		else if (classisChildOf(LInfo.defaultInventory[i], class'pickup'))
			GivePickup(class<pickup>(LInfo.defaultInventory[i]),PlayerPawn);
	}

	if (MutatorPtr.bDebugMode)
		log("ONPGameRules: ModifyPlayer: modifying player inventory succeeded, returning...");
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
				Player.PlayerReplicationInfo.VoiceType = class'ONPNaliVoice';
			else if (Player.Mesh == mesh'UnrealI.sktrooper')
				Player.PlayerReplicationInfo.VoiceType = class'ONPSkaarjVoice';
			else if (Player.Mesh == mesh'UnrealI.Male1')
				Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleOne';
			else
				Player.PlayerReplicationInfo.VoiceType = class'VoiceMaleTwo';
		}
	}
}

function GiveONPPlayerInteraction(Pawn Player)
{
	local ONPPlayerInteraction PlayerInteraction;

	foreach Player.ChildActors(class'ONPPlayerInteraction', PlayerInteraction)
		break;
	if (PlayerInteraction == none)
		Player.Spawn(class'ONPPlayerInteraction', Player);
}

function GiveONPUserUtils(Pawn Player)
{
	local Inventory Inv;

	if (!MutatorPtr.bUseSpeechMenuForU1Players ||
		PlayerPawn(Player) == none)
	{
		return;
	}

	for (Inv = Player.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.Class == class'ONPUserUtils' && !Inv.bDeleteMe)
			return;
	Inv = Spawn(class'ONPUserUtils', Player);
	if (Inv != none)
		Inv.GiveTo(Player);
}

function CreateONPPlayerController(Pawn Player)
{
	local ONPPlayerController Controller;

	foreach AllActors(class'ONPPlayerController', Controller)
		if (Controller.Owner == Player)
			return;

	Spawn(class'ONPPlayerController', Player).Initialize(MutatorPtr, self);
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
	if (Pickup.IsA('TvTranslator') || Pickup.bActivatable && Player.SelectedItem == none)
		Player.SelectedItem = Pickup;
	Pickup.PickupFunction(Player);
	if (Pickup.bActivatable && PlayerPawn(Player) == none)
		Pickup.Activate();
}

function GiveWeapon(class<weapon> WeapClass, pawn PlayerPawn)
{
	local weapon newWeapon;

	newWeapon = PlayerPawn.Spawn(WeapClass,,, PlayerPawn.Location);
	if (newWeapon == None)
		return;
	newWeapon.Instigator = PlayerPawn;
	newWeapon.BecomeItem();

	if (newWeapon.AmmoName != none && newWeapon.AmmoName.default.AmmoAmount > 0)
		newWeapon.PickupAmmoCount += newWeapon.AmmoName.default.AmmoAmount;

	PlayerPawn.AddInventory(newWeapon);
	if (newWeapon.IsA('spenf') && LInfo.bAkimboEnforcers)
	{
		spenf(newweapon).hastwoenf = true;
		newweapon.travelpostaccept();
	}
	newWeapon.BringUp();
	newWeapon.GiveAmmo(PlayerPawn);
	newWeapon.SetSwitchPriority(PlayerPawn);
	newWeapon.WeaponSet(PlayerPawn);
}

//called by muty.
function RegisterONPLevelInfo(actor newinfo)
{
	Linfo=ONPLevelInfo(newinfo);
	///brestartlevel=!Linfo.RespawnPlayer;
	log ("Successfully bound level information",'ONP');
}

function bool PreventDeath(Pawn P, Pawn Killer, name DamageType)
{
	return MutatorPtr.bPreventFallingOutOfWorld &&
		PlayerPawn(P) != none &&
		P.Region.ZoneNumber == 0 &&
		MoveToNearestNavPoint(P);
}

function bool MoveToNearestNavPoint(Pawn P)
{
	local NavigationPoint NavPoint, BestNavPoint;
	local float Dist, BestDist;
	local bool bCollideActors;
	local bool bBlockActors;
	local bool bBlockPlayers;
	local bool bMoved;

	BestDist = 256;

	for (NavPoint = Level.NavigationPointList; NavPoint != none; NavPoint = NavPoint.nextNavigationPoint)
		if (NavPoint.Class == class'NavigationPoint' ||
			PathNode(NavPoint) != none ||
			AlarmPoint(NavPoint) != none ||
			PatrolPoint(NavPoint) != none)
		{
			Dist = VSize(NavPoint.Location - P.Location);
			if (Dist < BestDist)
			{
				BestNavPoint = NavPoint;
				BestDist = Dist;
			}
		}

	if (BestNavPoint == none)
		return false;

	bCollideActors = P.bCollideActors;
	bBlockActors = P.bBlockActors;
	bBlockPlayers = P.bBlockPlayers;
	P.SetCollision(false, false, false);
	bMoved = P.SetLocation(BestNavPoint.Location);
	if (bMoved)
		P.SetPhysics(PHYS_Falling);
	P.SetCollision(bCollideActors, bBlockActors, bBlockPlayers);

	return bMoved;
}

function float PlayerJumpZScaling()
{
	return Level.Game.PlayerJumpZScaling();
}

defaultproperties
{
	bHandleDeaths=True
	bNotifyLogin=True
	bNotifySpawnPoint=True
}
