// ============================================================
// OLweapons.OLASMD: For the And Suck My Dick (yup, that's what ASMD stands for, not Advanced Shock Molecular Device or whatever you thought it was :D
// Psychic_313: after Doom's Big F***ing Gun, why doesn't that surprise me?
// mostly from original ASMD... Epic has seemed to bring it up to UT already (an example being the bot part of altfire).   Simple anims meant few changes required... Some bot and net code taken from shock rifle...
// Psychic_313: unchanged in Oldskool III
// ============================================================

class OLASMD expands UIweapons;

var() int HitDamage;
var Pickup Amp;
var Projectile Tracked;
var bool bBotSpecialMove;
var float TapTime;

function inventory SpawnCopy( pawn Other )
{
  //-local inventory Copy;
  //-local Inventory I;

  //-Copy = Super.SpawnCopy(Other);
  //-I = Other.FindInventoryType(class'Amplifier');
  //-if ( Amplifier(I) != None )
  //-  ASMD(Copy).Amp = Amplifier(I); // B227 note: Always fails due to wrong type cast

  //-return Copy;
  return super.SpawnCopy(Other);
}

function AltFire( float Value )
{
  local actor HitActor;
  local vector HitLocation, HitNormal, Start;

  if ( Owner.IsA('Bots') || Owner.IsA('Bot')  ) //make sure won't blow self up
  {
    Start = Owner.Location + CalcDrawOffset() + FireOffset.Z * vect(0,0,1);
    HitActor = Trace(HitLocation, HitNormal, Start + 250 * Normal(Pawn(Owner).Enemy.Location - Start), Start, false, vect(12,12,12));
    if ( HitActor != None )
    {
      Global.Fire(Value);
      return;
    }
    if ( Owner.IsInState('TacticalMove') && (Owner.Target == Pawn(Owner).Enemy)
       && (Owner.Physics == PHYS_Walking)
       && (Pawn(Owner).Skill > 1) && (FRand() < 0.35) )
      Pawn(Owner).SpecialFire();
  }
  if (AmmoType.UseAmmo(1))
  {
    GotoState('AltFiring');
    bCanClientFire = true;
    if ( PlayerPawn(Owner) != None )
    {
      PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(0, 0, 800));
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    }
    if ( Bot(Owner) != none )      //help those little bot guys with UT code :D
    {
      if ( Owner.IsInState('TacticalMove') && (Owner.Target == Pawn(Owner).Enemy)
       && (Owner.Physics == PHYS_Walking) && !Bot(Owner).bNovice
       && (FRand() * 6 < Pawn(Owner).Skill) )
        Pawn(Owner).SpecialFire();
    }
    Pawn(Owner).PlayRecoil(FiringSpeed);
    bPointing=True;
    ProjectileFire(B227_GetProjClass(AltProjectileClass), AltProjectileSpeed, bAltWarnTarget);
    ClientAltFire(value);
    //PlayAltFiring();
    if ( Owner.bHidden )
      CheckVisibility();
  }
}

function TraceFire( float Accuracy )
{
  local vector HitLocation, HitNormal, X,Y,Z;
  local actor Other;

  Owner.MakeNoise(Pawn(Owner).SoundDampening);
  GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
  B227_FireStartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
  B227_FireEndTrace = B227_FireStartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
    + Accuracy * (FRand() - 0.5 ) * Z * 1000 ;

  if ( bBotSpecialMove && (Tracked != None)
    && (((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40)) ||
      (Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95)) )
    B227_FireEndTrace += 10000 * Normal(Tracked.Location - B227_FireStartTrace);
  else
  {
    bSplashDamage = false;
    AdjustedAim = pawn(owner).AdjustAim(1000000, B227_FireStartTrace, 2.75*AimError, False, False);
    bSplashDamage = true;
    B227_FireEndTrace += (10000 * vector(AdjustedAim));
  }

  Tracked = None;
  bBotSpecialMove = false;

  Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,B227_FireEndTrace,B227_FireStartTrace);
  ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

