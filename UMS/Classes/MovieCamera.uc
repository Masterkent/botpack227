//=============================================================================
// MovieCamera.
//=============================================================================
class MovieCamera expands UMS;

//The current FOV of the camera.
var() float CurrentFOV;

var float initFOV;
var vector initLoc;
var rotator initRot;

var vector currentLoc;
var rotator currentRot;

//The number of units of rotation that make up half a full rotation,
//or one Pi radians.
const RotPiVal = 32768;

//Panning actually includes tilting and rotating the camera, since 
//all three can be controlled with it -- let me know if you need
//seperate functions for the three kinds of rotation
var bool bPanning;
var bool bSmoothPanning;
//The rotation to pan to
var rotator TargetRotation;
//The number of seconds to spend rotating
var float PanTime;
var float PanTotalTime;
var rotator OriginalPanRotation;
var float PanSmoothness;
//The change in Pan per second
var rotator PanChange;
//The actor the camera is trying to pan to
var actor PanTarget;
//Dollying is moving the camera around, to set locations.
var bool bDollying;
var bool bSmoothDollying;
//The location the camera is trying to dolly to.
var vector DesiredLocation;
var vector OriginalDollyLocation;
//The number of seconds to spend dollying
var float DollyTime;
var float DollyTotalTime;
var float DollySmoothness;
var float DollyAcceleration;
var bool bAccelerating;
//The change in camera location per second
var vector DollyChange;
//The actor the camera is trying to dolly to
var actor DollyTarget;
//Changing the Field Of View to see more or less of the picture.
var bool bZooming;
//The FOV the camera is trying to zoom to.
var float DesiredFOV;
//The number of seconds to spend zooming.
var float ZoomTime;
//The change per second while zooming
var float ZoomChange;
//The camera must stay pointed at the TrackingTarget.
var bool bTracking;
//The offset while tracking
var vector TrackingOffset;
//The actor the camera is tracking
var Actor TrackingTarget;
//The directions that will be tracked.  If the value is greater than
//or equal to zero that kind of rotation will be used to track.  So
//only if you don't want to track in a given direction will you want
//to set one of the values to -1.
var rotator TrackingDirections;
//The camera is right behind some actor, and stays exactly behind it.
var bool bChaseCam;
//The vector offset the camera is from the actor being chased, in the
//form of a rotator and a size
var rotator ChaseVecOffRot;
var float ChaseVecOffSize;
//The rotation offset as the camera chases
var rotator ChaseRotOffset;
//The actor the camera is chasing.
var actor ChaseTarget;
//The camera is circling some point, or some moving actor, but not
//pointing at it (unless combined with tracking).
var bool bCircling;
//The radius between the point and the camera that the camera uses
//to rotate.
var vector Radius;
//The change of rotation per second while circling
var rotator CirclingSpeed;
//The offset while circing
var vector CirclingOffset;
//The actor the camera is circling.
var actor CircleTarget;
//The camera needs to flip due to circling over a tracked target.
var bool bFlip;
var bool bFlipNext;
//Whether the camera is holding an actor in the middle of the screen
var bool bVertigo;
//The value that is set when the HoldZoom is started
var float VertigoConst;
//The target for holding the zoom on
var actor VertigoTarget;
//Whether the Circling radius is changing (it can be growing as well as shrinking)
var bool bCircleShrinking;
//The time for the radius to change
var float CircleShrinkTime;
//The radius after the change
var float CircleShrinkRadius;
//The amount that the circle will change per second
var float CircleShrinkAmount;

var bool bShaking;
var bool bShakeRollDir;
var bool bShakePitchDir;
var bool bShakeYawDir;
var float shakeTime;
var float shakePosMag;
var float shakeRollMag;

var vector shakePosOffset;
var rotator shakeRollOffset;


//Everything happens in Tick.  UnrealScript calls Tick several times
//a second, with DeltaTime being the time since the last tick (which
//changes all the time).  So we always check to see what needs to be
//updated in tick.
//
//Right now there are several combinations of commands that don't 
//work.  Let me know if you need any of these changed, since it is
//possible to change some of these with a little extra code.
//
//Invalid Combinations:
//	+ Circling with dollying, chase cam, or interpolation.
//	+ ChaseCam with anything other than zooming.
//	+ Tracking with chase cam or panning.
//  + Panning with tracking or chase cam.
//  + Dollying with chase cam, circling, or interpolation.
//  + Interpolation with chase cam, circling, or dollying.

