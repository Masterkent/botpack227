// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// StarterTelsaBolt : Controls the telsa bolt to move the tesla around.
// ============================================================

class StarterTelsaBolt expands TelsaBolt;

//target is used here.
var rotator AimRotation;   //rot of aim...
var float RotSpeed; //uses speed to minipulate aimrotation...      note: each end is oneDspeed*sqrt(2)/2....
var float AnimTime;
var vector BeamOffSet; //offset of base location..
var vector BaseLoc; //Base location.
//for other bolts (storage better here):
//var float AccumulatedDamage, LastHitTime; //here accumulated damage IS damage,,
var int maxdamage; //Max damage level ;)

replication
{
  // Things the server should send to the client.
  unreliable if( Role==ROLE_Authority )
    AimRotation, BeamOffset, BaseLoc, MaxDamage;
}
//Ohm's law:
simulated function float GetDamage(vector HitLocation){
  return maxdamage/fmax(vsize(HitLocation-location),1);
}
simulated function byte GetVolume(float Damage){
  return min(255,2550*damage/maxdamage);
}
simulated function PostBeginPlay()
{
  Super.PostBeginPlay();
  Sentinel=self;
  BaseLoc=location;
  Skin=SpriteAnim[0];
  ambientSound=Sound(DynamicLoadObject("ambmodern.elec4a",class'Sound'));
  oldsound=ambientsound;
}

simulated function Tick(float DeltaTime)
{
  ///local float Time; //temp for speed calc
  ///local rotator DeltaRot; //intended rot change
  local vector turnvec;
  local vector AimVec;
local vector TurnAxis;
local float CosToGo;
local float CosThisStep;
  AnimTime += DeltaTime;
  if ( AnimTime > 0.05 )
  {
    AnimTime -= 0.05;
    SpriteFrame++;
    if ( SpriteFrame == 5 )
      SpriteFrame = 0;
    if (skin!=none)
      Skin = SpriteAnim[SpriteFrame];
  }

	if (Level.NetMode == NM_Client)
	{
		B227_UpdatePosition(DeltaTime);
		return;
	}

    //old code
  //calculate aim!
 /* if (target!=none){  //always false on client :)
    turnvec=target.location+0.62 *vect(0,0,1)* target.CollisionHeight-BaseLoc;
    if (vsize(turnvec)>BeamSize*(MaxPos+1)){
      Destroy(); //give up..
      return;
    }
  //  DeltaRot=rotator(turnvec)-AimRotation; //aim for low-head area.
   DeltaRot = rotator(turnvec << AimRotation);
//    DeltaRot=rotator(turnvec)-AimRotation;
    Time=SQRT((DeltaRot.yaw*DeltaRot.yaw+DeltaRot.pitch*DeltaRot.pitch)/(RotSpeed*RotSpeed));
    DeltaTime=fmin(time,DeltaTime);
    if (DeltaTime!=0)
      Time=Time/DeltaTime;
    if (Time!=0)
      AimRotation+=DeltaRot/Time;
  }
   */
  //spanky code:
  if (Target == none || Target.bDeleteMe)
  {
    Destroy();
    return;
  }
  if (target != None) {
    turnvec = B227_AimPoint(Target) - BaseLoc;
    if (VSize(turnvec) > BeamSize * (MaxPos + 1) ||
       (pawn(target) != none && Pawn(target).health <= 0) ||
       !FastTrace(BaseLoc + turnvec, BaseLoc)
    ){
      Destroy(); //give up..
      return;
    }
    turnvec=normal(turnvec);
   AimVec = vector(AimRotation);

   // What's the angle between TurnVec and AimVec?  Dot product will tell us that.
   CosToGo = TurnVec Dot AimVec;

   // How far can we go in one time step?
   CosThisStep = Cos(RotSpeed * DeltaTime);

   // Can we get there in one step?  Cos() is a decreasing function, if
   // angle1 < angle2, then cos(angle1) > cos(angle2).
   if (CosToGo > CosThisStep) {
      // Aim straight at the dude.
      AimRotation = rotator(TurnVec);
   } else {
      // Rotate AimVec toward TurnVec by an angle of RotSpeed *DeltaTime.
      // Do this by rotating about a vector perpendicular to both AimVec and TurnVec.

      // Are AimVec and TurnVec pointing directly away from each other?
      if (CosToGo < -0.999) {
      // Yes, the problem is ill-conditioned.  So pick another direction
      // to turn toward that "looks nice."
        TurnVec = vector(rot(0,1,0)*(AimRotation.Yaw + 16384));
      }
      TurnAxis = normal(AimVec Cross TurnVec);


      // We've got the axis and the angle.  Rotate!
      // Since TurnAxis is perpendicular to AimVec, the formula is simple
      AimVec = sin(RotSpeed * DeltaTime) * (TurnAxis Cross AimVec) + CosThisStep * AimVec;

      // Now simply point toward AimVec
      AimRotation = rotator(AimVec);
   }
  }

  B227_UpdatePosition(DeltaTime);
}

static function vector B227_AimPoint(Actor Target)
{
	return Target.Location + 0.62 * vect(0,0,1) * Target.CollisionHeight;
}

simulated function B227_UpdatePosition(float DeltaTime)
{
	local vector X, Y, Z;

	SetRotation(AimRotation);
	GetAxes(Rotation,X,Y,Z);
	SetLocation(BaseLoc + BeamOffSet.X * X + BeamOffSet.Y * Y + BeamOffSet.Z * Z);
	CheckBeam(X, DeltaTime);
}

defaultproperties
{
     SpriteAnim(0)=Texture'olextras.Skins.sbbolt0'
     SpriteAnim(1)=Texture'olextras.Skins.sbbolt1'
     SpriteAnim(2)=Texture'olextras.Skins.sbbolt2'
     SpriteAnim(3)=Texture'olextras.Skins.sbbolt3'
     SpriteAnim(4)=Texture'olextras.Skins.sbbolt4'
     RemoteRole=ROLE_SimulatedProxy
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=170
     LightSaturation=67
     LightRadius=5
}
