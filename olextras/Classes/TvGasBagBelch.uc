// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvGasBagBelch : new explosion
// ===============================================================

class TvGasBagBelch expands GasBagBelch;

auto simulated state Flying
{
  simulated function Explode(vector HitLocation, vector HitNormal)
  {
    local UT_SpriteBallExplosion s;

    if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
      MakeNoise(1.0); //FIXME - set appropriate loudness

    s = Spawn(class'ut_SpriteBallExplosion',,,HitLocation+HitNormal*9);
    s.RemoteRole = ROLE_None;
    Destroy();
  }
  Begin:
  Sleep(3);
  Explode(Location, Vect(0,0,0));
}

defaultproperties
{
     MaxSpeed=10000.000000
     ExplosionDecal=Class'olweapons.ODBlastMark'
     bGameRelevant=False
}