function float RateSelf( out int bUseAltMode )
{
  local float rating;
  local bool bNovice;

  if ( Amp != None )
    rating = 2 * AIRating;
  else
    rating = AIRating;

  if ( AmmoType.AmmoAmount <=0 )
    return -2;

  if ( Pawn(Owner).Enemy == None )
    bUseAltMode = 0;
  else if ( Pawn(Owner).Enemy.IsA('StationaryPawn') )   //UT botcode...for those evil turrets :D
  {
    bUseAltMode = 1;
    return (AIRating + 0.4);
  }
  else if ( !bNovice &&Pawn(Owner).IsInState('Hunting') || Pawn(Owner).IsInState('StakeOut')
    || Pawn(Owner).IsInState('RangedAttack')
    || !Pawn(Owner).LineOfSightTo(Pawn(Owner).Enemy) )
  {
    bUseAltMode = 1;
    return (Rating + 0.3);
  }
 else if ( !bNovice && (Pawn(Owner).Acceleration == vect(0,0,0)) )          //ahh...more wonderful UT code.......
    bUseAltMode = 1;
  else if ( !bNovice && (VSize(Pawn(Owner).Enemy.Location - Pawn(Owner).Location) > 1200) )
  {
    bUseAltMode = 0;
    return (AIRating + 0.05 + FMin(0.00009 * VSize(Pawn(Owner).Enemy.Location - Pawn(Owner).Location), 0.3));
  }
  else if ( Pawn(Owner).Enemy.Location.Z > Pawn(Owner).Location.Z + 200 )
  {
    bUseAltMode = int( FRand() < 0.6 );
    return (AIRating + 0.15);
  }
  else
    bUseAltMode = int( FRand() < 0.4 );

  return rating;
}

function BecomePickup()
{
  Amp = None;
  Super.BecomePickup();
}

function Timer()
{
  local actor targ;
  local float bestAim, bestDist;
  local vector FireDir;

  bestAim = 0.95;
  if ( Pawn(Owner) == None )
  {
    GotoState('');
    return;
  }
  FireDir = vector(Pawn(Owner).ViewRotation);
  targ = Pawn(Owner).PickTarget(bestAim, bestDist, FireDir, Owner.Location);
  if ( Pawn(targ) != None )
  {
    bPointing = true;
    Pawn(targ).WarnTarget(Pawn(Owner), 300, FireDir);
    SetTimer(1 + 4 * FRand(), false);
  }
  else
  {
    SetTimer(0.5 + 2 * FRand(), false);
    bPointing = false;
  }
}

