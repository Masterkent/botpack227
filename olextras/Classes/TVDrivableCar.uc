// ============================================================
// TVDrivableCar : This is a version of a car that uses "wheel components".
// Wheels control movement. car links them.
// MaxForce=torque or soemthing.            4-wheel DRIVE!
// Note that Car Velocity in this case is the body velocity!  Velocity is global!
// ============================================================

class TVDrivableCar expands TVVehicle;

#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

//#exec TEXTURE IMPORT NAME=TVCarSkin FILE=Car\car_fertig.PCX GROUP=Skins

//#exec MESHMAP SETTEXTURE MESHMAP=TVCar NUM=0 TEXTURE=TVCarSkin

//configurable:
var () vector WheelOffSet;
var () int MaxWheelYaw; //in unreal units
var () float WheelRate; //rate at which wheels are turned (uurot/sec)
var () float WheelTurn; //amount wheels turned by (in uurot yaws). (controlled outside of friction)
var () float RollingResistance; //coeficient of tire rolling resistance.
var () bool bHasGun; //does car have a gun mounted? (probably should be false for bot cars)
var () float WheelRadius; //radius of wheel

var vector WheelThrust; //thrust from wheels (last tick)  used for relative accel stuff
var vector WheelTorque; //Torque from wheels (last tick)
var float MoInertia;//Moment of initertia
var rotator OldRotation; //my old rotation.
var TvCarWheel Wheels[4]; //frontleft, frontright, backright, backleft.
var float EngineForce;  //max accel engine is exerting. each wheel gets force/4. note force is limited to static friction!
var bool bBreaking; //if breaks are on (uses frictional decrease in accel)
var vector Torque;  //current torque
var byte TiresOnGround; //amount of tires on ground.....
var Quaternion OldQ;    //old q rotation
var float LastWheelTurn;   //old wheel turn

function PostBeginPlay(){ //generate wheels:
  local byte i;
  MoInertia=0.5*Square(collisionradius)*mass;
  QRotation=RotToQuat(rotation); //initialize quaternion rot representation
  QRotation=QNormal(QRotation);
  OldQ=QRotation;
  LastWheelTurn=WheelTurn;
  for (i=0;i<4;i++){
    Wheels[i]=Spawn(class'TvCarWheel',self);
    Wheels[i].Position=i;
    Wheels[i].QRotation=QRotation;
  }
  UpdateWheels(0);
}
function Destroyed(){
  local byte i;
  for (i=0;i<4;i++)
    Wheels[i].Destroy();
}

function UpdateWheels(float deltatime){ //after car has moved (physics already calculated):
  local vector offset;
  local vector DeltaRotVec;
  local rotator myrot;
  local Quaternion DeltaQ;
  local byte i;
  offset=wheeloffset;
  myrot=rotation;
  QRotation=QNormal(QRotation);
  SetRotation(QuatToRot(QRotation));
  if (Controller!=none)
    Controller.ViewRotation+=(rotation-myrot);
  DeltaQ=QRotation-OldQ;
  OldQ=QRotation;
  DeltaRotVec.Z=(WheelTurn-LastWheelTurn)/uurot;
  LastWheelTurn=WheelTurn;
  DeltaRotVec.y=vsize(Velocity)*deltatime/Wheelradius; //wheel speed.
  DeltaRotVec.y*=CarVelocity dot QGetAxis(Qrotation); //scale wheel turning
  for (i=0;i<4;i++){
    Wheels[i].Qrotation+=DeltaQ;
    Wheels[i].NoTurnQ+=DeltaQ;
    Wheels[i].Setlocation(location+QvRotate(~Qrotation,offset));
    Wheels[i].My2DOffset=Offset;
    Wheels[i].TurnWheelBy(DeltaRotVec);
    // Wheels[i].My2DOffset.z=0;
      Switch (i){
      Case 0:
      Case 2:
        Offset.y*=-1;
        break;
      Case 1:
        Offset.x*=-1;
        break;
    }
  }
}

