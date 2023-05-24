//=============================================================================
// RocketL.
//=============================================================================
class RocketL expands Tournamentweapon;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

//pickup


// 3rd person


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





// Fire Mines
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
		Spawn( class 'arocket',, '', Start, AdjustedAim);

		ClientFire(Value);
		GoToState('NormalFire');
	}
}

function PlayFiring()
{
	PlayAnim( 'Fire',6.0);
	PlaySound(FireSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	bMuzzleFlash++;
}

function PlayAltFiring()
{
	PlaySound(AltFireSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	PlayAnim('fire');
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
		Spawn(class'arocket2',,, Start,AdjustedAim);
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
	PlayAnim('Loading');
	Owner.PlaySound(CockingSound, SLOT_None,0.5*Pawn(Owner).SoundDampening);
}

function PlayFastReloading()
{
	PlayAnim('Loading');
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

function SetHand(float Hand)
{
	Hand = Clamp(Hand, -1, 2);
	if (Hand == 1)
		Hand = 0;
	super.SetHand(Hand);
}

simulated function vector B227_PlayerViewOffset(Canvas Canvas)
{
	local float Hand;

	if (B227_ViewOffsetMode() == 2 && B227_GetKnownHandedness(Hand) && Hand == 0)
		return PlayerViewOffset * Level.GetLocalPlayerPawn().FOVAngle / 90;
	return PlayerViewOffset;
}

defaultproperties
{
     WeaponDescription="Classification: Redeemer"
     InstFlash=-0.400000
     InstFog=(X=650.000000,Y=450.000000,Z=190.000000)
     AmmoName=Class'AX.rlammo'
     PickupAmmoCount=2
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=1.000000,Y=-1.000000,Z=-1.000000)
     ProjectileClass=Class'AX.arocket'
     AltProjectileClass=Class'AX.arocket2'
     aimerror=700.000000
     shakemag=350.000000
     shaketime=0.150000
     shakevert=8.500000
     AIRating=0.750000
     FireSound=Sound'AX.Sounds.RocketLauncher'
     AltFireSound=Sound'AX.Sounds.RocketLauncher'
     CockingSound=Sound'Botpack.Redeemer.WarheadPickup'
     SelectSound=Sound'Botpack.Redeemer.WarheadPickup'
     DeathMessage="%o Couldn't out run on one of %k's Rockets."
     NameColor=(G=96,B=0)
     MuzzleScale=2.000000
     FlashY=0.160000
     FlashO=0.015000
     FlashC=0.100000
     FlashLength=0.020000
     FlashS=256
     MFTexture=Texture'Botpack.Skins.Flakmuz'
     AutoSwitchPriority=10
     InventoryGroup=10
     bRotatingPickup=False
     PickupMessage="You got the Rocket Launcher."
     ItemName="rocket launcher"
     RespawnTime=60.000000
     PlayerViewOffset=(X=4.700000,Y=-3.500000,Z=-4.500000)
     PlayerViewMesh=LodMesh'AX.RocketL'
     PlayerViewScale=0.200000
     BobDamping=0.972000
     PickupViewMesh=LodMesh'AX.Rocketlpickup'
     PickupViewScale=0.650000
     ThirdPersonMesh=LodMesh'AX.Rocketl3rd'
     ThirdPersonScale=0.600000
     StatusIcon=Texture'AX.Icons.usemine'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzFF3'
     MuzzleFlashScale=0.400000
     MuzzleFlashTexture=Texture'Botpack.Skins.MuzzyFlak'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'AX.Icons.usemine'
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.Rocketl3rd'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=23.000000
     LightBrightness=228
     LightHue=30
     LightSaturation=71
     LightRadius=14
}
