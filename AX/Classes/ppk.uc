//=============================================================================
// ppk.
//=============================================================================
class ppk expands AXweapons;

#exec OBJ LOAD FILE="AXResources.u" PACKAGE=AX

//3rd person


var() int HitDamage;
var int aclip;
var int clip;
var Projectile Tracked;
var bool bBotSpecialMove;
var float TapTime;
var vector OwnerLocation;

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		aclip;
}

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn P;

	B227_UpdateClip();

	Super.PostRender(Canvas);
	P = PlayerPawn(Owner);
	if  (P != None)
	{

		Canvas.SetPos(0.9 * Canvas.ClipX , 0.9 * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            Canvas.Font = Canvas.SmallFont;
      if (clip < 5 )
            {
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
             }
        if (clip >= 5)
            {
            Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;

             }


		Canvas.DrawText("Clip:"$clip);
		Canvas.Reset();
	}

}


function Fire( float Value )
{
	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1))
	{
		GotoState('NormalFire');
		bPointing=True;
		bCanClientFire = true;
		ClientFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bInstantHit )
			TraceFire(0.1);
		else
			ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	}
}

function AltFire( float Value )
{
    B227_UpdateClip();
    if ( playerpawn(owner) != None && clip < ammotype.ammoamount && clip < 9)
    {
        aclip = 0;
        PlayAnim('Reload');
        PlaySound(AltFireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
    }
    if (Bot(owner) != None)
        Tracefire(1.2);
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000 ;
      Aclip++;
      if (( Aclip >= 9 )&& (AmmoType.AmmoAmount > 0))
      {
           Aclip = 0;
           PlayAnim('Reload');
           PlaySound(AltFireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
      }

	if ( bBotSpecialMove && (Tracked != None)
		&& (((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40)) ||
			(Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95)) )
		EndTrace += 10000 * Normal(Tracked.Location - StartTrace);
	else
	{
		AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
		EndTrace += (10000 * vector(AdjustedAim));
	}

	Tracked = None;
	bBotSpecialMove = false;

	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
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
	FireDir = vector(P.ViewRotation);
	targ = P.PickTarget(bestAim, bestDist, FireDir, Owner.Location);
	if ( Pawn(targ) != None )
	{
		bPointing = true;
		Pawn(targ).WarnTarget(P, 300, FireDir);
		SetTimer(1 + 4 * FRand(), false);
	}
	else
	{
		SetTimer(0.5 + 2 * FRand(), false);
		if ( (P.bFire == 0) && (P.bAltFire == 0) )
			bPointing = false;
	}
}

function Finish()
{
	if ( (Pawn(Owner).bFire!=0) && (FRand() < 0.6) )
		Timer();
	if ( !bChangeWeapon && (Tracked != None) && !Tracked.bDeleteMe && (Owner != None)
		&& (Owner.IsA('Bot')) && (Pawn(Owner).Enemy != None) && (FRand() < 0.3 + 0.35 * Pawn(Owner).skill)
		&& (AmmoType.AmmoAmount > 0) )
	{
		if ( (Owner.Acceleration == vect(0,0,0)) ||
			(Abs(Normal(Owner.Velocity) dot Normal(Tracked.Velocity)) > 0.95) )
		{
			bBotSpecialMove = true;
			GotoState('ComboMove');
			return;
		}
	}

	bBotSpecialMove = false;
	Tracked = None;
	Super.Finish();
}

///////////////////////////////////////////////////////
function PlayFiring()
{
	PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	PlayAnim('Fire1', 0.30 + 0.30 * FireAdjust,0.05);
      bMuzzleFlash++;

}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;
	local PlayerPawn PlayerOwner;
	local Projectile Proj;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
	Proj = Spawn(ProjClass,,, Start,AdjustedAim);
	Tracked = Proj;
	if ( Level.Game.IsA('DeathMatchPlus') && DeathmatchPlus(Level.Game).bNoviceMode )
		Tracked = None; //no combo move
	return Proj;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local PlayerPawn PlayerOwner;
      local UT_Shellcase s;   /////here



	s = Spawn(class'UT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+2.0) * Y - Z * 1);
	if ( s != None )
	{
		s.DrawScale = 1.0;
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
	}

////to here
	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));

      if ( ShockProj(Other)!=None )
	{
		AmmoType.UseAmmo(2);
		ShockProj(Other).SuperExplosion();
	}
	else
		Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal*8,rotator(HitNormal));
            Spawn(class'BulletImpact',,, HitLocation+HitNormal*8,rotator(HitNormal));
////////
   if ( (Other != self) && (Other != Owner) && (Other != None) )
	{
		if ( Other.bIsPawn )
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
		if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
			&& (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)) )
			Other.TakeDamage(80, Pawn(Owner), HitLocation, 35000 * X, AltDamageType);
		else
			Other.TakeDamage(20,  Pawn(Owner), HitLocation, 30000.0*X, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}
//////
function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim('Still',0.04,0.3);
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

state Idle
{

	function BeginState()
	{
		bPointing = false;
		SetTimer(0.5 + 2 * FRand(), false);
		Super.BeginState();
		if (Pawn(Owner).bFire!=0) Fire(0.0);
		if (Pawn(Owner).bAltFire!=0) AltFire(0.0);
	}

	function EndState()
	{
		SetTimer(0.0, false);
		Super.EndState();
	}
}

function SetHand(float Hand)
{
	Hand = Clamp(Hand, -1, 2);
	if (Hand == 1)
		Hand = 0;
	super.SetHand(Hand);
}

simulated function B227_UpdateClip()
{
	clip = Min(9 - aclip, AmmoType.AmmoAmount);
}

defaultproperties
{
     hitdamage=10
     WeaponDescription="Classification: Silenced Pistol"
     InstFlash=-0.400000
     InstFog=(Z=800.000000)
     AmmoName=Class'AX.Famasammo'
     PickupAmmoCount=36
     bInstantHit=True
     bAltWarnTarget=True
     FiringSpeed=1.000000
     FireOffset=(X=10.000000,Y=-5.000000,Z=-8.000000)
     MyDamageType=shot
     AltDamageType=Decapitated
     AIRating=0.630000
     AltRefireRate=0.200000
     FireSound=Sound'AX.Sounds.Apshot'
     AltFireSound=Sound'UnrealShare.AutoMag.Reload'
     SelectSound=Sound'Botpack.enforcer.Cocking'
     DeathMessage="%k made a teabag out of %o with the %w."
     NameColor=(R=128,G=0)
     MuzzleScale=1.000000
     FlashY=0.090000
     FlashO=0.030000
     FlashC=0.035000
     FlashLength=0.020000
     FlashS=128
     MFTexture=Texture'Botpack.Skins.Muz1'
     AutoSwitchPriority=2
     InventoryGroup=2
     bRotatingPickup=False
     PickupMessage="You got the PPK."
     ItemName="Silenced pistol"
     PlayerViewOffset=(X=10.700000,Y=-5.800000,Z=-12.500000)
     PlayerViewMesh=LodMesh'AX.ppk'
     PlayerViewScale=0.290000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'AX.ppk3rd'
     PickupViewScale=0.350000
     ThirdPersonMesh=LodMesh'AX.ppk3rd'
     ThirdPersonScale=0.240000
     StatusIcon=Texture'AX.Icons.useppk'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzsr3'
     MuzzleFlashScale=0.100000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy3'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=None
     Physics=PHYS_Falling
     Mesh=LodMesh'AX.ppk3rd'
     bNoSmooth=False
     CollisionRadius=34.000000
     CollisionHeight=8.000000
     Mass=20.000000
}
