// ===============================================================
// SevenB.SBflakslug: more powerful flak slug for flechette cannon
// ===============================================================

class SBflakslug extends flakslug;

function Explode(vector HitLocation, vector HitNormal)
{
  local vector start;

  HurtRadiusProj(damage, 170, 'FlakDeath', MomentumTransfer, HitLocation);
  start = Location + 10 * HitNormal;
   Spawn( class'ut_FlameExplosion',,,Start);
  Spawn( class 'UTChunk2',, '', Start);
  Spawn( class 'UTChunk3',, '', Start);
  Spawn( class 'UTChunk4',, '', Start);
  Spawn( class 'UTChunk1',, '', Start);
  Spawn( class 'UTChunk2',, '', Start);
  Spawn( class 'UTChunk3',, '', Start);
  Spawn( class 'UTChunk4',, '', Start);
  Spawn( class 'UTChunk1',, '', Start);
   Destroy();
}

defaultproperties
{
     Damage=90.000000
     MomentumTransfer=96000
}
