//=============================================================================
// MoviePawn.
//=============================================================================
class MoviePawn expands Pawn;

//The number of units of rotation that make up half a full rotation,
//or one Pi radians.
const RotPiVal = 32768;
//If the pawn is rotating.
var bool bRotating;
//The rotation to go to
var rotator TargetRotation;
//The number of seconds to spend rotating
var float RotTime;
//The change in rotation per second
var rotator RotChange;
//The actor the pawn is trying to rotate towards
var actor RotTarget;
//If the pawn is moving.
var bool bMoving;
var bool bInterpolating;
//The location the pawn is trying to move to.
var vector DesiredLocation;
var float MoveAcceleration;
var bool bAccelerating;
//The number of seconds to spend moving.
var float MoveTime;
var float TotalMoveTime;
//The change in location per second.
var vector MoveChange;
var vector OriginalMoveLocation;
//The actor the pawn is trying to move to
var actor MoveTarget;
//The pawn must stay facing the TrackingTarget.
var bool bTracking;
//The offset while tracking
var vector TrackingOffset;
//The actor the pawn is tracking
var Actor TrackingTarget;
//The directions that will be tracked.  If the value is greater than
//or equal to zero that kind of rotation will be used to track.  So
//only if you don't want to track in a given direction will you want
//to set one of the values to -1.
var rotator TrackingDirections;
//The pawn is circling some point, or some moving actor, but not
//facing it (unless combined with tracking).
var bool bCircling;
//The radius between the point and the pawn that the camera uses
//to rotate.
var vector Radius;
//The change of rotation per second while circling
var rotator CirclingSpeed;
//The offset while circing
var vector CirclingOffset;
//The actor the pawn is circling.
var actor CircleTarget;
//The pawn needs to flip due to circling over a tracked target.
var bool bFlip;
var bool bFlipNext;
//The rotation the Pawn wants to fire at
var rotator FiringRotation;
// The different footstep sounds that can be played when the pawn walks or runs
var(FootSteps) sound FootSteps[6];
// Up to six different animations can have footsteps
var(FootSteps) name FootStepAnimation[6];
// The two frames where a foot hits the ground
var(FootSteps) int Foot1Frame[6];
var(FootSteps) int Foot2Frame[6];
// The volume of the footsteps (can be different for each animation)
var(FootSteps) byte FootStepVolume[6];
// The total number of frames in that animation
var(FootSteps) int TotalFrames[6];
// The number of the animation that is being played
var int FootStepAnimNum;
// Whether there are footsteps or not
var bool bFootSteps;
// Whether the footsteps are looping
var bool bLoopingSteps;
// The time of one loop of the animation
var float FootStepTime;
// The time before the first and second footsteps
var float Foot1Time;
var float Foot2Time;
// The time since that loop started
var float FootStepLoopTime;
// Whether the two footsteps have been played yet
var bool bPlayedFoot1;
var bool bPlayedFoot2;


