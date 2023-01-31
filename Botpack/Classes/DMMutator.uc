//=============================================================================
// DMMutator.
//=============================================================================

class DMMutator expands UTC_Mutator;

var DeathMatchPlus MyGame;

function PostBeginPlay()
{
	MyGame = DeathMatchPlus(Level.Game);
	B227_ModifyDefaultWeapon();
	Super.PostBeginPlay();
}

function bool AlwaysKeep(Actor Other)
{
	if (Other.IsA('StationaryPawn'))
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
	if ( MyGame != none && MyGame.bMegaSpeed && Other.bIsPawn && Pawn(Other).PlayerReplicationInfo != none )
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
		if ( Other.IsA('TorchFlame') )
			Other.NetUpdateFrequency = 0.5;
		return true;
	}

	if ( MyGame != none && MyGame.bNoviceMode && MyGame.bRatedGame && (Level.NetMode == NM_Standalone) )
		Inv.RespawnTime *= (0.5 + 0.1 * MyGame.Difficulty);

	if ( Other.IsA('Weapon') )
	{
		if ( Other.IsA('TournamentWeapon') )
			return true;

		if (class'B227_Config'.default.bLogNonUTInventory)
			log("Found "$Other$" at "$Other.location);
		//Assert(false);
		if ( Other.IsA('Stinger') )
		{
			ReplaceWith(Other, "Botpack.PulseGun");
			return false; 
		}
		if ( Other.IsA('Rifle') )
		{
			ReplaceWith( Other, "Botpack.SniperRifle" );
			return false;
		}
		if ( Other.IsA('RazorJack') )
		{
			ReplaceWith( Other, "Botpack.Ripper" );
			return false;
		}
		if ( Other.IsA('Minigun') )
		{
			ReplaceWith( Other, "Botpack.Minigun2" );
			return false;
		}
		if ( Other.IsA('AutoMag') )
		{
			ReplaceWith( Other, "Botpack.Enforcer" );
			return false;
		}
		if ( Other.IsA('Eightball') )
		{
			ReplaceWith( Other, "Botpack.UT_Eightball" );
			return false;
		}
		if ( Other.IsA('FlakCannon') )
		{
			ReplaceWith( Other, "Botpack.UT_FlakCannon" );
			return false;
		}
		if ( Other.IsA('ASMD') )
		{
			ReplaceWith( Other, "Botpack.ShockRifle" );
			return false;
		}
		if ( Other.IsA('GESBioRifle') )
		{
			ReplaceWith( Other, "Botpack.UT_BioRifle" );
			return false;
		}
		if ( Other.IsA('DispersionPistol') )
		{
			ReplaceWith( Other, "Botpack.ImpactHammer");
			return false;
		}
		if ( Other.IsA('UTranslocator') )
		{
			ReplaceWith( Other, "Botpack.Translocator");
			return false;
		}
		bSuperRelevant = 0;
		return true;
	}
	if (Ammo(Other) != none)
	{
		if ( Other.IsA('TournamentAmmo') )
			return true;

		if (class'B227_Config'.default.bLogNonUTInventory)
			log("Found "$Other$" at "$Other.location);
		//Assert(false);

		if ( Other.IsA('ASMDAmmo') )
		{
			ReplaceWith( Other, "Botpack.ShockCore" );
			return false;
		}
		if ( Other.IsA('RocketCan') )
		{
			ReplaceWith( Other, "Botpack.RocketPack" );
			return false;
		}
		if ( Other.IsA('StingerAmmo') )
		{
			ReplaceWith(Other, "Botpack.PAmmo");
			return false;
		}
		if ( Other.IsA('RazorAmmo') )
		{
			ReplaceWith( Other, "Botpack.BladeHopper" );
			return false;
		}
		if ( Other.IsA('RifleRound') )
		{
			ReplaceWith( Other, "Botpack.RifleShell" );
			return false;
		}
		if ( Other.IsA('RifleAmmo') )
		{
			ReplaceWith( Other, "Botpack.BulletBox" );
			return false;
		}
		if ( Other.IsA('FlakBox') )
		{
			if (Other.IsA('FlakShellAmmo') &&
				class'B227_Config'.default.bEnableExtensions &&
				class'B227_Config'.default.bUseFlakShellAmmo)
			{
				if (ReplaceWith(Other, "Botpack.B227_FlakShellAmmo") && UTC_Ammo(B227_ReplacingActor) != none)
					B227_ReplacingActor.SetRotation(B227_ReplacingActor.Rotation + rot(16384, 0, 0));
			}
			else
				ReplaceWith(Other, "Botpack.FlakAmmo");
			return false;
		}
		if ( Other.IsA('Clip') )
		{
			ReplaceWith( Other, "Botpack.EClip" );
			return false;
		}
		if ( Other.IsA('ShellBox') )
		{
			ReplaceWith( Other, "Botpack.MiniAmmo" );
			return false;
		}
		if ( Other.IsA('Sludge') )
		{
			ReplaceWith( Other, "Botpack.BioAmmo" );
			return false;
		}
		bSuperRelevant = 0;
		return true;
	}

	if (Pickup(Other) != none)
	{
		if (class'B227_Config'.default.bAutoActivatePickups &&
			!Pickup(Other).bCanHaveMultipleCopies &&
			!Other.IsA('ForceField') &&
			!Other.IsA('SCUBAGear') &&
			!Other.IsA('Translator') &&
			!Other.IsA('UPakScubaGear') &&
			!Other.IsA('VoiceBox'))
		{
			Pickup(Other).bAutoActivate = true;
		}
		if ( Other.IsA('TournamentPickup') )
			return true;
	}
	if ( Other.IsA('TournamentHealth') )
		return true;

	//Assert(false);

	if (Pickup(Other) != none)
	{
		if (class'B227_Config'.default.bLogNonUTInventory)
			log("Found "$Other$" at "$Other.location);
		if ( Other.IsA('JumpBoots') )
		{
			if (MyGame != none && MyGame.bJumpMatch)
				return false;
			if (ReplaceWith(Other, "Botpack.UT_JumpBoots") && UT_JumpBoots(B227_ReplacingActor) != none && Inventory(Other) != none)
				UT_JumpBoots(B227_ReplacingActor).Charge = Inventory(Other).Charge;
			return false;
		}
		if ( Other.IsA('Amplifier') )
		{
			ReplaceWith( Other, "Botpack.UDamage" );
			return false;
		}
		if ( Other.IsA('WeaponPowerUp') )
			return false; 

		if ( Other.IsA('KevlarSuit') )
		{
			ReplaceWith( Other, "Botpack.ThighPads");
			return false;
		}
		if (Other.Class == class'SuperHealth')
		{
			ReplaceWith( Other, "Botpack.HealthPack" );
			return false;
		}
		if ( Other.IsA('Armor') )
		{
			ReplaceWith( Other, "Botpack.Armor2" );
			return false;
		}
		if (Other.Class == class'Bandages')
		{
			ReplaceWith( Other, "Botpack.HealthVial" );
			return false;
		}
		///if ( Other.IsA('Health') && !Other.IsA('HealthPack') && !Other.IsA('HealthVial')
		///	 && !Other.IsA('MedBox') && !Other.IsA('NaliFruit') )
		if (Other.Class == class'Health')
		{
			ReplaceWith( Other, "Botpack.MedBox" );
			return false;
		}
		if ( Other.IsA('ShieldBelt') )
		{
			ReplaceWith( Other, "Botpack.UT_ShieldBelt" );
			return false;
		}
		if ( Other.IsA('Invisibility') )
		{
			ReplaceWith( Other, "Botpack.UT_Invisibility" );
			return false;
		}
	}

	bSuperRelevant = 0;
	return true;
}

function B227_ModifyDefaultWeapon()
{
	if (Level.Game.DefaultWeapon == none)
		return;
	if (ClassIsChildOf(Level.Game.DefaultWeapon, class'DispersionPistol'))
		Level.Game.DefaultWeapon = class'ImpactHammer';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'AutoMag'))
		Level.Game.DefaultWeapon = class'Enforcer';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'Stinger'))
		Level.Game.DefaultWeapon = class'PulseGun';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'ASMD'))
		Level.Game.DefaultWeapon = class'ShockRifle';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'EightBall'))
		Level.Game.DefaultWeapon = class'UT_EightBall';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'FlakCannon'))
		Level.Game.DefaultWeapon = class'UT_FlakCannon';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'RazorJack'))
		Level.Game.DefaultWeapon = class'Ripper';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'GESBioRifle'))
		Level.Game.DefaultWeapon = class'UT_BioRifle';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'Rifle'))
		Level.Game.DefaultWeapon = class'SniperRifle';
	else if (ClassIsChildOf(Level.Game.DefaultWeapon, class'Minigun'))
		Level.Game.DefaultWeapon = class'Minigun2';
}
