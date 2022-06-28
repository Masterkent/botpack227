//=============================================================================
// Director.
//=============================================================================
class Director expands UMS;

//Whether or not the Director has started issuing commands.  Set this
//property to true if you want the Director to start as soon as the
//level loads.
var() bool bRolling;
//The Director follows this Script and issues its commands to objects.
//The Script is an array of strings--each string is a single command.
var() string Script[50];
//These are values that certian script commands need to function.
//They match the command number they are used with.  For example: if 
//command #19 is a 'Wait Time' command, ScriptValsOne[19] is the
//amount of time to wait
//
//Contains times, the amount of time to wait after processing this
//command before doing something else.
var() float WaitTimes[50];
//Contains floats, used for commands which use float values.
var() float ScriptVals[50];
//Contains vectors, used for commands which use vectors.
var() vector ScriptVectors[50];
//Contains rotators used for commands that use rotators.
var() rotator ScriptRotators[50];
//Contains names used for commands that need names and not strings.
var() name ScriptNames[50];
//
//This is the number of the Script command that is currently being
//executed.
var int CurrentCommand;
//This is how long the Director must wait until the next command
//can be issued.
var float WaitTime;
//The pawn the Director is waiting for if bWaitingForPawn is true
var MoviePawn WaitPawn;
//Used to count iterations when looping withing a Director's script
var int CurrentIterations;

var bool bDoneWithMovie;

// Motion blur vars
var bool bMotionBlur;
var MovieBlurMaster BlurFX;

// Pawn lock vars
var bool bFreezePawns;

var Actor thisPlayer;



//*******************************************************************
//General Director Stuff
//*******************************************************************

//General Director Timer. Currently only used for MotionBlur FX.

function Tick (float DeltaTime) 
{  
  local Pawn P;

  if (bFreezePawns) {

    for(P = Level.PawnList; P != None; P = P.NextPawn) {
      if (!P.IsA('MoviePawn'))
        P.SetLocation(P.OldLocation);
    }

  }
}

//Director will start using the script if triggered.  This is great if
//you want the script to wait until a certian action is preformed to
//start.  Also means you can have multiple directors in a level, who
//trigger each other when done.
event Trigger( Actor other, Pawn instigator )
{
      if(!bRolling)
      {
        bRolling = true;
      bDoneWithMovie = false;
      
      thisPlayer = instigator;
      
      Log ("I have been triggered! "$Self);
      CurrentCommand = 0;
    }
}

//Grab the next command from the script and execute it.
function ExecuteNextCommand()
{
    local String Command, Word;
 
  bDoneWithMovie = false;
  
  if (CurrentCommand > 50)
    GoBackToMyTrailer();  // We dont want to access out of bounds.
  Command = Script[CurrentCommand];
    Word = GetFirstWord(Command);
    Log (CurrentCommand$" : "$Command);
    Command = CutOutWord(Word, Command);
    switch(Word)    
    {
        case "Camera":          // Camera control.
            ExecuteCameraAction(Command);
            break;
        case "POV":            // Change Player view to a given object in the level.
            ExecutePOV(Command);    
        case "Pawn":          // Pawn control.
            ExecutePawnAction(Command);
            break;
        case "Effect":          // Trigger actor.
            ExecuteEffect(Command);
            break;
        case "SoundEffect":        // Play SFX.
            ExecuteSoundEffect(Command);
            break;
        case "SetVolume":
          ExecuteSetVolume(Command);
          break;
        case "PlaySong":        // Play a song...
            ExecutePlaySong(Command);
            break;
        case "Dialogue":        // Text will appear on player's HUDs.
            ExecuteDialogue(Command);
            break;
        case "SetSpeed":        // Set game speed. ( = Slomo X).
            ExecuteSetSpeed();
            break;
        case "ChangeHUD":        // Change all player's HUD's.
            ExecuteChangeHUD(Command);
            break;
        case "ChangeLevel":        // Go to another level.
            ExecuteChangeLevel(Command);
            break;
        case "Loop":          // ?
            ExecuteLoop(Command);
            break;
        case "Spawn":          // Spawns an actor.
            ExecuteSpawn(Command);
            break;
        case "Shake":          // Shakes Player view.
            ExecuteShake();
            break;
        case "Fade":          // Fade screen
            ExecuteFade(Command);
            break;            // Director control directives
        case "Done":          // 
            GoBackToMyTrailer();    // -- Done: Kills director.
            break;            //
        case "Reset":          //
      GoBackToWaiting();      // -- Reset: Resets and suspends Director.
      break;            //
    case "Restart":          //
      CurrentCommand = -1;    // -- Restart: Causes director to loop.
      break;            //
    case "MotionBlur":        
      ExecuteMotionBlur(Command);
      break;
    case "FreezePawns":
      ExecuteFreezePawns(Command);
      break;
    case "PlayerView":
      ExecutePlayerView();
      break;
    case "":
      GoBackToMyTrailer();
            break;
    }
    
    //Now wait the appropriate amount of time before doing the next
    //command.
    WaitTime = WaitTimes[CurrentCommand];
    GotoState('Waiting');
    
    CurrentCommand++;
}

