// ============================================================
//boltskorchlong.  a longer lasting bolt skorch (for krallbolts)
// Psychic_313: unchanged
// ============================================================

class boltskorchlong expands EnergyImpact;

simulated function AttachToSurface()    //fog zone hack (note that this code cannot be compiled normaly)
{
  super.AttachToSurface();
}

defaultproperties
{
     MultiDecalLevel=0
     Texture=Texture'botpack.energymark'
     DrawScale=0.200000
}
