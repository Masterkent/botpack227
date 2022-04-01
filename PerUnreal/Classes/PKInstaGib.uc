//=============================================================================
// InstaGibDM.
// The ultimate skill test.
//=============================================================================

class PKInstaGib expands Arena;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if ( Other.IsA('TournamentHealth') || Other.IsA('PKShieldbelt')
		|| Other.IsA('Armor2') || Other.IsA('ThighPads')
		|| Other.IsA('UT_Invisibility') || Other.IsA('PKUDamage') )
		return false;

	return Super.CheckReplacement( Other, bSuperRelevant );
/*
	if ( Other.IsA('Weapon') )
		if ((WeaponString != "") && !Other.IsA(WeaponName))
			return false;

	if ( Other.IsA('Ammo') )
	{
		if ((AmmoString != "") && !Other.IsA(AmmoName))
			ReplaceWith(Other, AmmoString);
		return false;
	}

	bSuperRelevant = 0;
	return true;
*/
}

defaultproperties
{
     WeaponName=PKSuperShockRifle
     AmmoName=SuperShockCore
     DefaultWeapon=Class'PerUnreal.PKSuperShockRifle'
}