function VehicleTick(float deltatime){
   if (controller.bPressedJump&&Eject()){
      EngineForce=0;
      return;
   }
   //handle key inputs:
   Controller.aLookup  *= 0.24;
   Controller.aTurn    *= 0.24;
   Controller.aForward = Sign(Controller.aForward)*EngineRate*deltatime;
   Controller.aStrafe = Sign(Controller.aStrafe)*WheelRate*deltatime;
   Controller.UpdateRotation(deltatime,2);  //view rot stuff.
   If (Controller.aForward>0){
      if (Sign(CarVelocity.X)>=0&&!bBreaking)
        EngineForce=fmin(EngineForce+Controller.AForward,MaxForce);
      else{
        Approach(EngineForce,2*EngineRate*deltatime,0);
        bBreaking=true;
      }
   }
   else if (Controller.aForward<0){
      if (Sign(CarVelocity.X)<=0&&!bBreaking)
        EngineForce=fmax(EngineForce+Controller.AForward,-MaxForce);
      else{
        Approach(EngineForce,2*EngineRate*deltatime,0);
        bBreaking=true;
      }
   }
   else{
      Approach(EngineForce,EngineRate*deltatime,0);
      bBreaking=false;
   }
   if (Controller.aStrafe>0)
      Approach(WheelTurn,WheelRate*deltatime,MaxWheelYaw);
   else if (Controller.aStrafe<0)
      Approach(WheelTurn,-WheelRate*deltatime,-MaxWheelYaw);
   else
      Approach(WheelTurn,WheelRate*deltatime,0);
   if (Controller.bfire>0)
      CamDist=min(camdist-200*deltatime,collisionradius);
   if (Controller.baltfire>0)
     CamDist+=200*deltatime;
//   UpdateWheels(0); //new turn amount.
   Super.VehicleTick(deltatime);
}

function VehicleMove(float deltatime){
   SetAcceleration();  //set forces.
   HandleRotation(deltatime);  //rotate
   DoMovement(deltatime);   //move car.
   UpdateWheels(deltatime); //final update.
}

//Get accel from wheels.
function SetAcceleration(){ //determine the acceleration of vehicle
//   local vector hitlocation, hitnormal;
   local byte i;
//   local vector TempAccel;
//   local float accel;
   Acceleration=(Velocity dot Velocity)*ArCoef*normal(-velocity)/mass;
   Acceleration += WheelThrust; //old
   Torque=normal(-RotationalVelocity)*(RotationalVelocity dot RotationalVelocity)*Square(collisionradius)*ARRotCoef;
   Torque+=WheelTorque;
   rotAcceleration=Torque/MoInertia;
   Acceleration+=0.5*Region.Zone.ZoneGravity;
   TiresOnGround=0;
   for (i=0;i<4;i++)
     Wheels[i].CheckGroundForces();
   Acceleration -= WheelThrust; //set back
   Torque-=WheelTorque;
   WheelTorque=vect(0,0,0);
   WheelThrust=vect(0,0,0);
   for (i=0;i<4;i++)
     Wheels[i].GetAcceleration();
   Torque +=WheelTorque;
   Acceleration +=WheelThrust;
/*
   if (base!=none) { //stay on ground
      floor.yaw=rotation.yaw;
      hitlocation=normal(Carvelocity<<floor);
      hitlocation.z=0; //remove any vertical velocity with respect to rotation
      CarVelocity=vsize(Carvelocity)*(hitlocation>>floor);
   } */
}

//rotate car: Acceleration frame-rate issues!
function HandleRotation(float deltatime){
  local byte i;
  local vector myrot;
  myrot=QGetAxis(Qrotation);
   rotAcceleration=Torque/MoInertia;
  RotationalVelocity+=(rotAcceleration)/MoInertia; //acceleration
/*  //friction:
  GroundFriction=0;
  for (i=0;i<4;i++)
    GroundFriction+=Wheels[i].GetRotationalFriction(myrot);   //moment is 1/2 ml squared
  RotationalVelocity-=normal(RotationalVelocity)*fmin(2*GroundFriction*collisionradius*deltatime,vsize(RotationalVelocity));
  */
  for (i=0;i<4;i++)
    RotationalVelocity+=Wheels[i].GetRotationalFriction(myrot);
  QRotation+=(QRotation*RotationalVelocity)*0.5*deltatime; //set qrotation by rot. velocity.
  QRotation=QNormal(QRotation);
}

