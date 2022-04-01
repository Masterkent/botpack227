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
  local string Params;

  if (Command~="exit"||Command~="quit"||Command~="debug gpf"){
    result="Warning: map author is a moron!";
    MessageResult=true;
  }
  else if (B227_ParseCommand(Command, Params) ~= "KillAll")
    B227_KillAll(Params);
  else
    result=EventInstigator.ConsoleCommand(Command);
  if (result==""||!MessageResult)
    return;
  if (Playerpawn(EventInstigator)!=none)
    EventInstigator.Clientmessage(result);
  else
    Broadcastmessage(result);
}

function string B227_ParseCommand(string Cmd, out string Params)
{
	B227_TrimStr(Cmd);
	B227_DivideStr(Cmd, " ", Cmd, Params);
	B227_TrimStr(Params);
	return Cmd;
}

// 227i's Divide is errouneous and useless
final static function bool B227_DivideStr(string S, string Delim, out string L, out string R)
{
	local int i;

	i = InStr(S, Delim);
	if (i < 0)
		return false;
	L = Left(S, i);
	R = Mid(S, i + Len(Delim));
	return true;
}

final static function B227_TrimStr(out string Str)
{
	local int StrLen;

	while (InStr(Str, " ") == 0)
		Str = Mid(Str, 1);
	while (true)
	{
		StrLen = Len(Str);
		if (StrLen == 0 || Mid(Str, StrLen - 1, 1) != " ")
			break;
		Str = Left(Str, StrLen - 1);
	}
}

function B227_KillAll(string ClassName)
{
	local class<Actor> ActorClass;
	local name ActorClassName;
	local Actor A;

	if (InStr(ClassName, ".") > 0)
	{
		ActorClass = class<Actor>(DynamicLoadObject(ClassName, class'Class', true));
		if (ActorClass != none)
		{
			foreach AllActors(class'Actor', A)
				if (ClassIsChildOf(A.Class, ActorClass))
					A.Destroy();
		}
	}
	else
	{
		ActorClassName = StringToName(ClassName);
		if (ActorClassName != '')
		{
			foreach AllActors(class'Actor', A)
				if (A.IsA(ActorClassName))
					A.Destroy();
		}
	}
}

defaultproperties
{
     MessageResult=True
}
