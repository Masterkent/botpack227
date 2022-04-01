//=============================================================================
//
//
//
//
//=============================================================================
class m79 extends addweapons;

// right hand

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

//left hand


// pickup mesh

//3 rd mesh view

var int Count;
var PlayerPawn PlayerOwnerX;
var PlayerPawn M79Pawn;
var int NumFire;
var vector OwnerLocation;
var float StillTime, StillStart;

var int B227_ServerRecoil, B227_ClientRecoil;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_ToggleZoom;

	reliable if (Role == ROLE_Authority)
		B227_ServerRecoil;
}


// set which hand is holding weapon
function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("addweap.m79L", class'Mesh'));
	else
		Mesh = mesh'm79';
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



function Finish()
{
	if ( (Pawn(Owner).bFire!=0) && (FRand() < 0.6) )
		Timer();
	Super.Finish();
}





///////////////////////////////////////////////////////////////////////////////////
state Zooming
{
	event BeginState()
	{
		Owner.PlaySound(ZoomSound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
		B227_ToggleZoom();
		Pawn(Owner).bAltFire = 0;
		GoToState('Idle');
	}
}

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn P;
	local float Scale;
        local float Dist;
	local Pawn Pr;
	local int XPos, YPos;
	local Vector X,Y,Z, Dir;
        local Pawn PawnOwner;



	Super(TournamentWeapon).PostRender(Canvas);
	P = PlayerPawn(Owner);

	if  (P != None)
	{

	 Canvas.SetPos(Canvas.ClipX-140 , ClipCountOffset * Canvas.ClipY);
     Canvas.Style = ERenderStyle.STY_Translucent;
     Canvas.Font = Canvas.SmallFont;
     Canvas.DrawText("Shots remaining:"$AClipCount);
	}



	if ( (P != None) && (P.DesiredFOV != P.DefaultFOV) )
	{


		bOwnsCrossHair = true;
		Scale = Canvas.ClipX/640;
		Canvas.SetPos(0.5 * Canvas.ClipX - 128 * Scale, 0.5 * Canvas.ClipY - 128 * Scale );
                Canvas.Style = ERenderStyle.STY_Translucent;
		shotc=0;
		Canvas.DrawIcon(Texture'm79reticle', Scale);
		Canvas.SetPos(0.5 * Canvas.ClipX + 64 * Scale, 0.5 * Canvas.ClipY + 96 * Scale);
		Canvas.DrawColor.R = 155;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Scale = P.DefaultFOV/P.DesiredFOV;
		//Canvas.DrawText("X"$int(Scale)$"."$int(10 * Scale - 10 * int(Scale)));


	      }



   	else
		{

		 bOwnsCrossHair = false;


		}
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist, Rating;
	local bool bRetreating;
	local vector EnemyDir;
	local Pawn P;

	// don't recommend self if out of ammo
	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	// by default use regular mode (rockets)
	bUseAltMode = 0;
	P = Pawn(Owner);
	if ( P.Enemy == None )
		return AIRating;

	// if standing on a lift, make sure not about to go around a corner and lose sight of target
	// (don't want to blow up a rocket in bot's face)
	if ( (P.Base != None) && (P.Base.Velocity != vect(0,0,0))
		&& !P.CheckFutureSight(0.1) )
		return 0.1;

	EnemyDir = P.Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	Rating = AIRating;

	// don't pick rocket launcher is enemy is too close
	if ( EnemyDist < 360 )
	{
		if ( P.Weapon == self )
		{
			// don't switch away from rocket launcher unless really bad tactical situation
			if ( (EnemyDist > 230) || ((P.Health < 50) && (P.Health < P.Enemy.Health - 30)) )
				return Rating;
		}
		return 0.05 + EnemyDist * 0.001;
	}

	// increase rating for situations for which rocket launcher is well suited
	if ( P.Enemy.IsA('StationaryPawn') )
		Rating += 0.4;

	// rockets are good if higher than target, bad if lower than target
	if ( Owner.Location.Z > P.Enemy.Location.Z + 120 )
		Rating += 0.25;
	else if ( P.Enemy.Location.Z > Owner.Location.Z + 160 )
		Rating -= 0.35;
	else if ( P.Enemy.Location.Z > Owner.Location.Z + 80 )
		Rating -= 0.05;

	// decide if should use alternate fire (grenades) instead
	//if ( (Owner.Physics == PHYS_Falling) || Owner.Region.Zone.bWaterZone )
	//	bUseAltMode = 0;
	//else if ( EnemyDist < -1.5 * EnemyDir.Z )
	//	bUseAltMode = int( FRand() < 0.5 );
	//else
	//{
		//// grenades are good covering fire when retreating
		//bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );
		//bUseAltMode = 0;
		//if ( bRetreating && (EnemyDist < 800) && (FRand() < 0.4) )
			//bUseAltMode = 1;
	//}
	return Rating;
}

