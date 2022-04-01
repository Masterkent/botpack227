//=============================================================================
// LastManStanding.
//=============================================================================
class PKLastManStanding extends LastManStanding
	config;

var(Sounds) sound 	PKTeleSound[5];

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
 	local UTTeleportEffect PTE;
 	local int rnd;

	rnd = Rand(5);

	if ( bRequireReady && (Countdown > 0) )
		return;

	if ( Incoming.bIsPawn && (Incoming.Mesh != None) )
	{
		if ( bSound )
		{
 			PTE = Spawn(class'UTTeleportEffect',Incoming,, Incoming.Location, Incoming.Rotation);
 			PTE.Initialize(Pawn(Incoming), bOut);
			PTE.PlaySound(PKTeleSound[rnd],,,,,0.9+0.2*FRand());
		}
	}
}

function AddDefaultInventory( pawn PlayerPawn )
{
	local Weapon weap;
	local inventory Inv;
	local float F;

	if ( PlayerPawn.IsA('Spectator') || (bRequireReady && (CountDown > 0)) )
		return;
	Super.AddDefaultInventory(PlayerPawn);

	GiveWeapon(PlayerPawn, "PerUnreal.PKMgun");
	GiveWeapon(PlayerPawn, "PerUnreal.PKShockRifle");
	GiveWeapon(PlayerPawn, "PerUnreal.RockLobber");
	GiveWeapon(PlayerPawn, "PerUnreal.PKFlakCannon");

	if ( PlayerPawn.IsA('PlayerPawn') )
	{
		GiveWeapon(PlayerPawn, "PerUnreal.PKSniperRifle");
		GiveWeapon(PlayerPawn, "PerUnreal.PKPulseGun");
		GiveWeapon(PlayerPawn, "PerUnreal.PKMinigun");
		GiveWeapon(PlayerPawn, "PerUnreal.PKEightball");
		PlayerPawn.SwitchToBestWeapon();
	}
	else
	{
		// randomize order for bots so they don't always use the same weapon
		F = FRand();
		if ( F < 0.7 )
		{
			GiveWeapon(PlayerPawn, "PerUnreal.PKSniperRifle");
			GiveWeapon(PlayerPawn, "PerUnreal.PKPulseGun");
			if ( F < 0.4 )
			{
				GiveWeapon(PlayerPawn, "PerUnreal.PKMinigun");
				GiveWeapon(PlayerPawn, "PerUnreal.PKEightball");
			}
			else
			{
				GiveWeapon(PlayerPawn, "PerUnreal.PKEightball");
				GiveWeapon(PlayerPawn, "PerUnreal.PKMinigun");
			}
		}
		else
		{
			GiveWeapon(PlayerPawn, "PerUnreal.PKMinigun");
			GiveWeapon(PlayerPawn, "PerUnreal.PKEightball");
			if ( F < 0.88 )
			{
				GiveWeapon(PlayerPawn, "PerUnreal.PKSniperRifle");
				GiveWeapon(PlayerPawn, "PerUnreal.PKPulseGun");
			}
			else
			{
				GiveWeapon(PlayerPawn, "PerUnreal.PKPulseGun");
				GiveWeapon(PlayerPawn, "PerUnreal.PKSniperRifle");
			}
		}
	}

	for ( inv=PlayerPawn.inventory; inv!=None; inv=inv.inventory )
	{
		weap = Weapon(inv);
		if ( (weap != None) && (weap.AmmoType != None) )
			weap.AmmoType.AmmoAmount = weap.AmmoType.MaxAmmo;
	}

	inv = Spawn(class'Armor2');
	if( inv != None )
	{
		inv.bHeldItem = true;
		inv.RespawnTime = 0.0;
		inv.GiveTo(PlayerPawn);
	}
}

function SendStartMessage(PlayerPawn P)
{
	P.ClearProgressMessages();
	P.SetProgressMessage(StartMessage, 0);
	class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, class'PKStartMessage');
}

defaultproperties
{
     PKTeleSound(0)=Sound'PerUnreal.Misc.PKtele1'
     PKTeleSound(1)=Sound'PerUnreal.Misc.PKtele2'
     PKTeleSound(2)=Sound'PerUnreal.Misc.PKtele3'
     PKTeleSound(3)=Sound'PerUnreal.Misc.PKtele4'
     PKTeleSound(4)=Sound'PerUnreal.Misc.PKtele5'
     GameName="PerUnreal Last Man Standing"
     DeathMessageClass=Class'PerUnreal.PKDeathMessagePlus'
     MutatorClass=Class'PerUnreal.PerUnreal'
}
