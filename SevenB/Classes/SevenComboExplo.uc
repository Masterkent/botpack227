// ===============================================================
// SevenB.SevenComboExplo: a request by hourences (from xidia)
// ===============================================================

class SevenComboExplo expands Effects;

function PostBeginPlay(){
  local actor a;
  a=spawn(Class'BallExplosion',self);
  a.LightBrightness=255;
  a.LightHue=20;
  a.LightSaturation=0;
  spawn(Class'BigSlowSupaRing',self);
}

defaultproperties
{
}