//This function is called when the Director has finished all the 
//commands for its script, but there is still stuff in the level
//that needs to occur.
function GoBackToMyTrailer()
{
  Log ("Destroying Self ("$Self$"). Save me Yoda!");
  Destroy();
}


function GoBackToWaiting()
{
  bRolling = false;
  CurrentCommand = 0;          
  bDoneWithMovie = true;
  WaitTime = 0.1;
  GotoState('Waiting');
}

function vector GetScriptVector( int i )
{
   return ScriptVectors[i];
}

//States are kind of like subclasses of the current class.  When an
//object goes into a new state, its functions can be overridden, so
//its behavior can change tottally, even though it is still the same
//objet.  It also, starting at "Begin:" runs through a series of 
//sequential commands that can have more headers and be looped.
//
//In this case, the director starts out waiting for bRolling to be
//true so it can start executing commands.  When this happens it goes
//to state Rolling which does all the checks for waiting on pawns and
//cameras, and executes a command if possible.



auto state Waiting
{
Begin:
StartWaiting:
    Sleep(WaitTime);
    GotoState('Rolling');
}

state Rolling
{
Begin:
  if(!bRolling) {
        GotoState('Waiting');
  }
ExecuteCommand:
    if(bRolling) {
        ExecuteNextCommand();
  }
CheckForWait:
    Goto'Begin';
}


//*******************************************************************
//Freeze Pawns
//*******************************************************************

function ExecuteFreezePawns(string Command)
{
  local Pawn P;
  if (Command == "On") 
  {
    log(self$": Freezing pawns");
    bFreezePawns = true;
    for(P = Level.PawnList; P != None; P = P.NextPawn)
    {
      P.GroundSpeed = 0;
      log(self$": Freezing"@P);
    }
  }
  if (Command == "Off") 
  {
    log(self$": Unfreezing pawns");
    for(P = Level.PawnList; P != None; P = P.NextPawn)
    {
      P.GroundSpeed = P.default.GroundSpeed;
      log(self$": Unfreezing"@P);
    }
    bFreezePawns = false;
  }
}

function ExecutePlayerView()
{
    local PlayerPawn P;
    
    foreach AllActors(class 'PlayerPawn', P)
        P.ViewTarget = none;
}

function ExecuteSetVolume(string Command)
{
  local Pawn P;
  local int Vol;
  
  Vol = ScriptVals[CurrentCommand];
  
  if(Command ~= "Music")
  {
    for(P = level.pawnlist; P != none; P = P.nextpawn)
    {
      if(P.IsA('PlayerPawn'))
        PlayerPawn(P).ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume "$Vol);
    }
  }
  
  if(Command ~= "Sound")
  {
    for(P = level.pawnlist; P != none; P = P.nextpawn)
    {
      if(P.IsA('PlayerPawn'))
        PlayerPawn(P).ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume "$Vol);
    }
  }
}
//*******************************************************************
//Motion Blur
//*******************************************************************

function ExecuteMotionBlur(string Command)
{
    if (Command == "On") {
    
    BlurFX = spawn(class'MovieBlurMaster');
    BlurFX.bMotionBlur = true;
    BlurFX.MotionBlurTime = (1 / ScriptVals[CurrentCommand]);
    BlurFX.MotionBlurFadeRate = ScriptVectors[CurrentCommand].X;
    BlurFX.Enable ('Timer');
    BlurFX.SetTimer (BlurFX.MotionBlurTime,true);
  }

  if (Command == "Off") {
  
    BlurFX.Destroy();

  }
}



//*******************************************************************
//POV Stuff
//*******************************************************************

//Sets the player's view to being that of some object in
//the level, which is presumably not a camera.
function ExecutePOV(string Command)
{
    local Actor TargetActor;
    
    TargetActor = FindActor(Command);
    
    ExecuteCutTo(TargetActor);
}


