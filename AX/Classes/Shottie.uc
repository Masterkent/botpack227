//=============================================================================
// Shottie.
//=============================================================================
class Shottie expands AXweapons;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

var vector ViewOffset;
var int B227_Handedness;

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		B227_Handedness;
}

//// fire shot/////
function Fire( float Value )
{
	local Vector Start, X,Y,Z;
	local Bot B;
	local Pawn P;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		bCanClientFire = true;
		bPointing=True;
		Start = Owner.Location + CalcDrawOffset();
		B = Bot(Owner);
		P = Pawn(Owner);
		P.PlayRecoil(FiringSpeed);
		Owner.MakeNoise(2.0 * P.SoundDampening);
		AdjustedAim = P.AdjustAim(AltProjectileSpeed, Start, AimError, True, bWarnTarget);
		GetAxes(AdjustedAim,X,Y,Z);
		Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		Spawn( class 'axpellet',, '', Start, AdjustedAim);
		Spawn( class 'axpellet',, '', Start - Z, AdjustedAim);
		Spawn( class 'axpellet',, '', Start + 2 * Y + Z, AdjustedAim);
		Spawn( class 'axpellet',, '', Start - Y, AdjustedAim);
		Spawn( class 'axpellet',, '', Start + 2 * Y - Z, AdjustedAim);
		Spawn( class 'axpellet',, '', Start, AdjustedAim);

	     Spawn( class 'axpellet',, '', Start + Y - Z, AdjustedAim);

	     Spawn( class 'axpellet',, '', Start + Y - Z, AdjustedAim);
           Spawn( class 'axpellet',, '', Start, AdjustedAim);

	     Spawn( class 'axpellet',, '', Start + Y - Z, AdjustedAim);

	     Spawn( class 'axpellet',, '', Start + Y - Z, AdjustedAim);


		ClientFire(Value);
		GoToState('NormalFire');
	}
}

function PlayFiring()
{
	PlayAnim( 'Fire', 0.9, 0.05);
	PlaySound(FireSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	bMuzzleFlash++;
}
function PlayAltFiring()
{

}
function AltFire( float Value )
{
local Vector Start, X,Y,Z;
	local Bot B;
	local Pawn P;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		bCanClientFire = true;
		bPointing=True;
		Start = Owner.Location + CalcDrawOffset();
		B = Bot(Owner);
		P = Pawn(Owner);
		P.PlayRecoil(FiringSpeed);
		Owner.MakeNoise(2.0 * P.SoundDampening);
		AdjustedAim = P.AdjustAim(AltProjectileSpeed, Start, AimError, True, bWarnTarget);
		GetAxes(AdjustedAim,X,Y,Z);
		Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		Spawn( class 'axpellet',, '', Start, AdjustedAim);
		Spawn( class 'axpellet',, '', Start - Z, AdjustedAim);
		Spawn( class 'axpellet',, '', Start + 2 * Y + Z, AdjustedAim);
		Spawn( class 'axpellet',, '', Start - Y, AdjustedAim);
		Spawn( class 'axpellet',, '', Start + 2 * Y - Z, AdjustedAim);
		Spawn( class 'axpellet',, '', Start, AdjustedAim);

	     Spawn( class 'axpellet',, '', Start + Y - Z, AdjustedAim);

	     Spawn( class 'axpellet',, '', Start + Y - Z, AdjustedAim);
           Spawn( class 'axpellet',, '', Start, AdjustedAim);

	     Spawn( class 'axpellet',, '', Start + Y - Z, AdjustedAim);

	     Spawn( class 'axpellet',, '', Start + Y - Z, AdjustedAim);


		ClientFire(Value);
		GoToState('NormalFire');
	}
}
function PlayReloading()
{
	PlayAnim('reload',0.7, 0.05);

}

function PlayFastReloading()
{
	PlayAnim('reload',1.4, 0.05);

}

state NormalFire
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'reload') && (AmmoType.AmmoAmount > 0) )
			PlayFastReloading();
		else
			Finish();
	}

Begin:
	FlashCount++;
}

///////////////////////////////////////////////////////////
function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else if ( AmmoType.AmmoAmount < 1 )
		TweenAnim('Select', 0.5);
	else
		PlayAnim('Down',1.0, 0.05);
}

function PlayIdleAnim()
{
}

function PlayPostSelect()
{
	PlayAnim('reload', 1.3, 0.05);
	Owner.PlaySound(Misc2Sound, SLOT_None,1.3*Pawn(Owner).SoundDampening);
}

function SetHand(float Hand)
{
	Hand = Clamp(Hand, -1, 2);
	if (Hand == 1)
		Hand = 0;
	super.SetHand(Hand);
	B227_Handedness = Hand;
}

simulated function vector B227_PlayerViewOffset()
{
	local vector ViewOffset;

	switch (B227_Handedness)
	{
		case -1:
			ViewOffset.X = 0;
			ViewOffset.Y = -0.7;
			ViewOffset.Z = -1.4;
			break;

		default:
			ViewOffset.X = 0;
			ViewOffset.Y = -3.33;
			ViewOffset.Z = -1.4;
			break;
	}

	return ViewOffset * 100;
}

defaultproperties
{
     WeaponDescription="Classification: Heavy Shrapnel"
     InstFlash=-0.400000
     InstFog=(X=650.000000,Y=450.000000,Z=190.000000)
     AmmoName=Class'AX.AXSgunammo'
     PickupAmmoCount=12
     bWarnTarget=True
     bSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=10.000000,Y=-7.000000,Z=-11.000000)
     ProjectileClass=Class'AX.AXpellet'
     aimerror=700.000000
     shakemag=350.000000
     shaketime=0.150000
     shakevert=8.500000
     AIRating=0.750000
     FireSound=Sound'AX.Sounds.Shotgun'
     CockingSound=Sound'UnrealShare.AutoMag.Reload'
     SelectSound=Sound'UnrealShare.AutoMag.Reload'
     Misc2Sound=Sound'UnrealShare.AutoMag.Reload'
     DeathMessage="%o was blown away by %k's %w."
     NameColor=(G=96,B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.140000
     FlashO=0.018000
     FlashC=0.031000
     FlashLength=0.013000
     FlashS=256
     MFTexture=Texture'Botpack.Rifle.MuzzleFlash2'
     AutoSwitchPriority=5
     InventoryGroup=5
     bRotatingPickup=False
     PickupMessage="You got the shotgun."
     ItemName="shotgun"
     PlayerViewOffset=(X=4.100000,Y=-0.700000,Z=-2.400000)
     PlayerViewMesh=LodMesh'AX.Shottie'
     PlayerViewScale=0.180000
     BobDamping=0.972000
     PickupViewMesh=LodMesh'AX.Shottiepickup'
     PickupViewScale=0.800000
     ThirdPersonMesh=LodMesh'AX.Shottie3rd'
     ThirdPersonScale=0.545000
     StatusIcon=Texture'AX.Icons.Useshotgun'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzFF3'
     MuzzleFlashScale=0.350000
     MuzzleFlashTexture=Texture'Botpack.Skins.MuzzyFlak'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'AX.Icons.Useshotgun'
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.Shottie3rd'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=23.000000
     LightBrightness=228
     LightHue=30
     LightSaturation=71
     LightRadius=14
}
