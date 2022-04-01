//=============================================================================
// Sniper.
//=============================================================================
class Sniper expands AXweapons;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

//3rd person


//pickup


var int NumFire;
var name FireAnims[5];
var vector OwnerLocation;
var float StillTime, StillStart;

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn P;
	local float Scale;

	Super.PostRender(Canvas);
	P = PlayerPawn(Owner);
	if ( (P != None) && (P.DesiredFOV != P.DefaultFOV) )
	{
		bOwnsCrossHair = true;
		Scale = Canvas.ClipX/640;
		Canvas.SetPos(0.5 * Canvas.ClipX - 128 * Scale, 0.5 * Canvas.ClipY - 128 * Scale );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.DrawIcon(Texture'aRetcle', Scale);
		Canvas.SetPos(0.5 * Canvas.ClipX + 64 * Scale, 0.5 * Canvas.ClipY + 96 * Scale);
		Canvas.DrawColor.R = 155;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Scale = P.DefaultFOV/P.DesiredFOV;
		Canvas.DrawText("X"$int(Scale)$"."$int(10 * Scale - 10 * int(Scale)));
		Canvas.Reset();
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




function PlayFiring()
{
	PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	PlayAnim(FireAnims[Rand(5)],0.5 + 0.5 * FireAdjust, 0.05);

	if ( (PlayerPawn(Owner) != None)
		&& (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV) )
		bMuzzleFlash++;
}


function bool ClientAltFire( float Value )
{
	GotoState('Zooming');
	return true;
}

function AltFire( float Value )
{
	ClientAltFire(Value);
}


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
	local UT_Shellcase s;

	s = Spawn(class'UT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
	if ( s != None )
	{
		s.DrawScale = 2.0;
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
	}
	if (Other == Level)
		Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other != self) && (Other != Owner) && (Other != None) )
	{
		if ( Other.bIsPawn )
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
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
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000 + 10000 * X;
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
             ///if (playerpawn(owner).desiredFOV != playerpawn(owner).defaultFOV)
             /// {
			TraceFire(0.0);
             ///    }
             ///if (playerpawn(owner).desiredFOV == playerpawn(owner).defaultFOV)
             ///      {
             ///     Tracefire(1.4);
             ///      }
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
		if ( Pawn(Owner).bAltFire == 0 )
		{
			if (PlayerPawn(Owner) != None)
				PlayerPawn(Owner).StopZoom();
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

defaultproperties
{
     FireAnims(0)=Fire
     FireAnims(1)=Fire
     FireAnims(2)=Fire
     FireAnims(3)=Fire
     FireAnims(4)=Fire
     WeaponDescription="Classification: Long Range Ballistic"
     AmmoName=Class'AX.Sniperammo'
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
     RefireRate=1.000000
     AltRefireRate=0.900000
     FireSound=Sound'AX.Sounds.Rifle'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
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
     InventoryGroup=9
     PickupMessage="You got a Sniper Rifle."
     ItemName="Sniper Rifle"
     PlayerViewOffset=(X=6.200000,Y=-1.750000,Z=-4.400000)
     PlayerViewMesh=LodMesh'AX.Sniper'
     PlayerViewScale=0.200000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'AX.Sniperpickup'
     ThirdPersonMesh=LodMesh'AX.Sniper3rd'
     ThirdPersonScale=0.675000
     StatusIcon=Texture'AX.Icons.usesniper'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'AX.Icons.usesniper'
     Physics=PHYS_Falling
     Rotation=(Roll=-1536)
     Mesh=LodMesh'AX.Sniper3rd'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
}
