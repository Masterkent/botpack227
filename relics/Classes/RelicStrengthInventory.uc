class RelicStrengthInventory expands RelicInventory;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

var float FireTime;
var Weapon StrengthWeapon;

var private bool B227_bIsFiringAnimSequence;
var private name B227_WeaponAnimSequence;
var private float B227_WeaponAnimFrame;
var private float B227_LastFireEffectTimestamp;

function bool HandlePickupQuery( inventory Item )
{
	if (Item.IsA('UDamage'))
		return true;
	else
		return Super.HandlePickupQuery( Item );
}

function PickupFunction(Pawn Other)
{
	local Inventory I;

	Super.PickupFunction(Other);

	// remove any damage amplifiers
	for ( I=Owner.Inventory; I!=None; I=I.Inventory )
		if ( I.IsA('UDamage') )
		{
			//-I.SetTimer(0.2, false);
			//-UDamage(I).FinalCount = 0;
			I.Destroy();
		}
}

state Activated
{
	function BeginState()
	{
		if (Pawn(Owner) != none)
			Pawn(Owner).DamageScaling *= 2.0;
		SetStrengthWeapon();
		B227_InitWeaponFireEffect();
		Super.BeginState();
	}

	function EndState()
	{
		if (Pawn(Owner) != none)
			Pawn(Owner).DamageScaling = FMax(Pawn(Owner).DamageScaling / 2.0, Pawn(Owner).default.DamageScaling);
		if (TournamentWeapon(StrengthWeapon) != None && TournamentWeapon(StrengthWeapon).Affector == self)
			TournamentWeapon(StrengthWeapon).Affector = None;
		Super.EndState();
	}

	event Tick(float DeltaTime)
	{
		B227_WeaponFireEffect();
	}
}

function SetStrengthWeapon()
{
	// Make old weapon normal again.
	if ( TournamentWeapon(StrengthWeapon) != None && TournamentWeapon(StrengthWeapon).Affector == self )
		TournamentWeapon(StrengthWeapon).Affector = None;

	StrengthWeapon = Pawn(Owner).Weapon;

	if ( TournamentWeapon(StrengthWeapon) != None )
		TournamentWeapon(StrengthWeapon).Affector = self;
}

function ChangedWeapon()
{
	if( Inventory != None )
		Inventory.ChangedWeapon();

	SetStrengthWeapon();
	B227_InitWeaponFireEffect();
}

simulated function FireEffect()
{
	SetLocation(Owner.Location);
	SetBase(Owner);
	PlaySound(sound'StrengthUse', SLOT_Interact, 6);
	PlaySound(sound'StrengthUse', SLOT_Interact, 6);
	FlashShell(0.15);
}

function B227_InitWeaponFireEffect()
{
	if (StrengthWeapon == none || TournamentWeapon(StrengthWeapon) != none)
		return;
	if (StrengthWeapon.IsAnimating())
		B227_WeaponAnimSequence = StrengthWeapon.AnimSequence;
	else
		B227_WeaponAnimSequence = '';
	B227_bIsFiringAnimSequence = B227_IsFiringAnimSequence(B227_WeaponAnimSequence);
	B227_WeaponAnimFrame = StrengthWeapon.AnimFrame;
}

function B227_WeaponFireEffect()
{
	if (StrengthWeapon == none || TournamentWeapon(StrengthWeapon) != none)
		return;
	if (!StrengthWeapon.IsAnimating())
	{
		B227_WeaponAnimSequence = '';
		return;
	}
	if (StrengthWeapon.AnimSequence != B227_WeaponAnimSequence)
	{
		B227_WeaponAnimSequence = StrengthWeapon.AnimSequence;
		B227_bIsFiringAnimSequence = B227_IsFiringAnimSequence(B227_WeaponAnimSequence);
	}
	else if (StrengthWeapon.AnimFrame >= B227_WeaponAnimFrame &&
		!StrengthWeapon.IsA('Minigun'))
	{
		B227_WeaponAnimFrame = StrengthWeapon.AnimFrame;
		return;
	}
	B227_WeaponAnimFrame = StrengthWeapon.AnimFrame;

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
		Sequence == 'AltFire2' && StrengthWeapon.IsA('RazorJack') ||
		Sequence == 'Fire' ||
		Sequence == 'Fire1' ||
		Sequence == 'FireOne' ||
		Sequence == 'Shoot' ||
		Sequence == 'Shoot0' ||
		Sequence == 'Shoot1' ||
		Sequence == 'Shoot2' && !StrengthWeapon.IsA('AutoMag') ||
		Sequence == 'Shoot3' ||
		Sequence == 'Shoot4' ||
		Sequence == 'Shoot5' ||
		Sequence == 'Shot2b' && StrengthWeapon.IsA('AutoMag'))
	{
		return InStr(Caps(StrengthWeapon.Class.Name), "TRANSLOCATOR") < 0;
	}

	return false;
}

function float B227_MinFireEffectDelay()
{
	if (StrengthWeapon.IsA('Minigun'))
	{
		if (StrengthWeapon.AnimSequence == 'Shoot1')
			return 0.3;
		return 0.25;
	}
	return 0.2;
}

defaultproperties
{
     ShellSkin=Texture'relics.Skins.RelicPurple'
     PickupMessage="You picked up the Relic of Strength!"
     PickupViewMesh=Mesh'relics.RelicStrength'
     PickupViewScale=0.700000
     Icon=Texture'relics.Icons.RelicIconStrength'
     Physics=PHYS_Rotating
     Texture=Texture'relics.Skins.JRelicStrength_01'
     Skin=Texture'relics.Skins.JRelicStrength_01'
     CollisionHeight=40.000000
     LightHue=185
     LightSaturation=0
     ItemName="Relic of Strength"
}
