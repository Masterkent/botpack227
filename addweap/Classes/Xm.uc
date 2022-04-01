//=============================================================================
//
//
//
//
//=============================================================================
class xm extends Addweapons;

// right hand

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

//left

// pickup mesh

//3 rd mesh view

var vector OwnerLocation;
var float StillTime, StillStart;

var int B227_ServerRecoil, B227_ClientRecoil;

replication
{
	reliable if (Role == ROLE_Authority)
		B227_ServerRecoil;
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
     Canvas.DrawText("Shots in clip:"$AClipCount);
	}


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

	return rating;
}

// set which hand is holding weapon
function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("addweap.xmL", class'Mesh'));
	else
		Mesh = mesh'xm';
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
	if (Ammotype.ammoamount <= 7)
		AClipCount = Ammotype.ammoamount;
	else AClipCount = 8;
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;
        local Pawn PawnOwner;
	local int i;
        local UT_Shellcase s;

	s = Spawn(class'XmShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
	if ( s != None )
	{
		s.DrawScale = 1.5;
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
	}

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + PawnOwner.Eyeheight * Z;
        AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);
	AimDir = vector(AdjustedAim);
	//weapon light
 	Spawn(class'WeaponLight',,'',StartTrace,rot(0,0,0));

	//recoil
	B227_Recoil(1200);

	AdjustAccuracy(owner,ShotAccuracyBase,ShotAccuracy);
	for (i=0;I<12;I++)
	{

	EndTrace = StartTrace + ShotAccuracy * (FRand() - 0.5 )* Y * 100*2
		+ ShotAccuracy * (FRand() - 0.5 ) * Z * 100*2;
	EndTrace += (1000*2 * AimDir);
	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);

	if  ( (VSize(HitLocation - StartTrace) > 100 ) && (i==1 || i==5 || i==8 ) ) Spawn(class'MTracerXM',,, StartTrace + 60 * AimDir,rotator(EndTrace - StartTrace));
	}




}


function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{

	local UT_HeavyWallHitEffect s;

	if (Other == Level)
	{
	s=Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	s.SoundVolume=128;
	s.SoundRadius=8;
	}

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


function AltFire( float Value )
{
	GoToState('NewClip');
}

function PlayFiring()
{
	PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	PlayAnim('fire',0.5 + 0.5 *(FireAdjust*0.15), 0.05);
	if  (PlayerPawn(Owner) != None) bMuzzleFlash++;
}

function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		PlayAnim('Still',1.0, 0.05);
}

function Fire( float Value )
{
		if ( AmmoType == None )
		{
			// ammocheck
			GiveAmmo(Pawn(Owner));
		}
		if (AmmoType.UseAmmo(1))
		{

	               If (AClipCount> 0)
		       {
			 AClipCount--;
	               	GotoState('NormalFire');
			bCanClientFire = true;
			bPointing=True;
			Pawn(Owner).PlayRecoil(FiringSpeed);
			TraceFire(0.5);
			AimError = Default.AimError;
			ClientFire(Value);
		       }
		       else GotoState('NewClip');

		}
		else GoToState('Idle');

}





/////////////////////////////////////////////////////////////////////////////
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


function PlayReloading()

{
  PlayAnim('Reloaded',1.2,0.05);
}


////////////////////////////////////////////////////////
state NewClip
{
ignores Fire, AltFire;

Begin:

	if (Ammotype.ammoamount <= 7)
		AClipCount = Ammotype.ammoamount;
	else AClipCount = 8;

	if (Ammotype.ammoamount >= 0)
	{
	PlayReloading();
	Sleep(0.9);
	Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	Sleep(3.1);
        Owner.PlaySound(Misc2Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);


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
     ShotAccuracyBase=2.500000
     LegDamage=8
     HeadDamage=12
     ArmorDamage=12
     WeaponDescription="Classification: XM 1014 Shotgun"
     AmmoName=Class'addweap.XmAmmo'
     PickupAmmoCount=8
     bInstantHit=True
     bAltInstantHit=True
     FiringSpeed=1.800000
     FireOffset=(Y=-5.000000,Z=-2.000000)
     shaketime=0.150000
     shakevert=8.000000
     AIRating=0.720000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'addweap.Xm.xmshot'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
     Misc1Sound=Sound'addweap.Xm.xmreload'
     Misc2Sound=Sound'addweap.Xm.xmreloadend'
     DeathMessage="%k put some shrapnels through %o's body."
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
     InventoryGroup=8
     bRotatingPickup=False
     PickupMessage="You got Benelli XM1014 ."
     ItemName="xm1014"
     PlayerViewOffset=(X=7.400000,Y=-4.600000,Z=-4.500000)
     PlayerViewMesh=LodMesh'addweap.Xm'
     PlayerViewScale=0.800000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'addweap.xmPick'
     PickupViewScale=0.900000
     ThirdPersonMesh=LodMesh'addweap.xmHand'
     ThirdPersonScale=0.650000
     StatusIcon=Texture'Botpack.Icons.UseRifle'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseRifle'
     Rotation=(Roll=-1536)
     Mesh=LodMesh'addweap.Xm'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
     bNetNotify=True
}
