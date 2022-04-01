// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVSkaarjProjectile : So it can hit other skaarj. plus net fixes
// ============================================================

class TVSkaarjProjectile expands olSkaarjProjectile;
auto simulated state Flying
{
  simulated function MakeSound()
  {
    PlaySound(ImpactSound);
    if (level.netmode!=nm_client)
      MakeNoise(1.0);
  }
  simulated function ProcessTouch (Actor Other, Vector HitLocation)
  {
    local vector momentum;

    if ( Other!=Instigator )
    {
      if ( Role == ROLE_Authority )
      {
        momentum = 10000.0 * Normal(Velocity);
        Other.TakeDamage(Damage, instigator, HitLocation, momentum, 'zapped');
      }
      Destroy();
    }
  }
  simulated function BeginState()
  {
    PlaySound(SpawnSound);
    SetTimer(0.20,False);
    if (role<role_authority)
      return;
    if ( ScriptedPawn(Instigator) != None )
      Speed = ScriptedPawn(Instigator).ProjectileSpeed;
    Velocity = Vector(Rotation) * speed;
  }

  Begin:
  Sleep(7.0); //self destruct after 7.0 seconds
  Explode(Location, vect(0,0,0));
}

defaultproperties
{
     MaxSpeed=10000.000000
}
