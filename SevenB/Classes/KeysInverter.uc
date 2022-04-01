// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// KeysInverter : When triggered, all player input keys will become inverted ;p
// Note: if binvertallplayers is false and a scriptedpawn triggers this, nothing will occur.
// Also scriptedpawns can only trigger this when in invertwhiletriggered state.
// ============================================================

class KeysInverter expands Triggers;
var () bool bInvertAllPlayers;  //if false, only affects instigator.

function SetInvert(bool binv, pawn EventInstigator){
local pawn p;
local byte btemp;
  if (bInvertAllPlayers)
    for (p=level.pawnlist;p!=none;p=p.nextpawn)
      If (p.isa('tvplayer')){
         tvplayer(p).PlayerMod=2*byte(binv);
          btemp=p.bfire;      //called between input and prender, so invert fire keys :)
          p.bfire=p.baltfire;
          p.baltfire=btemp;
      }
  else if (eventinstigator.Isa('tvplayer')){
     tvplayer(eventinstigator).PlayerMod=2*byte(binv);
     btemp=eventinstigator.bfire;      //called between input and prender, so invert fire keys :)
     eventinstigator.bfire=eventinstigator.baltfire;
     eventinstigator.baltfire=btemp;
  }
}

state() TriggerToggled
{
  function Trigger( actor Other, pawn EventInstigator )
  {
     if (eventinstigator.Isa('tvplayer'))
        SetInvert(tvplayer(EventInstigator).playermod!=2,EventInstigator);
  }
}


state() InvertWhileTriggered
{
  function Trigger( actor Other, pawn EventInstigator )
  {
    SetInvert(true,EventInstigator);
  }

  function UnTrigger( actor Other, pawn EventInstigator )
  {
    SetInvert(false,EventInstigator);
  }
}

defaultproperties
{
     bInvertAllPlayers=True
}
