//=============================================================================
// UDamage.
//=============================================================================
class UDamage extends TournamentPickup;

#exec OBJ LOAD FILE="BotpackResources.u" PACKAGE=Botpack

var Weapon UDamageWeapon;
var sound ExtraFireSound;
var sound EndFireSound;
var int FinalCount;

// Auxiliary
var private B227_UDamageEffect B227_Effect;
var private bool B227_bActive;
var private float B227_Discharge, B227_FinalCount;
var private bool B227_bIsFiringAnimSequence;
var private name B227_WeaponAnimSequence;
var private float B227_WeaponAnimFrame;
var private float B227_LastFireEffectTimestamp;

singular function UsedUp()
{
	Destroy();
}

simulated function FireEffect()
{
	if (Pawn(Owner) == none || Pawn(Owner).Weapon == none)
		return;
	if (!bActive || Charge * 0.1 - default.FinalCount < 5)
		class'UTC_Actor'.static.B227_PlaySound(Pawn(Owner).Weapon, EndFireSound, SLOT_Interact, 8);
	else
		class'UTC_Actor'.static.B227_PlaySound(Pawn(Owner).Weapon, ExtraFireSound, SLOT_Interact, 8);
}

function SetOwnerLighting()
{
	// Owner.AmbientGlow = 254; // [U227] Excluded
	if (B227_Effect == none || B227_Effect.bDeleteMe)
	{
		B227_Effect = Level.Spawn(class'B227_UDamageEffect', Owner,, Owner.Location);
		if (B227_Effect != none)
			B227_Effect.Activate();
	}
	else
	{
		if (B227_Effect.Owner != Owner)
		{
			B227_Effect.SetOwner(Owner);
			B227_Effect.SetLocation(Owner.Location);
		}
		B227_Effect.Activate();
	}
}

function SetUDamageWeapon()
{
	if (!B227_bActive || Pawn(Owner) == none)
		return;

	SetOwnerLighting();

	// Make old weapon normal again.
	if ( UDamageWeapon != None )
	{
		UDamageWeapon.SetDefaultDisplayProperties();
		if (TournamentWeapon(UDamageWeapon) != none && TournamentWeapon(UDamageWeapon).Affector == self)
			TournamentWeapon(UDamageWeapon).Affector = none;
	}

	UDamageWeapon = Pawn(Owner).Weapon;
	// Make new weapon cool.
	if (UDamageWeapon != none)
	{
		if (TournamentWeapon(UDamageWeapon) != none)
			TournamentWeapon(UDamageWeapon).Affector = self;
		B227_SetUDamageWeaponLook();
	}
}

function SetOwnerDisplay()
{
	super.SetOwnerDisplay();

	if (B227_bActive)
		SetUDamageWeapon();
}

function ChangedWeapon()
{
	super.ChangedWeapon();

	if (B227_bActive)
	{
		SetUDamageWeapon();
		B227_InitWeaponFireEffect();
	}
}

//
// Player has activated the item, pump up their damage.
//
state Activated
{
	event Tick(float DeltaTime)
	{
		if (Pawn(Owner) == none)
		{
			UsedUp();
			return;
		}
		B227_UseCharge(DeltaTime);
		if (Charge == 0)
		{
			UsedUp();
			return;
		}
		if (Charge * 0.1 <= default.FinalCount)
		{
			if (B227_FinalCount > 0)
				B227_FinalCount -= DeltaTime;
			if (B227_FinalCount <= 0)
			{
				if (B227_Effect != none)
					B227_Effect.PlaySound(DeActivateSound,, 8);
				B227_FinalCount += 1;
			}
		}
		else
			B227_FinalCount = 0;
		B227_UpdateUdamageWeapon();
		B227_WeaponFireEffect();
	}

	event BeginState()
	{
		if (Pawn(Owner) == none)
			return;
		bActive = true;
		FinalCount = default.FinalCount;
		B227_FinalCount = 0;
		B227_InitWeaponFireEffect();
		B227_Discharge = 0;
		B227_SetActive();
		if (B227_Effect != none)
			B227_Effect.PlaySound(ActivateSound);
	}

	event EndState()
	{
		B227_Deactivate();
	}
}

