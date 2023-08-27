// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// PlayerMotionFreeze : Disables all input keys.  cannot move, fire, switch weapons, or use items when active.
// As this is exclusively for in-level cutscenes, the HUD is disabled.
// ============================================================

class PlayerMotionFreeze expands Triggers;
var () bool bFreezeAllPlayers;
var () bool bHideFrozenPlayer; //should player be hidden?

function PlayerFreeze (tvplayer p, bool Freeze){
  if (!Freeze&&p.PlayerMod==1&&P.linfo.bCutscene){ //hack for cutscenes on intro.
    P.Linfo.bcutscene=false;
    P.linfo.ForceNoHud=false;
  }
  p.PlayerMod=byte(Freeze);
  if (bHideFrozenPlayer){
    if (Freeze){
       p.drawtype = DT_None;     //nbspecials stops view if p.bhidden!
       p.Visibility = 0;
    }
    else{
       p.drawtype = p.Default.DrawType;
       p.Visibility = p.Default.Visibility;
    }
  }
}
function SetFreeze(bool binv, pawn EventInstigator){
local tvplayer p;
  if (bFreezeAllPlayers){
    foreach AllActors(class'tvplayer', p)
       PlayerFreeze(p,binv);
  }
  else if (tvplayer(eventinstigator) != none)
    PlayerFreeze(tvplayer(eventinstigator),binv);
}

state() TriggerToggled
{
  function Trigger( actor Other, pawn EventInstigator )
  {
     if (tvplayer(eventinstigator) != none)
        SetFreeze(tvplayer(EventInstigator).playermod!=1,EventInstigator);
  }
}


state() FreezeWhileTriggered
{
  function Trigger( actor Other, pawn EventInstigator )
  {
    SetFreeze(true,EventInstigator);
  }

  function UnTrigger( actor Other, pawn EventInstigator )
  {
    SetFreeze(false,EventInstigator);
  }
}

defaultproperties
{
     bFreezeAllPlayers=True
}
