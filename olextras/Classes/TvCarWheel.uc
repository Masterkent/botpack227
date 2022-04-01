// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvCarWheel : This represents a "wheel" of the main car.
// It handles much physics, but parent car "limits"
// Note about collision: does not collide by itself!
// GravAccel: used as collision tangent
// ===============================================================

class TvCarWheel expands TVVehicle;

#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

var TVDrivableCar Body; //is also owner.
var byte Position; //position stored in vehicle array.
var vector My2DOffset; //used for torque calculation. This wheels local offset with z=0.
var vector RelativeAcceleration; //used for some stuff.
var vector RotFriction; //frictional rot.
var vector LinFriction; //frictional lin
var vector ContactA; //contact accel
var Quaternion NoTurnQ; //rotation without wheel turn factored in

function PostBeginPlay(){
  Body=TvDrivableCar(owner);
}

function GetAcceleration(){ //append accel to main car body.
   local vector Thrust;
   if (Base==none)
     return;
   ContactA = (-RelativeAcceleration dot NormalAccel) * NormalAccel /Body.TiresOnGround;
   LinFriction = vsize(ContactA) * GetMeiu() * GravAccel;
   Body.Acceleration += ContactA;
   ContactA = QVRotate(~Body.QRotation,ContactA)*mass;
   RotFriction = QVRotate(~Body.QRotation,LinFriction)*mass;
   Body.Torque += My2DOffset cross ContactA;
   RotFriction = My2DOffset cross RotFriction;
   Thrust=QGetAxis(NoTurnQ)*fmin(Body.EngineForce,vsize(LinFriction)); //this is feckign wrong
   Body.WheelThrust +=Thrust;
   Body.WheelTorque += (mass * thrust) cross My2DOffset;
   //rolling resistance:  parrellel to this thingy.
   if (body.velocity dot body.velocity > 0)
    Body.Acceleration+=QVRotate(QRotation,Body.RollingResistance*vsize(ContactA)*vect(-1,0,0));
}
//Check if contact with ground
function CheckGroundForces(){
   local vector hitlocation;
   local vector vel1;
   if (abs(Body.carvelocity.z)<=30)
     SetBase(GroundTrace(hitlocation,NormalAccel)); //get normal.
   else
     SetBase(none);
   if (Base==none)
     return;
   RelativeAcceleration = Body.Acceleration + (Body.RotationalVelocity cross (Body.RotationalVelocity cross My2DOffset))
    + (Body.RotAcceleration cross My2DOffset);
   if (RelativeAcceleration dot NormalAccel > 0.01){
     SetBase(none);
     return;
   }
   //calculate normal and frictional forces
   vel1 = Body.CarVelocity + (Body.RotationalVelocity cross My2DOffset);
   vel1 = QVRotate(Body.Qrotation,vel1);

   GravAccel = -Normal(vel1 - fmax(vel1 dot NormalAccel,0.01) * NormalAccel); //collision tangent.
   Body.TiresOnGround++;
}
//newvec must be normalized!
function vector GetLinearFriction (vector NewVeloc){
   if (Body.bBreaking)
      return LinFriction;
   else
      return LinFriction*sqrt(1-Square(NewVeloc dot QGetAxis(NoTurnQ))); //sin of angle between velocity and tires.
}

function vector GetRotationalFriction (vector CarRot){
   if (Body.bBreaking)
      return RotFriction;
   else
      return RotFriction*(CarRot dot QGetAxis(NoTurnQ)); //sin of angle between perpendicular to car and tires. (cos of car and tire)
}

function TurnWheelBy (vector deltaVec){
  if (Position>1)
     DeltaVec.Z=0;
  QRotation+=(QRotation*deltaVec)*0.5;
  DeltaVec.Y=0;
  NoTurnQ+=(NoTurnQ*deltaVec)*0.5;
  NoTurnQ=QNormal(NoTurnQ);
  QRotation=QNormal(QRotation);
  SetRotation(QuatToRot(QRotation));
}

defaultproperties
{
     RefreshTime=0.000000
     HullIntegrity=0
     Mesh=LodMesh'BotPack.RazorBlade'
     CollisionRadius=5.000000
     CollisionHeight=30.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
}
