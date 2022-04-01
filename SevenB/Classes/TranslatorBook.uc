// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TranslatorBook : A book that can do translator events :)  Use the skin var to change color.
// Use like any translator event.
// This is designed mostly so that the event will move with the book..
// ============================================================

class TranslatorBook expands Book;
// Human readable triggering message.
var() localized string Message;
var() localized string AltMessage;
var() sound NewMessageSound;
var() bool bTriggerAltMessage;
var() float ReTriggerDelay; //minimum time before trigger can be triggered again

var() localized String M_NewMessage;
var() localized String M_TransMessage;
var tvtranslatorevent trans;

function PostBeginPlay(){
  trans=spawn(class'tvtranslatorevent',,tag);
  if (trans == none)
    return;
  trans.setbase(Self);
  trans.Message=Message;
  Trans.AltMessage=AltMessage;
  Trans.NewMessageSound=NewMessageSound;
  Trans.btriggerAltMessage=bTriggerAltMessage;
  Trans.ReTriggerDelay=RetriggerDelay;
  if (M_NewMessage!=default.M_NewMessage)
    Trans.M_NewMessage=M_newmessage;
  if (M_Transmessage!=default.M_Transmessage)
    Trans.M_Transmessage=M_Transmessage;
}
//delete message if book goes bye bye
function Destroyed(){
  Super.Destroyed();
  if (trans != none)
    trans.Destroy();
}

defaultproperties
{
     NewMessageSound=Sound'UnrealShare.Pickups.TransA3'
     ReTriggerDelay=0.250000
     M_NewMessage="New Translator Message"
     M_TransMessage="Translator Message"
     Skin=Texture'UnrealShare.Skins.JBook4'
}
