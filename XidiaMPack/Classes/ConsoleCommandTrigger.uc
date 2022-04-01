// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// ConsoleCommandTrigger : I am very apprehensive about this, but nonetheless, here it is.
// Do NOT do something stupid!
// ============================================================

class ConsoleCommandTrigger expands Triggers;

var () string Command;  //the actual console command
var () bool MessageResult; //if the command returns something, should it be shown to client.  Note: only applies to native commands.

function Trigger( actor Other, pawn EventInstigator ){
  local string result;
  if (Command~="exit"||Command~="quit"||Command~="debug gpf"){
    result="Warning: map author is a moron!";
    MessageResult=true;
  }
  else
    result=EventInstigator.ConsoleCommand(Command);
  if (result==""||!MessageResult)
    return;
  if (Playerpawn(EventInstigator)!=none)
    EventInstigator.Clientmessage(result);
  else
    Broadcastmessage(result);
}

defaultproperties
{
     MessageResult=True
}
