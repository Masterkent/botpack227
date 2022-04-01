//=============================================================================
//
//
//
//
//=============================================================================
class smokegun extends addweapons;

// right hand

#exec OBJ LOAD FILE="addweapResources.u" PACKAGE=addweap

// left hand


// pickup mesh

//3 rd mesh view

//ammo mesh

var int Count;
var int shotc;
var vector OwnerLocation;
var float StillTime, StillStart;

// set which hand is holding weapon
function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("addweap.smokeGL", class'Mesh'));
	else
		Mesh = mesh'smokeG';
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
	OwnerLocation = P.Location;
	StillStart = Level.TimeSeconds;
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


simulated function PostRender( canvas Canvas )
{
	local PlayerPawn P;
	local float Scale;
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
	local float dist;
        local float EnemyDist;
	local bool bRetreating;
	local vector EnemyDir;
	local Pawn P;

        p = Pawn(owner);

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	if ( (p.Enemy != None) && (owner !=none ))

	{
	EnemyDir = P.Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );


	 if ( bRetreating && (EnemyDist < 800))
	 {
	  Return AIRating+0.35;
	  }
        }
	return AIRating;
}

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
	shotc=0;
	ClipCount = 0;
	if (Ammotype.ammoamount <= 7)
		AClipCount = Ammotype.ammoamount;
	else AClipCount = 8;
}

function LaunchSmoke()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;
        local Pawn PawnOwner;
	local int i;



	PawnOwner = Pawn(Owner);
	If (PawnOwner != none)
	{
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustToss(ProjectileSpeed, StartTrace, AimError, True, bWarnTarget);
	if ( Pawn(Owner) != None ) AdjustedAim = Pawn(Owner).ViewRotation;

	Spawn(class'WeaponLight',,'',StartTrace+X*20,rot(0,0,0));
	Spawn( class'smokeproj',, '', StartTrace,AdjustedAim);
	Pawn(Owner).ViewRotation.Pitch += (1500);
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

		else GotoState('NewClip');


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


	function EndState()
	{


		bSteadyFlash3rd = False;
		Super.EndState();
		OldFlashCount = FlashCount;

	}

Begin:

	PlayFiring();
        bMuzzleflash++;
	LaunchSmoke();
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

	shotc=0;
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
	Sleep(0.5);
	Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	Sleep(1.0);
        Owner.PlaySound(Misc2Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	shotc=0;
	ClipCount = 0;
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

defaultproperties
{
     AmmoName=Class'addweap.smokeammo'
     PickupAmmoCount=8
     FiringSpeed=1.800000
     FireOffset=(X=10.000000,Y=-5.000000,Z=-8.800000)
     shaketime=0.150000
     shakevert=8.000000
     AIRating=0.720000
     RefireRate=0.600000
     AltRefireRate=0.300000
     FireSound=Sound'addweap.Smoke.smokefire'
     SelectSound=Sound'UnrealI.Rifle.RiflePickup'
     Misc1Sound=Sound'addweap.Smoke.smokeopen'
     Misc2Sound=Sound'addweap.Smoke.smokeclose'
     DeathMessage="%o get from %k a little fresh air."
     NameColor=(R=0,G=0)
     bDrawMuzzleFlash=True
     MuzzleScale=1.000000
     FlashY=0.110000
     FlashO=0.014000
     FlashC=0.031000
     FlashLength=0.013000
     FlashS=256
     MFTexture=Texture'Botpack.Rifle.MuzzleFlash2'
     AutoSwitchPriority=4
     InventoryGroup=6
     bRotatingPickup=False
     PickupMessage="You got Tear gas launcher ."
     ItemName="Tear gas launcher"
     PlayerViewOffset=(X=8.400000,Y=-4.600000,Z=-4.000000)
     PlayerViewMesh=LodMesh'addweap.smokeG'
     PlayerViewScale=0.500000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'addweap.SmokePick'
     PickupViewScale=0.900000
     ThirdPersonMesh=LodMesh'addweap.SmokeHand'
     ThirdPersonScale=0.500000
     StatusIcon=Texture'Botpack.Icons.UseRifle'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseRifle'
     Mesh=LodMesh'addweap.smokeG'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=8.000000
     Mass=15.000000
}
