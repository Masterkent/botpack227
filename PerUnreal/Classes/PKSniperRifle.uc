//=============================================================================
// PKSniperRifle
// A military redesign of the rifle.
//=============================================================================
class PKSniperRifle extends TournamentWeapon;

#exec OBJ LOAD FILE="PerUnrealResources.u" PACKAGE=PerUnreal

var int NumFire;
var name FireAnims[5];
var vector OwnerLocation;
var float StillTime, StillStart;

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn P;
	local float Scale;

	Super.PostRender(Canvas);

	AmbientGlow = 0;
	P = PlayerPawn(Owner);
	if ( (P != None) && (P.DesiredFOV != P.DefaultFOV) )
	{
		bOwnsCrossHair = true;
		Canvas.Font = class'FontInfo'.static.GetStaticSmallFont(class'UTC_HUD'.static.B227_CrosshairSize(Canvas, 1));
		Scale = class'UTC_HUD'.static.B227_CrosshairSize(Canvas, 640);
		Canvas.SetPos(0.5 * Canvas.ClipX - 128 * Scale, 0.5 * Canvas.ClipY - 128 * Scale );
		if ( Level.bHighDetailMode )
			Canvas.Style = ERenderStyle.STY_Translucent;
		else
			Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawIcon(Texture'RReticle', Scale);
		Canvas.SetPos(0.5 * Canvas.ClipX + 64 * Scale, 0.5 * Canvas.ClipY + 96 * Scale);
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
		Scale = P.DefaultFOV/P.DesiredFOV;
		Canvas.DrawText("X"$int(Scale)$"."$int(10 * Scale - 10 * int(Scale)));

		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 255;
	}
	else
		bOwnsCrossHair = false;
}

function float RateSelf( out int bUseAltMode )
{
	local float dist;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	bUseAltMode = 0;
	if ( (Bot(Owner) != None) && Bot(Owner).bSniping )
		return AIRating + 1.15;
	if (  Pawn(Owner).Enemy != None )
	{
		dist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
		if ( dist > 1200 )
		{
			if ( dist > 2000 )
				return (AIRating + 0.75);
			return (AIRating + FMin(0.0001 * dist, 0.45));
		}
	}
	return AIRating;
}

// set which hand is holding weapon
function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("Botpack.Rifle2mL", class'Mesh'));
	else
		Mesh = mesh'Rifle2m';
}

function PlayFiring()
{
	AmbientGlow = 250;
	PlaySound(FireSound, SLOT_None, B227_SoundDampening(),,, level.timedilation+0.2+0.2*FRand());
	PlaySound(FireSound, SLOT_None, B227_SoundDampening(),,8192, level.timedilation-0.2+0.2*FRand());
	PlayAnim(FireAnims[Rand(5)],0.5 + 0.5 * FireAdjust, 0.05);

	if ( (PlayerPawn(Owner) != None)
		&& (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV) )
		bMuzzleFlash++;
}


function bool ClientAltFire( float Value )
{
	PlaySound(Misc1Sound, SLOT_Misc, 1.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1);
	GotoState('Zooming');
	return true;
}

function AltFire( float Value )
{
	PlaySound(Misc1Sound, SLOT_Misc, 1.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1);
	ClientAltFire(Value);
}

///////////////////////////////////////////////////////
state NormalFire
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

Begin:
	FlashCount++;
}

function Timer()
{
	local actor targ;
	local float bestAim, bestDist;
	local vector FireDir;
	local Pawn P;

	bestAim = 0.95;
	P = Pawn(Owner);
	if ( P == None )
	{
		GotoState('');
		return;
	}
	if ( VSize(P.Location - OwnerLocation) < 6 )
		StillTime += FMin(2.0, Level.TimeSeconds - StillStart);

	else
		StillTime = 0;
	StillStart = Level.TimeSeconds;
	OwnerLocation = P.Location;
	FireDir = vector(P.ViewRotation);
	targ = P.PickTarget(bestAim, bestDist, FireDir, Owner.Location);
	if ( Pawn(targ) != None )
	{
		SetTimer(1 + 4 * FRand(), false);
		bPointing = true;
		Pawn(targ).WarnTarget(P, 200, FireDir);
	}
	else
	{
		SetTimer(0.4 + 1.6 * FRand(), false);
		if ( (P.bFire == 0) && (P.bAltFire == 0) )
			bPointing = false;
	}
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_ShellCase s;

	s = Spawn(class'UT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
	if ( s != None )
	{
		s.DrawScale = 2.0;
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
	}
	if (Other == Level)
		Spawn(class'PKWallHit3',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other != self) && (Other != Owner) && (Other != None) )
	{
		if ( Other.bIsPawn )
			Other.PlaySound(sound'PKchunkhit',, 2.0,,1000, 0.9+0.2*FRand());
		if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
			&& (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)) )
			Other.TakeDamage(100, Pawn(Owner), HitLocation, 35000 * X, AltDamageType);
		else
			Other.TakeDamage(45,  Pawn(Owner), HitLocation, 30000.0*X, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}

