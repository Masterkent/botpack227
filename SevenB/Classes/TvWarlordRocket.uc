// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvWarlordRocket : ut explosion
// ===============================================================

class TvWarlordRocket expands olWarlordRocket;

simulated function Explode(vector HitLocation, vector HitNormal)
{
  local Actor s;
  HurtRadiusProj(damage, 200.0, 'exploded', MomentumTransfer, HitLocation);
  s=Spawn(class'Ut_SpriteBallExplosion',,,HitLocation);
  s.RemoteRole=Role_None;
  Destroy();
}

auto simulated state Flying
{
  simulated function ProcessTouch (Actor Other, Vector HitLocation)
  {
    if ((PeaceRocket(Other) == none) && (Other != Instigator) )
      Explode(HitLocation, vect(0,0,0));
  }


  simulated function BeginState()
  {
    if (Level.bHighDetailMode) SmokeRate = 0.035;
    else SmokeRate = 0.15;
    PlaySound(SpawnSound);
    if (role<role_authority)
      return;
    OriginalDirection = Vector(Rotation);
    Velocity = OriginalDirection * 500.0;
    Acceleration = Velocity * 0.4;
  }
  Begin:
  Sleep(7.0);
  Explode(Location, vect(0,0,0));
}

defaultproperties
{
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
}