//*******************************************************************
//Camera Stuff
//*******************************************************************

function ExecuteCameraAction(string Command)
{
    local String Word;
    local MovieCamera TargetCamera;
    
    //find the camera
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);
    TargetCamera = FindCamera(Word);

    if(TargetCamera == none)
    {
        log(self$": No camera found: '"$word$"'");
        return;
    }
    
    //now get next part of command
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);

    switch(Word)    
    {
        case "SmPan":
          ExecuteSmoothPan(TargetCamera, Command);
          break;
        case "SmDolly":
          ExecuteSmoothDolly(TargetCamera, Command);
          break;
        case "Pan":
            ExecutePan(TargetCamera, Command);
            break;
        case "Zoom":
            ExecuteZoom(TargetCamera);
            break;
    case "Vertigo":
      ExecuteVertigo(TargetCamera, Command);
      break;
        case "Dolly":
            ExecuteDolly(TargetCamera, Command);
            break;
        case "Circle":
            ExecuteCircle(TargetCamera, Command);
            break;
        case "Track":
            ExecuteTrack(TargetCamera, Command);
            break;
        case "ChaseCam":
            ExecuteChaseCam(TargetCamera, Command);
            break;
        case "CutTo":
            ExecuteCutTo(TargetCamera);
            break;
        case "Interpolate":
            ExecuteInterpolate(TargetCamera, Command); 
            break;
        case "Accelerate":
          ExecuteCameraAccelerate(TargetCamera, Command);
          break;
        case "Shake":
          ExecuteCameraShake(TargetCamera, Command);
          break;
        case "Reset":
          ExecuteCameraReset(TargetCamera);
          break;
    }
}

function ExecuteCutTo(Actor NewCamera)
{
    local PlayerPawn P;
    
    foreach AllActors(class 'PlayerPawn', P)
        P.ViewTarget = NewCamera;
}

function ExecuteCameraReset(MovieCamera TargetCamera)
{
  TargetCamera.ResetCamera();
}

function ExecuteCameraShake(MovieCamera TargetCamera, string Command)
{
  local float time;
  local float mag;

  time = ScriptVals[CurrentCommand];
  mag = vsize(ScriptVectors[CurrentCommand]);
  
  TargetCamera.DoShake(time, mag, mag * 0.015);
}

function ExecuteCameraAccelerate(MovieCamera TargetCamera, string Command)
{
  local float Acceleration;
    local actor TargetActor;
    local vector TargetLocation;
    local float Time;
    
    if (Command == "")
        TargetActor = NONE;
    else
        TargetActor = FindActor(Command);
    
    //Check for no target.
    if(TargetActor == NONE)
        TargetLocation = ScriptVectors[CurrentCommand];
    else
        TargetLocation = TargetActor.Location;
    
    Time = ScriptVals[CurrentCommand];
    
    Acceleration = 17;
    
    TargetCamera.DoAccelDolly(TargetLocation, Time, Acceleration);
}

function ExecuteSmoothPan(MovieCamera TargetCamera, string Command)
{
    local string Word;
    local actor PanTarget;
    local vector TargetVector;
    local rotator TargetRotation;
    local float Time;
    local float Smoothness;
    
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);

    //to something, or not to something, that is the question
    if(Word ~= "to")
    {
        //If no name after to, use the value in ScriptVectors
        if(Command == "")
            PanTarget = NONE;
        else
            PanTarget = FindActor(Command);
        
        if(PanTarget != NONE)
            TargetVector = PanTarget.Location;
        else
            TargetVector = ScriptVectors[CurrentCommand];
                    
        TargetRotation = rotator(TargetVector - TargetCamera.Location);
    }    
    else
        TargetRotation = TargetCamera.Rotation + ScriptRotators[CurrentCommand];
        
    Time = ScriptVals[CurrentCommand];
    
    Smoothness = 5;
    
    TargetCamera.DoSmoothPan(TargetRotation, PanTarget, Time, Smoothness);
}

function ExecuteSmoothDolly(MovieCamera TargetCamera, string Command)
{
    local actor TargetActor;
    local vector TargetLocation;
    local float Time;
    local float Smoothness;
    
    if (Command == "")
        TargetActor = NONE;
    else
        TargetActor = FindActor(Command);
    
    //Check for no target.
    if(TargetActor == NONE)
        TargetLocation = ScriptVectors[CurrentCommand];
    else
        TargetLocation = TargetActor.Location;
    
    Smoothness = 5;
    
    Time = ScriptVals[CurrentCommand];
    
    TargetCamera.DoSmoothDolly(TargetLocation, TargetActor, Time, Smoothness);
}

