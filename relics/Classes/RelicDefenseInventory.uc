class RelicDefenseInventory expands RelicInventory;

#exec OBJ LOAD FILE="relicsResources.u" PACKAGE=relics

function bool HandlePickupQuery( inventory Item )
{
	if (item.IsA('UT_Shieldbelt') )
		return true; //don't allow shieldbelt if have defense relic

	return Super.HandlePickupQuery(Item);
}

function PickupFunction(Pawn Other)
{
	local Inventory I;

	Super.PickupFunction(Other);

	// remove other armors
	for ( I=Owner.Inventory; I!=None; I=I.Inventory )
		if ( I.IsA('UT_Shieldbelt') )
			I.Destroy();
}

function ArmorImpactEffect(vector HitLocation)
{
	if ( Owner.IsA('PlayerPawn') )
	{
		PlayerPawn(Owner).ClientFlash(-0.05,vect(400,400,400));
	}
	Owner.PlaySound(DeActivateSound, SLOT_None, 2.7*Pawn(Owner).SoundDampening);
	FlashShell(0.4);
}

//
// Absorb damage.
//
function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	if (!bActive)
		return Damage;
	ArmorImpactEffect(HitLocation);
	return 0.4 * Damage;
}

//
// Return armor value.
//
function int ArmorPriority(name DamageType)
{
	return 1;  // very low absorption priority (only if no other armor left
}

defaultproperties
{
     ShellSkin=Texture'relics.Skins.RelicGreen'
     PickupMessage="You picked up the Relic of Defense!"
     PickupViewMesh=LodMesh'relics.RelicHelmet'
     PickupViewScale=0.600000
     bIsAnArmor=True
     Icon=Texture'relics.Icons.RelicIconDefense'
     Physics=PHYS_Rotating
     Skin=Texture'relics.Skins.JRelicHelmet'
     CollisionHeight=40.000000
     LightBrightness=200
     LightHue=100
     LightSaturation=0
     RotationRate=(Yaw=6000,Roll=0)
     DesiredRotation=(Roll=0)
     ItemName="Relic of Defense"
}
