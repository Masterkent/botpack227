//=============================================================================
// PerUnreal.
//=============================================================================

class PerUnreal expands Mutator;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var DeathMatchPlus MyGame;
var bool bCanClientFire;
var Weapon Affector;

function PostBeginPlay()
{
	MyGame = DeathMatchPlus(Level.Game);
	Super.PostBeginPlay();
}

function bool AlwaysKeep(Actor Other)
{
	if ( Other.IsA('StationaryPawn') )
		return true;

	if (NextMutator != none)
		return class'UTC_Mutator'.static.UTSF_AlwaysKeep(NextMutator, Other);
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local Inventory Inv;

	// replace Unreal I inventory actors by their Unreal Tournament equivalents
	// set bSuperRelevant to false if want the gameinfo's super.IsRelevant() function called
	// to check on relevancy of this actor.

	bSuperRelevant = 1;
	if ( MyGame.bMegaSpeed && Other.bIsPawn && Pawn(Other).bIsPlayer )
	{
		Pawn(Other).GroundSpeed *= 1.4;
		Pawn(Other).WaterSpeed *= 1.4;
		Pawn(Other).AirSpeed *= 1.4;
		Pawn(Other).AccelRate *= 1.4;
	}

	if ( Other.IsA('StationaryPawn') )
		return true;

	Inv = Inventory(Other);
 	if ( Inv == None )
	{
		bSuperRelevant = 0;
		return true;
	}

	if ( MyGame.bNoviceMode && MyGame.bRatedGame && (Level.NetMode == NM_Standalone) )
		Inv.RespawnTime *= (0.5 + 0.1 * MyGame.Difficulty);

	if ( Other.IsA('Weapon') )
                {
              	if ( Other.IsA('Enforcer') )
		{
			ReplaceWith(Other, "PerUnreal.PKmgun");
			return false;
		}
	if ( Other.IsA('UT_Biorifle') )
		{
			ReplaceWith(Other, "PerUnreal.Shotgun");
			return false;
		}
	 if ( Other.IsA('ShockRifle') )
		{
			ReplaceWith(Other, "PerUnreal.PKShockRifle");
			return false;
		}
	if ( Other.IsA('Pulsegun') )
		{
			ReplaceWith(Other, "PerUnreal.PKPulsegun");
			return false;
		}
                	if ( Other.IsA('Ripper') )
		{
			ReplaceWith(Other, "PerUnreal.RockLobber");
			return false;
		}
                	if ( Other.IsA('Minigun2') )
		{
			ReplaceWith(Other, "PerUnreal.Sixpack");
			return false;
		}
                	if ( Other.IsA('UT_FlakCannon') )
		{
			ReplaceWith(Other, "PerUnreal.PKFlakCannon");
			return false;
		}
                                if ( Other.IsA('UT_Eightball') )
		{
			ReplaceWith(Other, "PerUnreal.PKEightball");
			return false;
		}
                                if ( Other.IsA('SniperRifle') )
		{
			ReplaceWith(Other, "PerUnreal.PKSniperRifle");
			return false;
		}
//Original Unreal weapons
		if ( Other.IsA('Stinger') )
		{
			ReplaceWith(Other, "PerUnreal.PKPulseGun");
			return false;
		}
		if ( Other.IsA('Rifle') )
		{
			ReplaceWith( Other, "PerUnreal.PKSniperRifle" );
			return false;
		}
		if ( Other.IsA('Razorjack') )
		{
			ReplaceWith( Other, "PerUnreal.RockLobber" );
			return false;
		}
		if ( Other.IsA('Minigun') )
		{
			ReplaceWith( Other, "PerUnreal.Chaingun" );
			return false;
		}
		if ( Other.IsA('AutoMag') )
		{
			ReplaceWith( Other, "PerUnreal.PKmgun" );
			return false;
		}
		if ( Other.IsA('Eightball') )
		{
			ReplaceWith( Other, "PerUnreal.PKEightball" );
			return false;
		}
		if ( Other.IsA('FlakCannon') )
		{
			ReplaceWith( Other, "PerUnreal.PKFlakCannon" );
			return false;
		}
		if ( Other.IsA('ASMD') )
		{
			ReplaceWith( Other, "PerUnreal.PKShockRifle" );
			return false;
		}
		if ( Other.IsA('GesBioRifle') )
		{
			ReplaceWith( Other, "PerUnreal.Shotgun" );
			return false;
		}
		if ( Other.IsA('DispersionPistol') )
		{
			ReplaceWith( Other, "PerUnreal.PKmgun" );
			return false;
		}
                }
	if ( Other.IsA('Miniammo') )
	{
		ReplaceWith( Other, "PerUnreal.PKminiammo" );
		return false;
	}
	if ( Other.IsA('EClip') )
	{
		ReplaceWith( Other, "PerUnreal.PKSGAmmo" );
		return false;
	}
	if ( Other.IsA('bioammo') )
	{
		ReplaceWith( Other, "PerUnreal.PKSGAmmo" );
		return false;
	}
	if ( Other.IsA('ShockCore') )
	{
		ReplaceWith( Other, "PerUnreal.PKShockCore" );
		return false;
	}
	if ( Other.IsA('PAmmo') )
	{
		ReplaceWith( Other, "PerUnreal.PKPammo" );
		return false;
	}
	if ( Other.IsA('BladeHopper') )
	{
		ReplaceWith( Other, "PerUnreal.RockAmmo" );
		return false;
	}
	if ( Other.IsA('flakammo') )
	{
		ReplaceWith( Other, "PerUnreal.PKflakammo" );
		return false;
	}
	if ( Other.IsA('RocketPack') )
	{
		ReplaceWith( Other, "PerUnreal.PKRocketPack" );
		return false;
	}
	if ( Other.IsA('BulletBox') )
	{
		ReplaceWith( Other, "PerUnreal.PKBulletBox" );
		return false;
	}
	if ( Other.IsA('RifleShell') )
	{
		ReplaceWith( Other, "PerUnreal.PKRifleShell" );
		return false;
	}
//Original Unreal ammo
		if ( Other.IsA('ASMDAmmo') )
		{
			ReplaceWith( Other, "PerUnreal.PKShockCore" );
			return false;
		}
		if ( Other.IsA('RocketCan') )
		{
			ReplaceWith( Other, "PerUnreal.PKRocketPack" );
			return false;
		}
		if ( Other.IsA('StingerAmmo') )
		{
			ReplaceWith(Other, "PerUnreal.PKPAmmo");
			return false;
		}
		if ( Other.IsA('RazorAmmo') )
		{
			ReplaceWith( Other, "PerUnreal.RockAmmo" );
			return false;
		}
		if ( Other.IsA('RifleRound') )
		{
			ReplaceWith( Other, "PerUnreal.PKRifleShell" );
			return false;
		}
		if ( Other.IsA('RifleAmmo') )
		{
			ReplaceWith( Other, "PerUnreal.PKBulletBox" );
			return false;
		}
		if ( Other.IsA('FlakBox') )
		{
			ReplaceWith( Other, "PerUnreal.PKFlakAmmo" );
			return false;
		}
		if ( Other.IsA('Clip') )
		{
			ReplaceWith( Other, "PerUnreal.PKSGAmmo" );
			return false;
		}
		if ( Other.IsA('ShellBox') )
		{
			ReplaceWith( Other, "PerUnreal.PKMiniAmmo" );
			return false;
		}
		if ( Other.IsA('Sludge') )
		{
			ReplaceWith( Other, "PerUnreal.PKSGAmmo" );
			return false;
		}
	if ( Other.IsA('HealthVial') )
	{
		ReplaceWith( Other, "PerUnreal.PKHealthVial" );
		return false;
	}
	if ( Other.IsA('UDamage') )
	{
		ReplaceWith( Other, "PerUnreal.PKUDamage" );
		return false;
	}
//Original Unreal stuff
	if ( Other.IsA('JumpBoots') )
	{
		if ( MyGame.bJumpMatch )
			return false;
		ReplaceWith( Other, "Botpack.UT_JumpBoots" );
		return false;
	}
	if ( Other.IsA('Amplifier') )
	{
		ReplaceWith( Other, "PerUnreal.PKUDamage" );
		return false;
	}
	if ( Other.IsA('WeaponPowerUp') )
		return false;

	if ( Other.IsA('KevlarSuit') )
	{
		ReplaceWith( Other, "Botpack.ThighPads");
		return false;
	}
	if ( Other.IsA('SuperHealth') )
	{
		ReplaceWith( Other, "Botpack.HealthPack" );
		return false;
	}
	if ( Other.IsA('Armor') )
	{
		ReplaceWith( Other, "Botpack.Armor2" );
		return false;
	}
	if ( Other.IsA('Bandages') )
	{
		ReplaceWith( Other, "PerUnreal.HealthVial" );
		return false;
	}
	if ( Other.IsA('ShieldBelt') )
	{
		ReplaceWith( Other, "PerUnreal.PKShieldBelt" );
		return false;
	}
	if ( Other.IsA('UT_ShieldBelt') )
	{
		ReplaceWith( Other, "PerUnreal.PKShieldBelt" );
		return false;
	}
	if ( Other.IsA('Invisibility') )
	{
		ReplaceWith( Other, "Botpack.UT_Invisibility" );
		return false;
	}

	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
     DefaultWeapon=Class'PerUnreal.PKChainSaw'
}