//actual movement routine.  WARNING: HAS FRAME-RATE GLITCH!  (higher FPS=faster accel)
function DoMovement(float deltatime){
  local vector HitLoc, HitNorm;
  local byte i;
  local vector myrot;
  myrot=vector(rotation);

  Velocity+=Acceleration*deltatime; //add engines+gravity.
  //friction:
/*  GroundFriction=0;
  for (i=0;i<4;i++)
    GroundFriction+=Wheels[i].GetLinearFriction(myrot);   //moment is 1/2 ml squared
  CarVelocity-=fmin(vsize(CarVelocity),GroundFriction*deltatime)*normal(carvelocity); //friction reduces velocity
  */
  for (i=0;i<4;i++)
    Velocity+=Wheels[i].GetLinearFriction(myrot);
  if (CollisionCheck(hitloc,hitnorm,velocity*deltatime)!=none)
      Velocity=(HitLoc-(Location+collisionradius*normal(velocity)))/deltatime; //reset
  else
      HitLoc=vect(0,0,0);

  if (!SetLocation(location+velocity*deltatime)&&Controller!=none)
    controller.ClientMessage("WARNING: collision detection failure! SetLocation() failed! Vector ["$location+velocity*deltatime$"] is outside of world!");
  if (HitLoc!=vect(0,0,0))
    HitWall(hitnorm,level);
  CarVelocity = QvRotate(~Qrotation,velocity);
}
/*
//If HITS any wall. Does refrection (world cannot be altered).  if velocity is low enough can set base...
function ProcessCollision(actor Collided,vector CrashAngle){
  local vector oldvelocity;
  oldvelocity=CarVelocity;
  CarVelocity -= 2 * ( CarVelocity dot CrashAngle) * CrashAngle; //vector reflection
  CarVelocity*=EnergyLoss;
  If ((vsize(CarVelocity-oldvelocity)<-0.5*Region.Zone.ZoneGravity.Z&&carvelocity.z>=0)||abs(carvelocity.z)<-0.09*Region.Zone.ZoneGravity.Z){ //not really realistic
//    carvelocity.z=0; //again, physics problems here.
    SetAcceleration();
    HandleRotation(0);
  }
  Timer(); //update stuff NOW.
}
*/
function ProcessCollision(actor B2,vector CrashAngle){
  local Vector pt1, pt2, CollisionTangent;
  local float  j;
  local float  fCr;
  local float Vrt;
  local float  mu;
  fcr=COEFFICIENTOFRESTITUTION;
  mu = GetMeiu();
  CollisionTangent=-((velocity-b2.velocity) - (((velocity-b2.velocity) dot CrashAngle) * CrashAngle));
    if(b2.bispawn&&b2.mass>0) // not ground plane
    {
      pt1 = location - CrashAngle*collisionradius;
      pt2 = CrashAngle*b2.collisionradius - b2.location;

      // calculate impulse
      j = (-(1+fCr) * ((velocity-b2.velocity) dot CrashAngle)) /
        ( (1/Mass + 1/b2.Mass) +
        (CrashAngle dot ( ( (pt1 cross CrashAngle)/moinertia ) cross pt1) ));

      Vrt = (velocity-b2.velocity) dot CollisionTangent;

      if(abs(Vrt) > 0.0) {
        Velocity += ( (j * CrashAngle) + ((mu * j) * CollisionTangent) ) / Mass;
        RotationalVelocity += (pt1 cross ((j * CrashAngle) + ((mu * j) * CollisionTangent)))/MoInertia;
        Pawn(b2).AddVelocity(-((j * CrashAngle) + ((mu * j) * CollisionTangent)) /B2.Mass);

      } else {
        // apply impulse
        Velocity += (j * Crashangle) / Mass;
        RotationalVelocity += (pt1 cross (j * Crashangle))/MoInertia;

        Pawn(B2).AddVelocity(-(j * Crashangle) / B2.Mass);
      }
    } else { // ground plane
      if (b2==level)
        fCr = COEFFICIENTOFRESTITUTIONGROUND;
      else
        fcr=COEFFICIENTOFRESTITUTION;
      pt1 = location - CrashAngle*collisionradius;

      // calculate impulse
      j = (-(1+fCr) * (CarVelocity dot CrashAngle)) /
        ( (1/Mass) +
        (CrashAngle dot ( ( (pt1 cross CrashAngle)/moinertia ) cross pt1)));

      Vrt = CarVelocity dot CollisionTangent;

      if(abs(Vrt) > 0.0) {
        Velocity += ( (j * CrashAngle) + ((mu * j) * CollisionTangent) ) / Mass;
        RotationalVelocity += (pt1 cross ((j * CrashAngle) + ((mu * j) * CollisionTangent)))/moinertia;
      } else {
        // apply impulse
        Velocity += (j * CrashAngle) / Mass;
        RotationalVelocity += (pt1 cross (j * CrashAngle))/moinertia;
      }


    }

}
//EZ-write
function WriteText(canvas Canvas, string text, out float Y, optional bool Right){
  local float W, H;
  Canvas.TextSize(text, W, H);
  Canvas.CurY=Y;
  if (Right)
    Canvas.CurX=Canvas.Clipx-5-W;
  else
    Canvas.CurX=5;
  Canvas.DrawText (text, false);
  if (right)
    Y+=H+4;
}

