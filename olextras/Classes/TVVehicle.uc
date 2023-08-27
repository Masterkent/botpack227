// ============================================================
// For ONP
// TVVehicle : Base class of all vehicles.
// Useful note:
// >>  -> to world coords
// << -> to local coords.
// ============================================================

class TVVehicle expands Decoration;   //should be abstract, but some mappers added this to the world :/

Const UUMeter = 43.0; //97 uus in 1 meter.
Const UURot = 10430.38; //radians*this=uu rot units.
//active vars with physics:
//acceleration used as that!
//base is base.
//mass used for many calcs
var TvPlayer Controller; //playerpawn that is driving.
//active stuff
var vector AirResistance; //current AR   (accel only)
var vector CarVelocity; //Unrealty wiped velocity on move.  I know longer use that function, however, I do not feel like changing the name.
var float GroundFriction; //current friction scaler.  multiply by normal(velocity) for vector.
var vector NormalAccel;  //only for other accels (friction) and renderer.
var vector GravAccel; //slippage due to gravity. (real acceleration)
var float YawAccel; //acceleration of yaw. entire rot was seemingly too hard to implement.
var float YawVelocity; //velocity of yaw. entire rot was seemingly too hard to implement.
var float ScaleAccel; //acceleration scalar.
var vector RotationalVelocity; //a full rotational velocity vector :) in a vector as easier for adding. rot conversion is not too hard...
var vector RotAcceleration; //rotational acceleration vector
var rotator Floor; //rotation of car pre-yaw velocity.
var float ViewIntegrityMult; //in vehicle HUD
//config stuff:
var () float ARCoef; //coeficient of air resistance.  AR=Coef*velocity^2
var () float ARRotCoef; //coeficient of rotational ar*ar.  AR=rotar*Coef*velocity^2
var () float Meiu; //coeficient of friction. (scaled by zone ground friction)
var () float MaxForce; //maximum force of power generators.      (used as accel in wheel car)
var () int MinForce; //minimum force (often retro rockets)
var () float EngineRate; //engine accel per second.
var float AccelerationMag; //acceleration magnitude.  used AFTER rotational accel! (always in rot accel dir)
var float Gravity; //DEPRECATED. NOW USES REGION.ZONE.ZONEGRAVITY!
var () float EnergyLoss; //percentage of energy lost in collisions. 0-1.

var () float RefreshTime; //timer for HUD updates.
var () int CamDist; //camera distance
var () int HullIntegrity; //strength in HULL (damage does normal)
var () int MaxViewIntegrity; //amount integrity reads when damage is at 1
var () vector WheelOffSet;
var () int MaxWheelYaw; //in unreal units

//more stuff
var () float CoefficientOfRestitution;
var () float CoefficientOfRestitutionGround;
var float MoInertia; //Moment of initertia (calculated at start). note same for all axis.

/////////////////////////////////////////////////////////////////////
// Quaternion Code (for rotation stuff):
// Note: All functions with quaternions have been taken from "Physics for Game Developers" by David M. Bourgh.  NOT DAVID MUNNICH!
/////////////////////////////////////////////////////////////////////
struct Quaternion
{
  var () float n; //scalar
  var () vector v; //vector
};
var () Quaternion QRotation; //rotation as a quaternion.

static final function Quaternion ONPQuad(float a, float b, float c, float d){  //quaternion constructor
   local Quaternion Temp;
   Temp.n=a;
   Temp.v.x=b;
   Temp.v.y=c;
   Temp.v.z=d;
   return Temp;
}
static final function Rotator Roti (int Pitch, int Yaw, int Roll){ //because rot() not like expressions...
  local Rotator Temp;
  Temp.Pitch=Pitch;
  Temp.Yaw=Yaw;
  Temp.Roll=Roll;
  return Temp;
}
static final operator(16) Quaternion  * ( Quaternion A, Quaternion B ){   //mult quads
  return ONPQuad(
    A.n*B.n-A.v.x*B.v.x-A.v.y*B.v.y-A.v.z*B.v.z,
    A.n*B.v.x+A.v.x*B.n+A.v.y*B.v.z-A.v.z*B.v.y,
    A.n*B.v.y+A.v.y*B.n+A.v.z*B.v.x-A.v.x*B.v.z,
    A.n*B.v.z+A.v.z*B.n+A.v.x*B.v.y-A.v.y*B.v.x
  );
}