function Finish()
{
  if ( (Pawn(Owner).bFire!=0) && (FRand() < 0.6) )
    Timer();
  if ( !bChangeWeapon && (Tracked != None) && !Tracked.bDeleteMe && (Owner != None)
    && (Owner.IsA('Bots') || Owner.IsA('Bot')) && (Pawn(Owner).Enemy != None)
    && (AmmoType.AmmoAmount > 0) && (Pawn(Owner).Skill > 1) )
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
  PlayAnim('Fire1', 0.5,0.05);

}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
  local Vector Start, X,Y,Z;
  local float Mult;

  Amp = B227_FindActiveAmplifier(Amp);
  if (Amp!=None) Mult = Amp.UseCharge(80);
  else Mult=1.0;

  Owner.MakeNoise(Pawn(Owner).SoundDampening);
  GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
  Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
  bSplashDamage = false;
  AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
  bSplashDamage = true;
  Tracked = Spawn(ProjClass,,, Start,AdjustedAim);
  Tracked.Damage = Tracked.Damage*Mult;
   if ( Level.Game.IsA('DeathMatchPlus') && DeathmatchPlus(Level.Game).bNoviceMode )
    Tracked = None; //no combo move
  return Tracked;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local float Mult;
  local class<RingExplosion> rc;
  local RingExplosion r;
  local PlayerPawn PlayerOwner;

  if (Other==None)
  {
    HitNormal = -X;
    HitLocation = Owner.Location + X*10000.0;
  }
  //ripped from shock from here
  PlayerOwner = PlayerPawn(Owner);
  if ( PlayerOwner != None )
    PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
    //to here..
  Amp = B227_FindActiveAmplifier(Amp);
  if (Amp!=None) Mult = Amp.UseCharge(100);
  else Mult=1.0;

  B227_SpawnBeamEffects(Other, HitLocation, HitNormal, X, Y, Z);

  if ( TazerProj(Other)!=None )
  {
    AmmoType.UseAmmo(2);
    Other.Instigator = Pawn(Owner);
    TazerProj(Other).SuperExplosion();
  }
  else
  {
    if (Mult>1.5)
      rc = class'RingExplosion3';
    else
      rc = class'RingExplosion';

    r = Spawn(rc,,, HitLocation+HitNormal*8,rotator(HitNormal));
    //doesn't work in network and I don't think decals are that nessacary for primary fire....
    //if (bUseDecals)
    //Spawn(class'EnergyImpact',,, HitLocation+HitNormal*8,rotator(HitNormal));
    if ( r != None )
      r.PlaySound(r.ExploSound,,6);
  }

  if ( (Other != self) && (Other != Owner) && (Other != None) )
    Other.TakeDamage(HitDamage*Mult, Pawn(Owner), HitLocation, 50000.0*X, 'jolted');
}


function SpawnEffect(Vector DVector, int NumPoints, rotator SmokeRotation, vector SmokeLocation)
{
  local RingExplosion4 Smoke;

  Smoke = Spawn(class'RingExplosion4',,,SmokeLocation,SmokeRotation);
  Smoke.MoveAmount = DVector/NumPoints;
  Smoke.NumPuffs = NumPoints;
}

function PlayAltFiring()
{
  PlaySound(AltFireSound, SLOT_None,Pawn(Owner).SoundDampening*4.0);
  PlayAnim('Fire1',0.8,0.05);
}

