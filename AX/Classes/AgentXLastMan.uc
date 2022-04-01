//=============================================================================
// LastManStanding.
//=============================================================================
class AgentXLastMan extends LastManStanding;



function AddDefaultInventory( pawn PlayerPawn )
{
	local Weapon weap;
	local inventory Inv;
	local float F;

	if ( PlayerPawn.IsA('Spectator') || (bRequireReady && (CountDown > 0)) )
		return;
	Super.AddDefaultInventory(PlayerPawn);

	GiveWeapon(PlayerPawn, "AX.ppk");
	GiveWeapon(PlayerPawn, "AX.Asm4");
	GiveWeapon(PlayerPawn, "AX.Famasg2");
	GiveWeapon(PlayerPawn, "AX.ak47");
        GiveWeapon(PlayerPawn, "AX.ppk");


	if ( PlayerPawn.IsA('PlayerPawn') )
	{
		GiveWeapon(PlayerPawn, "ax.Sniper");
		GiveWeapon(PlayerPawn, "AX.shottie");
		GiveWeapon(PlayerPawn, "AX.famasg2");

		PlayerPawn.SwitchToBestWeapon();
	}
	else
	{
		// randomize order for bots so they don't always use the same weapon
		F = FRand();
		if ( F < 0.7 )
		{
			GiveWeapon(PlayerPawn, "AX.Sniper");
			GiveWeapon(PlayerPawn, "AX.famasg2");
			if ( F < 0.4 )
			{
				GiveWeapon(PlayerPawn, "AX.shottie");
				GiveWeapon(PlayerPawn, "AX.famasg2");
			}
			else
			{
				GiveWeapon(PlayerPawn, "AX.famasg2");
				GiveWeapon(PlayerPawn, "AX.sniper");
			}
		}
		else
		{
			GiveWeapon(PlayerPawn, "Ax.asm4");
			GiveWeapon(PlayerPawn, "AX.shottie");
			if ( F < 0.88 )
			{
				GiveWeapon(PlayerPawn, "AX.famasg2");
				GiveWeapon(PlayerPawn, "AX.ppk");
			}
			else
			{
				GiveWeapon(PlayerPawn, "AX.ppk");
				GiveWeapon(PlayerPawn, "AX.shottie");
			}
		}
	}

	for ( inv=PlayerPawn.inventory; inv!=None; inv=inv.inventory )
	{
		weap = Weapon(inv);
		if ( (weap != None) && (weap.AmmoType != None) )
			weap.AmmoType.AmmoAmount = weap.AmmoType.MaxAmmo;
	}

	inv = Spawn(class'AXkevlar');
	if( inv != None )
	{
		inv.bHeldItem = true;
		inv.RespawnTime = 0.0;
		inv.GiveTo(PlayerPawn);
	}
}

defaultproperties
{
     HUDType=Class'AX.axHUD'
     GameName="AgentX Last Man Standing"
     MutatorClass=Class'AX.AgentXArena'
}
