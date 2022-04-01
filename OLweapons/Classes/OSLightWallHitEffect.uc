// ============================================================
// OLweapons.OSLightWallHitEffect: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// Psychic_313: unchanged
// ============================================================

class OSLightWallHitEffect expands LightWallHitEffect;
var rotator RealRotation;

replication
{
  // Things the server should send to the client.
  unreliable if( Role==ROLE_Authority )
    RealRotation;
}
function PostBeginPlay();
Auto State StartUp
{
  simulated function Tick(float DeltaTime)
  {
    if ( Instigator != None )
      MakeNoise(0.3);
    if ( Role == ROLE_Authority )
      RealRotation = Rotation;
    else
      SetRotation(RealRotation);

    if ( Level.NetMode != NM_DedicatedServer )
      SpawnEffects();
    Disable('Tick');
  }
}
simulated function SpawnEffects()
{
  local Actor A;
  local float decision;
  if ( Level.NetMode == NM_DedicatedServer )
  return;
  decision = FRand();
  if (decision<0.2)
    PlaySound(sound'ricochet',, 1,,1200, 0.5+FRand());
  else if ( decision < 0.4 )
    PlaySound(sound'Impact1',, 3.0,,800);
  else if ( decision < 0.6 )
    PlaySound(sound'Impact2',, 3.0,,800);

  if (FRand()< 0.2)
  {
    A = spawn(class'Chip');
    if ( A != None )
      A.RemoteRole = ROLE_None;
  }
  if ( !Level.bHighDetailMode )
    return;
   If(class'olweapons.UIweapons'.default.bUseDecals&& Level.NetMode != NM_DedicatedServer )
Spawn(class'odPock');
   if ( Level.bDropDetail )
    return;
  if (FRand()< 0.2)
  {
    A = spawn(class'SmallSpark',,,,Rotation + RotRand());
    if ( A != None )
      A.RemoteRole = ROLE_None;
  }
}

defaultproperties
{
}
