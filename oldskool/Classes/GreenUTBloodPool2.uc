// ============================================================
//The main oldskool package.
//Holds the mutators, singleplayer game, windows, Unreal I models and mappacks.
//GreenUTBloodPool2. simply uses bio textures.
// ============================================================

class GreenUTBloodPool2 expands UTBloodPool2;
/*simulated function BeginPlay()
{
  if ( class'GameInfo'.Default.bveryLowGore )   //its green :P
  {
    destroy();
    return;
  }
  if ( !Level.bDropDetail&&frand()<0.5 )   //well, 2 textures only!
    Texture = Texture'botpack.biosplat2';
} */
simulated function AttachToSurface()    //fog zone hack (note that this code cannot be compiled normaly)
{
  super.AttachToSurface();
}

defaultproperties
{
     Splats(0)=Texture'OldSkool.GreenSplat7'
     Splats(1)=Texture'OldSkool.GreenSplat5'
     Splats(2)=Texture'OldSkool.GreenSplat1'
     Splats(3)=Texture'OldSkool.GreenSplat3'
     Splats(4)=Texture'OldSkool.GreenSplat4'
     Texture=Texture'OldSkool.GreenSplat1'
}