function ExecutePan(MovieCamera TargetCamera, string Command)
{
    local string Word;
    local actor PanTarget;
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
            PanTarget = NONE;
        else
            PanTarget = FindActor(Command);
        
        if(PanTarget != NONE)
            TargetVector = PanTarget.Location;
        else
            TargetVector = ScriptVectors[CurrentCommand];
                    
        TargetRotation = rotator(TargetVector - TargetCamera.Location);
    }    
    else
        TargetRotation = TargetCamera.Rotation + ScriptRotators[CurrentCommand];
        
    Time = ScriptVals[CurrentCommand];
    
    TargetCamera.DoPan(TargetRotation, PanTarget, Time);
}

function ExecuteDolly(MovieCamera TargetCamera, string Command)
{
    local actor TargetActor;
    local vector TargetLocation;
    local float Time;
    
    if (Command == "")
        TargetActor = NONE;
    else
        TargetActor = FindActor(Command);
    
    //Check for no target.
    if(TargetActor == NONE)
        TargetLocation = ScriptVectors[CurrentCommand];
    else
        TargetLocation = TargetActor.Location;
    
    Time = ScriptVals[CurrentCommand];
    
    TargetCamera.DoDolly(TargetLocation, TargetActor, Time);
}

function ExecuteZoom(MovieCamera TargetCamera)
{
    local float Zoom, Time; 

    Time = ScriptVals[CurrentCommand];
    //  Okay, using a vector for the zoom dosen't make a whole lot of
    //sense, but it keeps us from adding an entire nother array of 
    //floats just for this one function.
    //  So, just put a number in one of the three spaces for the 
    //vector and that will where you zoom to.
    Zoom = VSize(ScriptVectors[CurrentCommand]);
    
    TargetCamera.DoZoom(Zoom, Time);
}

function ExecuteVertigo(MovieCamera TargetCamera, string Command)
{
  local actor TargetActor;
  
  TargetActor = FindActor(Command);
  
  TargetCamera.DoVertigo(TargetActor);
}

function ExecuteCircle(MovieCamera TargetCamera, string Command)
{
    local actor TargetActor;
    local rotator Speed;
    local vector Offset;
    local float Distance;
    
    TargetActor = FindActor(Command);
    Speed = ScriptRotators[CurrentCommand];
    Offset = ScriptVectors[CurrentCommand];
    Distance = ScriptVals[CurrentCommand];
    
    TargetCamera.DoCircling(TargetActor, Speed, Offset, Distance);
}

function ExecuteTrack(MovieCamera TargetCamera, string Command)
{
    local actor TargetActor;
    local vector Offset;
    local rotator TrackDirections;
    
    TargetActor = FindActor(Command);
    Offset = ScriptVectors[CurrentCommand];
    TrackDirections = ScriptRotators[CurrentCommand];
    
    TargetCamera.DoTracking(TargetActor, Offset, TrackDirections);
}

function ExecuteChaseCam(MovieCamera TargetCamera, string Command)
{
    local actor TargetActor;
    local vector Offset;
    local rotator RotOffset;
    local float Distance;

    TargetActor = FindActor(Command);
    Offset = ScriptVectors[CurrentCommand];
    RotOffset = ScriptRotators[CurrentCommand];
    
    TargetCamera.DoChaseCam(TargetActor, Offset, RotOffset);
}

function ExecuteInterpolate(MovieCamera TargetCamera, string Command)
{
    local actor TargetActor;
    local float NewRate, NewAlpha;

    TargetActor = FindActor(Command);
    NewRate = ScriptVals[CurrentCommand];
    //As I've said before, we're just using the vector as a float.
    //You'll want to set either X, Y, or Z to the value.
    NewAlpha = VSize(ScriptVectors[CurrentCommand]);
    
    TargetCamera.DoInterpolate(TargetActor, NewRate, NewAlpha);
}

//*******************************************************************
//Pawn Stuff
//*******************************************************************

