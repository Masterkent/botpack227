class RelicStrengthInventory expands RelicInventory;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

var float FireTime;
var TournamentWeapon StrengthWeapon;

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
		Super.BeginState();
	}

	function EndState()
	{
		if (Pawn(Owner) != none)
			Pawn(Owner).DamageScaling = FMax(Pawn(Owner).DamageScaling / 2.0, Pawn(Owner).default.DamageScaling);
		if (StrengthWeapon != None && StrengthWeapon.Affector == self)
			StrengthWeapon.Affector = None;
		Super.EndState();
	}
}

function SetStrengthWeapon()
{
	// Make old weapon normal again.
	if ( StrengthWeapon != None && StrengthWeapon.Affector == self )
		StrengthWeapon.Affector = None;

	StrengthWeapon = TournamentWeapon(Pawn(Owner).Weapon);

	if ( StrengthWeapon != None )
		StrengthWeapon.Affector = self;
}

function ChangedWeapon()
{
	if( Inventory != None )
		Inventory.ChangedWeapon();

	SetStrengthWeapon();
}

simulated function FireEffect()
{
	SetLocation(Owner.Location);
	SetBase(Owner);
	PlaySound(sound'StrengthUse', SLOT_Interact, 6);
	PlaySound(sound'StrengthUse', SLOT_Interact, 6);
	FlashShell(0.15);
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
