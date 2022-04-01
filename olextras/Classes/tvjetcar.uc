// ============================================================
// This Class used in physic's project!
// TVJetCar : A player touching this can get it and drive :)
// physics note: center of gravity is location, for simplicities sake.
// Note: This car is powered by two jets; is the original car used for my (UsAaR33) physics project.
// ============================================================

class TVJetCar expands TVVehicle;
//jet-car physics.
var float JetRThrust; //jet thrusts located at location +/- vect(colradius, colradius, 0) in newtons..
var float JetLThrust; //calculations however are assumed at loc +/- col. radius for simplicity...

var int HUDJetRThrust; //jet thrusts located at location +/- vect(colradius, colradius, 0) in newtons..
var int HUDJetLThrust; //calculations however are assumed at loc +/- col. radius for simplicity...

//HUD information HOLDER:
var vector HUDVelocity;
var vector HUDAcceleration;
var float HUDScaleAccel;
var vector HUDAirResistance; //current AR   (accel only)
var float HUDGroundFriction; //current friction scaler.  multiply by normal(velocity) for vector.
var vector HUDNormalAccel;  //only for other accels (friction) and renderer.
var vector HUDGravAccel; //slippage due to gravity. (net acceleration)
var float HUDYawAccel; //acceleration of yaw. entire rotation was seemingly too hard to implement.
var float HUDYawVelocity; //acceleration of yaw. entire rotation was seemingly too hard to implement.
var rotator HUDrotation; //saved rotation.

function PostBeginPlay(){
  SetTimer(RefreshTime,false);
  PrePivot.z=-collisionheight; //drawing hack
}
Simulated function actor GroundTrace(out vector HitLocation, out vector HitNormal){
local vector OffSet;
Offset.x=collisionradius;
Offset.y=collisionradius;
Offset.z=collisionheight;
return Trace (hitlocation,HitNormal,Location+(vect(0,0,-1)*(collisionheight+0.01)),location,true,Offset);

}
//update?
function Timer(){
  HUDVelocity=CarVelocity;
  HUDAcceleration=Acceleration;
  Hudrotation=rotation;
  HUDAirResistance=AirResistance;
  HUDScaleAccel=ScaleAccel;
  HUDGroundFriction=GroundFriction;
  HUDNormalAccel=NormalAccel;
  HUDGravAccel=GravAccel;
  HUDYawAccel=YawAccel;
  HUDYawVelocity=YawVelocity;
  HUDJetRThrust=JetRThrust;
  HUDJetLThrust=JetLThrust;
  SetTimer(RefreshTime,false);
}

function VehicleTick(float deltatime){
   if (controller.bPressedJump&&Eject()){
      JetRThrust=0;
      JetLThrust=0;
      return;
   }
   //handle key inputs:
   Controller.aLookup  *= 0.24;
   Controller.aTurn    *= 0.24;
   Controller.aForward = 0.79*Sign(Controller.aForward)*EngineRate*deltatime;
   Controller.aStrafe = Sign(Controller.aStrafe)*EngineRate*deltatime;
   Controller.UpdateRotation(deltatime,2);  //view rot stuff.
   If (Controller.aForward!=0){ //can only cut jet to 0...
      if (Controller.aStrafe==0){
          JetRThrust=(JetLThrust+JetRThrust)/2;  //equalize.
          JetLThrust=JetRThrust;
          if (Sign(JetRThrust)!=Sign(controller.aforward))
            JetRThrust=0;
          if (Sign(JetLThrust)!=Sign(controller.aforward))
            JetLThrust=0;

          JetRThrust=Clamp(JetRThrust+Controller.aForward,MinForce,MaxForce);
          JetLThrust=Clamp(JetLThrust+Controller.aForward,MinForce,MaxForce);
         }
        else if (Controller.aStrafe>0^^Controller.Aforward<0){    //move right
          JetRThrust=Clamp(JetRThrust+Controller.aForward,MinForce,MaxForce);
          Approach(JetLThrust,Controller.aStrafe,0);
        }
        else{    //move left
          JetLThrust=Clamp(JetLThrust+Controller.aForward,MinForce,MaxForce);
          Approach(JetRThrust,Controller.aStrafe,0);
        }
   }
   else { //no forward motion. can be +/-
      if (Controller.aStrafe==0){ //decrease force only!
          JetRThrust=(JetLThrust+JetRThrust)/2;  //equalize.
          JetLThrust=JetRThrust;
          Approach(JetRThrust,EngineRate*deltatime,0);
          Approach(JetLThrust,EngineRate*deltatime,0);
      }
      else{
        JetLThrust=Clamp(JetLThrust-Controller.aStrafe,max(MinForce,-1*MaxForce),min(MaxForce,-1*MinForce));
        JetRThrust=Clamp(JetRThrust+Controller.aStrafe,max(MinForce,-1*MaxForce),min(MaxForce,-1*MinForce));
      }
   }
   if (Controller.bfire>0)
      CamDist=min(camdist-200*deltatime,collisionradius);
   if (Controller.baltfire>0)
     CamDist+=200*deltatime;

   Super.VehicleTick(deltatime);
}