function ExecutePawnAction(string Command)
{
    local String Word;
    local MoviePawn TargetPawn;
    
    //find the pawn
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);
    TargetPawn = MoviePawn(FindPawn(Word));
    
    //now get next part of command
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);
    
    //When working on a project you will probably want more control
    //over the pawns you are filming.  Therefore this is the code
    //you are going to most likely have to modify.  Just add another
    //case in here, another Execute function, and then add support
    //for your new action in the pawn you plan to use it in, or in
    //MoviePawn itself.

    switch(Word)    
    {
        case "Move":
            ExecuteMove(TargetPawn, Command);
            break;
        case "Rotate":
            ExecuteRotate(TargetPawn, Command);
            break;
        case "PlayAnim":
            ExecutePlayAnim(TargetPawn, Command);
            break;
        case "StopAnim":
            ExecuteStopAnim(TargetPawn, Command);
            break;
        case "SetWeapon":
            ExecuteSetWeapon(TargetPawn, Command);
            break;
        case "SetHead":
            ExecuteSetHead(TargetPawn, Command);
            break;
        case "Fire":
            ExecuteFire(TargetPawn, Command);
            break;
        case "AltFire":
            ExecuteAltFire(TargetPawn, Command);
            break;
        case "Circle":
            ExecutePawnCircle(TargetPawn, Command);
            break;
        case "Track":
            ExecutePawnTrack(TargetPawn, Command);
            break;
        case "SetSkin":
            ExecuteSetSkin(TargetPawn, Command);
            break;
        case "Interpolate":
          ExecutePawnInterpolate(TargetPawn, Command);
          break;
        case "Accelerate":
          ExecutePawnAccelerate(TargetPawn, Command);
          break;
        case "ChangeAcceleration":
          ExecutePawnChangeAccel(TargetPawn);
    }
}

function ExecutePawnChangeAccel(MoviePawn TargetPawn)
{
  local AccelerateMoviePawn TargetAccelPawn;
  local vector AccelVector;
  
  TargetAccelPawn = AccelerateMoviePawn(TargetPawn);
  log(self$": ExecutePawnChangeAccel() called");
  if(TargetAccelPawn == none)
  {
    log(self$": The pawn selected was not an accelerated pawn");
    return;
  }
  
  AccelVector = ScriptVectors[CurrentCommand];
  
  TargetAccelPawn.ChangeAccel(AccelVector);
}

function ExecutePawnAccelerate(MoviePawn TargetPawn, string Command)
{
  local float Acceleration;
    local actor TargetActor;
    local vector TargetLocation;
    local float Time;
    
    if (Command == "")
        TargetActor = NONE;
    else
        TargetActor = FindActor(Command);
    
    //Check for no target.
    if(TargetActor == NONE)
        TargetLocation = ScriptVectors[CurrentCommand];
    else
        TargetLocation = TargetActor.Location;
    
    Time = ScriptVals[CurrentCommand];
    
    Acceleration = 17;
    
    TargetPawn.DoAccelMove(TargetLocation, Time, Acceleration);
}

function ExecutePawnInterpolate(MoviePawn TargetPawn, string Command)
{
    local actor TargetActor;
    local float NewRate, NewAlpha;

    TargetActor = FindActor(Command);
    NewRate = ScriptVals[CurrentCommand];
    //As I've said before, we're just using the vector as a float.
    //You'll want to set either X, Y, or Z to the value.
    NewAlpha = VSize(ScriptVectors[CurrentCommand]);
    
    TargetPawn.DoInterpolate(TargetActor, NewRate, NewAlpha);
}

function ExecuteMove(MoviePawn TargetPawn, string Command)
{
    local actor TargetActor;
    local vector TargetLocation;
    local float Time;
    
    if (Command == "")
        TargetActor = NONE;
    else
        TargetActor = FindActor(Command);
    
    //Check for no target.
    if(TargetActor == NONE)
        TargetLocation = ScriptVectors[CurrentCommand];
    else
        TargetLocation = TargetActor.Location;
    
    Time = ScriptVals[CurrentCommand];
    
    TargetPawn.DoMove(TargetLocation, TargetActor, Time);
}

function ExecuteRotate(MoviePawn TargetPawn, string Command)
{
    local string Word;
    local actor RotTarget;
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
            RotTarget = NONE;
        else
            RotTarget = FindActor(Command);
        
        if(RotTarget != NONE)
            TargetVector = RotTarget.Location;
        else
            TargetVector = ScriptVectors[CurrentCommand];
                    
        TargetRotation = rotator(TargetVector - TargetPawn.Location);
    }    
    else
        TargetRotation = TargetPawn.Rotation + ScriptRotators[CurrentCommand];
        
    Time = ScriptVals[CurrentCommand];
    
    TargetPawn.DoRotate(TargetRotation, RotTarget, Time);
}

