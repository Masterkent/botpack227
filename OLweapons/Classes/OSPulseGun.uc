// ============================================================
// OLweapons.OSPulseGun: can use amp...
// Psychic_313: unchanged
// ============================================================

class OSPulseGun expands PulseGun;
var Pickup Amp;
var Projectile Tracked;
var float countamp;
function inventory SpawnCopy( pawn Other )
{
  local inventory Copy;
  local Inventory I;

  Copy = Super.SpawnCopy(Other);
  I = Other.FindInventoryType(class'Amplifier');
  if ( Amplifier(I) != None )
    OSpulsegun(Copy).Amp = Amplifier(I);

  return Copy;
}
function float RateSelf( out int bUseAltMode )
{
   local Pawn P;
  if ( Amp != None )
    airating = 1.9 * AIRating;
  else
    airating = AIRating;


  if ( AmmoType.AmmoAmount <=0 )
    return -2;

  P = Pawn(Owner);
  if ( (P.Enemy == None) || (Bot(Owner) != none && Bot(Owner).bQuickFire) )
  {
    bUseAltMode = 0;
    return AIRating;
  }

  if ( P.Enemy.IsA('StationaryPawn') )
  {
    bUseAltMode = 0;
    return (AIRating + 0.4);
  }
  else
    bUseAltMode = int( 700 > VSize(P.Enemy.Location - Owner.Location) );

  AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);
  return AIRating;
}
function BecomePickup()
{
  Amp = None;
  Super.BecomePickup();
}
/*-
function AltFire( float Value )
{
  //local float Mult;
  //if (Amp!=None) Mult = Amp.UseCharge(50);
  //else Mult=1.0;
  if ( AmmoType == None )
  {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if (AmmoType.UseAmmo(1))
  {
    GotoState('AltFiring');
    bCanClientFire = true;
    bPointing=True;
    Pawn(Owner).PlayRecoil(FiringSpeed);
    ClientAltFire(value);
    if ( PlasmaBeam == None )
    {
      if (owner.isa('scriptedpawn')) //hack
      sethand(0);
      PlasmaBeam = PBolt(ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget));
      if ( FireOffset.Y == 0 )
        PlasmaBeam.bCenter = true;
      else if ( Mesh == mesh'PulseGunR' )
        PlasmaBeam.bRight = false;
    }
  }
}
*/
state AltFiring         //all this just to keep using amp power.....
{
  ignores AnimEnd;

  function Tick(float DeltaTime)
  {
    local Pawn P;
    //-local float Mult;
    P = Pawn(Owner);
    if ( P == None )
    {
      GotoState('Pickup');
      return;
    }
    if (P.bAltFire == 0 ||
        Bot(P) != none && (P.Enemy == none || Level.TimeSeconds - Bot(P).LastSeenTime > 5))
    {
      P.bAltFire = 0;
      Finish();
      return;
    }

    Count += Deltatime;
    countamp += Deltatime;
    //-if (Amp!=None){
    //-if ( Countamp > 0.01 )    //every milisecond we use 2 amp charges :D
    //-Mult=Amp.UseCharge(2);
    //-}
    //-else Mult=1.0;
    if ( Countamp > 0.01 )
    {
      countamp=0;
      //-PlasmaBeam.Damage = Plasmabeam.Damage*Mult;
    }    //stupid verification thingy......
    if ( Count > 0.24 )
    {
      if ( Owner.IsA('PlayerPawn') )
        PlayerPawn(Owner).ClientInstantFlash( InstFlash,InstFog);
      if ( Affector != None )
        Affector.FireEffect();
      Count -= 0.24;
      if (AmmoType.UseAmmo(1))
      {
          if (PlasmaBeam == none || PlasmaBeam.bDeleteMe)
              B227_EmitBeam();
          if (PlasmaBeam != none)
              PlasmaBeam.B227_DamageMult = B227_AmplifyDamage(Max(1, PlasmaBeam.Damage * 0.24), Amp);
          SoundVolume = P.SoundDampening * 255;
      }
      else
        Finish();

    }
  }

  function EndState()
  {
    AmbientGlow = 0;
    AmbientSound = None;
    if ( PlasmaBeam != None )
    {
      PlasmaBeam.Destroy();
      PlasmaBeam = None;
    }
    Super.EndState();
  }

Begin:
  AmbientGlow = 200;
  FinishAnim();
  LoopAnim( 'boltloop');
}
state NormalFire
{
  ignores AnimEnd;

  function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
  {
    local float Mult;
    local Vector Start, X,Y,Z;

    Amp = B227_FindActiveAmplifier(Amp);
    if (Amp!=None) Mult = Amp.UseCharge(80);
    else Mult=1.0;
    Owner.MakeNoise(Pawn(Owner).SoundDampening);
    GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
    Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
    AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
    Start = Start - Sin(Angle)*Y*4 + (Cos(Angle)*4 - 10.78)*Z;
    Angle += 1.8;
    Tracked= Spawn(ProjClass,,, Start,AdjustedAim);
    if (Tracked != none)
    {
        Tracked.Damage = Tracked.Damage*Mult;
        if (B227_ShouldModifyPlasmaLighting())
            Tracked.LightRadius = Clamp(Tracked.LightRadius * Sqrt(Mult), default.LightRadius, 255);
    }
    return Tracked;
  }

  function Tick( float DeltaTime )
  {
    if (Owner==None)
      GotoState('Pickup');
  }

  function BeginState()
  {
    Super.BeginState();
    Angle = 0;
    AmbientGlow = 200;
  }

  function EndState()
  {
    PlaySpinDown();
    AmbientSound = None;
    AmbientGlow = 0;
    OldFlashCount = FlashCount;
    Super.EndState();
  }

Begin:
  Sleep(0.18);
  Finish();
}
function SetSwitchPriority(pawn Other)         //uses master priority
{
  local int i;
  local name temp, carried;

  if ( PlayerPawn(Other) != None )
  {
    for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
      if ( PlayerPawn(Other).WeaponPriority[i] == 'PulseGun' )
      {
        AutoSwitchPriority = i;
        return;
      }
    // else, register this weapon
    carried = 'PulseGun';
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

defaultproperties
{
     AltProjectileClass=Class'OLweapons.OLstarterbolt'
}