//Just like with the camera, tick is where most things happen.  The
//position, rotation, ect. of the pawn is updated here.
//
//Just like the camera, these do functions are called by the director
//to set up and start various actions.
//
//Invalid Combinations:
//  + Circling with moving.
//  + Tracking with rotating.
//  + Rotating with tracking.
//  + Moving with circling.
//
event Tick(float DeltaTime)
{
    local vector TempVec, X, Y, Z;
    local rotator TempRot, TempRot2;
    local int RandFootStep;

//    log(self$": Tick() called in MoviePawn");
    
    // Check for footsteps
    if(bFootSteps)
    {
        if(bLoopingSteps)
        {
            FootStepLoopTime += DeltaTime;
            if(!bPlayedFoot1 && FootStepLoopTime >= Foot1Time)
            {
                RandFootStep = Rand(6);
                PlaySound(FootSteps[RandFootStep],,FootStepVolume[FootStepAnimNum]);
            }
            if(!bPlayedFoot2 && FootStepLoopTime >= Foot2Time)
            {
                RandFootStep = Rand(6);
                PlaySound(FootSteps[RandFootStep],,FootStepVolume[FootStepAnimNum]);
            }
            if(FootStepLoopTime >= FootStepTime)
            {
                FootStepLoopTime = 0;
            }
        }
        else
        {
            FootStepLoopTime += DeltaTime;
            if(!bPlayedFoot1 && FootStepLoopTime >= Foot1Time)
            {
                RandFootStep = Rand(6);
                PlaySound(FootSteps[RandFootStep],,FootStepVolume[FootStepAnimNum]);
            }
            if(!bPlayedFoot2 && FootStepLoopTime >= Foot2Time)
            {
                RandFootStep = Rand(6);
                PlaySound(FootSteps[RandFootStep],,FootStepVolume[FootStepAnimNum]);
            }
            if(FootStepLoopTime >= FootStepTime)
            {
                bFootSteps = false;
            }
        }
    }

/*  //Check for interpolation
  if(bInterpolating)
  {
    log(self$": Interpolating");
    //Do nothing, regular physics will handle this
  }
  else*/
  if (!bInterpolating)
    SetPhysics(PHYS_None);

    //Check for rotating
  if(bRotating)
  {
    //First, do update for moving target/pawn if neccesary.
    if(RotTarget != NONE)
    {
      TempRot = rotator(RotTarget.Location - Location);
      DoRotate(TempRot, RotTarget, RotTime);
    }
    
    //We need a check to see if it is done.
    if(RotTime <= DeltaTime)
    {
      SetRotation(TargetRotation);
      bRotating = false;
    }
    else
    {
      SetRotation(Rotation + (RotChange * DeltaTime));
      RotTime -= DeltaTime;
    }
  }
  
  if(bAccelerating)
  {
    if(MoveTime <= DeltaTime)
    {
      SetLocation(DesiredLocation);
      bAccelerating = false;
    }
    else
    {
      TempVec = (CalcAccelPos(MoveTime, TotalMoveTime, MoveAcceleration) * MoveChange);
      SetLocation(OriginalMoveLocation + TempVec);
      MoveTime -= DeltaTime;
    }
  }
  
  //Check for moving
  if(bMoving)
  {
    //First, do update for moving target if neccesary.
    if(MoveTarget != NONE)
    {
      TempVec = MoveTarget.Location;
      DoMove(TempVec, MoveTarget, MoveTime);
    }

    //Check to make sure you do not over-move
    if(MoveTime <= DeltaTime)
    {
      //SetLocation(DesiredLocation);
      bMoving = false;
    }
    else
    {
      SetLocation(Location + (MoveChange * DeltaTime));
      MoveTime -= DeltaTime;
    }
  }
  
  //Check for circling
  if(bCircling)
  {  
    //First, check to see if we have lost our target.
    if(CircleTarget == NONE)
      bCircling = false;
    else
    {
      TempRot = rotator(Radius);
      TempRot2 = CirclingSpeed * DeltaTime;
      
      //Check for over-head switch
      if(abs(TempRot.Pitch + TempRot2.Pitch) > (RotPiVal/2))
      {
        TempRot.Yaw += RotPiVal;
        CirclingSpeed.Pitch *= -1;
        //Flip the camera over so it does not look goofy.
        bFlip = !bFlip;
      }
      
      TempRot += CirclingSpeed * DeltaTime;      
      TempVec = vector(TempRot) * VSize(Radius);
      Radius = TempVec;
      SetLocation(CircleTarget.Location + Radius + CirclingOffset);
    }
  }
  
  //Check for tracking
  if(bTracking)
  {
    //First, check to see if we have lost our target.
    if(TrackingTarget == NONE)
      bTracking = false;
    else
    {
      TempVec = (TrackingTarget.Location + TrackingOffset) - Location;
      TempRot = rotator(TempVec);
      //Examine TrackingDirections to determine how to track.
      if(TrackingDirections.Yaw < 0)
        TempRot.Yaw = 0;
      if(TrackingDirections.Pitch < 0)
        TempRot.Pitch = 0;
      if(TrackingDirections.Roll < 0)
        TempRot.Roll = 0;
      //Flip over the camera if needed.
      if(bFlip)
      {
        TempRot.Roll += RotPiVal;
      }
      SetRotation(TempRot);
      
    }
  }
}

