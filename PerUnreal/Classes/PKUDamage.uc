//=============================================================================
// PKUDamage.
//=============================================================================
class PKUDamage extends TournamentPickup;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var Weapon UDamageWeapon;
var sound ExtraFireSound;
var int FinalCount;

singular function UsedUp()
{
	if ( UDamageWeapon != None )
	{
		UDamageWeapon.SetDefaultDisplayProperties();
		if ( UDamageWeapon.IsA('TournamentWeapon') )
			TournamentWeapon(UDamageWeapon).Affector = None;
	}
	if ( Owner != None )
	{
		if ( Owner.bIsPawn )
		{
			if ( !Pawn(Owner).bIsPlayer || (Pawn(Owner).PlayerReplicationInfo.HasFlag == None) )
			{
				Owner.AmbientGlow = Owner.Default.AmbientGlow;
				Owner.LightType = LT_None;
			}
			Pawn(Owner).DamageScaling = 1.0;
		}
		bActive = false;
		if ( Owner.Inventory != None )
		{
			Owner.Inventory.SetOwnerDisplay();
			Owner.Inventory.ChangedWeapon();
		}
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
	}
	Destroy();
}

simulated function FireEffect()
{
	Pawn(Owner).Weapon.PlaySound(ExtraFireSound, SLOT_Interact, 8,,,0.75+0.05 * FinalCount);
}

function SetOwnerLighting()
{
	if ( Owner.bIsPawn && Pawn(Owner).bIsPlayer
		&& (Pawn(Owner).PlayerReplicationInfo.HasFlag != None) )
		return;
	Owner.AmbientGlow = 254;
	Owner.LightEffect=LE_NonIncidence;
	Owner.LightBrightness=255;
	Owner.LightHue=210;
	Owner.LightRadius=10;
	Owner.LightSaturation=0;
	Owner.LightType=LT_Steady;
}

function SetUDamageWeapon()
{
	if ( !bActive )
		return;

	SetOwnerLighting();

	// Make old weapon normal again.
	if ( UDamageWeapon != None )
	{
		UDamageWeapon.SetDefaultDisplayProperties();
		if ( UDamageWeapon.IsA('TournamentWeapon') )
			TournamentWeapon(UDamageWeapon).Affector = None;
	}

	UDamageWeapon = Pawn(Owner).Weapon;
	// Make new weapon cool.
	if ( UDamageWeapon != None )
	{
		if ( UDamageWeapon.IsA('TournamentWeapon') )
			TournamentWeapon(UDamageWeapon).Affector = self;
		if ( Level.bHighDetailMode )
			UDamageWeapon.SetDisplayProperties(ERenderStyle.STY_Translucent,
									 FireTexture'UnrealShare.Belt_fx.UDamageFX',
									 true,
									 true);
		else
			UDamageWeapon.SetDisplayProperties(ERenderStyle.STY_Normal,
							 FireTexture'UnrealShare.Belt_fx.UDamageFX',
							 true,
							 true);
	}
}

//
// Player has activated the item, pump up their damage.
//
state Activated
{
	function Timer()
	{
		if ( FinalCount > 0 )
		{
			SetTimer(1.0, true);
			Owner.PlaySound(DeActivateSound,, 8);
			FinalCount--;
			return;
		}
		UsedUp();
	}

	function SetOwnerDisplay()
	{
		if( Inventory != None )
			Inventory.SetOwnerDisplay();

		SetUDamageWeapon();
	}

	function ChangedWeapon()
	{
		if( Inventory != None )
			Inventory.ChangedWeapon();

		SetUDamageWeapon();
	}

	function EndState()
	{
		UsedUp();
	}

	function BeginState()
	{
		bActive = true;
		FinalCount = Min(FinalCount, 0.1 * Charge - 1);
		SetTimer(0.1 * Charge - FinalCount,false);
		Owner.PlaySound(ActivateSound);
		SetOwnerLighting();
		Pawn(Owner).DamageScaling = 3.0;
		SetUDamageWeapon();
	}
}

defaultproperties
{
     ExtraFireSound=Sound'PerUnreal.Misc.PKampfire'
     FinalCount=5
     bAutoActivate=True
     bActivatable=True
     bDisplayableInv=True
     PickupMessage="You got the Damage Amplifier!"
     ItemName="Damage Amplifier"
     RespawnTime=120.000000
     PickupViewMesh=LodMesh'Botpack.UDamage'
     Charge=300
     MaxDesireability=2.500000
     PickupSound=Sound'PerUnreal.Misc.PKampstart'
     DeActivateSound=Sound'PerUnreal.Misc.PKampend'
     Icon=Texture'Botpack.Icons.I_UDamage'
     Physics=PHYS_Rotating
     RemoteRole=ROLE_DumbProxy
     Texture=Texture'Botpack.GoldSkin2'
     Mesh=LodMesh'Botpack.UDamage'
     bMeshEnviroMap=True
}
