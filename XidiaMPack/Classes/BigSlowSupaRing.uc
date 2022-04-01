// ===============================================================
// XidiaMPack.BigSlowSupaRing: something hour wanted
// ===============================================================

class BigSlowSupaRing expands ut_superring;

simulated function PostBeginPlay()
{
  if ( Level.NetMode != NM_DedicatedServer )
  {
    PlayAnim( 'Explo', 0.18, 0.0 );
    SpawnEffects();
  }
  if ( Instigator != None )
    MakeNoise(0.5);
}

defaultproperties
{
     DrawScale=1.000000
}
