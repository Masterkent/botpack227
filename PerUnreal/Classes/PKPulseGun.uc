//=============================================================================
// PKPulseGun.
//=============================================================================
class PKPulseGun extends PulseGun;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

function PlayFiring()
{
	super.PlayFiring();
	SoundPitch=byte(default.soundpitch*level.timedilation-2*FRand());
}

function AltFire( float Value )
{
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		SoundPitch=byte(default.soundpitch*level.timedilation-10*FRand());
		GotoState('AltFiring');
		bCanClientFire = true;
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ClientAltFire(value);
		if (PlasmaBeam == none || PlasmaBeam.bDeleteMe)
			B227_EmitBeam();
	}
}

function PlaySpinDown()
{
	if ( (Mesh != PickupViewMesh) && (Owner != None) )
	{
		PlayAnim('Spindown', 1.0, 0.0);
		Owner.PlaySound(DownSound, SLOT_None,1.0*Pawn(Owner).SoundDampening,,,Level.TimeDilation-0.1*FRand());
	}
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, 0.8 * Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1*FRand());
}

defaultproperties
{
	DownSound=Sound'PerUnreal.PulseGun.PKpulsedown'
	WeaponDescription="Classification: Plasma Rifle"
	AmmoName=Class'PerUnreal.PKPAmmo'
	ProjectileClass=Class'PerUnreal.PKPlasmaSphere'
	AltProjectileClass=Class'PerUnreal.PKstarterbolt'
	FireSound=Sound'PerUnreal.PulseGun.PKpulsefire'
	AltFireSound=Sound'PerUnreal.PulseGun.PKpulsebolt'
	RespawnTime=6.000000
	PickupSound=Sound'PerUnreal.Misc.PKpickup'
}
