class UnOldskool expands UTC_Mutator;

var const string VersionInfo;
var const string Version;

event BeginPlay()
{
	local Ammo Ammo;
	local Decoration Deco;
	local Pawn Pawn;
	local ThingFactory ThingFactory;

	foreach AllActors(class'Ammo', Ammo)
		AdjustAmmo(Ammo);

	foreach AllActors(class'Decoration', Deco)
		AdjustDecoration(Deco);

	foreach AllActors(class'Pawn', Pawn)
		AdjustPawn(Pawn);

	foreach AllActors(class'ThingFactory', ThingFactory)
		AdjustThingFactory(ThingFactory);
}

function bool CheckReplacement(Actor A, out byte bSuperRelevant)
{
	if (Inventory(A) != none)
		return InventoryReplacement(Inventory(A));
	return true;
}

function class<Actor> ReplaceActorClass(class<Actor> ActorClass)
{
	if (ActorClass == none)
		return none;
	if (ClassIsChildOf(ActorClass, class'Inventory'))
		return ReplaceInventoryClass(class<Inventory>(ActorClass));
	return ActorClass;
}

function ReplaceActorClassInPlace(out class<Actor> ActorClass)
{
	ActorClass = ReplaceActorClass(ActorClass);
}

function class<Inventory> ReplaceInventoryClass(class<Inventory> InvClass)
{
	if (InvClass == none)
		return none;
	if (ClassIsChildOf(InvClass, class'Pickup'))
		return ReplacePickupClass(class<Pickup>(InvClass));
	if (ClassIsChildOf(InvClass, class'Weapon'))
		return ReplaceWeaponClass(class<Weapon>(InvClass));
	return InvClass;
}

function ReplaceInventoryClassInPlace(out class<Inventory> InvClass)
{
	InvClass = ReplaceInventoryClass(InvClass);
}

function class<Pickup> ReplacePickupClass(class<Pickup> PickupClass)
{
	if (ClassIsChildOf(PickupClass, class'Ammo'))
		return PickupClass;
	switch (PickupClass)
	{
		case class'olweapons.osamplifier':
			return class'Amplifier';
		case class'olWeapons.OsDispersionpowerup':
			return class'WeaponPowerUp';
		case class'olweapons.osShieldBelt':
			return class'ShieldBelt';
		case class'olweapons.ospowershield':
			return class'PowerShield';
	}
	return PickupClass;
}

function class<Weapon> ReplaceWeaponClass(class<Weapon> WeaponClass)
{
	switch (WeaponClass)
	{
		case class'olweapons.OSPulseGun':
			return class'Botpack.PulseGun';
		case class'olweapons.osShockRifle':
			return class'Botpack.ShockRifle';
		case class'olweapons.olstinger':
			return class'Stinger';
		case class'olweapons.olRifle':
			return class'Rifle';
		case class'olweapons.olrazorjack':
			return class'Razorjack';
		case class'olweapons.olquadshot':
			return class'QuadShot';
		case class'olweapons.olMinigun':
			return class'Minigun';
		case class'olweapons.olautomag':
			return class'AutoMag';
		case class'olweapons.olEightball':
			return class'EightBall';
		case class'olweapons.olFlakCannon':
			return class'FlakCannon';
		case class'olweapons.olasmd':
			return class'ASMD';
		case class'olweapons.olgesBioRifle':
			return class'GESBioRifle';
		case class'olweapons.oldpistol':
			return class'DispersionPistol';
	}
	return WeaponClass;
}

function ReplaceWeaponClassInPlace(out class<Weapon> WeaponClass)
{
	WeaponClass = ReplaceWeaponClass(WeaponClass);
}

function class<Actor> ReplaceProjectileClass(class<Actor> ProjClass)
{
	switch (ProjClass)
	{
		case class'oldskool.olBruteProjectile':
			return class'UnrealShare.BruteProjectile';
		case class'oldskool.olmercrocket':
			return class'UnrealI.MercRocket';
		case class'oldskool.olGasBagBelch':
			return class'UnrealI.GasBagBelch';
		case class'oldskool.olkraalbolt':
			return class'UnrealI.KraalBolt';
		case class'oldskool.ol1337krallbolt':
			return class'UnrealI.EliteKrallBolt';
		case class'oldskool.olskaarjprojectile':
			return class'Unrealshare.SkaarjProjectile';
		case class'oldskool.olqueenprojectile':
			return class'Unreali.QueenProjectile';
		case class'oldskool.oltentacleprojectile':
			return class'Unrealshare.TentacleProjectile';
		case class'oldskool.olSlithProjectile':
			return class'UnrealShare.SlithProjectile';
		case class 'oldskool.olwarlordrocket':
			return class'UnrealI.WarlordRocket';
	}
	return ProjClass;
}

function AdjustPawn(Pawn P)
{
	local ScriptedPawn ScriptedPawn;

	ReplaceInventoryClassInPlace(P.DropWhenKilled);

	ScriptedPawn = ScriptedPawn(P);
	if (ScriptedPawn != none)
	{
		ScriptedPawn.RangedProjectile = ReplaceProjectileClass(ScriptedPawn.RangedProjectile);
		if (ScriptedPawn.CarcassType == class'olCreatureCarcass')
			ScriptedPawn.CarcassType = ScriptedPawn.default.CarcassType;
		if (SkaarjTrooper(P) != none)
			AdjustSkaarjTrooperWeaponType(SkaarjTrooper(P));
	}
}

function AdjustSkaarjTrooperWeaponType(SkaarjTrooper P)
{
	ReplaceWeaponClassInPlace(P.WeaponType);
}

function AdjustAmmo(Ammo Ammo)
{
	if (Ammo.default.PickupSound == sound'UnrealShare.Pickups.AmmoSnd' &&
		Ammo.PickupSound == sound'BotPack.Pickups.AmmoPick')
	{
		Ammo.PickupSound = Ammo.default.PickupSound;
	}
}

function AdjustDecoration(Decoration Deco)
{
	ReplaceActorClassInPlace(Deco.Contents);
	ReplaceActorClassInPlace(Deco.Content2);
	ReplaceActorClassInPlace(Deco.Content3);
}

function AdjustThingFactory(ThingFactory Factory)
{
	ReplaceActorClassInPlace(Factory.prototype);
}

// Returns true if no replacement or removal should be done
function bool InventoryReplacement(Inventory Inv)
{
	local class<Inventory> NewInvClass;

	NewInvClass = ReplaceInventoryClass(Inv.Class);
	if (NewInvClass == none)
		return false;
	else if (NewInvClass != Inv.Class)
		return !B227_ReplaceWith(Inv, NewInvClass);
	return true;
}

function string GetHumanName()
{
	return "UnOldskool v1.0";
}

defaultproperties
{
	VersionInfo="UnOldskool v1.0 [2022-07-04]"
	Version="1.0"
}