function ExecutePlayAnim(MoviePawn TargetPawn, string Command)
{
    local float Time, TweenTime;
    local name AnimSeq;
    
    Time = ScriptVals[CurrentCommand];
    AnimSeq = ScriptNames[CurrentCommand];
    //Yes, it dosen't make much sense to use ScriptVectors, but it
    //means one less array of variables.  Put the value you want in
    //X, Y, or Z, but only one of them.
    TweenTime = VSize(ScriptVectors[CurrentCommand]);    
    
    if(Command ~= "Loop")
        TargetPawn.DoLoopAnim(AnimSeq, Time, TweenTime);
    else    
        TargetPawn.DoPlayAnim(AnimSeq, Time, TweenTime);
}

function ExecuteStopAnim(MoviePawn TargetPawn, string Command)
{
    if(Command ~= "Hard")
        TargetPawn.DoHardStop();
    else
        TargetPawn.DoSoftStop();
}

function ExecuteSetWeapon(MoviePawn TargetPawn, string Command)
{
    local weapon NewWeapon;
    local class<weapon> WeaponType;
    local rotator WeaponRotation;

    WeaponRotation=ScriptRotators[CurrentCommand];

    WeaponType = class<weapon>(DynamicLoadObject(Command, class'Class'));
    TargetPawn.Weapon = spawn(WeaponType);
    TargetPawn.Weapon.GiveTo(TargetPawn);
    TargetPawn.Weapon.SetRotation(WeaponRotation);
}

function ExecuteSetHeadSize(MoviePawn TargetPawn)
{
    local float NewHeadSize;

    NewHeadSize = ScriptVals[CurrentCommand];
    TargetPawn.Weapon.ThirdPersonScale=NewHeadSize;
}

function ExecuteSetHead(MoviePawn TargetPawn, string Command)
{
  local weapon NewHead;
    local class<weapon> HeadType;
    local rotator HeadRotation;

    HeadRotation=ScriptRotators[CurrentCommand];

    HeadType = class<MovieHead>(DynamicLoadObject(Command, class'Class'));
    TargetPawn.Weapon = spawn(HeadType);
    TargetPawn.Weapon.GiveTo(TargetPawn);
    TargetPawn.Weapon.SetRotation(HeadRotation);

  
}

function ExecuteFire(MoviePawn TargetPawn, string Command)
{
    local vector Offset;
    local actor TargetActor;
    local string Word;
    
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);
    
    TargetActor = FindActor(Word);
    Offset = ScriptVectors[CurrentCommand];
    
    TargetPawn.DoFire(TargetActor.Location, Offset);
}

function ExecuteAltFire(MoviePawn TargetPawn, string Command)
{
    local vector Offset;
    local actor TargetActor;
    local string Word;
    
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);
    
    TargetActor = FindActor(Word);
    Offset = ScriptVectors[CurrentCommand];
    
    TargetPawn.DoAltFire(TargetActor.Location, Offset);
}

function ExecutePawnCircle(MoviePawn TargetPawn, string Command)
{
    local actor TargetActor;
    local rotator Speed;
    local vector Offset;
    local float Distance;
    
    TargetActor = FindActor(Command);
    Speed = ScriptRotators[CurrentCommand];
    Offset = ScriptVectors[CurrentCommand];
    Distance = ScriptVals[CurrentCommand];
    
    TargetPawn.DoCircling(TargetActor, Speed, Offset, Distance);
}

function ExecutePawnTrack(MoviePawn TargetPawn, string Command)
{
    local actor TargetActor;
    local vector Offset;
    local rotator TrackDirections;
    
    TargetActor = FindActor(Command);
    Offset = ScriptVectors[CurrentCommand];
    TrackDirections = ScriptRotators[CurrentCommand];
    
    TargetPawn.DoTracking(TargetActor, Offset, TrackDirections);
}

function ExecuteSetSkin(Pawn TargetPawn, string Command)
{
    local string NewSkinName;
    local int ElementNum;
    
    NewSkinName = GetFirstWord(Command);
    
    ElementNum = ScriptVals[CurrentCommand];
    
    if(ElementNum >= 0 && ElementNum <= 7)
        TargetPawn.SetSkinElement(TargetPawn, ElementNum, NewSkinName, "");
    else
        TargetPawn.Skin = Texture(DynamicLoadObject(NewSkinName, class'Texture'));
}


//*******************************************************************
//Shake Stuff
//*******************************************************************