function PostBeginPlay()
{
	initFOV = CurrentFOV;
	initRot = Rotation;
	initLoc = Location;
	currentRot = Rotation;
	currentLoc = Location;
}

function ResetCamera()
{
	CurrentFOV = initFOV;
	currentRot = initRot;
	currentLoc = initLoc;
	
	SetRotation(currentRot);
	SetLocation(currentLoc);
	
	bInterpolating = false;
	bSmoothPanning = false;
	bSmoothDollying = false;
	bAccelerating = false;
	bPanning = false;
	bDollying = false;
	bZooming = false;
	bVertigo = false;
	bCircleShrinking = false;
	bCircling = false;
	bTracking = false;
	bChaseCam = false;
}

event Tick(float DeltaTime)
{
	local vector TempVec;
	local rotator TempRot, TempRot2;
	local float TempFloat, TempFloat2;
	
	
	//Check for interpolation
	if(bInterpolating)
	{
		//Do nothing, regular physics will handle this
	}
	else
		SetPhysics(PHYS_None);
	
	if(bSmoothPanning)
	{
		//We need a check to see if it is done.
		if(PanTime <= DeltaTime)
		{
			currentRot = TargetRotation;
			bSmoothPanning = false;
		}
		else
		{
			//SetRotation(Rotation + (PanChange * DeltaTime));
			TempRot = (CalcSmoothPos(PanTime, PanTotalTime, PanSmoothness) * PanChange);
			currentRot = TempRot + OriginalPanRotation;
			PanTime -= DeltaTime;
		}
	}
	
	if(bSmoothDollying)
	{
		//Check to make sure you do not over-dolly
		if(DollyTime <= DeltaTime)
		{
			currentLoc = DesiredLocation;
			bSmoothDollying = false;
		}
		else
		{
			TempVec = (CalcSmoothPos(DollyTime, DollyTotalTime, DollySmoothness) * DollyChange);
			currentLoc = OriginalDollyLocation + TempVec;
			DollyTime -= DeltaTime;
		}
	}

	if(bAccelerating)
	{
		if(DollyTime <= DeltaTime)
		{
			currentLoc = DesiredLocation;
			bAccelerating = false;
		}
		else
		{
			TempVec = (CalcAccelPos(DollyTime, DollyTotalTime, DollyAcceleration) * DollyChange);
			currentLoc = OriginalDollyLocation + TempVec;
			DollyTime -= DeltaTime;
		}
	}
	
	//Check for panning
	if(bPanning)
	{
		//First, do update for moving target/camera if neccesary.
		if(PanTarget != NONE)
		{
			TempRot = rotator(PanTarget.Location - currentLoc);
			DoPan(TempRot, PanTarget, PanTime);
		}
		
		//We need a check to see if it is done.
		if(PanTime <= DeltaTime)
		{
			currentRot = TargetRotation;
			bPanning = false;
		}
		else
		{
			currentRot = currentRot + (PanChange * DeltaTime);
			PanTime -= DeltaTime;
		}
	}
	
	//Check for dollying
	if(bDollying)
	{
		//First, do update for moving target if neccesary.
		if(DollyTarget != NONE)
		{
			TempVec = DollyTarget.Location;
			DoDolly(TempVec, DollyTarget, DollyTime);
		}

		//Check to make sure you do not over-dolly
		if(DollyTime <= DeltaTime)
		{
			currentLoc = DesiredLocation;
			bDollying = false;
		}
		else
		{
			currentLoc = currentLoc + (DollyChange * DeltaTime);
			DollyTime -= DeltaTime;
		}
	}
	
	//Check for zooming
	if(bZooming)
	{
		//Check to see if finished zooming.
		if(ZoomTime <= DeltaTime)
		{
			CurrentFOV = DesiredFOV;
			bZooming = false;
		}
		else
		{
			CurrentFOV += ZoomChange * DeltaTime;
			ZoomTime -= DeltaTime;
		}
	}
	
	if(bVertigo)
	{
		if(VertigoTarget == NONE)
			bVertigo = false;
		else
		{
			TempFloat = vsize(currentLoc - VertigoTarget.Location);
			TempFloat2 = 2 * atan(VertigoConst / TempFloat);
			CurrentFOV = TempFloat2 * (180 / pi);
		}
	}

	if(bCircleShrinking)
	{
		if(!bCircling)
			bCircleShrinking = false;
		else
		{
			TempFloat = CircleShrinkRadius/CircleShrinkTime;
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
			currentLoc = CircleTarget.Location + Radius + CirclingOffset;
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
			TempVec = (TrackingTarget.Location + TrackingOffset) - currentLoc;
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
			currentRot = TempRot;
			
		}
	}

	//Check for chase cam
	if(bChaseCam)
	{
		//Check to see if target has been lost.
		if(ChaseTarget == NONE)
			bChaseCam = false;
		else
		{
			currentRot = ChaseTarget.Rotation + ChaseRotOffset;
			TempRot = currentRot + ChaseVecOffRot;
			TempVec = vector(TempRot);
			TempVec *= ChaseVecOffSize;
			currentLoc = ChaseTarget.Location + TempVec;
		}
	}
	
	if(bShaking)
	{
		if(shakeTime < DeltaTime)
		{
			bShaking = false;
			
			shakePosOffset.x = 0;
			shakePosOffset.y = 0;
			shakePosOffset.z = 0;
			
			shakeRollOffset.Pitch = 0;
			shakeRollOffset.Yaw = 0;
			shakeRollOffset.Roll = 0;
		}
		else
		{
			if(bShakeRollDir)
			{
				shakeRollOffset.Roll += Int(10 * shakeRollMag * FMin(0.1, DeltaTime));
				bShakeRollDir = (shakeRollOffset.Roll > 32768) || (shakeRollOffset.Roll < (0.5 + FRand()) * shakeRollMag);
				if((shakeRollOffset.Roll < 32768) && (shakeRollOffset.Roll > 1.3 * shakeRollMag))
				{
					shakeRollOffset.Roll = 1.3 * shakeRollMag;
					bShakeRollDir = false;
				}
				else if(FRand() < 3 * DeltaTime)
					bShakeRollDir = !bShakeRollDir;
			}
			else
			{
				shakeRollOffset.Roll -= Int(10 * shakeRollMag * FMin(0.1, DeltaTime));
				bShakeRollDir = (shakeRollOffset.Roll > 32768) && (shakeRollOffset.Roll < 65535 - (0.5 + FRand()) * shakeRollMag);
				if ( (shakeRollOffset.Roll > 32768) && (shakeRollOffset.Roll < 65535 - 1.3 * shakeRollMag) )
				{
					shakeRollOffset.Roll = 65535 - 1.3 * shakeRollMag;
					bShakeRollDir = true;
				}
				else if (FRand() < 3 * DeltaTime)
					bShakeRollDir = !bShakeRollDir;
			}
			
			if(bShakeYawDir)
			{
				shakeRollOffset.Yaw += Int(10 * shakeRollMag * FMin(0.1, DeltaTime));
				bShakeYawDir = (shakeRollOffset.Yaw > 32768) || (shakeRollOffset.Yaw < (0.5 + FRand()) * shakeRollMag);
				if((shakeRollOffset.Yaw < 32768) && (shakeRollOffset.Yaw > 1.3 * shakeRollMag))
				{
					shakeRollOffset.Yaw = 1.3 * shakeRollMag;
					bShakeYawDir = false;
				}
				else if(FRand() < 3 * DeltaTime)
					bShakeYawDir = !bShakeYawDir;
			}
			else
			{
				shakeRollOffset.Yaw -= Int(10 * shakeRollMag * FMin(0.1, DeltaTime));
				bShakeYawDir = (shakeRollOffset.Yaw > 32768) && (shakeRollOffset.Yaw < 65535 - (0.5 + FRand()) * shakeRollMag);
				if ( (shakeRollOffset.Yaw > 32768) && (shakeRollOffset.Yaw < 65535 - 1.3 * shakeRollMag) )
				{
					shakeRollOffset.Yaw = 65535 - 1.3 * shakeRollMag;
					bShakeYawDir = true;
				}
				else if (FRand() < 3 * DeltaTime)
					bShakeYawDir = !bShakeYawDir;
			}

			if(bShakePitchDir)
			{
				shakeRollOffset.Pitch += Int(10 * shakeRollMag * FMin(0.1, DeltaTime));
				bShakePitchDir = (shakeRollOffset.Pitch > 32768) || (shakeRollOffset.Pitch < (0.5 + FRand()) * shakeRollMag);
				if((shakeRollOffset.Pitch < 32768) && (shakeRollOffset.Pitch > 1.3 * shakeRollMag))
				{
					shakeRollOffset.Pitch = 1.3 * shakeRollMag;
					bShakePitchDir = false;
				}
				else if(FRand() < 3 * DeltaTime)
					bShakePitchDir = !bShakePitchDir;
			}
			else
			{
				shakeRollOffset.Pitch -= Int(10 * shakeRollMag * FMin(0.1, DeltaTime));
				bShakePitchDir = (shakeRollOffset.Pitch > 32768) && (shakeRollOffset.Pitch < 65535 - (0.5 + FRand()) * shakeRollMag);
				if ( (shakeRollOffset.Pitch > 32768) && (shakeRollOffset.Pitch < 65535 - 1.3 * shakeRollMag) )
				{
					shakeRollOffset.Pitch = 65535 - 1.3 * shakeRollMag;
					bShakePitchDir = true;
				}
				else if (FRand() < 3 * DeltaTime)
					bShakePitchDir = !bShakePitchDir;
			}

			shakeTime -= DeltaTime;
		}
	}


	SetLocation(currentLoc + shakePosOffset);
	SetRotation(currentRot + shakeRollOffset);
}

