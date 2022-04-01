// Weak Nali projectile weapon
// Code by Sergey 'Eater' Levin

#exec OBJ LOAD FILE="NaliChroniclesResources.u" PACKAGE=NaliChronicles

class NCNaliGun extends NCWeapon;

var bool bFireSoundOn;
var bool bFShot;

function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( PlayerPawn(Owner).Handedness == 1 )
		Mesh = mesh'naligunl';
	else
		Mesh = mesh'naligunr';
}

function DoFire( float Value )
{
	//if ((AmmoType != None) && (AmmoType.AmmoAmount>0)) {
	GotoState('NormalFire');
	Pawn(Owner).PlayRecoil(FiringSpeed);
	bCanClientFire = true;
	bPointing=True;
	ClientFire(value);
	//}
}

function EndFiring()
{
	AmbientSound = none;
	//PlayAnim('Idle2', 1.0);
}

function PlayFiring()
{
	PlayAnim( 'Fire', 1.0 );
	AmbientSound = FireSound;
	bFireSoundOn = true;
	ResetMuzzSkin();
}

function PlayEndFiring()
{
	PlayAnim( 'Fire', 1.0 );
	AmbientSound = Misc1Sound;
	bFireSoundOn = false;
	ClearMuzzSkin();
}

function ClearMuzzSkin() {
	multiskins[3] = Texture'NaliChronicles.ClearTex';
}

function ResetMuzzSkin() {
	multiskins[3] = Texture'UnrealShare.Effect50.FireEffect50';
}

state NormalFire
{
	ignores AnimEnd;

	function Fire(float F)
	{
		//Pawn(Owner).ClientMessage("FFIRE!");
	}

	function AltFire(float F)
	{
	}

	function EndState() {
		AmbientSound = none;
		Super.EndState();
	}

	function BeginState() {
		Super.BeginState();
		bFShot = true;
	}

	function Timer() {
		if (((Pawn(Owner).bFire!=0) || (bFShot)) && (AmmoType.UseAmmo(1))) {
			bFShot = false;
			ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
			if (!bFireSoundOn) {
				AmbientSound = FireSound;
				bFireSoundOn = true;
				ResetMuzzSkin();
			}
		}
		else {
			if (bFireSoundOn) {
				AmbientSound = Misc1Sound;
				bFireSoundOn = false;
				ClearMuzzSkin();
			}
		}
		SetTimer(0.19,false);
	}

Begin:
	sleep(0.19);
	Timer();
	FinishAnim();
	if ((Pawn(Owner).bFire==0) || (AmmoType.AmmoAmount <= 0)) {
		if (bFireSoundOn) {
			PlayEndFiring();
			Goto('Begin');
		}
		else {
			EndFiring();
			Finish();
		}
	}
	else {
		PlayFiring();
		Goto('Begin');
	}
}

state Idle
{
	function AnimEnd() {
		PlayIdleAnim();
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

	function Fire(float f) {
		global.Fire(f);
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 )
		Fire(0.0);
	FinishAnim();
	AnimFrame=0;
	PlayIdleAnim();
	Goto('Begin');
}

function PlayIdleAnim()
{
	local float r;

	r = FRand();
	if (r > 0.66)
		PlayAnim('Idle');
	else if (r > 0.33)
		PlayAnim('Idle1');
	else
		PlayAnim( 'Idle2' );
}

function Finish()
{
	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	if ( PlayerPawn(Owner) == None )
	{
		if ( (Pawn(Owner).bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else
		{
			Pawn(Owner).StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else
		GotoState('Idle');
}

function TweenDown()
{
	Owner.PlaySound(SelectSound);
	Super.TweenDown();
	AmbientSound = None;
}

defaultproperties
{
     InfoTexture=Texture'NaliChronicles.Icons.NaliGunInfo'
     bHasHand=True
     AmmoName=Class'NaliChronicles.NCNaliBullets'
     PickupAmmoCount=50
     bRapidFire=True
     FireOffset=(X=-10.000000,Y=-10.000000,Z=-22.000000)
     ProjectileClass=Class'NaliChronicles.NCNaliBullet'
     MyDamageType=shot
     RefireRate=1.000000
     FireSound=Sound'NaliChronicles.PickupSounds.NaliGunShoot'
     SelectSound=Sound'NaliChronicles.PickupSounds.DrawWoodWep'
     Misc1Sound=Sound'NaliChronicles.PickupSounds.NaliGunDown'
     DeathMessage="%k filled %o with tarydium from his %w."
     InventoryGroup=2
     bAmbientGlow=False
     bRotatingPickup=False
     PickupMessage="You found a Nali DaGraz gun."
     ItemName="Nali gun"
     PlayerViewOffset=(X=4.000000,Y=-1.500000,Z=-1.900000)
     PlayerViewMesh=LodMesh'NaliChronicles.naligunr'
     PlayerViewScale=0.035000
     PickupViewMesh=LodMesh'NaliChronicles.naligunpick'
     PickupViewScale=0.500000
     ThirdPersonMesh=LodMesh'NaliChronicles.naligunthird'
     ThirdPersonScale=0.500000
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'NaliChronicles.Icons.NaliGunIcon'
     Skin=Texture'NaliChronicles.Skins.handskin'
     Mesh=LodMesh'NaliChronicles.naligunpick'
     AmbientGlow=0
     bNoSmooth=False
     SoundRadius=96
     SoundVolume=255
}