function ExecuteShake()
{
    local Pawn P;
    local float ShakeTime, ShakeMag;

    ShakeTime = ScriptVals[CurrentCommand];
    ShakeMag = VSize(ScriptVectors[CurrentCommand]);

    for(P = level.pawnlist; P != none; P = P.nextpawn)
    {
      if(P.IsA('PlayerPawn'))
            PlayerPawn(P).ShakeView(ShakeTime,ShakeMag, 0.015 * ShakeMag);
    }
    
    log(self$": Shaking: Time ="@ShakeTime@" & ShakeMag ="@ShakeMag);
}

//*******************************************************************
//Effects Stuff
//*******************************************************************

function ExecuteEffect(string Command)
{
    local string Word;
    local actor TargetEffect;
    local pawn Instigator;
    
    //get the effect name
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);
    
    //find the instigator
    Instigator = FindPawn(Command);
    
    //Go through and for EVERY actor whose tag matches word, trigger
    foreach AllActors(class 'Actor', TargetEffect)
        if (Word ~= string(TargetEffect.Tag))
               TargetEffect.Trigger(self, Instigator);
}


//*******************************************************************
//SoundEffects Stuff
//*******************************************************************

function ExecuteSoundEffect(string Command)
{
    local PlayerPawn M;
    local sound MySound;
    local float Volume;

    MySound = Sound(DynamicLoadObject(Command, class'Sound'));
    Volume = ScriptVals[CurrentCommand];
    
    foreach AllActors(class 'PlayerPawn', M)
    {
        M.PlaySound(MySound,,Volume);
    }
}

//*******************************************************************
//Fade Stuff
//*******************************************************************

function ExecuteFade(string Command)
{
    local MoviePlayer P;
    local vector FadeColor;
    local float FadeTime;
    local bool bFadeOut;

    switch(Command)
    {
        case "In":
            bFadeOut = true;
            break;
        case "Out":
            bFadeOut = false;
            break;
    }
    
    FadeColor = ScriptVectors[CurrentCommand];
    FadeTime = ScriptVals[CurrentCommand];

    foreach AllActors(class'MoviePlayer', P)
        P.FadeView(FadeTime, FadeColor, bFadeOut);
}

//*******************************************************************
//PlaySong Stuff
//*******************************************************************

function ExecutePlaySong(string Command)
{
    local PlayerPawn M;
    local Music Song;
    local float SongSection, TransitionNum;
    local EMusicTransition Transition;

    Song = Music(DynamicLoadObject(Command, class'Music'));
    SongSection = ScriptVals[CurrentCommand];
    //Once again I am using a value that really doesn't make sense, 
    //but I do it only because it is the easiest way to do things 
    //both from my standpoint and yours.  There are six possible
    //music transitions.  Set one of the values of ScriptVectors to
    //a number 0 through 5 (X, Y, or Z, it doesn't matter, but only
    //one of them).  This will correspond with one of the six kinds
    //of transitions.  If you don't care about transitions, don't do
    //anything.
    TransitionNum = VSize(ScriptVectors[CurrentCommand]);

    switch (TransitionNum)
    {
        case 0:
            Transition = MTRAN_Instant;
            break;
        case 1:
            Transition = MTRAN_Segue;
            break;
        case 2:
            Transition = MTRAN_Fade;
            break;
        case 3:
            Transition = MTRAN_FastFade;
            break;
        case 4:
            Transition = MTRAN_SlowFade;
            break;
        caseelse:
            Transition = MTRAN_None;        
            break;
    }
    
    foreach AllActors(class 'PlayerPawn', M)
    {
        M.ClientSetMusic(Song, SongSection, 255, Transition);
    }
}


//*******************************************************************
//Dialogue Stuff
//*******************************************************************

function ExecuteDialogue(string Command)
{
    local PlayerPawn M;
    local float Size;
    local color NewColor;
    
    Size = ScriptVals[CurrentCommand];
    //Once again, it doesen't make sense for a vector to be defining
    //color, but it is easier this way.  Just set X, Y, and Z to the
    //Red, Green, and Blue values respectively (between 0 and 255).
    NewColor.R = ScriptVectors[CurrentCommand].X;
    NewColor.G = ScriptVectors[CurrentCommand].Y;
    NewColor.B = ScriptVectors[CurrentCommand].Z;
    
    foreach AllActors(class 'PlayerPawn', M)
    {
        if(MovieHUD(M.myHUD) != NONE)
            MovieHUD(M.myHUD).SetUpDialogue(Command, Size, NewColor);
    }
}

//*******************************************************************
//SetSpeed Stuff
//*******************************************************************

