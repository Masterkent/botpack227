// ============================================================
// OLweapons.OSShockRifle: can use amp...
// Psychic_313: unchanged
// ============================================================

class OSShockRifle expands ShockRifle;
var Pickup Amp;

var transient bool B227_bSuperShockBeam;

function inventory SpawnCopy( pawn Other )
{
  local inventory Copy;
  local Inventory I;

  Copy = Super.SpawnCopy(Other);
  I = Other.FindInventoryType(class'OSAmplifier');
  if ( Amplifier(I) != None )
    OSshockrifle(Copy).Amp = OSAmplifier(I);

  return Copy;
}
//if have amp the weapon is better......
function float RateSelf( out int bUseAltMode )
{
  local Pawn P;
  local bool bNovice;

  if ( Amp != None )
    Airating = 2 * AIRating;
  else
    airating = AIRating;
  if ( AmmoType.AmmoAmount <=0 )
    return -2;

  P = Pawn(Owner);
  bNovice = ( (Bot(Owner) == None) || Bot(Owner).bNovice );
  if ( P.Enemy == None )
    bUseAltMode = 0;
  else if ( P.Enemy.IsA('StationaryPawn') )
  {
    bUseAltMode = 1;
    return (AIRating + 0.4);
  }
  else if ( !bNovice && (P.IsInState('Hunting') || P.IsInState('StakeOut')
    || P.IsInState('RangedAttack')
    || (Level.TimeSeconds - P.LastSeenTime > 0.8)) )
  {
    bUseAltMode = 1;
    return (AIRating + 0.3);
  }
  else if ( !bNovice && (P.Acceleration == vect(0,0,0)) )
    bUseAltMode = 1;
  else if ( !bNovice && (VSize(P.Enemy.Location - P.Location) > 1200) )
  {
    bUseAltMode = 0;
    return (AIRating + 0.05 + FMin(0.00009 * VSize(P.Enemy.Location - P.Location), 0.3));
  }
  else if ( P.Enemy.Location.Z > P.Location.Z + 200 )
  {
    bUseAltMode = int( FRand() < 0.6 );
    return (AIRating + 0.15);
  }
  else
    bUseAltMode = int( FRand() < 0.4 );

  return AIRating;
}
//can't have amp on if its a pickup...
function BecomePickup()
{
  Amp = None;
  Super.BecomePickup();
}
//use amp...
function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{

  local Vector Start, X,Y,Z;
  local PlayerPawn PlayerOwner;
  local float Mult;

  Amp = B227_FindActiveAmplifier(Amp);
  if (Amp!=None) Mult = Amp.UseCharge(80);
  else Mult=1.0;
  Owner.MakeNoise(Pawn(Owner).SoundDampening);
  GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
  Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
  AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);

  PlayerOwner = PlayerPawn(Owner);
  if ( PlayerOwner != None )
    PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
  Tracked = Spawn(ProjClass,,, Start,AdjustedAim);
  if (Tracked != none)
    Tracked.Damage = Tracked.Damage*Mult;
  if (DeathMatchPlus(Level.Game) != none && DeathmatchPlus(Level.Game).bNoviceMode)
    Tracked = None; //no combo move

  return Tracked;
}
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z){
  local PlayerPawn PlayerOwner;
  local float Mult;

  Amp = B227_FindActiveAmplifier(Amp);
  if (Amp!=None) Mult = Amp.UseCharge(100);
  else Mult=1.0;
  if (Other==None)
  {
    HitNormal = -X;
    HitLocation = Owner.Location + X*10000.0;
  }

  PlayerOwner = PlayerPawn(Owner);
  if ( PlayerOwner != None )
    PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
  if (Mult>1.5)   //supershock beem if the amp IS ON!!!!
  {
    B227_bSuperShockBeam = true;
    B227_SpawnBeamEffects(Other, HitLocation, HitNormal, X, Y, Z);
    B227_bSuperShockBeam = false;
  }
  else
    B227_SpawnBeamEffects(Other, HitLocation, HitNormal, X, Y, Z);

  if ( ShockProj(Other)!=None )
  {
    AmmoType.UseAmmo(2);
    ShockProj(Other).SuperExplosion();
  }
  else{
   if (Mult>1.5)   //supershock if we've got amp!!!!!
   Spawn(class'ut_SuperRing2',,, HitLocation+HitNormal*8,rotator(HitNormal));
   else
    Spawn(class'ut_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));
          }
  if ( (Other != self) && (Other != Owner) && (Other != None) )
    Other.TakeDamage(HitDamage*mult, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);

}
  //taken from supershockrifle...
function SpawnEffectmult(vector HitLocation, vector SmokeLocation)
{
  local SuperShockBeam Smoke;
  local Vector DVector;
  local int NumPoints;
  local rotator SmokeRotation;

  DVector = HitLocation - SmokeLocation;
  NumPoints = VSize(DVector)/135.0;
  if ( NumPoints < 1 )
    return;
  SmokeRotation = rotator(DVector);
  SmokeRotation.roll = Rand(65535);

  Smoke = Spawn(class'SuperShockBeam',,,SmokeLocation,SmokeRotation);
  Smoke.MoveAmount = DVector/NumPoints;
  Smoke.NumPuffs = NumPoints - 1;
}
function SetSwitchPriority(pawn Other)         //uses master priority
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'ShockRifle' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'ShockRifle';
    for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
    {
      if ( PlayerPawn(Other).WeaponPriority[i] == '' )
      {
        PlayerPawn(Other).WeaponPriority[i] = carried;
        return;
      }
      else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
      {
        temp = PlayerPawn(Other).WeaponPriority[i];
        PlayerPawn(Other).WeaponPriority[i] = carried;
        carried = temp;
      }
    }
  }
}

// B227 Auxiliary
static function Actor B227_SpawnShockBeam(Actor Spawner, vector BeamLocation, rotator BeamRotation, vector MoveAmount, int NumPuffs)
{
	if (OSShockRifle(Spawner) != none && OSShockRifle(Spawner).B227_bSuperShockBeam)
		return class'SuperShockRifle'.static.B227_SpawnShockBeam(Spawner, BeamLocation, BeamRotation, MoveAmount, NumPuffs);
	return class'ShockRifle'.static.B227_SpawnShockBeam(Spawner, BeamLocation, BeamRotation, MoveAmount, NumPuffs);
}

function B227_SpawnEffectExtension(vector HitLocation, vector BeamLocation, class<ShockRifle> ShockRifleClass)
{
	if (B227_bSuperShockBeam)
		super.B227_SpawnEffectExtension(HitLocation, BeamLocation, class'SuperShockRifle');
	else
		super.B227_SpawnEffectExtension(HitLocation, BeamLocation, ShockRifleClass);
}

defaultproperties
{
}
