//=============================================================================
// MovieHeadAnimate.
// by Hugh Macdonald
//=============================================================================
class MovieHeadAnimate expands UMS;

//This is the pawn who's head is being animated
var() string PawnName;
var pawn MyPawn;
var() string HeadScript[50];
var() name HeadAnimation[50];
var() rotator HeadRotation[50];
var() float HeadScriptVals[50];
var() float WaitTimes[50];
var() texture HeadSkins[80];
var bool bRolling;
var int CurrentCommand;
var float WaitTime;

//MovieLipSynch will start using the HeadScript if triggered.
event Trigger( Actor other, Pawn instigator )
{
    MyPawn = FindPawn(PawnName);
    bRolling = true;
}

//Grab the next command from the HeadScript and execute it.
function ExecuteNextCommand()
{
    local string Command, Word;

    Command=HeadScript[CurrentCommand];

    Word=GetFirstWord(Command);
    Command = CutOutWord(Word, Command);

    switch(Word)
    {
        case "Anim":
            ExecuteAnimate(Command);
            break;
        case "Rotate":
            ExecuteRotate(Command);
            break;
        case "Track":
            ExecuteTrack(Command);
            break;
        case "Skin":
            ExecuteSkinChange(Command);
            break;
     }

    //Now wait the appropriate amount of time before doing the next
    //command.
    if (CurrentCommand != 0)
    {
        WaitTime = WaitTimes[CurrentCommand];
        GotoState('Waiting');
    }

    CurrentCommand++;

    
}

function GoBackToMyTrailer()
{
    Destroy();
}

//State used to wait.
auto state Waiting
{
Begin:
StartWaiting:
    Sleep(WaitTime);
    GotoState('Rolling');
}

//State used to execute commands.
state Rolling
{
Begin:
    if(!bRolling)
        GotoState('Waiting');
ExecuteCommand:
    if(bRolling)
        ExecuteNextCommand();
CheckForWait:
    Goto'Begin';
}



//*******************************************************************
//Head changing stuff
//*******************************************************************

function ExecuteAnimate(string Command)
{
    local float Time;
    local name Animation;

    Time = HeadScriptVals[CurrentCommand];
    Animation = HeadAnimation[CurrentCommand];

    MovieHead(MyPawn.Weapon).DoAnimate(Animation, Time);
}


function ExecuteRotate(string Command)
{
    local string Word;
    local actor RotateTarget;
    local vector TargetVector;
    local rotator TargetRotation;
    local float Time;
    
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);

    //to something, or not to something, that is the question
    if(Word ~= "to")
    {
        //If no name after to, use the value in ScriptVectors
        if(Command == "")
            RotateTarget = NONE;
        else
            RotateTarget = FindActor(Command);
        
        if(RotateTarget != NONE)
            TargetVector = RotateTarget.Location;

        TargetRotation = rotator(TargetVector - MyPawn.Weapon.Location);
    }    
    else
        TargetRotation = MyPawn.Weapon.Rotation + HeadRotation[CurrentCommand];
        
    Time = HeadScriptVals[CurrentCommand];

    TargetRotation-=MyPawn.Rotation;
    
    MovieHead(MyPawn.Weapon).DoRotate(TargetRotation, RotateTarget, Time);
}

function ExecuteSkinChange(string Command)
{
    local int ElementNum, DesiredSkin;

    DesiredSkin = int(Command);
    ElementNum = HeadScriptVals[CurrentCommand];

    if(ElementNum >= 0 && ElementNum <= 7)
        MovieHead(MyPawn.Weapon).MultiSkins[ElementNum] = HeadSkins[DesiredSkin];
    else
        MovieHead(MyPawn.Weapon).Skin = HeadSkins[DesiredSkin];

}

function ExecuteTrack(string Command)
{
    local actor TargetActor;
    local rotator TrackDirections;
    
    TargetActor = FindActor(Command);
    TrackDirections = HeadRotation[CurrentCommand];
    MovieHead(MyPawn.Weapon).DoTrack(TargetActor, TrackDirections);
}


//*******************************************************************
//Finding stuff
//*******************************************************************

function Actor FindActor(string ActorName)
{
    local Actor A;

    foreach AllActors(class 'Actor', A)
        if (ActorName ~= string(A.Tag) || ActorName ~= string(A.Name))
               return A;
    //If there is no matching actor, return none.
    return NONE;
}


function Pawn FindPawn(string PawnName)
{
    local Pawn P;

    foreach AllActors(class'Pawn', P)
        if (PawnName ~= string(P.Tag) || PawnName ~= string(P.Name))
               return P;
    //If there is no matching pawn, return none.
    return NONE;
}


//*******************************************************************
//String Stuff
//*******************************************************************

//This returns the first word (everything before the first space) of 
//the string it is given.
function string GetFirstWord(String Message)
{
    local int lcv, MessLength;
    local String Parser, FirstWord;
    
    MessLength = Len(Message);
    
    for(lcv = 0; lcv < MessLength; lcv++)
    {
        Parser = Mid(Message, lcv, 1);
        
        if(Parser == " ")
            break;
    }
    
    FirstWord = Mid(Message, 0, lcv);
    
    return FirstWord;
}

//Takes "word" out of "message" and returns the new string.
function string CutOutWord(string Word, string Message)
{
    local int Pos, WordLength, MessageLength;
    local String NewMessage;
    
    WordLength = Len(Word);
    MessageLength = Len(Message);
    Pos = InStr(Message, Word);
    
    //if Word is not in Message, then return a blank string
    if(Pos < 0)
        return "";
    
    //If we are at the end of the message, just get what is before
    //the word, but not the space before it.  If not, get what is
    //before and after, and get rid of the space after the word.
    if((Pos + WordLength) >= MessageLength)
        NewMessage = Mid(Message,0,Pos);
    else
        NewMessage = Mid(Message,0,Pos) $ Mid(Message, (Pos + WordLength + 1));

    return NewMessage;
}

defaultproperties
{
}
