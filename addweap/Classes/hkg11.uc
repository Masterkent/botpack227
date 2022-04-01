//=============================================================================
//
//
//
//
//=============================================================================
class hkg11 extends addweapons;

// right hand

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

//left hand


// pickup mesh

//3 rd mesh view

//#exec TEXTURE IMPORT NAME=hkcross FILE=textures\hkcross.PCX GROUP=Skins FLAGS=2

var int Count;

var vector OwnerLocation;
var float StillTime, StillStart;
var () int HKGMAXFov;

var int B227_ServerRecoil, B227_ClientRecoil;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_ToggleZoom;

	reliable if (Role == ROLE_Authority)
		B227_ServerRecoil;
}


simulated event RenderOverlays( canvas Canvas )
{
	local UT_Shellcase s;
	local vector X,Y,Z;
	local float dir;


	FlashY = Default.FlashY * (1.08 - 0.16 * FRand());
	if ( !Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Handedness == 0) )
	FlashO = Default.FlashO * (4 + 0.15 * FRand());
	else
	FlashO = Default.FlashO * (1 + 0.15 * FRand());

	Super(TournamentWeapon).RenderOverlays(Canvas);


}

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn P;
	local float Scale;
        local float Dist;
	local int XPos, YPos;
	local Pawn PawnOwner;



	Super.PostRender(Canvas);
	P = PlayerPawn(Owner);

	if  (P != None)
	{

	 Canvas.SetPos(Canvas.ClipX-140, ClipCountOffset * Canvas.ClipY);
         Canvas.Style = ERenderStyle.STY_Translucent;
         Canvas.Font = Canvas.SmallFont;
         Canvas.DrawText("Shots in cartridge:"$AClipCount);

	}


	if ( (P != None) && (P.DesiredFOV != P.DefaultFOV) )
	{


		 bOwnsCrossHair = true;
		 Scale = Canvas.ClipX/1024*1.16;
		 shotc=0;
		 Canvas.Style = ERenderStyle.STY_Masked;
                 Canvas.SetPos(0,0);
                 Canvas.DrawTile(texture'cliptest', Canvas.ClipX, Canvas.ClipY/2, 0, 0, 256,128);
                 Canvas.SetPos(0,Canvas.ClipY/2);
                 Canvas.DrawTile(texture'cliptest2', Canvas.ClipX, Canvas.ClipY/2, 0, 0, 256,128);
		 Canvas.SetPos(Canvas.ClipX/2-256*scale,Canvas.ClipY/2-256*scale);
                 Canvas.DrawIcon(texture'rectileA1',Scale);
                 Canvas.SetPos(Canvas.ClipX/2,Canvas.ClipY/2-256*Scale);
                 Canvas.DrawIcon(texture'rectileA2',Scale);
		 Canvas.SetPos(Canvas.ClipX/2-256*scale,Canvas.ClipY/2);
                 Canvas.DrawIcon(texture'rectileB1',Scale);
                 Canvas.SetPos(Canvas.ClipX/2,Canvas.ClipY/2);
                 Canvas.DrawIcon(texture'rectileB2',Scale);

       }
   	else
		{

		bOwnsCrossHair = false;


		}
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

		    return (AIRating + 0.25);

		}
	}
	return AIRating;
}

// set which hand is holding weapon
function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("addweap.hkL", class'Mesh'));
	else
		Mesh = mesh'hk';
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

function PlayPostSelect()
{
	Super.PlayPostSelect();
	shotc=0;
	if (Ammotype.ammoamount <= 32)
	AClipCount = Ammotype.ammoamount;
	else AClipCount = 33;

}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;
        local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);


	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + PawnOwner.Eyeheight * Z;
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);
	X = vector(AdjustedAim);

	AdjustAccuracy(owner,ShotAccuracyBase,ShotAccuracy);

	 EndTrace = StartTrace + ShotAccuracy * (FRand() - 0.5 )* Y * 1000
		+ ShotAccuracy * (FRand() - 0.5 ) * Z * 1000;
	 AimDir = vector(AdjustedAim);
	 EndTrace += (10000 * AimDir);


	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);



	//recoil
	B227_Recoil(shotc * 8);
	shotc++;

	// visible tracing
        Count++;
	if ( Count == 3 )
	{
		Count = 0;
		if ( VSize(HitLocation - StartTrace) > 250 ) Spawn(class'MTracerXM',,, StartTrace + 96 * AimDir,rotator(EndTrace - StartTrace));
	}

	 ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);

}


