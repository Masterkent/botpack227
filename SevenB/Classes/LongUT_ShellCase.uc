// ===============================================================
// SevenB.LongUT_ShellCase: lasts a longer time
// ===============================================================

class LongUT_ShellCase extends UT_ShellCase;

simulated function PostBeginPlay()
{
  Super.PostBeginPlay();
  SetTimer(0.15, false);
  if ( Level.bDropDetail && (Level.NetMode != NM_DedicatedServer)
    && (Level.NetMode != NM_ListenServer) )
    LifeSpan = 5.0;
  if ( Level.bDropDetail )
    LightType = LT_None;
}

simulated function HitWall( vector HitNormal, actor Wall )
{
  local vector RealHitNormal;
  if ( bHasBounced && ((numBounces > 3) || (FRand() < 0.85) || (Velocity.Z > -50)) )
    bBounce = false;
  numBounces++;
  if ( !Region.Zone.bWaterZone )
    PlaySound(sound 'shell2');
  RealHitNormal = HitNormal;
  HitNormal = Normal(HitNormal + 0.4 * VRand());
  if ( (HitNormal Dot RealHitNormal) < 0 )
    HitNormal *= -0.5;
  Velocity = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
  RandSpin(100000);
  bHasBounced = True;
}

simulated function Landed( vector HitNormal )
{
  local rotator RandRot;

  if ( Level.bDropDetail ) //still allowed
  {
    Destroy();
    return;
  }
  if ( !Region.Zone.bWaterZone )
    PlaySound(sound 'shell2');

  SetPhysics(PHYS_None);
  RandRot = Rotation;
  RandRot.Pitch = 0;
  RandRot.Roll = 0;
  SetRotation(RandRot);
}

defaultproperties
{
     LifeSpan=11.000000
}