auto state Pickup
{
	event Touch(Actor Other)
	{
		if (Pawn(Other) != none && Pawn(Other).bAutoActivate && bActivatable && bAutoActivate)
			PickupSound = none;
		else
			PickupSound = Sound'UnrealShare.Pickups.GenPickSnd';
		super.Touch(Other);
	}
}

state DeActivated
{
	event BeginState()
	{
		if (Pawn(Owner) == none)
		{
			UsedUp();
			return;
		}
		if (Pawn(Owner).Health <= 0)
		{
			B227_Deactivate();
			return;
		}
		if (Charge > 0)
			B227_SetActive();
	}

	event Tick(float DeltaTime)
	{
		if (!B227_bActive)
		{
			Disable('Tick');
			return;
		}

		if (Pawn(Owner) == none)
		{
			UsedUp();
			return;
		}
		if (Pawn(Owner).Health <= 0)
		{
			B227_Deactivate();
			return;
		}

		B227_UseCharge(DeltaTime);
		if (Charge == 0)
		{
			UsedUp();
			return;
		}
		if (B227_FinalCount > 0)
			B227_FinalCount -= DeltaTime;
		if (B227_FinalCount <= 0)
		{
			if (FinalCount > 0)
			{
				if (B227_Effect != none)
					B227_Effect.PlaySound(DeActivateSound,, 8);
				B227_FinalCount += 1;
				FinalCount -= 1;
			}
			else
				B227_Deactivate();
		}
		B227_UpdateUdamageWeapon();
		B227_WeaponFireEffect();
	}
}

function bool HandlePickupQuery(Inventory Item)
{
	if (B227_bActive &&
		Item.Class == Class &&
		Pawn(Owner) != none &&
		Pawn(Owner).bAutoActivate &&
		bActivatable &&
		bAutoActivate &&
		B227_Effect != none)
	{
		B227_Effect.PlaySound(ActivateSound);
	}
	return super.HandlePickupQuery(Item);
}

function Destroyed()
{
	B227_Deactivate();
	if (B227_Effect != none)
		B227_Effect.LifeSpan = 3; // finish playing sounds and destroy

	super.Destroyed();
}

event float BotDesireability(Pawn Bot)
{
	local Inventory Inv;

	for (Inv = Bot.Inventory; Inv != none; Inv = Inv.Inventory)
		if (Inv.IsA('RelicStrengthInventory'))
			return -1; // can't pickup up UDamage if have strength relic

	return super.BotDesireability(Bot);
}

// Auxiliary
function B227_UpdateUdamageWeapon()
{
	if (Pawn(Owner) == none)
		return;
	if (UDamageWeapon != Pawn(Owner).Weapon)
		SetUDamageWeapon();
	else
		B227_SetUDamageWeaponLook();
}

function B227_SetUDamageWeaponLook()
{
	if (UDamageWeapon == none)
		return;

	if (Level.bHighDetailMode)
		UDamageWeapon.SetDisplayProperties(
			ERenderStyle.STY_Translucent,
			FireTexture'Botpack227_Base.Belt_fx.UDamageFX',
			true,
			true);
	else
		UDamageWeapon.SetDisplayProperties(
			ERenderStyle.STY_Normal,
			FireTexture'Botpack227_Base.Belt_fx.UDamageFX',
			true,
			true);
}

function B227_InitWeaponFireEffect()
{
	if (UDamageWeapon == none || TournamentWeapon(UDamageWeapon) != none)
		return;
	if (UDamageWeapon.IsAnimating())
		B227_WeaponAnimSequence = UDamageWeapon.AnimSequence;
	else
		B227_WeaponAnimSequence = '';
	B227_bIsFiringAnimSequence = B227_IsFiringAnimSequence(B227_WeaponAnimSequence);
	B227_WeaponAnimFrame = UDamageWeapon.AnimFrame;
}

