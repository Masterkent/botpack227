// ============================================================
// OLweapons.OSChunk2: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// Psychic_313: unchanged
// ============================================================

class OSChunk2 expands Chunk2;
simulated function HitWall( vector HitNormal, actor Wall )
 {
if (!bDelayTime)
    {
      if ( (Level.Netmode != NM_DedicatedServer) && (FRand()<0.5) &&class'olweapons.uiweapons'.default.busedecals)
      Spawn(class'odWallCrack',,,Location, rotator(HitNormal));
      }
      Super.HitWall(HitNormal, Wall );
      }

defaultproperties
{
}