function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	if (Other == Level) Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other != self) && (Other != Owner) && (Other != None) )
	{
		if ( Other.bIsPawn )
		{
		        ProcessHitLocation(owner,Other,HitLocation,X,HeadDamage,ArmorDamage,LegDamage);
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
		}

		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
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
		If (AClipCount> 0)
		{
		AclipCount--;
		SoundVolume = 255;//*Pawn(Owner).SoundDampening;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bCanClientFire = true;
		bPointing=True;
		ClientFire(value);
		GotoState('NormalFire');
		}
		else
		{
		GotoState('NewClip');
		}
	}
	else GoToState('Idle');
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
	Tracefire(0.0);
        AimError = Default.AimError;
	FinishAnim();
        Finish();



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



function PlayFiring()
{
	PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	bSteadyFlash3rd = True;
	PlayAnim('fire',0.5 + 0.5 *(FireAdjust*17.0), 0.05);


	if (PlayerPawn(Owner) != None)
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

////////////////////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
	{
		PlayAnim('Still',1.0, 0.05);

	}

	shotc=0;
	bSteadyFlash3rd = False;
	}


function PlayReloading()
{
	PlayAnim('Reloaded',1.1,0.05);
}


////////////////////////////////////////////////////////
state NewClip

{
ignores Fire, Altfire ;

Begin:

	PlayerPawn(Owner).EndZoom();
	bSteadyFlash3rd = False;
	if (Ammotype.ammoamount <= 32) AClipCount = Ammotype.ammoamount;
	else AClipCount = 33;

	if (Ammotype.ammoamount >= 0)
	{
	PlayReloading();
	Sleep(0.9);
	Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	FinishAnim();
	}
	shotc=0;


	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( /*bFireMem ||*/ Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else if ( /*bAltFireMem ||*/ Pawn(Owner).bAltFire!=0 )
		Global.AltFire(0);
	else GotoState('Idle');
}


///////////////////////////////////////////////////////////////////////////////////
state Zooming
{
	function BeginState()
	{
		Owner.PlaySound(ZoomSound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
		B227_ToggleZoom();
		Pawn(Owner).bAltFire = 0;
		GoToState('Idle');
	}
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
     LegDamage=10
     HeadDamage=40
     ArmorDamage=20
     ZoomSound=Sound'addweap.Msg.msgzoom'
     ADMAXFOV=40
     WeaponDescription="Classification: H&K G11E assault rifle"
     AmmoName=Class'addweap.Hkg11Ammo'
     PickupAmmoCount=50
     bInstantHit=True
     bAltInstantHit=True
     bRapidFire=True
     FiringSpeed=1.800000
     FireOffset=(Y=-5.000000,Z=-2.000000)
     shaketime=0.150000
     shakevert=8.000000
     AIRating=0.540000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'addweap.hkg11.HKG11Fire'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
     Misc1Sound=Sound'addweap.hkg11.HKG11Reload'
     Misc2Sound=Sound'addweap.hkg11.HKG11Reload'
     Misc3Sound=Sound'addweap.hkg11.HKG11Reload'
     DeathMessage="%k put a 4.7MM bullet through %o's body."
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
     InventoryGroup=10
     bRotatingPickup=False
     PickupMessage="You got  H&K G11."
     ItemName="HKG11"
     PlayerViewOffset=(X=7.400000,Y=-4.600000,Z=-4.500000)
     PlayerViewMesh=LodMesh'addweap.hk'
     PlayerViewScale=0.650000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'addweap.HKPick'
     PickupViewScale=1.500000
     ThirdPersonMesh=LodMesh'addweap.HKHand'
     ThirdPersonScale=1.100000
     StatusIcon=Texture'Botpack.Icons.UseRifle'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseRifle'
     Rotation=(Roll=-1536)
     Mesh=LodMesh'addweap.hk'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
     bNetNotify=True
}
