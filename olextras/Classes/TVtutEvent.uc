// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVtutEvent. Used for tutorial.  And only for tutorial :P
// gameinfo manages it. Of course this prevents co-op but oh well.
// ============================================================

class TVtutEvent expands Triggers;
var () int MSGNumber; //the number to go to next.
function prebeginplay(){    //ONLY FOR tvTUTORIALS.
  if (!level.game.isa('TVTutorial'))
    destroy();
}
function Trigger( actor Other, pawn EventInstigator )
{
  TVtutorial(level.game).advance(MSGNumber);
  //disable('trigger'); //1 trigger only!
}

defaultproperties
{
     Texture=Texture'Engine.S_SpecialEvent'
}