function B227_WeaponFireEffect()
{
	if (UDamageWeapon == none || TournamentWeapon(UDamageWeapon) != none)
		return;
	if (!UDamageWeapon.IsAnimating())
	{
		B227_WeaponAnimSequence = '';
		return;
	}
	if (UDamageWeapon.AnimSequence != B227_WeaponAnimSequence)
	{
		B227_WeaponAnimSequence = UDamageWeapon.AnimSequence;
		B227_bIsFiringAnimSequence = B227_IsFiringAnimSequence(B227_WeaponAnimSequence);
	}
	else if (UDamageWeapon.AnimFrame >= B227_WeaponAnimFrame &&
		!UDamageWeapon.IsA('Minigun'))
	{
		B227_WeaponAnimFrame = UDamageWeapon.AnimFrame;
		return;
	}
	B227_WeaponAnimFrame = UDamageWeapon.AnimFrame;

	if (B227_bIsFiringAnimSequence &&
		(Level.TimeSeconds - B227_LastFireEffectTimestamp > B227_MinFireEffectDelay() || B227_LastFireEffectTimestamp == 0))
	{
		B227_LastFireEffectTimestamp = Level.TimeSeconds;
		FireEffect();
	}
}

function bool B227_IsFiringAnimSequence(name Sequence)
{
	if (Sequence == 'AltFire' ||
		Sequence == 'AltFire2' && UDamageWeapon.IsA('RazorJack') ||
		Sequence == 'Fire' ||
		Sequence == 'Fire1' ||
		Sequence == 'FireOne' ||
		Sequence == 'Shoot' ||
		Sequence == 'Shoot0' ||
		Sequence == 'Shoot1' ||
		Sequence == 'Shoot2' && !UDamageWeapon.IsA('AutoMag') ||
		Sequence == 'Shoot3' ||
		Sequence == 'Shoot4' ||
		Sequence == 'Shoot5' ||
		Sequence == 'Shot2b' && UDamageWeapon.IsA('AutoMag'))
	{
		return InStr(Caps(UDamageWeapon.Class.Name), "TRANSLOCATOR") < 0;
	}

	return false;
}

function float B227_MinFireEffectDelay()
{
	if (UDamageWeapon.IsA('Minigun'))
	{
		if (UDamageWeapon.AnimSequence == 'Shoot1')
			return 0.3;
		return 0.25;
	}
	return 0.2;
}

function B227_UseCharge(float DeltaTime)
{
	B227_Discharge += DeltaTime * 10;
	if (B227_Discharge >= 1)
	{
		Charge = Max(0, Charge - int(B227_Discharge));
		B227_Discharge -= int(B227_Discharge);
	}
}

function B227_SetActive()
{
	B227_bActive = true;
	SetOwnerLighting();
	Pawn(Owner).DamageScaling *= 3.0;
	SetUDamageWeapon();
}

function B227_Deactivate()
{
	if (!B227_bActive)
		return;

	bActive = false;
	B227_bActive = false;

	if (UDamageWeapon != none)
	{
		UDamageWeapon.SetDefaultDisplayProperties();
		if (TournamentWeapon(UDamageWeapon) != none && TournamentWeapon(UDamageWeapon).Affector == self)
			TournamentWeapon(UDamageWeapon).Affector = none;
	}

	if (B227_Effect != none)
		B227_Effect.Deactivate();

	if (Owner != none)
	{
		if (Owner.bIsPawn)
			Pawn(Owner).DamageScaling = FMax(Pawn(Owner).DamageScaling / 3.0, Pawn(Owner).default.DamageScaling);
		if (Owner.Inventory != none)
		{
			Owner.Inventory.SetOwnerDisplay();
			Owner.Inventory.ChangedWeapon();
		}
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
	}
	UDamageWeapon = none;
	Disable('Tick');
}

defaultproperties
{
	ExtraFireSound=Sound'Botpack.Pickups.AmpFire'
	EndFireSound=Sound'Botpack.Pickups.AmpFire2b'
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
	ActivateSound=Sound'Botpack.Pickups.AmpPickup'
	DeActivateSound=Sound'Botpack.Pickups.AmpOut'
	Icon=Texture'Botpack.Icons.I_UDamage'
	Physics=PHYS_Rotating
	RemoteRole=ROLE_DumbProxy
	Texture=Texture'Botpack.GoldSkin2'
	Mesh=LodMesh'Botpack.UDamage'
	bMeshEnviroMap=True
	bNetNotify=True
}