static final operator(16) Quaternion  * ( Quaternion A, Vector B ){   //mult quad by vector
  return ONPQuad(
    -(A.v.x*B.x+A.v.y*B.y+A.v.z*B.z),
    A.n*B.x+A.v.y*B.z-A.v.z*B.y,
    A.n*B.y+A.v.z*B.x-A.v.x*B.z,
    A.n*B.z+A.v.x*B.y-A.v.y*B.x
  );
}
static final operator(16) Quaternion  * ( Vector B, Quaternion A ){   //mult quad by vector (other order
  return A*B;
}
static final operator(16) Quaternion  * ( Quaternion A, float B ){   //mult quads by scalar
return ONPQuad(
    A.n*B,
    A.v.x*B,
    A.v.y*B,
    A.v.z*B
  );
}

static final operator(16) Quaternion  * ( float B, Quaternion A ){   //mult quads by scalar (other order)
  return A*B;
}

static final operator(20) Quaternion  + ( Quaternion A, Quaternion B ){   //add quads
 return ONPQuad(
    A.n+B.n,
    A.v.x+B.V.x,
    A.v.y+B.V.y,
    A.v.z+B.V.z
  );
}

static final operator(20) Quaternion  - ( Quaternion A, Quaternion B ){   //subtracts quads
  return ONPQuad(
    A.n-B.n,
    A.v.x-B.V.x,
    A.v.y-B.V.y,
    A.v.z-B.V.z
  );
}

static final operator(34) Quaternion  += ( out Quaternion A, Quaternion B ){   //add quads to
  A.n-=B.n;
  A.v.x-=B.V.x;
  A.v.y-=B.V.y;
  A.v.z-=B.V.z;
  return A;
}

static final operator(34) Quaternion  -= ( out Quaternion A, Quaternion B ){   //subtracts quads from
  A.n-=B.n;
  A.v.x-=B.V.x;
  A.v.y-=B.V.y;
  A.v.z-=B.V.z;
  return A;
}

static final operator(34) Quaternion  *= ( out Quaternion A, float B ){   //mult by scalar
  A.n*=B;
  A.v.x*=B;
  A.v.y*=B;
  A.v.z*=B;
  return A;
}

static final operator(34) Quaternion  /= ( out Quaternion A, float B ){   //divide by scalar
  A.n/=B;
  A.v.x/=B;
  A.v.y/=B;
  A.v.z/=B;
  return A;
}

static final preoperator  Quaternion  ~  ( Quaternion A ){      //conjugate (negative of vector part)
  return ONPQuad(A.n,-A.v.x,-A.v.y,-A.v.z);
}

static final function float QSizeSquared(Quaternion A){ //get size (faster)
   return Square(A.n)+Square(A.v.x)+Square(A.v.y)+Square(A.v.z);
}

static final function float QSize(Quaternion A){ //get size  (magnitude)
   return sqrt(QSizeSquared(A));
}

static final function Quaternion QNormal(Quaternion A){ //normalize
   return A/=QSize(A);
}

static final function float QGetAngle(Quaternion A){ //get angle about quad vector axis
   return 2*acos(A.n);
}

static final function vector QGetAxis(Quaternion A){ //get unit vector along rot.
   return Normal(A.v);
}

static final function Quaternion QRotate(Quaternion A, Quaternion B){ //rotate A by B
   return A*B*(~A);
}

static final function Vector QVRotate(Quaternion A, Vector B){ //rotate vector B by quaternion B
   return (A*B*(~A)).V;
}
//new conversion: THIS CONVERSION HAS BEEN VERIFIED!
static final function Quaternion ROTtoQuat(Rotator A){
  local float pitch;  //converted to radians.
  local float yaw;
  local float roll;
  local float cyaw, cpitch, croll, syaw, spitch, sroll;  //multiplies
  local float cyawcpitch, syawspitch, cyawspitch, syawcpitch;

  pitch=-0.5*A.pitch/UURot;   //these may be CCW.. I think?
  yaw=-0.5*A.yaw/UURot;
  roll=0.5*A.roll/UURot;

  cpitch=cos(pitch);
  cyaw=cos(yaw);
  croll=cos(roll);
  spitch=sin(pitch);
  syaw=sin(yaw);
  sroll=sin(roll);

  cyawcpitch=cyaw*cpitch;
  syawspitch=syaw*spitch;
  cyawspitch=cyaw*spitch;
  syawcpitch=syaw*cpitch;

  return ONPQuad(
    cyawcpitch * croll + syawspitch * sroll,
    cyawcpitch * sroll - syawspitch * croll,
    cyawspitch * croll + syawcpitch * sroll,
    syawcpitch * croll - cyawspitch * sroll
  );
}