function PlayIdleAnim()
{
  if ( AnimSequence == 'Fire1' && FRand()<0.2)
  {
    PlaySound(Misc1Sound, SLOT_None, Pawn(Owner).SoundDampening*0.5);
    PlayAnim('Steam',0.1,0.4);
  }
  else if ( VSize(Owner.Velocity) > 20 )
  {
    if ( AnimSequence=='Still' )
      LoopAnim('Sway',0.1,0.3);
  }
  else if ( AnimSequence!='Still' )
  {
    if (FRand()<0.5)
    {
      PlayAnim('Steam',0.1,0.4);
      PlaySound(Misc1Sound, SLOT_None, Pawn(Owner).SoundDampening*0.5);
    }
    else LoopAnim('Still',0.04,0.3);
  }
  Enable('AnimEnd');
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

state ComboMove
{
  function Fire(float F);
  function AltFire(float F);

  function Tick(float DeltaTime)
  {
    if ( (Owner == None) || (Pawn(Owner).Enemy == None) )
    {
      Tracked = None;
      bBotSpecialMove = false;
      Finish();
      return;
    }
    if ( (Tracked == None) || Tracked.bDeleteMe
      || (((Tracked.Location - Owner.Location)
        dot (Tracked.Location - Pawn(Owner).Enemy.Location)) >= 0)
      || (VSize(Tracked.Location - Pawn(Owner).Enemy.Location) < 100) )
      Global.Fire(0);
  }

Begin:
  Sleep(7.0);
  Tracked = None;
  bBotSpecialMove = false;
  Global.Fire(0);
}

// Auxiliary

function B227_SpawnBeamEffects(out Actor HitActor, out vector HitLocation, out vector HitNormal, out vector X, vector Y, vector Z)
{
	local vector StartTrace, BeamStart;
	local int MaxWarps;
	local bool bWarped;

	StartTrace = B227_FireStartTrace;
	MaxWarps = 8;

	if (B227_ShouldTraceFireThroughWarpZones())
		bWarped = B227_AdjustTraceResult(Level, StartTrace, B227_FireEndTrace, HitActor, HitLocation, HitNormal, MaxWarps);
	BeamStart = B227_FireStartTrace + FireOffset.Y * (3.3 - 1.0) * Y + FireOffset.Z * Z * (3.0 - 1.0);
	B227_SpawnEffect(HitLocation, BeamStart, rotator(X));
	if (bWarped)
	{
		HitActor = B227_TraceShot(self, StartTrace, B227_FireEndTrace, HitLocation, HitNormal);
		BeamStart = StartTrace;
		while (B227_AdjustTraceResult(Level, StartTrace, B227_FireEndTrace, HitActor, HitLocation, HitNormal, MaxWarps))
		{
			GetAxes(rotator(HitLocation - BeamStart), X, Y, Z);
			B227_SpawnEffect(HitLocation, BeamStart, rotator(X));
			HitActor = B227_TraceShot(self, StartTrace, B227_FireEndTrace, HitLocation, HitNormal);
			BeamStart = StartTrace;
		}
		GetAxes(rotator(HitLocation - BeamStart), X, Y, Z);
		B227_SpawnEffect(HitLocation, BeamStart, rotator(X));
	}
}

function B227_SpawnEffect(vector HitLocation, vector BeamLocation, rotator BeamRotation)
{
	local vector DVector;
	local float NumPoints;

	DVector = HitLocation - BeamLocation;
	NumPoints = VSize(DVector)/70.0;
	BeamLocation += DVector/NumPoints;
	if (NumPoints > 15)
		NumPoints = 15;
	if (NumPoints>1.0)
		SpawnEffect(DVector, NumPoints, BeamRotation, BeamLocation);
}

function class<Projectile> B227_GetProjClass(class<Projectile> ProjClass)
{
	if (class'UIweapons'.default.B227_bUseClassicProjectiles && ProjClass == class'OLTazerProj')
		return class'TazerProj';
	return ProjClass;
}

defaultproperties
{
     hitdamage=35
     WeaponDescription="Classification: Energy Rifle\n\nPrimary Fire: Lightning-Fast Burst of focused energy.\n\nSecondary Fire: Unstable Energy projectile, expands radially.\n\nTechniques: Hitting the secondary fire energy projectiles with the regular fire's energy will cause an immensely powerful explosion."
     AmmoName=Class'UnrealShare.ASMDAmmo'
     PickupAmmoCount=20
     bInstantHit=True
     bAltWarnTarget=True
     bSplashDamage=True
     FireOffset=(X=12.000000,Y=-6.000000,Z=-7.000000)
     AltProjectileClass=Class'OLweapons.OLTazerProj'
     MyDamageType=jolted
     AIRating=0.600000
     AltRefireRate=0.700000
     FireSound=Sound'UnrealShare.ASMD.TazerFire'
     AltFireSound=Sound'UnrealShare.ASMD.TazerAltFire'
     SelectSound=Sound'UnrealShare.ASMD.TazerSelect'
     Misc1Sound=Sound'UnrealShare.ASMD.Vapour'
     DeathMessage="%k inflicted mortal damage upon %o with the %w."
     AutoSwitchPriority=4
     InventoryGroup=4
     PickupMessage="You got the ASMD"
     ItemName="ASMD"
     PlayerViewOffset=(X=3.500000,Y=-1.800000,Z=-2.000000)
     PlayerViewMesh=LodMesh'UnrealShare.ASMDM'
     PickupViewMesh=LodMesh'UnrealShare.ASMDPick'
     ThirdPersonMesh=LodMesh'UnrealShare.ASMD3'
     StatusIcon=Texture'botpack.Icons.UseASMD'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'botpack.Icons.UseASMD'
     Mesh=LodMesh'UnrealShare.ASMDPick'
     bNoSmooth=False
     CollisionRadius=28.000000
     CollisionHeight=8.000000
     Mass=50.000000
}
