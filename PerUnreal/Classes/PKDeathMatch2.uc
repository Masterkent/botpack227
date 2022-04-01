//=============================================================================
// DeathMatch.
//=============================================================================
class PKDeathMatch2 extends DeathMatchPlus
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
	local Weapon NewWeapon;
	local Bot B;

	if ( PlayerPawn.IsA('Spectator') || (bRequireReady && (CountDown > 0)) )
		return;

	// Spawn Automag
	GiveWeapon(PlayerPawn, "PerUnreal.PKMgun");

	Super.AddDefaultInventory(PlayerPawn);

	if ( bUseTranslocator && (!bRatedGame || bRatedTranslocator) )
	{
		// Spawn Translocator.
		if( PlayerPawn.FindInventoryType(class'Translocator')==None )
		{
			newWeapon = Spawn(class'Translocator');
			if( newWeapon != None )
			{
				newWeapon.Instigator = PlayerPawn;
				newWeapon.BecomeItem();
				PlayerPawn.AddInventory(newWeapon);
				newWeapon.GiveAmmo(PlayerPawn);
				newWeapon.SetSwitchPriority(PlayerPawn);
				newWeapon.WeaponSet(PlayerPawn);
			}
		}
	}

	B = Bot(PlayerPawn);
	if ( B != None )
		B.bHasImpactHammer = (B.FindInventoryType(class'ImpactHammer') != None);
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
     MapPrefix=""
     GameName="PerUnreal DM all maps"
     DeathMessageClass=Class'PerUnreal.PKDeathMessagePlus'
     MutatorClass=Class'PerUnreal.PerUnreal'
}