function VehicleMove(float deltatime){
   SetAcceleration();  //set forces.
   HandleRotation(deltatime);  //rotate
   DoMovement(deltatime);   //move car.
}

//critical function!
function SetAcceleration(){ //determine the acceleration of vehicle
   local vector hitlocation, hitnormal;
   MoInertia=0.5*mass*Square(collisionradius/Uumeter); //the car is assumed to be a cylinder.
   YawAccel=UURot*(collisionradius/Uumeter)*(JetRThrust-JetLThrust)/MoInertia; //yaw rate of accel. (uu's)
   AccelerationMag=UUMeter*(JetRThrust+JetLThrust)/mass;  //real accel (uu's)
   if (abs(carvelocity.z)<=-Region.Zone.ZoneGravity.Z/2)
     SetBase(GroundTrace(hitlocation,hitnormal)); //get normal.
   else
    SetBase(none);
   if (base==none){ //not in contact..
      NormalAccel=vect(0,0,0);
      GroundFriction=0;
      GravAccel=Region.Zone.ZoneGravity/2;
   }
   else { //stay on ground
      NormalAccel=-0.5*Region.Zone.ZoneGravity.Z*hitnormal.z*hitnormal; //hitnormal.z represents sin of normal angle (cosine of normal-pi/2)
      //shifts angle and gets the cosine through pythagorean identity ( sin^2 x + cos^2 x = 1 )
      GravAccel=-0.5*Region.Zone.ZoneGravity.Z*SQRT(1-Square(hitnormal.z))*((hitnormal cross vect(0,0,-1)) cross hitnormal);
      GroundFriction=Meiu*vsize(NormalAccel); //friction scaler. always positive here. (subtracted from velocity...)
      floor.yaw=rotation.yaw;
      hitlocation=normal(Carvelocity<<floor);
      hitlocation.z=0; //remove any vertical velocity with respect to rotation
      CarVelocity=vsize(Carvelocity)*(hitlocation>>floor);
   }
}
//rotate car: Acceleration frame-rate issues!
function HandleRotation(float deltatime){
  local rotator newrot;
  local float rate;
  local float oldVeloc;
  OldVeloc=YawVelocity;
  rate=uurot*Region.Zone.ZoneGravity.Z*deltatime/(uumeter*-30); //"fake" rotation rate
  //air resistance. iffy as the interia is calculated as a cylinder. but I must have a legal limit:
//  YawVelocity-=Sign(YawVelocity)*deltatime*square(collisionradius*yawvelocity)*collisionradius*ARCoef/(uurot*square(uumeter)*uumeter*MoInertia);
  YawVelocity-=Sign(YawVelocity)*deltatime*square(collisionradius*yawvelocity)*collisionradius*ARCoef*ARRotCoef/(square(uumeter)*uumeter*MoInertia);
  YawVelocity+=YawAccel*deltatime; //acceleration
  //friction:
  YawVelocity-=Sign(YawVelocity)*fmin((deltatime*mass*collisionradius*UURot*GroundFriction)/(MoInertia*Square(UUmeter)),abs(YawVelocity));
  FloorRot(NormalAccel);    //WARNING: not correct. gravity should accelerate pitch and roll!
  Newrot=rotation;
  SetClosest(newrot.roll,floor.roll);
  if (newrot.roll!=floor.roll){
    if (floor.roll>newrot.roll)
      newrot.roll=fmin(floor.roll,newrot.roll+rate);
    else
      newrot.roll=fmax(floor.roll,newrot.roll-rate);
  }
  SetClosest(newrot.pitch,floor.pitch);
  if (newrot.pitch!=floor.pitch){
    if (floor.pitch>newrot.pitch)
      newrot.pitch=fmin(floor.pitch,newrot.pitch+rate);
    else
      newrot.pitch=fmax(floor.pitch,newrot.pitch-rate);
  }
  newrot.yaw=Rotation.Yaw+normalizeangle(YawVelocity*deltatime);
  if (Controller!=none)
    Controller.ViewRotation.Yaw+=YawVelocity*deltatime;
  setrotation(Normalize(newrot));
  if (Deltatime>0)
    YawAccel=(YawVelocity-oldveloc)/deltatime;
}
//actual movement routine.  WARNING: HAS FRAME-RATE GLITCH!  (higher FPS=faster accel)
function DoMovement(float deltatime){
  local vector x, y, z;
  local vector Oldvelocity;
  ///local vector Oldvelocity, tracesize;
  local vector HitLoc, HitNorm;
  OldVelocity=CarVelocity;
  GetAxes (rotation, X, Y, Z);
  AirResistance=-Square(vsize(CarVelocity))*ArCoef*normal(carvelocity)/mass; //air resistance accel (seems more logical to be here?)
  CarVelocity+=AirResistance*deltatime;
  CarVelocity+=(AccelerationMag*X+GravAccel)*deltatime; //add engines+gravity.
  CarVelocity-=fmin(vsize(CarVelocity),GroundFriction*deltatime)*normal(carvelocity); //friction reduces velocity
 /* traceSize.X = 1.5*CollisionRadius; //larger at front.
  traceSize.Y = CollisionRadius;
  traceSize.Z = CollisionHeight;
  tracesize=(tracesize>>rotation); //um..
  if (Trace(hitloc,hitnorm,location+collisionradius*normal(carvelocity)+CarVelocity*deltatime,location+collisionradius*normal(carvelocity),true,traceSize)!=none)
  */
  if (CollisionCheck(hitloc,hitnorm,carvelocity*deltatime)!=none)
      Velocity=(HitLoc-(Location+collisionradius*normal(carvelocity)))/deltatime; //reset
  else {
      HitLoc=vect(0,0,0);
      Velocity=CarVElocity;
  }
  Velocity=CarVelocity;

  if (!SetLocation(location+velocity*deltatime)&&Controller!=none)
    controller.ClientMessage("WARNING: collision detection failure! SetLocation() failed! Vector ["$location+velocity*deltatime$"] is outside of world!");
  if (HitLoc!=vect(0,0,0))
    HitWall(hitnorm,level);

   Acceleration=(CarVelocity-OldVelocity)/deltatime; //for HUD
  ScaleAccel=(vsize(carvelocity)-vsize(oldvelocity))/deltatime;
}
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
  WriteTEXT(canvas,"Speed"@vsize(HUDVelocity)/UUMeter@"m/s",Y);
  WriteTEXT(canvas,"Velocity vector ["$(HUDVelocity<<HUDrotation)/UUMeter$"] m/s",Y,true);
  WriteTEXT(canvas,"Acceleration forward"@HUDScaleAccel/UUMeter@"m/s^2",Y);
  //WriteTEXT(canvas,"Acceleration"@AccelerationMag/UUMeter$"m/s^2",Y);
  WriteTEXT(canvas,"Acceleration vector ["$(HUDAcceleration<<HUDrotation)/UUMeter$"] m/s^2",Y,true);
  WriteTEXT(canvas,"Net Force"@mass*vsize(HUDAcceleration)/UUMeter@"N",Y);
  WriteTEXT(canvas,"Net Force vector ["$mass*(HUDAcceleration<<HUDrotation)/UUMeter$"] N",Y,true);
  WriteTEXT(canvas,"Left Engine Thrust"@HUDJetLThrust@"N",Y);
  WriteTEXT(canvas,"Right Engine Thrust"@HUDJetRThrust@"N",Y,true);
  WriteTEXT(canvas,"NET Acceleration from Gravity vector ["$(HUDGravAccel<<HUDRotation)/UUMeter@"] m/s^2",Y);
  WriteTEXT(canvas,"Kinetic Energy:"@0.5*mass*Square(vsize(HUDVelocity)/UUMeter)@"J",Y,true);
  WriteTEXT(canvas,"Force from Air Resistance (Coefficient of Air Reistance * Velocity^2)"@mass*vsize(HUDAirResistance)/UUMeter@"N",Y);
  WriteTEXT(canvas,"Frictional Force (Meiu * Normal Force)"@mass*HUDGroundFriction/UUMeter@"N",Y,true);
  WriteTEXT(canvas,"Normal Force"@mass*vsize(HUDNormalAccel)/UUMeter@"N",Y);
  if (vsize(HUDNormalAccel)!=0)
    WriteTEXT(canvas,"Normal Force Vector ["$mass*HUDNormalAccel/UUMeter$"] N",Y,true);
  else
    WriteTEXT(canvas,"Not in contact with ground.",Y,true);
  WriteTEXT(canvas,"Yaw NET acceleration"@HUDYawAccel/UURot@"rad/s^2",Y);
  WriteTEXT(canvas,"Yaw NET Torque"@MoInertia*HUDYawAccel/UURot@"Nm",Y,true);
  WriteTEXT(canvas,"Yaw Velocity"@HUDYawVelocity/UURot@"rad/s",Y);
  WriteTEXT(canvas,"Moment of Intertia for yaw axis:"@MoInertia@"kg*m^2",Y,true);
  Y+=5;
  WriteTEXT(canvas,"Current Left Engine Thrust"@JetLThrust@"N",Y);
  WriteTEXT(canvas,"Current Right Engine Thrust"@JetRThrust@"N",Y,true);
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
     ARCoef=0.710000
     ARRotCoef=0.100000
     Meiu=0.400000
     MaxForce=10000.000000
     MinForce=-4500
     EngineRate=5500.000000
     Physics=PHYS_Projectile
     Mesh=LodMesh'BotPack.car03M'
     CollisionRadius=54.000000
     Mass=764.000000
}
