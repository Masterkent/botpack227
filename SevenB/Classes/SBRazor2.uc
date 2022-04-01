// ===============================================================
// SevenB.SBRazor2: much more powerful
// ===============================================================

class SBRazor2 extends Razor2;

auto state Flying
{
  function ProcessTouch(Actor Other, Vector HitLocation)
  {
    if ( bCanHitInstigator || (Other != Instigator) )
    {
      if ( Role == ROLE_Authority )
      {
        if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
          && (Bot(Instigator) == none || !Bot(Instigator).bNovice) )
        {
          Other.TakeDamage(300, instigator,HitLocation,
            (MomentumTransfer * Normal(Velocity)), 'decapitated' );
        }
        else
          Other.TakeDamage(damage, instigator,HitLocation,
            (MomentumTransfer * Normal(Velocity)), 'shredded' );
      }
      if ( Other.bIsPawn )
        PlaySound(MiscSound, SLOT_Misc, 2.0);
      else
        PlaySound(ImpactSound, SLOT_Misc, 2.0);
      destroy();
    }
  }
}

defaultproperties
{
     Damage=60.000000
     MomentumTransfer=30000
     LifeSpan=50.000000
}
