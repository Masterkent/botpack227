// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvBruteProjectile : balh
// ===============================================================

class TvBruteProjectile expands BruteProjectile;

auto simulated state Flying
{
  simulated function BlowUp(vector HitLocation)
  {
    local int mult;
    PlaySound(ImpactSound);
    if (level.netmode==nm_client)
      return;
    if (instigator!=none)
      mult=instigator.skill*45;
    HurtRadiusProj(damage, 50 + mult, 'exploded', MomentumTransfer, HitLocation);
    MakeNoise(1.0);
  }

  simulated function Explode(vector HitLocation, vector HitNormal)
  {
    local UT_SpriteBallExplosion s;

    BlowUp(HitLocation);
    s = spawn(class 'UT_SpriteBallExplosion',,'',HitLocation+HitNormal*10 );
    s.RemoteRole = ROLE_None;
    Destroy();
  }

  Begin:
  Sleep(7.0); //self destruct after 7.0 seconds
  Explode(Location,vect(0,0,0));
}

defaultproperties
{
     ExplosionDecal=Class'olweapons.ODBlastMark'
     bGameRelevant=False
}
