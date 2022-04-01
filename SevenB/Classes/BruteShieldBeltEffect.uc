// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// BruteShieldBeltEffect : Used with the brute to fix up a low texture problem.
// ===============================================================

class BruteShieldBeltEffect expands UT_ShieldBeltEffect;

var Texture RepLowDetailTexture;
var float BaseScaleGlow;

replication{
  reliable if (Role==role_authority)
     RepLowDetailTexture, BaseScaleGlow;
}

simulated function Timer()
{
  bHidden = true;
  if ( Level.NetMode == NM_Client )
  {
    Owner.Texture = RepLowDetailTexture;
    Owner.bMeshEnviromap = true;
  }
  else
    Owner.SetDisplayProperties(Owner.Style, RepLowDetailTexture, false, true);
}

simulated function Tick(float DeltaTime)
{
  local int IdealFatness;

  if ( bHidden || (Level.NetMode == NM_DedicatedServer) || (Owner == None) )
  {
    Disable('Tick');
    return;
  }

  IdealFatness = Owner.Fatness; // Convert to int for safety.
  IdealFatness += FatnessOffset;

  if ( Fatness > IdealFatness )
    Fatness = Max(IdealFatness, Fatness - 130 * DeltaTime);
  else{
    Fatness = Min(IdealFatness, 255);
    ScaleGlow=BaseScaleGlow;
  }
}

defaultproperties
{
     BaseScaleGlow=0.500000
}
