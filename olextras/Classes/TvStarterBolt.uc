// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvStarterBolt : Simply the controller of the new colored bolt.  Same code as the Oldskool one.
// ===============================================================

#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

class TvStarterBolt expands Tvpbolt;

var float OldError, NewError, StartError, AimError; //used for bot aiming
var rotator AimRotation;
var float AnimTime;

var vector B227_Location;
var int B227_Pitch, B227_Yaw, B227_Roll;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		AimError, NewError, AimRotation;

	reliable if (Role == ROLE_Authority)
		B227_Location, B227_Pitch, B227_Yaw, B227_Roll;
}

/*-
replication
{
  // Things the server should send to the client.
  unreliable if( Role==ROLE_Authority )
    AimRotation;
}
*/

simulated function PostBeginPlay()
{
  Super.PostBeginPlay();

  BaseBolt=self;
  if ( instigator == None )
    return;
  if ( Bot(Instigator) != none && Bot(Instigator).bNovice )
    aimerror = 2200 + (3 - instigator.skill) * 300;
  else
    aimerror = 1000 + (3 - instigator.skill) * 400;

  if ( FRand() < 0.5 )
    aimerror *= -1;
}

simulated event Tick(float DeltaTime)
{
	if (!B227_bGuidedByWeapon)
	{
		B227_OriginalTick(DeltaTime);
		return;
	}

	BeamLength = 0;
	NumHits = 0;

	class'StarterBolt'.static.B227_BoltTick(
		self,
		DeltaTime,
		OldError,
		NewError,
		StartError,
		AimError,
		AimRotation,
		AnimTime,
		B227_Location,
		B227_Rotation(),
		true);
}

simulated function B227_OriginalTick(float DeltaTime)
{
  local vector X,Y,Z, AimSpot, DrawOffset, AimStart;
  local int YawErr;
  local float dAdjust;
  local Bot MyBot;

  AnimTime += DeltaTime;
  if ( AnimTime > 0.05 )
  {
    AnimTime -= 0.05;
    SpriteFrame++;
    if ( SpriteFrame == 5 )
      SpriteFrame = 0;
    Skin = SpriteAnim[SpriteFrame];
  }
  BeamLength=0;
  NumHits=0;
  // orient with respect to instigator
  if ( Instigator != None )
  {
    if ( (Level.NetMode == NM_Client) && (!Instigator.IsA('PlayerPawn') || (PlayerPawn(Instigator).Player == None)) )
    {
      SetRotation(AimRotation);
      Instigator.ViewRotation = AimRotation;
      DrawOffset = ((0.01 * class'PulseGun'.Default.PlayerViewOffset) >> Rotation);
      DrawOffset += (Instigator.EyeHeight * vect(0,0,1));
    }
    else
    {
      MyBot = Bot(instigator);
      if ( MyBot != None || !instigator.bIsPlayer) //AI
      {
        if ( Instigator.Target == None )
          Instigator.Target = Instigator.Enemy;
        if ( Instigator.Target == Instigator.Enemy && Instigator.Enemy != none)
        {
          if (MyBot!=none && MyBot.bNovice )
            dAdjust = DeltaTime * (4 + instigator.Skill) * 0.075;
          else
            dAdjust = DeltaTime * (4 + instigator.Skill) * 0.12;
          if ( OldError > NewError )
            OldError = FMax(OldError - dAdjust, NewError);
          else
            OldError = FMin(OldError + dAdjust, NewError);

          if ( OldError == NewError )
            NewError = FRand() - 0.5;
          if ( StartError > 0 )
            StartError -= DeltaTime;
          else if (MyBot!=none && MyBot.bNovice && (Level.TimeSeconds - MyBot.LastPainTime < 0.2) )
            StartError = MyBot.LastPainTime;
          else if (ScriptedPawn(instigator) != none && instigator.skill<2 && (Level.TimeSeconds - ScriptedPawn(instigator).LastPainTime < 0.2) )
            StartError = ScriptedPawn(instigator).LastPainTime;
          else
            StartError = 0;
          AimSpot = 1.25 * Instigator.Target.Velocity + 0.75 * Instigator.Velocity;
          if ( Abs(AimSpot.Z) < 120 )
            AimSpot.Z *= 0.25;
          else
            AimSpot.Z *= 0.5;
          if ( Instigator.Target.Physics == PHYS_Falling )
            AimSpot = Instigator.Target.Location - 0.0007 * AimError * OldError * AimSpot;
          else
            AimSpot = Instigator.Target.Location - 0.0005 * AimError * OldError * AimSpot;
          if ( (Instigator.Physics == PHYS_Falling) && (Instigator.Velocity.Z > 0) )
            AimSpot = AimSpot - 0.0003 * AimError * OldError * AimSpot;

          AimStart = Instigator.Location + FireOffset.X * X + FireOffset.Y * Y + (1.2 * FireOffset.Z - 2) * Z;
          if ( FastTrace(AimSpot - vect(0,0,10), AimStart) )
            AimSpot  = AimSpot - vect(0,0,10);
          GetAxes(Instigator.Rotation,X,Y,Z);
          AimRotation = Rotator(AimSpot - AimStart);
          AimRotation.Yaw = AimRotation.Yaw + (OldError + StartError) * 0.75 * aimerror;
          YawErr = (AimRotation.Yaw - (Instigator.Rotation.Yaw & 65535)) & 65535;
          if ( (YawErr > 3000) && (YawErr < 62535) )
          {
            if ( YawErr < 32768 )
              AimRotation.Yaw = Instigator.Rotation.Yaw + 3000;
            else
              AimRotation.Yaw = Instigator.Rotation.Yaw - 3000;
          }
        }
        else if ( Instigator.Target != None )
          AimRotation = Rotator(Instigator.Target.Location - Instigator.Location);
        else
          AimRotation = Instigator.ViewRotation;
        Instigator.ViewRotation = AimRotation;
        SetRotation(AimRotation);
      }
      else
      {
        AimRotation = Instigator.ViewRotation;
        SetRotation(AimRotation);
      }
      Drawoffset = Instigator.Weapon.CalcDrawOffset();
    }
    GetAxes(Instigator.ViewRotation,X,Y,Z);

    if ( bCenter )
    {
      FireOffset.Z = Default.FireOffset.Z * 1.5;
      FireOffset.Y = 0;
    }
    else
    {
      FireOffset.Z = Default.FireOffset.Z;
      if ( bRight )
        FireOffset.Y = Default.FireOffset.Y;
      else
        FireOffset.Y = -1 * Default.FireOffset.Y;
    }
    if (instigator.isa('nali')||instigator.isa('nalitrooper'))
        drawoffset+=vect(14,5.5,-9) >> Instigator.Rotation;
    else if (instigator.isa('skaarj')||instigator.isa('rebelskaarj'))
        drawoffset+=vect(33,-37,-7) >> Instigator.Rotation;
    SetLocation(Instigator.Location + DrawOffset + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z);
  }
  else
    GetAxes(Rotation,X,Y,Z);

  CheckBeam(X, DeltaTime);
}

// Auxiliary
simulated function rotator B227_Rotation()
{
	return B227_Pitch * rot(1, 0, 0) + B227_Yaw * rot(0, 1, 0) + B227_Roll * rot(0, 0, 1);
}

function B227_SetBeamRepMovement(vector Pos, rotator Dir)
{
	B227_Location = Pos;
	B227_Pitch = Dir.Pitch;
	B227_Yaw = Dir.Yaw;
	B227_Roll = Dir.Roll;
}

defaultproperties
{
     StartError=0.500000
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
     LightSaturation=72
     LightRadius=5
}
