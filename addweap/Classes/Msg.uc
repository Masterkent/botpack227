//=============================================================================
//
//
//=============================================================================
class msg extends Addweapons;

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

////////////left hand


// pickup mesh

//3 rd mesh view


var int Count;

var vector OwnerLocation;
var float StillTime, StillStart;
var bool bIsInZoom;

var bool B227_bIsInZoom;
var int B227_ServerRecoil, B227_ClientRecoil;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_ZoomIn;

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
         Canvas.DrawText("Shots in clip:"$AClipCount);
	}


	if ( (P != None) && (P.DesiredFOV != P.DefaultFOV) )
	{


		 bOwnsCrossHair = true;
		 Scale = Canvas.ClipX/1024*1.16;
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
		Mesh = mesh(DynamicLoadObject("addweap.msgL", class'Mesh'));
	else
		Mesh = mesh'msg';
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

	if (Ammotype.ammoamount <= 9)
		AClipCount = Ammotype.ammoamount;
	else
		AClipCount = 10;

	bIsInZoom = false;
	B227_bIsInZoom = false;
	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).EndZoom();
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;
        local Pawn PawnOwner;
        local UT_ShellCase s;

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

        //weapon light
 	Spawn(class'WeaponLight',,'',StartTrace,rot(0,0,0));


	//recoil
	B227_Recoil(700);


	// visible tracing
	Count++;
	if ( Count == 3 )
	{
		Count = 0;
		if ( VSize(HitLocation - StartTrace) > 250 ) Spawn(class'MTracerMSG',,, StartTrace + 96 * AimDir,rotator(EndTrace - StartTrace));
	}
        s = Spawn(class'UT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
	if ( s != None )
	{
		s.DrawScale = 1.5;
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
	}

	 ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);

}


function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{



	if (Other == Level) Spawn(class'ADHeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
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
	PlayAnim('fire',0.5 + (0.5 *FireAdjust*2), 0.05);

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
		PlayAnim('Still',1.0, 0.05);

	bSteadyFlash3rd = False;
}


function PlayReloading()
{
	PlayAnim('Reloaded',1.3,0.05);
}


////////////////////////////////////////////////////////
state NewClip

{
ignores Fire, Altfire ;




Begin:

	PlayerPawn(Owner).EndZoom();
	bSteadyFlash3rd = False;
	if (Ammotype.ammoamount <= 9) AClipCount = Ammotype.ammoamount;
	else AClipCount = 10;

	if (Ammotype.ammoamount >= 0)
	{
	PlayReloading();
	Sleep(0.6);
	Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	Sleep(1.4);
	Owner.PlaySound(Misc2Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	Sleep(0.6);
	Owner.PlaySound(Misc3Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	FinishAnim();
	}




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

	event BeginState()
	{
		B227_ToggleZoom();
	}

	event EndState()
	{
		if (bIsInZoom && !B227_bIsInZoom)
			bIsInZoom = false;
	}

	function AnimEnd()
	{
		Owner.PlaySound(ZoomSound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
		if (bIsInZoom)
		{
			B227_bIsInZoom = true;
			B227_ZoomIn();
		}

		Pawn(Owner).bAltFire = 0;
		GoToState('Idle');
	}
}

simulated function B227_ZoomIn()
{
	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).DesiredFOV = ADMaxFOV;
}

function B227_ToggleZoom()
{
	bIsInZoom = !bIsInZoom;
	if (bIsInZoom)
		PlayAnim('Zoom',1,0.05);
	else
	{
		B227_bIsInZoom = false;
		PlayAnim('DeZoom',1,0.05);
	}

	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).EndZoom();
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
     ShotAccuracyBase=0.000000
     LegDamage=50
     HeadDamage=200
     ArmorDamage=100
     ZoomSound=Sound'addweap.Msg.msgzoom'
     ADMAXFOV=18
     WeaponDescription="Classification: Long Range Ballistic"
     AmmoName=Class'addweap.MsgAmmo'
     PickupAmmoCount=10
     bInstantHit=True
     bAltInstantHit=True
     FiringSpeed=3.800000
     FireOffset=(Y=-5.000000,Z=-2.000000)
     shakemag=400.000000
     shaketime=0.150000
     shakevert=8.000000
     AIRating=0.540000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'addweap.Msg.msgfire'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
     Misc1Sound=Sound'addweap.Msg.msgclipout'
     Misc2Sound=Sound'addweap.Msg.msgclipin'
     Misc3Sound=Sound'addweap.mpk.mpkSlide'
     DeathMessage="%k put a bullet through %o's brain."
     NameColor=(R=0,G=0)
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.110000
     FlashO=0.014000
     FlashC=0.031000
     FlashLength=0.013000
     FlashS=256
     MFTexture=Texture'Botpack.Rifle.MuzzleFlash2'
     AutoSwitchPriority=8
     InventoryGroup=5
     bRotatingPickup=False
     PickupMessage="You got a MSG 90."
     ItemName="MSG 90"
     PlayerViewOffset=(X=10.500000,Y=-4.600000,Z=-4.000000)
     PlayerViewMesh=LodMesh'addweap.Msg'
     PlayerViewScale=0.700000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'addweap.msgPick'
     PickupViewScale=1.400000
     ThirdPersonMesh=LodMesh'addweap.msghand'
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
     Mesh=LodMesh'addweap.Msg'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
     Mass=30.000000
     bNetNotify=True
}