function Finish()
{
	if ( (Pawn(Owner).bFire!=0) && (FRand() < 0.6) )
		Timer();
	Super.Finish();
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + PawnOwner.Eyeheight * Z;
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);
	X = vector(AdjustedAim);
	EndTrace = StartTrace + 1000000 * X;
	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}


state Idle
{
	function Fire( float Value )
	{
		if ( AmmoType == None )
		{
			// ammocheck
			GiveAmmo(Pawn(Owner));
		}
		if (AmmoType.UseAmmo(1))
		{
			GotoState('NormalFire');
			bCanClientFire = true;
			bPointing=True;
			if ( Owner.IsA('Bot') )
			{
				// simulate bot using zoom
				if ( Bot(Owner).bSniping && (FRand() < 0.65) )
					AimError = AimError/FClamp(StillTime, 1.0, 8.0);
				else if ( VSize(Owner.Location - OwnerLocation) < 6 )
					AimError = AimError/FClamp(0.5 * StillTime, 1.0, 3.0);
				else
					StillTime = 0;
			}
			Pawn(Owner).PlayRecoil(FiringSpeed);
			TraceFire(0.0);
			AimError = Default.AimError;
			ClientFire(Value);
		}
	}


	function BeginState()
	{
		bPointing = false;
		SetTimer(0.4 + 1.6 * FRand(), false);
		Super.BeginState();
	}

	function EndState()
	{
		SetTimer(0.0, false);
		Super.EndState();
	}

Begin:
	bPointing=False;
	if ( AmmoType.AmmoAmount<=0 )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	Disable('AnimEnd');
	PlayIdleAnim();
}

///////////////////////////////////////////////////////
state Zooming
{
	function Tick(float DeltaTime)
	{
		if (Pawn(Owner) != none && Pawn(Owner).bAltFire == 0)
		{
			if (PlayerPawn(Owner) != none)
				PlayerPawn(Owner).StopZoom();
			PlaySound(Misc2Sound, SLOT_Misc, 1.0*Pawn(Owner).SoundDampening,,, Level.TimeDilation-0.1);
			SetTimer(0.0,False);
			GoToState('Idle');
		}
	}

	function BeginState()
	{
		if ( Owner.IsA('PlayerPawn') )
		{
			PlayerPawn(Owner).ToggleZoom();
			SetTimer(0.2,True);
		}
		else
		{
			Pawn(Owner).bFire = 1;
			Pawn(Owner).bAltFire = 0;
			Global.Fire(0);
		}
	}
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim('Still',1.0, 0.05);
}

function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',1.0,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, B227_SoundDampening(),,, Level.TimeDilation-0.1+0.1*FRand());
}

defaultproperties
{
     FireAnims(0)=Fire
     FireAnims(1)=Fire2
     FireAnims(2)=Fire3
     FireAnims(3)=Fire4
     FireAnims(4)=Fire5
     WeaponDescription="Classification: Long Range Ballistic"
     AmmoName=Class'PerUnreal.PKBulletBox'
     PickupAmmoCount=8
     bInstantHit=True
     bAltInstantHit=True
     FiringSpeed=1.800000
     FireOffset=(Y=-5.000000,Z=-2.000000)
     MyDamageType=shot
     AltDamageType=Decapitated
     shakemag=400.000000
     shaketime=0.150000
     shakevert=8.000000
     AIRating=0.540000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'PerUnreal.Sniper.PKsniper'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
     Misc1Sound=Sound'PerUnreal.Sniper.PKzoomstart'
     Misc2Sound=Sound'PerUnreal.Sniper.PKzoomstop'
     DeathMessage="%k put a bullet through %o's head."
     NameColor=(R=0,G=0)
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.110000
     FlashO=0.014000
     FlashC=0.031000
     FlashLength=0.013000
     FlashS=256
     MFTexture=Texture'Botpack.Rifle.MuzzleFlash2'
     AutoSwitchPriority=5
     InventoryGroup=10
     PickupMessage="You got a Sniper Rifle."
     ItemName="Sniper Rifle"
     RespawnTime=6.000000
     PlayerViewOffset=(X=5.000000,Y=-1.600000,Z=-1.700000)
     PlayerViewMesh=LodMesh'Botpack.Rifle2m'
     PlayerViewScale=2.000000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'Botpack.RiflePick'
     ThirdPersonMesh=LodMesh'Botpack.RifleHand'
     StatusIcon=Texture'Botpack.Icons.UseRifle'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'PerUnreal.Misc.PKpickup'
     Icon=Texture'Botpack.Icons.UseRifle'
     Rotation=(Roll=-1536)
     Mesh=LodMesh'Botpack.RiflePick'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
}
