// ============================================================
// OLweapons.OSRingExplosion2: spawns the decals......
// Psychic_313: unchanged
// ============================================================

class OSRingExplosion2 expands RingExplosion2;

simulated function SpawnEffects(){
super.SpawnEffects();
If(class'olweapons.UIweapons'.default.bUseDecals)
Spawn(class'odBigEnergyImpact',,,,rot(16384,0,0));}

defaultproperties
{
}
