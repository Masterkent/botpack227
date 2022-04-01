//=============================================================================
// Arena.
// replaces all weapons and ammo
//=============================================================================

class Arena expands UTC_Mutator
	abstract;

var name WeaponName, AmmoName;
var string WeaponString, AmmoString;


// B227 addition
event PreBeginPlay()
{
	super.PreBeginPlay();
	if (DefaultWeapon != none)
		Level.Game.DefaultWeapon = DefaultWeapon;
}

function AddMutator(Mutator M)
{
	if ( M.IsA('Arena') )
	{
		log(M$" not allowed (already have an Arena mutator)");
		return; //only allow one arena mutator
	}
	Super.AddMutator(M);
}

function bool AlwaysKeep(Actor Other)
{
	if (WeaponName != '' && Weapon(Other) != none && Other.IsA(WeaponName))
	{
		if (Weapon(Other).AmmoName != none)
			Weapon(Other).PickupAmmoCount = Weapon(Other).AmmoName.default.MaxAmmo;
		return true;
	}
	if (AmmoName != '' && Ammo(Other) != none && Other.IsA(AmmoName))
	{
		Ammo(Other).AmmoAmount = Ammo(Other).MaxAmmo;
		return true;
	}

	if (NextMutator != none)
		return class'UTC_Mutator'.static.UTSF_AlwaysKeep(NextMutator, Other);
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Weapon(Other) != none)
	{
		if (DefaultWeapon != none && Other.Class == DefaultWeapon)
			return true;
		if (Len(WeaponString) == 0 || Len(WeaponName) == 0)
			return false;
		if (Len(WeaponString) > 0 && !Other.IsA(WeaponName))
		{
			Level.Game.bCoopWeaponMode = false;
			ReplaceWith(Other, WeaponString);
			return false;
		}
	}

	if (Ammo(Other) != none)
	{
		if (DefaultWeapon != none && Other.Class == DefaultWeapon.default.AmmoName)
			return true;
		if (Len(AmmoString) == 0 || Len(AmmoName) == 0)
			return false;
		else if (Len(AmmoString) > 0 && !Other.IsA(AmmoName))
		{
			ReplaceWith(Other, AmmoString);
			return false;
		}
	}

	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
}