//entry point of render info.
function PostRender(canvas canvas){
  local float Y;
  canvas.Reset();
  canvas.font=canvas.medfont;
  Canvas.DrawColor.R=100;
  Canvas.DrawColor.B=24;
  Canvas.DrawColor.G=200;
  Y=20;
  WriteTEXT(canvas,"Speed"@vsize(Velocity)@"m/s",Y);
  WriteTEXT(canvas,"Velocity vector ["$(CarVelocity)$"] m/s",Y,true);
  WriteTEXT(canvas,"Acceleration vector ["$(Acceleration)$"] m/s^2",Y);
  WriteTEXT(canvas,"Rotational accel vector"@rotAcceleration,Y,true);
  WriteTEXT(canvas,"Torque vector"@Torque,Y);
  WriteTEXT(canvas,"Rotational Velocity"@RotationalVelocity,Y,true);
  WriteTEXT(canvas,"Amount of wheels on ground"@TiresOnGround,Y);
  WriteTEXT(canvas,"Current wheel turn"@wheelturn,Y,true);
  WriteTEXT(canvas,"Acceleration from wheels"@WheelThrust,Y);
  WriteTEXT(canvas,"Torque from wheels"@WheelTorque,Y,true);
  WriteTEXT(canvas,"My rotation"@Rotation,Y);
  WriteTEXT(canvas,"Rotation of front-left wheel"@Wheels[0].rotation,Y,true);
  WriteTEXT(canvas,"Contact force on primary wheel"@Wheels[0].ContactA,Y);
  WriteTEXT(canvas,"Relativeaccel of primary wheel"@Wheels[0].RelativeAcceleration,Y,true);
  Y+=15;
  WriteTEXT(canvas,"Commands:",Y);
  Y+=10;
  WriteTEXT(canvas,"Hit the TAB key, and type in the following commands to change simulator properties. (replace [value] with a number)",Y);
  Y+=10;
  WriteTEXT(canvas,"SetMass [value]          --- Sets the mass of the vehicle.",Y);
  Y+=10;
  WriteTEXT(canvas,"SetMaxThrust [value]     --- Sets the maximum force the engines can give off.",Y);
  Y+=10;
  WriteTEXT(canvas,"SetMaxBreak [value]      --- Sets the maximum force the reversed engines can give off.",Y);
//  Y+=10;
//  WriteTEXT(canvas,"SetGravity [value]       --- Self-explainatory.",Y);
  Y+=10;
  WriteTEXT(canvas,"SetMeiu [value]          --- Sets the coefficient of kinetic friction.",Y);
  Y+=10;
  WriteTEXT(canvas,"SetAirResistance [value] --- Sets the air resistance coefficent.  It is multiplied by velocity^2",Y);
  Y+=10;
  WriteTEXT(canvas,"SetRotatioanalAirResistance [value] --- Sets the rotational air resistance coefficent.  It is multiplied by the normal air resitance",Y);
  Y+=10;
  WriteTEXT(canvas,"SetEngineRate [value]    --- Sets the rate at which the control keys alter the engine force",Y);
  Y+=10;
  WriteTEXT(canvas,"SetHUDRefresh [value]    --- Sets the delay in seconds between new info displayed on screen.",Y);
  Y+=10;
  WriteTEXT(canvas,"SetEnergyLoss [value]    --- Sets the percentage of energy lost in collisions.",Y);
  Acceleration=vect(0,0,0); //temp
}

defaultproperties
{
     WheelOffSet=(X=47.000000,Y=62.500000,Z=-12.000000)
     MaxWheelYaw=8000
     WheelRate=36700.000000
     RollingResistance=0.014000
     bHasGun=True
     WheelRadius=25.000000
     ARCoef=0.040000
     ARRotCoef=0.100000
     Meiu=0.800000
     MaxForce=170.000000
     EngineRate=97.000000
     Physics=PHYS_Projectile
     Mesh=LodMesh'BotPack.car03M'
     CollisionRadius=54.000000
     Mass=764.000000
}
