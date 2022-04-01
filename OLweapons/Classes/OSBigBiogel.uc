// ============================================================
// OLweapons.OSBigBiogel
// Psychic_313: unchanged
// ============================================================

class OSBigBiogel expands BigBiogel;

simulated function SetWall(vector HitNormal, Actor Wall)
{
Super.SetWall(HitNormal, Wall);
if ( Level.NetMode != NM_DedicatedServer && class'olweapons.uiweapons'.default.busedecals)
    spawn(class'odBioMark',,,Location, rotator(SurfaceNormal));
}
function DropDrip()
{
  local BioGel Gel;

  PlaySound(SpawnSound);    // Dripping Sound
  Gel = Spawn(class'OSBioDrop', Pawn(Owner),,Location-Vect(0,0,1)*10);
  Gel.DrawScale = DrawScale * 0.5;
}

defaultproperties
{
}