static final function Rotator QuatToRot(Quaternion q){
 local float r11, r21, r31, r32, r33, r12, r13;
 local float q00, q11, q22, q33;
 local float tmp;

 q00 = Square (q.n);
 q11 = Square (q.v.x);
 q22 = Square (q.v.y);
 q33 = Square (q.v.z);    //under pitch->yaw system, this would be q11.

 r11 = q00 + q11 - q22 - q33;
 r21 = 2 * (q.v.x*q.v.y +  q.n*q.v.z);
 r31 = 2 * (q.v.x*q.v.z - q.n*q.v.y);
 r32 = 2 * (q.v.y*q.v.z + q.n*q.v.x);
 r33 = q00 - q11 - q22 + q33;

 tmp = abs(r31);
 if (tmp>=1){  //gimble lock                   //REMEMBER: YAW AND PITCH NOW - WHAT ORIGINAL SOURCE IS!
    r12 = 2 * (q.v.x*q.v.y - q.n*q.v.z);
    r13 = 2 * (q.v.x*q.v.z + q.n*q.v.y);
    return Roti((pi/2)*(r31/tmp)*uurot, -ONP_ATan2(-r12,-r31*r13)*uurot, 0);
 }
 return Roti(-ONP_ASin(-r31)*uurot, -ONP_ATan2(r21, r11)*uurot, ONP_ATan2(r32,r33)*uurot);
}
/////////////////////////////////////////////
// End Quaternion Code.
// Begin General Physics/Vehicle Handling Code.
/////////////////////////////////////////////

function BeginPlay(){
  ViewIntegrityMult=MaxViewIntegrity/HullIntegrity;
}

function VehicleTick(float deltatime){  //called by playerpawn.playertick(). Used for inputs
  VehicleMove(deltatime);
  Controller.SetLocation(Location); //might as well.
}

//called by playerpawn.PlayerCalcView(). default is car.
event VehicleCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
  CameraRotation = Controller.ViewRotation;
  // View rotation.
  Controller.DesiredFOV = Controller.DefaultFOV;
  ViewActor = self;
  CameraLocation = Location;
  if( Controller.bBehindView ){
    //camerarotation.pitch=fclamp(viewrotation.pitch+500*(viewrotation.pitch/abs(viewrotation.pitch)),viewrotation.pitch+5461,viewrotation.pitch-5461); //maybe a retarded way, but it works :P
    //CameraLocation.Z -= camerarotation.pitch/8192-50; //kinda starfoxy with loc.
    CameraLocation.Z+=50;
    Controller.CalcBehindView(CameraLocation, CameraRotation, CamDist);
   // if (viewrotation.pitch<=32768)
   // camerarotation.pitch=viewrotation.pitch/2; //stays steady
  //    else
   //  camerarotation.pitch=-0.5*(viewrotation.pitch-32786); //make sure negative rule
    }
  else
    CameraLocation.Z += Controller.Default.BaseEyeHeight;
}

function VehicleMove(float deltatime); //implemented in subclass. move vehicle.

function Tick (float deltatime){ //must move here if no controller.
  if (controller==none)
     VehicleMove(deltatime);
}

function bool KeyInput (float deltatime); //called by playerpawn.KeyInput().  return true if handled and does not global.

function GetIn (tvplayer Driver){
  Controller=Driver;
  Velocity=vect(0,0,0);
  SetOwner(driver);
  Driver.Vehicle=self;
  Driver.GotoState('VehicleControl');
  bprojtarget=True;
//  bcollideworld=false; //hack?
}
function bool Eject (){ //ejects controller
  local vector X,Y, Z;
  local tvplayer oldcontroller;
  GetAxes(rotation,X,Y,z);
  Y.z=0;
  oldcontroller=controller;
  if (controller.SetLocation(location+vect(0,0,1)*(collisionheight+controller.collisionheight)-(controller.collisionradius+collisionradius+7)*normal(Y))){
   Controller.Walk();
 //  Controller.Velocity=vect(0,0,0);
   oldController.AddVelocity(velocity);
   bprojtarget=false;
   return true;
  }
}
function Bump (actor other){
  if (Controller==none && tvplayer(other) != none)
    GetIn(tvplayer(other));
  else
    ProcessCollision(other,-1*normal(Velocity+other.velocity)); //fake
}
//UT is funky when it comes to these physics....
function HitWall(vector HitNormal, actor HitWall){
    ProcessCollision(HitWall,HitNormal);
}

