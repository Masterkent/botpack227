//=============================================================================
// MovieHead.
// by Hugh Macdonald
//=============================================================================
class MovieHead expands Weapon;

//The number of units of rotation that make up half a full rotation,
//or one Pi radians.
const RotPiVal = 32768;

//Panning actually includes tilting and rotating the camera, since 
//all three can be controlled with it -- let me know if you need
//seperate functions for the three kinds of rotation
var bool bRotating;
//The rotation to pan to
var rotator TargetRotation;
//The number of seconds to spend rotating
var float RotateTime;
//The change in Pan per second
var rotator RotateChange;
//The actor the camera is trying to pan to
var actor RotateTarget;
//The camera must stay pointed at the TrackingTarget.
var bool bTracking;
//The actor the camera is tracking
var Actor TrackingTarget;
//The directions that will be tracked.  If the value is greater than
//or equal to zero that kind of rotation will be used to track.  So
//only if you don't want to track in a given direction will you want
//to set one of the values to -1.
var rotator TrackingDirections;


event Tick(float DeltaTime)
{
	local vector TempVec, X, Y, Z;
	local rotator TempRot, TempRot2;
	
	
    //Check for rotating
 	if(bRotating)
	{
        //First, do update for moving target/camera if neccesary.
		if(RotateTarget != NONE)
		{
            TempRot = rotator(RotateTarget.Location - Location);
            DoRotate(TempRot, RotateTarget, RotateTime);
		}
		
		//We need a check to see if it is done.
        if(RotateTime <= DeltaTime)
		{
			SetRotation(TargetRotation);
            bRotating = false;
		}
		else
		{
            SetRotation(Rotation + (RotateChange * DeltaTime));
            RotateTime -= DeltaTime;
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
			TempVec = (TrackingTarget.Location) - Location;
			TempRot = rotator(TempVec);
			//Examine TrackingDirections to determine how to track.
			if(TrackingDirections.Yaw < 0)
				TempRot.Yaw = 0;
			if(TrackingDirections.Pitch < 0)
				TempRot.Pitch = 0;
			if(TrackingDirections.Roll < 0)
				TempRot.Roll = 0;
			//Flip over the camera if needed.

		}
	}

}


function DoRotate(rotator NewRotation, actor NewTarget, float Time)
{
	//Check for instant pan.
	if(Time == 0)
	{
		SetRotation(NewRotation);
        bRotating = false;
	}		
	else
	{
        bRotating = true;
        bTracking = false;
        RotateTime = Time;
        RotateTarget = NewTarget;
		TargetRotation = NewRotation;
        RotateChange = (TargetRotation - Rotation) / RotateTime;
	}
}

function DoTrack(actor NewTarget, rotator Directions)
{
	//Check for no target.
	if(NewTarget == NONE)
		bTracking = false;
	else
	{
		bTracking = true;
        bRotating = false;
		TrackingTarget = NewTarget;
		TrackingDirections = Directions;
	}
}

function DoAnimate(name AnimSeq, float Time)
{
    local float Rate;

    PlayAnim(AnimSeq, 1, 0);
    Rate = DetermineRate(Time);
    PlayAnim(AnimSeq, Rate, 0);
}


function float DetermineRate(float Time)
{
	local float FramesLeft, CurSecsLeft, Ratio;
	FramesLeft = 1 - AnimFrame;
	CurSecsLeft = FramesLeft / AnimRate;
	Ratio = CurSecsLeft / Time;
	return Ratio;
}

defaultproperties
{
}
