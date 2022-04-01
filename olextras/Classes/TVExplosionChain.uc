// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVExplosionChain : An explosion chain that uses UT effects...
// ===============================================================

class TVExplosionChain expands ExplosionChain;

state Exploding
{
  ignores TakeDamage;

  function Timer()
  {
    local UT_SpriteBallExplosion f;

    bExploding = true;
     HurtRadius(damage, Damage+100, 'Detonated', MomentumTransfer, Location);
     f = spawn(class'UT_SpriteBallExplosion',,,Location + vect(0,0,1)*16,rot(16384,0,0));
     f.DrawScale = (Damage/100+0.4+FRand()*0.5)*Size*0.4;  //0.4 is conversion drawscale between ut's and unreal's
     Destroy();
  }
}

defaultproperties
{
     bNetTemporary=True
     bCollideWorld=False
}
