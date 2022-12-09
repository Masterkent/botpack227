//=============================================================================
// UnrealityFlare.
//=============================================================================
class UnrealityFlare expands Pickup;

var() sound TorchSound;

var B227_UnrealityFlareEffect B227_FlareEffect;

state Activated
{
	function EndState()
	{
		B227_DestroyFlareEffect();
		bActive = false;
	}

	function B227_DestroyFlareEffect()
	{
		if (B227_FlareEffect != none)
		{
			B227_FlareEffect.Destroy();
			B227_FlareEffect = none;
		}
	}

Begin:
	if (Owner != none && !Owner.bDeleteMe)
	{
		Owner.PlaySound(ActivateSound);
		B227_DestroyFlareEffect();
		B227_FlareEffect = Owner.Spawn(class'B227_UnrealityFlareEffect', Owner);
		if (B227_FlareEffect != none)
			B227_FlareEffect.AmbientSound = TorchSound;
	}
}

state DeActivated
{
Begin:

}

defaultproperties
{
	TorchSound=Sound'UnrealShare.Pickups.flarel1'
	ExpireMessage="Your flare has ran out of fuel"
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up a Flare!"
	ItemName="Flare"
	RespawnTime=30.000000
	PickupViewMesh=LodMesh'UnrealShare.FlareM'
	PickupViewScale=2.000000
	Charge=1000000
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	ActivateSound=Sound'UnrealShare.Pickups.flares1'
	DeActivateSound=Sound'UnrealShare.General.Explg02'
	Icon=Texture'UnrealShare.Icons.I_Flare'
	Mesh=LodMesh'UnrealShare.FlareM'
}
