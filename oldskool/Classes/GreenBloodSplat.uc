// ============================================================
// oldskool.GreenBloodSplat : Uses Alcor's green blood decals
// The main oldskool package.
// Holds the mutators, singleplayer game, windows, Unreal I models and mappacks.
// ============================================================

class GreenBloodSplat expands olBloodSplat;

#exec OBJ LOAD FILE="OldSkoolResources.u" PACKAGE=oldskool

defaultproperties
{
     Splats(0)=Texture'OldSkool.GreenSplat1'
     Splats(1)=Texture'OldSkool.GreenSplat2'
     Splats(2)=Texture'OldSkool.GreenSplat3'
     Splats(3)=Texture'OldSkool.GreenSplat4'
     Splats(4)=Texture'OldSkool.GreenSplat5'
     Splats(5)=Texture'OldSkool.GreenSplat6'
     Splats(6)=Texture'OldSkool.GreenSplat7'
     Splats(7)=Texture'OldSkool.GreenSplat8'
     Splats(8)=Texture'OldSkool.GreenSplat9'
     Splats(9)=Texture'OldSkool.GreenSplat10'
     Texture=Texture'OldSkool.GreenSplat1'
}
