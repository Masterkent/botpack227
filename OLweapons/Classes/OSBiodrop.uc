// ============================================================
// OLweapons.OSBiodrop
// Psychic_313: unchanged
// ============================================================

class OSBiodrop expands Biodrop;
simulated function SetWall(vector HitNormal, Actor Wall)
{
Super.SetWall(HitNormal, Wall);
if ( Level.NetMode != NM_DedicatedServer && class'olweapons.uiweapons'.default.busedecals)
    spawn(class'odBioMark',,,Location, rotator(SurfaceNormal));
}

defaultproperties
{
}