function float CalcAccelPos(float Time, float TotalTime, float Acceleration)
{
  local float CurrentPoint;
  local float CurrentPoint2;
  local float TempFloat, TempFloat2;
  
  CurrentPoint = (TotalTime - Time) / TotalTime;
  if(Acceleration < 2)
    return CurrentPoint;
  
  TempFloat = Acceleration - 5;
  TempFloat2 = ((TempFloat + Sqrt(Square(TempFloat) + 4)) / 2) - 0.2;
  
  TempFloat = (Acceleration * CurrentPoint) - 5;
  CurrentPoint2 = (((TempFloat + Sqrt(Square(TempFloat) + 4)) / 2) - 0.2) / TempFloat2;

  return CurrentPoint2;
}

function DoInterpolate(actor InterpPoint, float DesiredRate, float DesiredAlpha)
{
  log(self$": About to start interpolating");
  
  //Check for no target
  if(InterpPoint == NONE)
    bInterpolating = false;
  else
  {
    log(self$": Starting to interpolate");
    SetCollision(True,false,false);
    bCollideWorld = False ;
    Target = InterpPoint;
    SetPhysics(PHYS_Interpolating);
    PhysRate = DesiredRate;
    PhysAlpha = DesiredAlpha;
    bInterpolating = true;
    bMoving = false;
    bAccelerating = false;
    bCircling = false;
  }
}

function DoAccelMove(vector TargetLocation, float Time, float Acceleration)
{
  //Check for instant move.
  if(Time == 0)
  {
    SetLocation(TargetLocation);
    bAccelerating = false;
  }    
  else
  {
    DesiredLocation = TargetLocation;
    OriginalMoveLocation = Location;
    bMoving = false;
    bAccelerating = true;
    bInterpolating = false;
    bCircling = false;
    MoveTime = Time;
    TotalMoveTime = Time;
    MoveAcceleration = Acceleration;
    MoveChange = (DesiredLocation - Location);
  }
}

function DoPlayAnim(name AnimSeq, float Time, float TweenTime)
{
    local float Rate;
    local int i;

    for(i=0;i<6;i++)
    {
        if(AnimSeq == FootStepAnimation[i])
        {
            bFootSteps = true;
            bLoopingSteps = false;
            bPlayedFoot1 = false;
            bPlayedFoot2 = false;
            FootStepAnimNum = i;
            FootStepTime = Time;
            Foot1Time = (Foot1Frame[i] / TotalFrames[i]) * FootStepTime;
            Foot2Time = (Foot2Frame[i] / TotalFrames[i]) * FootStepTime;
            FootStepLoopTime = 0;
            break;
        }
    }

    PlayAnim(AnimSeq, 1, 0);
    Rate = DetermineRate(Time);
    PlayAnim(AnimSeq, Rate, TweenTime);
}

function DoLoopAnim(name AnimSeq, float Time, float TweenTime)
{
    local float Rate;
    local int i;
  
    for(i=0;i<6;i++)
    {
        if(AnimSeq == FootStepAnimation[i])
        {
            bFootSteps = true;
            bLoopingSteps = true;
            bPlayedFoot1 = false;
            bPlayedFoot2 = false;
            FootStepAnimNum = i;
            FootStepTime = Time;
            Foot1Time = (Foot1Frame[i] / TotalFrames[i]) * FootStepTime;
            Foot2Time = (Foot2Frame[i] / TotalFrames[i]) * FootStepTime;
            FootStepLoopTime = 0;
            break;
        }
    }

    LoopAnim(AnimSeq, 1, 0);
    Rate = DetermineRate(Time);
    LoopAnim(AnimSeq, Rate, TweenTime);
}

function float DetermineRate(float Time)
{
  local float FramesLeft, CurSecsLeft, Ratio;
  FramesLeft = 1 - AnimFrame;
  CurSecsLeft = FramesLeft / AnimRate;
  Ratio = CurSecsLeft / Time;
  return Ratio;
} 

function DoSoftStop()
{
  GotoState('FinishAnimating');
}

function DoHardStop()
{
  PlayAnim(AnimSequence, 100000, 0);
}

