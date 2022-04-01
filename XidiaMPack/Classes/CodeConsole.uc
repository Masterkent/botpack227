// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// CodeConsole.  Used to allow the player to input a "security" code.
// Code Randomly generated at start and can bind to a translator event which will tell the player what the code is.
// When security code is correct, it triggers actors of 'event'
// if wrong, it will trigger actors with the failure tag.
// Triggering this actor causes it to swap benabled.
// ============================================================

class CodeConsole expands Triggers;

//Level designer configurable:
var () int MinNumber; //smallest number allowed
var () int MaxNumber; //largest number allowed
// Tag of the translator which will have a code inserted in it.  supports both the message and altmessage
// The macro %c has the random number inserted into it.
var () name TranslatorTag;
var () string ClearenceMessage; //message to give if code inputted is correct
var () sound ClearenceSound; //sound to play if correct code
var () string FailureMessage; //message to give if code inputted is incorrect.
var () sound FailureSound; //sound to play if incorrect code
var () string SecurityPrompt; //Message shown in console.
var () sound PromptSound;  //sound when touched
var () sound KeyEnterSound; //sound to play when a key is pressed in the console
var () name FailureEvent; //triggers actors with the tag of failure trigger if code is wrong (i.e. alarms)
var () bool bEnabled; //is it on and working?
var () name MessageType; //what msg types are they?
var () name LinkedTag; //for linked consoles.  Only 1 will generate the code.  Only 1 console should have translatortag.
var () bool DisableOnCorrect; //disable on correct code?
//Internal:
var int MyCode; //the all important code :D
var int digits; //digits to decide how long code can be to enter.
var bool bActive; //being used?
//net: must replicate EVERYTHING!
replication{
  reliable if (role==role_authority)
    MyCode, bEnabled, digits, ClearenceMessage, ClearenceSound, FailureMessage, FailureSound,
     SecurityPrompt, PromptSound, KeyEnterSound, MessageType, DisableOnCorrect;
}
function postbeginplay(){ //generate random number here.
  local codeconsole cc;
  if (mycode==-1){
    Mycode=rand(1+MaxNumber-MinNumber)+MinNumber; //generate code
    if (LinkedTag!='')
      foreach AllActors(class'codeconsole',CC,linkedTag)
        CC.MyCode=Mycode; //1 will be me, but no big deal.
   }
  SetupTrans();
}
simulated function PostNetBeginPlay(){
  Texture=none;
}
function SetupTrans(){ //done on client as well
local Tvtranslatorevent trans;
//message manipulation:
local int pos;
local string outstr, ins, code;
Texture=none;
digits=len(string(MaxNumber)); //count digits to test input.
  code=string(mycode);
  for (pos=len(code);pos<digits;pos++) //inserts in 0's
     code="0"$code;
  digits=len(code);
  if (Role<Role_Authority)
    return;
  if (translatortag!='')
    foreach allactors(class'Tvtranslatorevent',trans,Translatortag){ //insert in code in transevents.
     ins=trans.Message; //normal message
     pos=instr(ins,"%c");
     while (pos!=-1){
       outstr=outstr$left(ins,pos)$Code;
       ins=mid(ins,pos+2);
       pos=instr(ins,"%c");
     }
     trans.message=outstr$ins;
     outstr="";
     ins=trans.AltMessage; //Alt message
     pos=instr(ins,"%c");
     while (pos!=-1){
       outstr=outstr$left(ins,pos)$Code;
       ins=mid(ins,pos+2);
       pos=instr(ins,"%c");
     }
     trans.altmessage=outstr$ins;
    }
}
//from teleporter:
function Trigger( actor Other, pawn EventInstigator )
{
  bEnabled = !bEnabled;
  if ( bEnabled &&level.netmode!=nm_dedicatedserver) //console any players already in my radius
   CheckTouching();
}
function CheckTouching(){ //save games/enabling
  local int i;
  bactive=false; //not using!
  for (i=0;i<4;i++)
      if ( Touching[i] != None )
        Touch(Touching[i]);
}
simulated function touch(actor other){
  local CodeConsoleWindow CCW;
  if (!bEnabled||bActive||!other.isa('tvplayer')||viewport(playerpawn(other).player)==none)
    return;
  //play sound and initialize uwindow menu:
  if (Promptsound!=none)
    PlaySound(PromptSound, SLOT_Misc);
  Other.Acceleration=vect(0,0,0);
  WindowConsole(Playerpawn(Other).Player.Console).bQuickKeyEnable = true;
  WindowConsole(Playerpawn(other).Player.Console).LaunchUWindow();
  if (!WindowConsole(Playerpawn(other).Player.Console).bcreatedroot) //must generate root
     WindowConsole(Playerpawn(other).Player.Console).createrootwindow(none);
  CCW=CodeConsoleWindow(WindowConsole(Playerpawn(other).Player.Console).Root.CreateWindow(class'CodeConsoleWindow', 0, 0, 200, 200));
  bActive=true;
  CCW.CC=self; //init.
}
simulated function TestCode (tvplayer p, int code){
  //log ("in code is"@code@"Correct code is"@mycode);
  P.CodeSend(self,code==mycode);
}


function DoEvent(bool Cleared, tvplayer EventInstigator){ //run events (client replicates this call)
  local name searchtag;
  local actor a;
  if (!benabled) //h4x0r
    return;
  if (cleared){
    searchtag=event;
    if (DisableOnCorrect)
      benabled=false;
  }
  else
    searchTag=FailureEvent;
  if (searchtag!='')
    foreach AllActors (class'actor',a,SearchTag){
      if (A!=self)
        A.Trigger( Self, EventInstigator );
    }

  if (cleared){ //good!
     EventInstigator.clientmessage(ClearenceMessage,MessageType,true);
     if (ClearenceSound!=none)
       PlaySound(ClearenceSound, SLOT_Misc);
   }
   else { //incorrect code
     EventInstigator.clientmessage(FailureMessage,MessageType,true);
     if (FailureSound!=none)
       PlaySound(FailureSound, SLOT_Misc);
   }
}

defaultproperties
{
     MaxNumber=9999
     ClearenceMessage="Access Granted"
     ClearenceSound=Sound'UnrealShare.Pickups.TransA3'
     FailureMessage="Incorrect Security Code:  Access Denied"
     FailureSound=Sound'UnrealShare.Pickups.TransA3'
     SecurityPrompt="Enter Security Code:"
     PromptSound=Sound'UnrealShare.Pickups.TransA3'
     KeyEnterSound=Sound'UnrealShare.Pickups.TransA3'
     bEnabled=True
     MessageType=CriticalEvent
     DisableOnCorrect=True
     MyCode=-1
     bHidden=False
     RemoteRole=ROLE_SimulatedProxy
}