event Landed( vector HitNormal ){
    ProcessCollision(Level,HitNormal);
}
//called when hit something in driving mode.
function ProcessCollision(actor Collided,vector CrashAngle);

//useful somewhere...
final static function int Sign (float a){
  if (a>0)
    return 1;
  else if (a<0)
    return -1;
  else return 0;
}
final static function float normalizeangle(float inangle)
{
 local int divisions;

 divisions = sign(inangle)*int(abs(inangle)/32768);

 return inangle-divisions*65536;
}
//approach a value
final static function Approach (out float value, float toAdd, float Approach){
  toadd=ABS(toadd);
  if (value>Approach){
    value-=toAdd;
    if (value<Approach)
      value=Approach;
  }
  else if (value<Approach){
    value+=toadd;
    if (value>Approach)
      value=Approach;
  }
}
simulated final function float GetMeiu(){ //allow mappers to vary meiu in different areas.
  return Meiu*region.zone.ZoneGroundFriction/class'zoneinfo'.default.ZoneGroundFriction;
}
//this function traces from various points on the ground.  If any hits, returns it. various priority settings as well.
Simulated function actor GroundTrace(out vector HitLocation, out vector HitNormal){
///local vector Normals[5]; //priority order. 0=highest. 4=lowest.
///local actor Hits[5];
///local vector HitLoc[5];
	local vector OffSet;
///local vector OffSet, x, y, z;
///local rotator rot;
///local byte i;
/*
if (vsize(carvelocity)==0)
   rot=rotation;
else
  rot=rotator(carvelocity);
GetAxes(rot,X,Y,Z); //to get a vector switch...
for (i=0;i<5;i++){
  Hits[i]=Trace(hitloc[i],Normals[i],Location+Offset+vect(0,0,-1)*(collisionheight+1),Location+offset,true);
  if (Hits[i]!=none)
    break;
  switch(i+1){   //a better way to do this?
    case 1:
   // offset=vect(0,1,0)*collionradius>>rotator(velocity);
    offset=collisionradius*x+collisionradius*y;
    break;
    case 2:
    offset=collisionradius*x-collisionradius*y;
    break;
    case 3:
    offset=-collisionradius*x+collisionradius*y;
    break;
    case 4:
    offset=-collisionradius*x-collisionradius*y;
    break;
  }
}
if (i==5)
  return none;
HitNormal=Normals[i];
HitLocation=Hitloc[i];
return Hits[i];
*/
Offset.x=collisionradius;
Offset.y=collisionradius;
//Offset.z=collisionheight;
if (Owner!=none)
  return Owner.Trace (hitlocation,HitNormal,Location+(vect(0,0,-1)*(collisionheight+0.01)),location,true,Offset);
else
  return Trace (hitlocation,HitNormal,Location+(vect(0,0,-1)*(collisionheight+0.01)),location,true,Offset);

}
//checks for collision using seven points on cylinder.
Simulated final function actor CollisionCheck(out vector HitLocation, out vector HitNormal, vector toMove){
local vector Normals[7]; //array of traces
local actor Hits[7];
local vector HitLoc[7];
local byte besttrace, i;
local vector X,Y,Z, offset;
besttrace=7;
   if (vsize(tomove)==0)
      return none; //cannot collide if not moving
GetAxes(rotator(tomove),X,Y,Z); //various vectors with respect to rotator (swapped angles)
for (i=0;i<7;i++){
//  if (i<3)
    offset+=collisionradius*x;
//  else
//    offset+=collisionradius*x*0.707;
  offset+=location;
  Hits[i]=Trace(hitloc[i],Normals[i],Offset+tomove,offset,true);
  if ((!FastTrace(offset,offset+tomove)||Hits[i]!=none)&&(besttrace==7||vsize(hitloc[i]-location)<vsize(hitloc[besttrace]-location)))
     besttrace=i;
  switch(i){   //a better way to do this?
    case 0:
      offset=collisionheight*z;
      break;
    case 1:
      offset=-collisionheight*z;
      break;
    case 2:
   // offset=vect(0,1,0)*collionradius>>rotator(velocity);
    offset=collisionradius*y+collisionheight*z;
    break;
    case 3:
    offset=collisionradius*y-collisionheight*z;
    break;
    case 4:
    offset=-collisionradius*y+collisionheight*z;
    break;
    case 5:
    offset=-collisionradius*y-collisionheight*z;
    break;
  }
}
if (besttrace==7)
  return none;
HitNormal=Normals[besttrace];
HitLocation=Hitloc[besttrace];
return Hits[besttrace];
}
//sets floorrot to rotation based on hitnormal.
final simulated function FloorRot(vector HitNorm)
{
 local vector temploc;
 local rotator adjustrotation;

 if(VSize(HitNorm)==0){
  floor=rot(0,0,0);
  return;
 }
 temploc = (HitNorm << rot(0,1,0)*rotation.yaw);
 //use slope of Z/Y
 AdjustRotation.roll  = normalizeangle(ONP_ATan2(temploc.Y,temploc.Z)*UURot);
 //slope of roll/X
 AdjustRotation.pitch = -normalizeangle(
                        ONP_ATan2(temploc.X,
                              sqrt(square(temploc.Z)+square(temploc.Y))
                        )*UURot);
 Floor=adjustrotation;
}
//rotator component closest thingy.
static final function SetClosest(int a, out int b){
  local int c;
  a=normalizeangle(a);
  b=normalizeangle(b);
  c=b+65536;
  if (abs(b-a)>abs(c-a))
     b=c;
}
static final function int Round(float a){ //returns rounded float.
  return int(a+0.5);
}
function PostRender( canvas Canvas );  //vehicle HUD

