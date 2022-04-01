// ============================================================
//The main oldskool package.
//Holds the mutators, singleplayer game, windows, Unreal I models and mappacks.
// ============================================================

class olBloodSplat expands BloodSplat;
simulated function AttachToSurface()    //fog zone hack (note that this code cannot be compiled normaly)
{
  super.AttachToSurface();
}

defaultproperties
{
}
