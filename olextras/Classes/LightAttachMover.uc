// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// Light Attachmover.  Allows attachment of lights in Multiplay.
// NOTE THAT CLIENT-SIDE IT WILL ONLY ATTACH LIGHTS. NOTHING ELSE!
// NOTE THAT ATTACHING LIGHTS WILL INCREASE ILLUM TIMES LIKE MAD! KEEP THIS IN LOW-POLY AREAS!
// ============================================================

class LightAttachMover expands Mover;

var(Attachment) name AttachTag;

replication{
  reliable if (role==role_Authority)
    AttachTag;
}
//simulated so it attaches non-replicated actors.  i.e lights
simulated function PostBeginPlay()
{
  local Actor Act;
  local Mover Mov;
  local light Light;
  Super.PostBeginPlay();
  if (role==role_authority||( AttachTag == '' )){
 // Initialize all slaves.
  if ( AttachTag != '' )
    foreach AllActors( class 'Actor', Act, AttachTag )
    {
      Mov = Mover(Act);
      if (Mov == None) {

        Act.SetBase( Self );
      }
      else if (Mov.bSlave) {

        Mov.GotoState('');
        Mov.SetBase( Self );
      }
    }
  return;
  }
  //client-side checks:
foreach AllActors( class 'light', Light, AttachTag ) //attach lights only
  Light.SetBase( Self );
}

defaultproperties
{
}