/////////////////////////////////////////////
// various math functions  (used for quaternions... although I wrote these earlier just for the hell of it)
/////////////////////////////////////////////

static final function float ONP_ASin(float A)
{
	return Pi/2.0 - ACos(A);
}

/*-
static final function float ASin  ( float A ){
  if (A>1||A<-1) //outside domain!
    return 0;
  if (A==1)  //div by 0 checks
    return Pi/2.0;
  if (A==-1)
    return Pi/-2.0;
  return ATan(A/Sqrt(1-Square(A)));
}

//same philosophy as asin. Must add 180 to results below 0 however (want 1st quadrant, not 3rd!)
static final function float ACos  ( float A ){
  if (A>1||A<-1) //outside domain!
    return 0;
  if (A==0) //div by 0 check
    return (Pi/2.0);
  A=ATan(Sqrt(1.0-Square(A))/A);
  if (A<0)
    A+=Pi;
  Return A;
}
*/

// X = width/adjacent, Y = height, opposite   (on circle where 0 degrees is +x axis)
final static function float ONP_ATan2(float Y, float X)
{
 local float tempang;

 if(X==0) { //div by 0 checks.
  if(Y<0)
   return -pi/2.0;
  else if(Y>0)
   return pi/2.0;
  else
   return 0; //technically impossible (nothing exists)
 }
 tempang=ATan(Y/X);

 if (X<0)
  tempang+=pi;  //1st/3th quad

 //normalize (from -pi to pi)
 if(tempang>pi)
  tempang-=pi*2.0;

 if(tempang<-pi)
  tempang+=pi*2.0;

 return tempang;
}

// Y = height, opposite Rad=Hypotenuse/radius  (on circle where 0 degrees is +x axis)
final static function float ONP_ASin2(float Y, float Rad)
{
 local float tempang;

 if(Rad==0)
   return 0; //technically impossible (no hypotenuse = nothing)
 tempang=ONP_ASin(Y/Rad);

 if (Rad<0)
  tempang=pi-tempang;  //lower quads

 return tempang;
}

// X = width, adj.  Rad=Hypotenuse/radius  (on circle where 0 degrees is +x axis)
final static function float ONP_ACos2(float X, float Rad)
{
 local float tempang;

 if(Rad==0)
   return 0; //no possible angle
 tempang=ACos(X/Rad);

 if (X<0)
  tempang*=-1;  //left quads

 return tempang;
}

defaultproperties
{
     EngineRate=2000.000000
     Gravity=421.399994
     EnergyLoss=0.680000
     RefreshTime=0.250000
     CamDist=400
     HullIntegrity=317
     MaxViewIntegrity=100
     CoefficientOfRestitution=0.500000
     CoefficientOfRestitutionGround=0.025000
     bStatic=False
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Mesh
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bBounce=True
}