function DoShake(float time, float rollMag, float posMag)
{
	bShaking = true;
	
	shakeTime = time;
	
	shakeRollMag = rollMag;

	shakePosMag = posMag;
}

function float CalcSmoothPos(float Time, float TotalTime, float Smoothness)
{
	local float CurrentPoint;
	local float CurrentPoint2;
	
	CurrentPoint = (TotalTime - Time) / TotalTime;
	if(Smoothness == 0)
		return CurrentPoint;
	
	log(self$": CurrentPoint ="@CurrentPoint);
	CurrentPoint2 = (atan (Smoothness * ((2 * CurrentPoint) - 1))) / (2 * (atan (Smoothness))) + 0.5;
	log(self$": CurrentPoint2 ="@CurrentPoint2);
	return CurrentPoint2;
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

//The Do Functions
//Each command that is given to a camera takes the form of calling a
//Do funtion, which sets up the camera to do the command properly.

function DoSmoothPan(rotator NewRotation, actor NewTarget, float Time, float Smoothness)
{
    //Check for instant pan.
	if(Time == 0)
	{
		currentRot = NewRotation;
		bSmoothPanning = false;
	}		
	else
	{
		bSmoothPanning = true;
		bPanning=false;
		bChaseCam = false;
		bTracking = false;
		PanTime = Time;
		PanTotalTime = Time;
		PanTarget = NewTarget;
		PanSmoothness = Smoothness;
		OriginalPanRotation = Rotation;
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
        PanChange = (TargetRotation - Rotation);
	}
}

function DoAccelDolly(vector TargetLocation, float Time, float Acceleration)
{
	//Check for instant move.
	if(Time == 0)
	{
		currentLoc = TargetLocation;
		bAccelerating = false;
	}		
	else
	{
		DesiredLocation = TargetLocation;
		OriginalDollyLocation = Location;
		bAccelerating = true;
		bSmoothDollying = false;
		bDollying=false;
		bCircling = false;
		bChaseCam = false;
		bInterpolating = false;
		DollyTime = Time;
		DollyTotalTime = Time;
		DollyAcceleration = Acceleration;
		DollyChange = (DesiredLocation - Location);
	}
}

function DoSmoothDolly(vector NewLocation, actor NewTarget, float Time, float Smoothness)
{		
	//Check for instant dolly.
	if(Time == 0)
	{
		currentLoc = NewLocation;
		bSmoothDollying = false;
	}		
	else
	{
		DesiredLocation = NewLocation;
		DollyTarget = NewTarget;
		OriginalDollyLocation = Location;
		bSmoothDollying = true;
		bDollying=false;
		bAccelerating = false;
		bCircling = false;
		bChaseCam = false;
		bInterpolating = false;
		DollyTime = Time;
		DollyTotalTime = Time;
		DollySmoothness = Smoothness;
		DollyChange = (DesiredLocation - Location);
	}
}

function DoPan(rotator NewRotation, actor NewTarget, float Time)
{
    //Check for instant pan.
	if(Time == 0)
	{
		currentRot = NewRotation;
		bPanning = false;
	}		
	else
	{
		bPanning = true;
		bSmoothPanning = false;
		bChaseCam = false;
		bTracking = false;
		PanTime = Time;
		PanTarget = NewTarget;
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
        PanChange = (TargetRotation - Rotation) / PanTime;
	}
}

function DoDolly(vector NewLocation, actor NewTarget, float Time)
{		
	//Check for instant dolly.
	if(Time == 0)
	{
		currentLoc = NewLocation;
		bDollying = false;
	}		
	else
	{
		DesiredLocation = NewLocation;
		DollyTarget = NewTarget;
		bDollying = true;
		bSmoothDollying = false;
		bAccelerating = false;
		bCircling = false;
		bChaseCam = false;
		bInterpolating = false;
		DollyTime = Time;
		DollyChange = (DesiredLocation - Location) / DollyTime;
	}
}

function DoZoom(float NewFOV, float Time)
{
	//Check for instant zoom.
	if(Time == 0)
	{
		CurrentFOV = NewFOV;
		bZooming = false;
	}		
	else
	{
		bZooming = true;
		bVertigo = false;
		DesiredFOV = NewFOV;
		ZoomTime = Time;
		ZoomChange = (DesiredFOV - CurrentFOV) / ZoomTime;
	}
}

function DoVertigo(actor NewTarget)
{
	local float DistFromActor, CurrentFOVRad;
	
	if(NewTarget == NONE)
		bVertigo = false;
	else
	{
		bVertigo = true;
		bZooming = false;
		VertigoTarget = NewTarget;
		CurrentFOVRad = CurrentFOV * (pi / 180);
		DistFromActor = vsize(Location - NewTarget.Location);
		VertigoConst = DistFromActor * tan(CurrentFOVRad/2);
	}
}

function DoCircling(actor NewTarget, rotator Speed, vector Offset, float Distance)
{
	//Check for no target.
	if(NewTarget == NONE)
		bCircling = false;
	else
	{
		bCircling = true;
		bDollying = false;
		bSmoothDollying = false;
		bAccelerating = false;
		bChaseCam = false;
		bInterpolating = false;
		CircleTarget = NewTarget;
		Radius = -1 * (CircleTarget.Location - Location);
		if(Distance != 0)
			Radius = (Radius / VSize(Radius)) * Distance;
		CirclingSpeed = Speed;
		CirclingOffset = Offset;
	}
}

function DoCircleShrink(vector NewRadius, float TimeToChange)
{
	if(!bCircling)
		bCircleShrinking = false;
	else
	{
		bCircleShrinking = true;
		CircleShrinkTime = TimeToChange;
		CircleShrinkRadius = vsize(NewRadius);
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
		bPanning = false;
		bSmoothPanning = false;
		bChaseCam = false;
		TrackingTarget = NewTarget;
		TrackingOffset = Offset;
		TrackingDirections = Directions;
	}
}

function DoChaseCam(actor NewTarget, vector Offset, rotator RotOffset)
{
	//Check for no target.
	if(NewTarget == NONE)
		bChaseCam = false;
	else
	{
		bChaseCam = true;
		bPanning = false;
		bSmoothPanning = false;
		bAccelerating = false;
		bDollying = false;
		bSmoothDollying = false;
		bCircling = false;
		bTracking = false;
		bInterpolating = false;
		ChaseTarget = NewTarget;
		ChaseVecOffRot = rotator(Offset);
		ChaseVecOffSize = VSize(Offset);
		ChaseRotOffset = RotOffset;
	}
}

function DoInterpolate(actor InterpPoint, float DesiredRate, float DesiredAlpha)
{
	//Check for no target
	if(InterpPoint == NONE)
		bInterpolating = false;
	else
	{
		SetCollision(True,false,false);
		bCollideWorld = False ;
		Target = InterpPoint;
		SetPhysics(PHYS_Interpolating);
		PhysRate = DesiredRate;
		PhysAlpha = DesiredAlpha;
		bInterpolating = true;
		bChaseCam = false;
		bAccelerating = false;
		bDollying = false;
		bSmoothDollying = false;
		bCircling = false;
	}
}

function InterpolateEnd(actor InterpPoint)
{
	if(InterpolationPoint(InterpPoint).bEndOfPath)
		SetPhysics(PHYS_None) ;
}

defaultproperties
{
				CurrentFOV=90.000000
				bCanTeleport=True
				bStasis=True
				DrawType=DT_Mesh
				Mesh=LodMesh'UnrealI.BigFlash'
				CollisionRadius=0.000000
				CollisionHeight=0.000000
				Mass=0.000000
}