function ExecuteSetSpeed()
{
    local float Speed;
    
    Speed = ScriptVals[CurrentCommand];

    Level.Game.Level.TimeDilation = Speed;
    Level.Game.SetTimer(Level.TimeDilation, true);
}

//*******************************************************************
//ChangeHUD Stuff
//*******************************************************************

function ExecuteChangeHUD(string Command)
{
    local PlayerPawn M;
    local class<HUD> NewHUDType;
    
    NewHUDType = class<HUD>(DynamicLoadObject(Command, class'Class'));

    foreach AllActors(class 'PlayerPawn', M)
    {
        M.HUDType = NewHUDType;
        M.myHUD = spawn(M.HUDType, M);
    }
}

//*******************************************************************
//ChangeLevel Stuff
//*******************************************************************

function ExecuteChangeLevel(string Command)
{
    local string URL;
    local GameInfo NewGame;
    local class<GameInfo> GameClass;
    //-local pawn p;
    
    // Reset the game class.
    GameClass.Static.ResetGame();

    URL = Command; //$"?Game="$GameType$"?Mutator="$MutatorList;

    //ParentWindow.Close();
    //Root.Console.CloseUWindow();
    /*-
    for (p=level.pawnlist;p!=none;p=p.nextpawn)
      if (p.IsA('playerpawn')){
        if (level.game.IsA('tvsp')) //ONP hack!
          Playerpawn(P).ClientTravel( URL, TRAVEL_Relative, false );
        else
          Playerpawn(P).ClientTravel(URL, TRAVEL_Absolute, false);
      }
    */
    if (Level.NetMode == NM_Standalone)
        Level.GetLocalPlayerPawn().ClientTravel(URL, TRAVEL_Relative, false);
    else
        Level.ServerTravel(URL, false);
}


//*******************************************************************
//Loop Stuff
//*******************************************************************

function ExecuteLoop(string Command)
{
    local int NewCommandLine;
    local float DesiredIterations;
    
    NewCommandLine = int(Command);
    DesiredIterations = ScriptVals[CurrentCommand];
    
    if(DesiredIterations > 0)
    {
        CurrentIterations++;
    }
    
    if(CurrentIterations <= DesiredIterations)
    {
        //We change it to NewCommandLine - 1 so that the increment that
        //occurs after this command is performed will set it to the
        //desired command line number.
        CurrentCommand = NewCommandLine - 1;
    }
    else
    {
        //Do nothing
        CurrentIterations = 0;
    }
}


//*******************************************************************
//Spawn Stuff
//*******************************************************************

function ExecuteSpawn(string Command)
{
    local string Word;
    local class<actor> SpawnClass;
    local actor TargetActor;
    local vector Offset;
    local rotator TargetRotation;
    local name TargetTag;
    
    //get the object
    Word = GetFirstWord(Command);
    Command = CutOutWord(Word, Command);
    
    SpawnClass = class<actor>(DynamicLoadObject(Word, class'Class'));
    TargetActor = FindActor(Command);
        
    if(TargetActor == NONE)
        TargetActor = self;
    
    Offset = ScriptVectors[CurrentCommand];
    TargetRotation = ScriptRotators[CurrentCommand];
    TargetTag = ScriptNames[CurrentCommand];
    
    Spawn(SpawnClass, self, TargetTag, (TargetActor.Location + Offset), (TargetActor.Rotation + TargetRotation));
}

//*******************************************************************
//Finding Stuff
//*******************************************************************

function Pawn FindPawn(string PawnName)
{
    local Pawn P;

    if(PawnName ~= "PlayerPawn")
      return Pawn(thisPlayer);

    foreach AllActors(class'Pawn', P)
        if (PawnName ~= string(P.Tag) || PawnName ~= string(P.Name))
               return P;
    //If there is no matching pawn, return none.
    return NONE;
}

function Actor FindActor(string ActorName)
{
    local Actor A;
    
    if(ActorName ~= "PlayerPawn")
      return thisPlayer;
      
    foreach AllActors(class 'Actor', A)
        if (ActorName ~= string(A.Tag) || ActorName ~= string(A.Name))
               return A;
    //If there is no matching actor, return none.
    return NONE;
}

function MovieCamera FindCamera(string CameraName)
{
    local MovieCamera C;

    foreach AllActors(class 'MovieCamera', C)
        if (CameraName ~= string(C.Tag) || CameraName ~= string(C.Name))
               return C;
    //If there is no matching camera, return none.
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