// return delta to combat style while using this weapon
function float SuggestAttackStyle()
{
	local float EnemyDist;

	// recommend backing off if target is too close
	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 600 )
	{
		if ( EnemyDist < 300 )
			return -1.5;
		else
			return -0.7;
	}
	else
		return -0.2;
}


function PlayPostSelect()
{
	Super.PlayPostSelect();
	AClipCount = 1;

}

function FireM79Rocket()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	//AimError = Default.AimError;
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustAim(ProjectileSpeed, StartTrace, AimError, True, bWarnTarget);
	Spawn(class'WeaponLight',,'',StartTrace+X*20,rot(0,0,0));
	Spawn( class'm79rocket',, '', StartTrace,AdjustedAim);
	B227_Recoil(2400);
}

function Fire( float Value )
{
	Enable('Tick');
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		SoundVolume = 255;//*Pawn(Owner).SoundDampening;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bCanClientFire = true;
		bPointing=True;
		ClientFire(value);
		GotoState('NormalFire');
	}
	else GoToState('Idle');
}
////////////////////////////////////////////////////////////////////////////////
state Idle
{

	function BeginState()
	{
		bPointing = false;
		SetTimer(0.4 + 1.6 * FRand(), false);
		Super.BeginState();
	}

	function EndState()
	{
		bSteadyFlash3rd = False;
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

////////////////////////////////////////////////////////////////////////////
state NormalFire
{
	function Tick( float DeltaTime )
	{
		if (Owner==None)
			AmbientSound = None;
	}

	function AnimEnd()
	{

	}

	function BeginState()
	{


	}

	function EndState()
	{


		bSteadyFlash3rd = False;
		Super.EndState();
		OldFlashCount = FlashCount;

	}

Begin:

	PlayFiring();
        bMuzzleflash++;
	FireM79Rocket();
        AimError = Default.AimError;
	FinishAnim();
	AClipCount--;
	if (  ( bChangeWeapon ) ) GotoState('DownWeapon');
        else  GoToState('NewClip');


}

function PlayFiring()
{
	PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	PlayAnim('fire',7, 0.05);
	bMuzzleFlash++;
}

function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
	{
		PlayAnim('Still',1.0, 0.05);

	}

	shotc=0;
	bSteadyFlash3rd = False;
}



////////////////////////////////////////////////////////
state NewClip

{
ignores Fire, AltFire;



Begin:
   	M79Pawn = PlayerPawn(Owner);
	M79Pawn.EndZoom();
	bSteadyFlash3rd = False;

      if (Ammotype.ammoamount > 0)
      {
	PlayReloading();
	Sleep(1.5);
	Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	FinishAnim();
	shotc=0;
      }
	if (Ammotype.ammoamount <= 0)
		AClipCount = Ammotype.ammoamount;
	else AClipCount = 1;

	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( /*bFireMem ||*/ Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else if ( /*bAltFireMem ||*/ Pawn(Owner).bAltFire!=0 )
		Global.AltFire(0);
	else GotoState('Idle');
}


function PlayReloading()
{
	PlayAnim('Reloaded',1.0,0.05);
}


simulated function B227_ToggleZoom()
{
	if (PlayerPawn(owner).DefaultFOV != PlayerPawn(owner).DesiredFOV)
		PlayerPawn(owner).DesiredFOV = PlayerPawn(owner).DefaultFOV;
	else
		PlayerPawn(owner).DesiredFOV = ADMaxFOV;
}

function B227_Recoil(int Recoil)
{
	if (PlayerPawn(Owner) == none)
		return;
	if (Viewport(PlayerPawn(Owner).Player) != none)
		B227_ApplyRecoil(Recoil);
	else
	{
		if (B227_ServerRecoil > 2000000000)
			B227_ServerRecoil = 0;
		B227_ServerRecoil += Recoil;
	}
}

simulated event PostNetReceive()
{
	B227_ClientApplyRecoil();
}

simulated function B227_ClientApplyRecoil()
{
	if (B227_ServerRecoil > B227_ClientRecoil)
		B227_ApplyRecoil(B227_ServerRecoil - B227_ClientRecoil);
	else if (B227_ServerRecoil < B227_ClientRecoil)
		B227_ApplyRecoil(B227_ServerRecoil);
	B227_ClientRecoil = B227_ServerRecoil;
}

simulated function B227_ApplyRecoil(int Recoil)
{
	if (PlayerPawn(Owner) == none)
		return;
	if (16384 < Pawn(Owner).ViewRotation.Pitch && Pawn(Owner).ViewRotation.Pitch < 32768)
		return;

	Pawn(Owner).ViewRotation.Pitch += Recoil;
	if (16384 < Pawn(Owner).ViewRotation.Pitch && Pawn(Owner).ViewRotation.Pitch < 32768)
		Pawn(Owner).ViewRotation.Pitch = 16384;
}

defaultproperties
{
     ZoomSound=Sound'addweap.Msg.msgzoom'
     ADMAXFOV=30
     WeaponDescription="Classification: M79"
     AmmoName=Class'addweap.m79ammo'
     PickupAmmoCount=1
     FiringSpeed=1.800000
     FireOffset=(Y=-5.000000,Z=-2.000000)
     ProjectileSpeed=2000.000000
     shaketime=0.150000
     shakevert=8.000000
     AIRating=0.750000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'addweap.m79.m79fire'
     SelectSound=Sound'Botpack.Redeemer.WarheadPickup'
     Misc1Sound=Sound'addweap.m79.m79reload'
     Misc2Sound=Sound'addweap.hkg11.HKG11Reload'
     Misc3Sound=Sound'addweap.hkg11.HKG11Reload'
     DeathMessage="%k erased %o'from this world..."
     NameColor=(R=0,G=0)
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.110000
     FlashO=0.014000
     FlashC=0.031000
     FlashLength=0.013000
     FlashS=256
     MFTexture=Texture'Botpack.Rifle.MuzzleFlash2'
     AutoSwitchPriority=10
     InventoryGroup=9
     bRotatingPickup=False
     PickupMessage="You got M79 Rocket launcher..enjoy."
     ItemName="m79"
     PlayerViewOffset=(X=7.400000,Y=-4.600000,Z=-1.000000)
     PlayerViewMesh=LodMesh'addweap.m79'
     PlayerViewScale=0.650000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'addweap.m79Pick'
     PickupViewScale=1.500000
     ThirdPersonMesh=LodMesh'addweap.m79Hand'
     ThirdPersonScale=1.300000
     StatusIcon=Texture'Botpack.Icons.UseRifle'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseRifle'
     Rotation=(Roll=-1536)
     Mesh=LodMesh'addweap.m79'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightSaturation=32
     LightRadius=12
     bNetNotify=True
}