function DoMove(vector TargetLocation, actor NewTarget, float Time)
{
  //Check for instant move.
  if(Time == 0)
  {
    SetLocation(TargetLocation);
    bMoving = false;
  }    
  else
  {
    DesiredLocation = TargetLocation;
    MoveTarget = NewTarget;
    bMoving = true;
    bAccelerating = false;
    bInterpolating = false;
    bCircling = false;
    MoveTime = Time;
    MoveChange = (DesiredLocation - Location) / MoveTime;
  }
}

function DoRotate(rotator NewRotation, actor NewTarget, float Time)
{
  //Check for instant rotate.
  if(Time == 0)
  {
    SetRotation(NewRotation);
    bRotating = false;
  }    
  else
  {
    bRotating = true;
    bTracking = false;
    RotTime = Time;
    RotTarget = NewTarget;
    TargetRotation = NewRotation;
        while((TargetRotation.yaw - Rotation.yaw) > 32768)
        {
            TargetRotation.yaw -= 65536;
        }
        while((TargetRotation.pitch - Rotation.pitch) > 32768)
        {                  
            TargetRotation.pitch -= 65536;
        }
        while((TargetRotation.roll - Rotation.roll) > 32768)
        {
            TargetRotation.roll -= 65536;
        }
        while((TargetRotation.yaw - Rotation.yaw) < -32768)
        {
            TargetRotation.yaw += 65536;
        }
        while((TargetRotation.pitch - Rotation.pitch) < -32768)
        {                  
            TargetRotation.pitch += 65536;
        }
        while((TargetRotation.roll - Rotation.roll) < -32768)
        {
            TargetRotation.roll += 65536;
        }
    RotChange = (TargetRotation - Rotation) / RotTime;
  }
}

function DoFire(vector TargetLocation, vector Offset)
{
  local vector Start, X, Y, Z;
  
  GetAxes(ViewRotation, X, Y, Z);
  Weapon.FireOffset = Offset;
  Start = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X
  * X + Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
  FiringRotation = rotator(TargetLocation - Start);
  Weapon.Fire(0);
}


function DoAltFire(vector TargetLocation, vector Offset)
{
  local vector Start, X, Y, Z;
  
  GetAxes(ViewRotation, X, Y, Z);
  Weapon.FireOffset = Offset;
  Start = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X
  * X + Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
  FiringRotation = rotator(TargetLocation - Start);
  Weapon.AltFire(0);
}

function DoCircling(actor NewTarget, rotator Speed, vector Offset, float Distance)
{
  //Check for no target.
  if(NewTarget == NONE)
    bCircling = false;
  else
  {
    bCircling = true;
    bMoving = false;
    bInterpolating = false;
    bAccelerating = false;
    CircleTarget = NewTarget;
    Radius = -1 * (CircleTarget.Location - Location);
    if(Distance != 0)
      Radius = (Radius / VSize(Radius)) * Distance;
    CirclingSpeed = Speed;
    CirclingOffset = Offset;
  }
}

function DoTracking(actor NewTarget, vector Offset, rotator Directions)
{
  //Check for no target.
  if(NewTarget == NONE)
    bTracking = false;
  else
  {
    bTracking = true;
    bRotating = false;
    TrackingTarget = NewTarget;
    TrackingOffset = Offset;
    TrackingDirections = Directions;
  }
}

//This is in there to handle the end of an interpolation
function InterpolateEnd(actor InterpPoint)
{
  if(InterpolationPoint(InterpPoint).bEndOfPath)
  {
    SetPhysics(PHYS_None);
    bInterpolating = false;
  }
}

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
  return FiringRotation;
}

//Stuff we want to override from the Pawn superclass so that they
//do nothing.
function TakeFallingDamage()
{        
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
}


/* function DoChangeMesh(mesh NewMesh)
{ 
  Mesh = NewMesh;
} */


//This state is used to stop an animation that is already in progress.
//It is here because FinishAnim has to be called from a state, since
//it is a latent function.
state FinishAnimating
{
  begin:
    FinishAnim();
}

defaultproperties
{
				BaseEyeHeight=23.000000
				Intelligence=BRAINS_NONE
				DrawType=DT_Mesh
				Mesh=LodMesh'UnrealShare.Nali1'
}
