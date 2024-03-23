// ===============================================================
// SevenB.SevenShockRifle: electrically discharges underwater
// also has headshot ability...
// ===============================================================

class SevenShockRifle expands OSShockRifle;

function float RateSelf( out int bUseAltMode )  //don't use in water
{
  // don't recommend self in water!
  if (owner.region.zone.bwaterzone)
    return -2;
  return Super.RateSelf(bUseAltMode);
}

function SetSwitchPriority(pawn Other)   //priority stuff
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

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local PlayerPawn PlayerOwner;
  local int Damage;

  Damage=HitDamage;

  if (Other==None)
  {
    HitNormal = -X;
    HitLocation = Owner.Location + X*10000.0;
  }

  PlayerOwner = PlayerPawn(Owner);
  if ( PlayerOwner != None )
    PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
  SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

  if ( ShockProj(Other)!=None )
  {
    AmmoType.UseAmmo(2);
    ShockProj(Other).SuperExplosion();
  }
  else
    Spawn(class'ut_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));

  if (Other.region.zone.bWaterZone&&!level.game.isa('coopgame2'))
     Damage*=2.5; //more damage in water
  if ( (Other != self) && (Other != Owner) && (Other != None) ){
    if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (Bot(instigator) != none && !Bot(Instigator).bNovice)||
        (ScriptedPawn(Other) != none && (ScriptedPawn(Other).bIsBoss || level.game.difficulty>=3))) )
      Other.TakeDamage(2*HitDamage, Pawn(Owner), HitLocation, 60000.0*X, 'decapitated');
    else
      Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);
  }
}

function Discharge(){ //kill stuff
  if (AmmoType.AmmoAmount <= 0)
    return;
  spawn(class'UT_ComboRing',,,owner.location); //should scale.. but oh well
  AmmoType.UseAmmo(AmmoType.AmmoAmount);
  GotoState('Idle');
  WaterHurtRadius(40*AmmoType.AmmoAmount,100*AmmoType.ammoamount,'Electrocuted',10*ammoType.ammoAmount,owner.location);
}

final function bool IsInWaterZone(actor other){ //return true if other is in water zone.
    if (Other.Region.Zone.bWaterZone)
      return true;
    if (Other.Isa('pawn'))
      return (pawn(Other).HeadRegion.Zone.bWaterZone||pawn(Other).FootRegion.Zone.bWaterZone);
}

final function WaterHurtRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
  local actor Victims;
  local float damageScale, dist;
  local vector dir;

  foreach RadiusActors( class 'Actor', Victims, DamageRadius, HitLocation )
  {
    if( Victims != self && IsInWaterZone(Victims))
    {
      dir = Victims.Location - HitLocation;
      dist = FMax(1,VSize(dir));
      dir = dir/dist;
      damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
      Victims.TakeDamage
      (
        damageScale * DamageAmount,
        Instigator,
        Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
        (damageScale * Momentum * dir),
        DamageName
      );
    }
  }
}

function AltFire( float Value )
{
  if (owner.Region.zone.bWaterZone&&!level.game.isa('coopgame2'))
    Discharge();
  else
    Super.AltFire(Value);
}

function Fire (float Value){
  if (owner.Region.zone.bWaterZone&&!level.game.isa('coopgame2'))
    Discharge();
  else
    Super.Fire(Value);
}

defaultproperties
{
     bAmbientGlow=False
     RotationRate=(Yaw=0)
}
