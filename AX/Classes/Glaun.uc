//=============================================================================
// Glaun.
//=============================================================================
class Glaun expands AXweapons;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

//3rd person


// Pickup


// return delta to combat style
function float SuggestAttackStyle()
{
	local bot B;

	B = Bot(Owner);
	if ( (B != None) && B.bNovice )
		return 0.2;
	return 0.4;
}

function float SuggestDefenseStyle()
{
	return -0.3;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;

	if ( AmmoType != None )
		Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 30, 10, Temp, Font'LEDFont2', C );
}


function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist, rating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}
	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, AIRating);
	if ( Pawn(Owner).Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 0;
		return AIRating + 0.3;
	}
	if ( EnemyDist > 900 )
	{
		bUseAltMode = 0;
		if ( EnemyDist > 2000 )
		{
			if ( EnemyDist > 3500 )
				return 0.2;
			return (AIRating - 0.3);
		}
		if ( EnemyDir.Z < -0.5 * EnemyDist )
		{
			bUseAltMode = 1;
			return (AIRating - 0.3);
		}
	}
	else if ( (EnemyDist < 750) && (Pawn(Owner).Enemy.Weapon != None) && Pawn(Owner).Enemy.Weapon.bMeleeWeapon )
	{
		bUseAltMode = 0;
		return (AIRating + 0.3);
	}
	else if ( (EnemyDist < 340) || (EnemyDir.Z > 30) )
	{
		bUseAltMode = 0;
		return (AIRating + 0.2);
	}
	else
		bUseAltMode = int( FRand() < 0.65 );
	return rating;
}


simulated event RenderOverlays( canvas Canvas )
{
	Texture'FlakAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'FlakAmmoled'.NotifyActor = None;
}



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
		Spawn(ProjectileClass,, '', Start, AdjustedAim);

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
	PlaySound(AltFireSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	PlayAnim('AltFire', 1.3, 0.05);
	bMuzzleFlash++;
}

function AltFire( float Value )
{
	local Vector Start, X,Y,Z;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bPointing=True;
		bCanClientFire = true;
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset();
		Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim = pawn(owner).AdjustToss(AltProjectileSpeed, Start, AimError, True, bAltWarnTarget);
		Spawn(AltProjectileClass,,, Start,AdjustedAim);
		ClientAltFire(Value);
		GoToState('AltFiring');
	}
}

////////////////////////////////////////////////////////////
state AltFiring
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0) )
			PlayReloading();
		else
			Finish();
	}

Begin:
	FlashCount++;
}

/////////////////////////////////////////////////////////////
function PlayReloading()
{
	PlayAnim('Loading',0.7, 0.05);
	Owner.PlaySound(CockingSound, SLOT_None,0.5*Pawn(Owner).SoundDampening);
}

function PlayFastReloading()
{
	PlayAnim('Loading',1.4, 0.05);
	Owner.PlaySound(CockingSound, SLOT_None,0.5*Pawn(Owner).SoundDampening);
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
		if ( (AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0) )
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
	PlayAnim('Loading', 1.3, 0.05);
	Owner.PlaySound(Misc2Sound, SLOT_None,1.3*Pawn(Owner).SoundDampening);
}

function SetHand(float Hand)
{
	Hand = Clamp(Hand, -1, 2);
	if (Hand == 1)
		Hand = 0;
	super.SetHand(Hand);
}

defaultproperties
{
     WeaponDescription="Classification: Heavy Shrapnel"
     InstFlash=-0.400000
     InstFog=(X=650.000000,Y=450.000000,Z=190.000000)
     AmmoName=Class'AX.grammo'
     PickupAmmoCount=5
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     FiringSpeed=0.800000
     FireOffset=(X=10.000000,Y=-9.000000,Z=-15.000000)
     ProjectileClass=Class'AX.Grenade'
     AltProjectileClass=Class'AX.Grenade2'
     aimerror=700.000000
     shakemag=700.000000
     shaketime=0.150000
     shakevert=10.500000
     AIRating=0.750000
     FireSound=Sound'UnrealShare.Eightball.EightAltFire'
     AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
     CockingSound=Sound'UnrealI.flak.load1'
     SelectSound=Sound'UnrealI.flak.pdown'
     Misc2Sound=Sound'UnrealI.flak.Hidraul2'
     DeathMessage="%o was blow to pieces by %k's %w."
     NameColor=(G=96,B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=2.000000
     FlashY=0.160000
     FlashO=0.015000
     FlashC=0.100000
     FlashLength=0.020000
     FlashS=256
     MFTexture=Texture'Botpack.Skins.Flakmuz'
     AutoSwitchPriority=8
     InventoryGroup=8
     bRotatingPickup=False
     PickupMessage="You got the GrenadeLauncher."
     ItemName="Grenade Launcher"
     PlayerViewOffset=(X=8.000000,Y=-6.800000,Z=-7.300000)
     PlayerViewMesh=LodMesh'AX.Glaun'
     PlayerViewScale=0.300000
     BobDamping=0.972000
     PickupViewMesh=LodMesh'AX.Glaunpickup'
     PickupViewScale=0.350000
     ThirdPersonMesh=LodMesh'AX.Glaun3rd'
     ThirdPersonScale=0.400000
     StatusIcon=Texture'AX.Icons.useglaun'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzFF3'
     MuzzleFlashScale=0.400000
     MuzzleFlashTexture=Texture'Botpack.Skins.MuzzyFlak'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=None
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.Glaun3rd'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=23.000000
     LightBrightness=228
     LightHue=30
     LightSaturation=71
     LightRadius=14
}
