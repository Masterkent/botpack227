// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// ScriptedHuman : A Scripted Pawn human.
// ===============================================================

class ScriptedHuman expands WeaponHolder
abstract;
//variables:
//mapper:
var () class<ChallengeVoicePack> Voice;
var () texture SpeechFaces[6];
var () float SpeechFaceTime;
//internal:
var float SpeechTimeCur;
var texture NoSpeakFace;
var int numSpeechFaces;
var int CurFace;
var float CanSpeakTime;
var string DefaultSkinName;
var string DefaultPackage;
//mapper can set these sounds:
var(Sounds) sound   drown;
var(Sounds) sound  Footstep1;
var(Sounds) sound  Footstep2;
var(Sounds) sound  Footstep3;
var(Sounds) sound  HitSound3;
var(Sounds) sound  HitSound4;
var(Sounds)  Sound  Deaths[6];
var(Sounds) sound  UWHit1;
var(Sounds) sound  UWHit2;
var(Sounds) sound   LandGrunt;
var(Sounds) sound  JumpSound;

//AI/speech stuff
function PostBeginPlay(){
  Super.PostBeginPlay();
  while (Speechfaces[numSpeechFaces]!=none)
    numSpeechFaces++;
//  if (Voice==none)
//    Voice=default.Voice;
  NoSpeakFace=multiskins[3];
  SpeechTimeCur=SpeechFaceTime;
}
//voice pack play control: 0=taunt, 1=friendly fire, 2=other
function PlayVoice(int Mode, int Num, optional bool bImportant){
  local sound ToPlay;
  if (voice==none)
    return;
  if (!bImportant&&CanSpeakTime>level.timeseconds)
    return;
  if (Num==-1){
    if (Mode==0)
      Num=rand(Voice.default.numTaunts);
    else if (mode==1)
      Num=rand(Voice.default.numFFires);
    else
      Num=rand(17);
  }
  if (Mode==0)
    ToPlay=voice.default.TauntSound[Num];
  else if (mode==1)
    ToPlay=voice.default.FFireSound[Num];
  else
    ToPlay=voice.default.OtherSound[Num];

  PlaySound(ToPlay, SLOT_Talk);
  if (level.netmode!=nm_standalone) //replication would screw up
    return;
  CanSpeakTime=GetSoundDuration(ToPlay)+level.timeseconds;
  SpeechTimeCur=SpeechFaceTime;
  SpeechTimer(); //move mouth now
}

function Scream
(
  sound        InScream,
  optional ESoundSlot Slot,
  optional float    Volume,
  optional bool    bNoOverride,
  optional float    Radius,
  optional float    Pitch
){
  CanSpeakTime=level.timeseconds+GetSoundDuration(InScream);
  SpeechTimer();
  speechtime=GetSoundDuration(InScream);
  if (Volume==0)
    Volume=16;
  if (Radius==0)
    Radius=1600;
  PlaySound(InScream, Slot,Volume);
  if (Pitch>0)
    PlaySound(InScream, Slot,Volume, bNoOverride,Radius,Pitch);
  else
//    PlaySound(InScream, Slot,Volume, bNoOverride,Radius);
    PlaySound(InScream, Slot,Volume);
}
//controls face altering:
function SpeechTimer()
{
  local int i;
  if (NumSpeechFaces==0)
    return;
  if (CanSpeakTime<=level.timeseconds)
    multiskins[3]=NoSpeakFace;
  else{
    if (numSpeechFaces!=1){
      i=rand(NumSpeechFaces);
      if (i==CurFace)
        i+=1;
      CurFace=i%NumSpeechFaces;
    }
    multiskins[3]=SpeechFaces[CurFace];
    SpeechTime=SpeechTimeCur;
  }
}
//for ducking:
simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
  local float adjZ, maxZ;

  TraceDir = Normal(TraceDir);
  HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;
  if ( BaseEyeHeight == Default.BaseEyeHeight )
    return true;

  maxZ = Location.Z + BaseEyeHeight + 0.25 * CollisionHeight;
  if ( HitLocation.Z > maxZ )
  {
    if ( TraceDir.Z >= 0 )
      return false;
    adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
    HitLocation.Z = maxZ;
    HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
    HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;
    if ( VSize(HitLocation - Location) > CollisionRadius )
      return false;
  }
  return true;
}
//Animations and sounds:
function PlayDodge(bool bDuckLeft){
  if ( bDuckLeft )
    TweenAnim('DodgeL', 0.25);
  else
    TweenAnim('DodgeR', 0.25);
}
function PlayWaiting()
{
  local name newAnim;

  if ( Physics == PHYS_Swimming )
  {
    BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
    if ( (Weapon == None) || (Weapon.Mass < 20) )
      LoopAnim('TreadSM');
    else
      LoopAnim('TreadLG');
  }
  else
  {
    BaseEyeHeight = Default.BaseEyeHeight;
    if ( (Weapon != None) && Weapon.bPointing )
    {
      if ( Weapon.bRapidFire && ((bFire != 0) || (bAltFire != 0)) )
        LoopAnim('StillFRRP');
      else if ( Weapon.Mass < 20 )
        TweenAnim('StillSMFR', 0.3);
      else
        TweenAnim('StillFRRP', 0.3);
    }
    else
    {
      if ( FRand() < 0.1 )
      {
        if ( (Weapon == None) || (Weapon.Mass < 20) )
          PlayAnim('CockGun', 0.5 + 0.5 * FRand(), 0.3);
        else
          PlayAnim('CockGunL', 0.5 + 0.5 * FRand(), 0.3);
      }
      else
      {
        if ( (Weapon == None) || (Weapon.Mass < 20) )
        {
          if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1') || (AnimSequence == 'Breath2')) )
            newAnim = AnimSequence;
          else if ( FRand() < 0.5 )
            newAnim = 'Breath1';
          else
            newAnim = 'Breath2';
        }
        else
        {
          if ( (FRand() < 0.75) && ((AnimSequence == 'Breath1L') || (AnimSequence == 'Breath2L')) )
            newAnim = AnimSequence;
          else if ( FRand() < 0.5 )
            newAnim = 'Breath1L';
          else
            newAnim = 'Breath2L';
        }

        if ( AnimSequence == newAnim )
          LoopAnim(newAnim, 0.4 + 0.4 * FRand());
        else
          PlayAnim(newAnim, 0.4 + 0.4 * FRand(), 0.25);
      }
    }
  }
}
function PlayLookAround()
{
  PlayAnim('Look', 0.3 + 0.7 * FRand(), 0.1);
}
function PlayPatrolStop()
{
  PlayLookAround();
}

simulated function PlayFootStep()
{
  local sound step;
  local float decision;

  if ( FootRegion.Zone.bWaterZone )
  {
    PlaySound(sound 'LSplash', SLOT_Interact, 1, false, 1500.0, 1.0);
    return;
  }

//  step=GetTexSound();
  //-if (TvPawnShadow(Shadow)!=none&&TvPawnShadow(Shadow).NumSounds!=0)
  //-   Step=TvPawnShadow(Shadow).CurFootSound[rand(TVPawnshadow(shadow).NumSounds)];
  if (step==none){
    decision = FRand();
    if ( decision < 0.34 )
      step = Footstep1;
    else if (decision < 0.67 )
      step = Footstep2;
    else
      step = Footstep3;
  }
  PlaySound(step, SLOT_Interact, 2.2, false, 1000.0);
}
function PlayWaitingAmbush()
{
  PlayWaiting();
}
function PlayDive()
{
  TweenToSwimming(0.2);
}
function TweenToPatrolStop(float tweentime)
{
  TweenToWaiting(tweentime);
}

function TweenToFighter(float tweentime)
{
  TweenToWaiting(tweentime);
}
function TweenToWalking(float tweentime)
  {
    if ( Physics == PHYS_Swimming )
    {
      if ( (vector(Rotation) Dot Acceleration) > 0 )
        TweenToSwimming(tweentime);
      else
        TweenToWaiting(tweentime);
    }

    BaseEyeHeight = Default.BaseEyeHeight;
    if (Weapon == None)
      TweenAnim('Walk', tweentime);
    else if ( Weapon.bPointing )
    {
      if (Weapon.Mass < 20)
        TweenAnim('WalkSMFR', tweentime);
      else
        TweenAnim('WalkLGFR', tweentime);
    }
    else
    {
      if (Weapon.Mass < 20)
        TweenAnim('WalkSM', tweentime);
      else
        TweenAnim('WalkLG', tweentime);
    }
  }

function TweenToRunning(float tweentime)
{
  local name newAnim;

  if ( Physics == PHYS_Swimming )
  {
    if ( (vector(Rotation) Dot Acceleration) > 0 )
      TweenToSwimming(tweentime);
    else
      TweenToWaiting(tweentime);
    return;
  }

  BaseEyeHeight = Default.BaseEyeHeight;

  if (Weapon == None)
    newAnim = 'RunSM';
  else if ( Weapon.bPointing )
  {
    if (Weapon.Mass < 20)
      newAnim = 'RunSMFR';
    else
      newAnim = 'RunLGFR';
  }
  else
  {
    if (Weapon.Mass < 20)
      newAnim = 'RunSM';
    else
      newAnim = 'RunLG';
  }

  if ( (newAnim == AnimSequence) && (Acceleration != vect(0,0,0)) && IsAnimating() )
    return;
  TweenAnim(newAnim, tweentime);
}

function PlayWalking()
{
  if ( Physics == PHYS_Swimming )
  {
    if ( (vector(Rotation) Dot Acceleration) > 0 )
      PlaySwimming();
    else
      PlayWaiting();
    return;
  }

  BaseEyeHeight = Default.BaseEyeHeight;
  if (Weapon == None)
    LoopAnim('Walk');
  else if ( Weapon.bPointing )
  {
    if (Weapon.Mass < 20)
      LoopAnim('WalkSMFR');
    else
      LoopAnim('WalkLGFR');
  }
  else
  {
    if (Weapon.Mass < 20)
      LoopAnim('WalkSM');
    else
      LoopAnim('WalkLG');
  }
}
function PlayMovingAttackAnim(){
  PlayRunning();
}
function PlayFiring()
{
  // switch animation sequence mid-stream if needed
  if ( GetAnimGroup(AnimSequence) == 'MovingFire' )
    return;
  else if (AnimSequence == 'RunLG')
    AnimSequence = 'RunLGFR';
  else if (AnimSequence == 'RunSM')
    AnimSequence = 'RunSMFR';
  else if (AnimSequence == 'WalkLG')
    AnimSequence = 'WalkLGFR';
  else if (AnimSequence == 'WalkSM')
    AnimSequence = 'WalkSMFR';
  else if ( AnimSequence == 'JumpSMFR' )
    TweenAnim('JumpSMFR', 0.03);
  else if ( AnimSequence == 'JumpLGFR' )
    TweenAnim('JumpLGFR', 0.03);
  else if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture')
    && (AnimSequence != 'TreadLG') && (AnimSequence != 'TreadSM') )
  {
    if ( Weapon.Mass < 20 )
      TweenAnim('StillSMFR', 0.02);
    else if ( !Weapon.bRapidFire || (AnimSequence != 'StillFRRP') )
      TweenAnim('StillFRRP', 0.02);
    else if ( !IsAnimating() )
      LoopAnim('StillFRRP');
  }
}
function PlayFlip()
{
  PlayAnim('Flip', 1.35 * FMax(0.35, Region.Zone.ZoneGravity.Z/Region.Zone.Default.ZoneGravity.Z), 0.06);
}
function PlayRunning()
{
  local float strafeMag;
  local vector Focus2D, Loc2D, Dest2D;
  local vector lookDir, moveDir, Y;
  local name NewAnim;

  if ( Physics == PHYS_Swimming )
  {
    if ( (vector(Rotation) Dot Acceleration) > 0 )
      PlaySwimming();
    else
      PlayWaiting();
    return;
  }
  BaseEyeHeight = Default.BaseEyeHeight;

  if ( Focus != Destination )
  {
    // check for strafe or backup
    Focus2D = Focus;
    Focus2D.Z = 0;
    Loc2D = Location;
    Loc2D.Z = 0;
    Dest2D = Destination;
    Dest2D.Z = 0;
    lookDir = Normal(Focus2D - Loc2D);
    moveDir = Normal(Dest2D - Loc2D);
    strafeMag = lookDir dot moveDir;
    if ( strafeMag < 0.75 )
    {
      if ( strafeMag < -0.75 )
        LoopAnim('BackRun');
      else
      {
        Y = (lookDir Cross vect(0,0,1));
        if ((Y Dot (Dest2D - Loc2D)) > 0)
          LoopAnim('StrafeL');
        else
          LoopAnim('StrafeR');
      }
      return;
    }
  }

  if (Weapon == None)
    newAnim = 'RunSM';
  else if ( Weapon.bPointing )
  {
    if (Weapon.Mass < 20)
      newAnim = 'RunSMFR';
    else
      newAnim = 'RunLGFR';
  }
  else
  {
    if (Weapon.Mass < 20)
      newAnim = 'RunSM';
    else
      newAnim = 'RunLG';
  }
  if ( (newAnim == AnimSequence) && IsAnimating() )
    return;

  LoopAnim(NewAnim);
}
function TweenToWaiting(float tweentime)
{
  if ( Physics == PHYS_Swimming )
  {
    BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
    if ( (Weapon == None) || (Weapon.Mass < 20) )
      TweenAnim('TreadSM', tweentime);
    else
      TweenAnim('TreadLG', tweentime);
  }
  else
  {
    BaseEyeHeight = Default.BaseEyeHeight;
    if ( Enemy != None )
      ViewRotation = Rotator(Enemy.Location - Location);
    else
    {
      if ( GetAnimGroup(AnimSequence) == 'Waiting' )
        return;
      ViewRotation.Pitch = 0;
    }
    ViewRotation.Pitch = ViewRotation.Pitch & 65535;
    If ( (ViewRotation.Pitch > RotationRate.Pitch)
      && (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
    {
      If (ViewRotation.Pitch < 32768)
      {
        if ( (Weapon == None) || (Weapon.Mass < 20) )
          TweenAnim('AimUpSm', 0.3);
        else
          TweenAnim('AimUpLg', 0.3);
      }
      else
      {
        if ( (Weapon == None) || (Weapon.Mass < 20) )
          TweenAnim('AimDnSm', 0.3);
        else
          TweenAnim('AimDnLg', 0.3);
      }
    }
    else if ( (Weapon == None) || (Weapon.Mass < 20) )
      TweenAnim('StillSMFR', tweentime);
    else
      TweenAnim('StillFRRP', tweentime);
  }
}

function PlayChallenge()
{
  if (Region.Zone.bWaterZone || FRand() < 0.3 )
    PlayWaiting();
  else
    TweenToFighter(0.1);
}
function PlayVictoryDance(){
  local float Decision;
  local name Sequence;
  if (ScriptedPawn(Target)==none||!ScriptedPawn(Target).bIsBoss)
    PlayVoice(0,-1);
  else
    PlayVoice(2,16,true);
  Decision=frand();
  if (Decision<0.34)
    Sequence='victory1';
  else if (Decision<0.67)
    Sequence='taunt1';
  else
    Sequence='thrust';
  PlayAnim(Sequence, 0.7);
}

function PlaySwimming()
{
  BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
  if ((Weapon == None) || (Weapon.Mass < 20) )
    LoopAnim('SwimSM');
  else
    LoopAnim('SwimLG');
}

function TweenToSwimming(float tweentime)
{
  BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
  if ((Weapon == None) || (Weapon.Mass < 20) )
    TweenAnim('SwimSM',tweentime);
  else
    TweenAnim('SwimLG',tweentime);
}

function PlayOutOfWater()
{
  PlayDuck();
}
function PlayDuck()
{
  BaseEyeHeight = 0;
  if ( (Weapon == None) || (Weapon.Mass < 20) )
    TweenAnim('DuckWlkS', 0.25);
  else
    TweenAnim('DuckWlkL', 0.25);
}
function TweenToFalling()
{
  if ( (Velocity.Z > 300) && (MoveTarget != None)
      && ((FRand() < 0.13) || ((Region.Zone.ZoneGravity.Z > Region.Zone.Default.ZoneGravity.Z) && (FRand() < 0.2)))
      && (VSize(Destination - Location) > 160)
      && ((Vector(Rotation) Dot (Destination - Location)) > 0) )
      PlayFlip();
}
function PlayInAir()
{
  local float TweenTime;

  BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
  if ( GetAnimGroup(AnimSequence) == 'Jumping' )
  {
    if ( (Weapon == None) || (Weapon.Mass < 20) )
      TweenAnim('DuckWlkS', 2);
    else
      TweenAnim('DuckWlkL', 2);
    return;
  }
  else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
    TweenTime = 2;
  else
    TweenTime = 0.7;

  if ( (Weapon == None) || (Weapon.Mass < 20) )
    TweenAnim('JumpSMFR', TweenTime);
  else
    TweenAnim('JumpLGFR', TweenTime);
}
function PlayLanded(float impactVel)
{
  impactVel = impactVel/JumpZ;
  impactVel = 0.1 * impactVel * impactVel;
  BaseEyeHeight = Default.BaseEyeHeight;

  if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
    Scream(Land, SLOT_Interact, FClamp(4 * impactVel,0.2,4.5), false,1600, 1.0);
  if ( impactVel > 0.17 )
    Scream(LandGrunt, SLOT_Talk, FMin(4, 5 * impactVel),false,1600,FRand()*0.4+0.8);

  if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') )
  {
    if ( (Weapon == None) || (Weapon.Mass < 20) )
      TweenAnim('LandSMFR', 0.12);
    else
      TweenAnim('LandLGFR', 0.12);
  }
  else if ( !IsAnimating() )
  {
    if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
      AnimEnd();
    else
    {
      if ( (Weapon == None) || (Weapon.Mass < 20) )
        TweenAnim('LandSMFR', 0.12);
      else
        TweenAnim('LandLGFR', 0.12);
    }
  }
}
function PlayThreatening()   //um.. probably never even used
{
  PlayWaiting();
}
function PlayAcquisitionSound()
{
  PlayVoice(2,14,true); //incoming/take down
}

function PlayFearSound()
{
  PlayVoice(2,13); //need backup
}

function PlayRoamingSound()
{
  Scream(Roam,Slot_talk,,true);
}

function PlayThreateningSound()
{
  PlayAcquisitionSound();
}

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
  if ( Level.TimeSeconds - LastPainSound < 0.25 )
    return;
  LastPainSound = Level.TimeSeconds;
  if ( HeadRegion.Zone.bWaterZone )
  {
    if ( damageType == 'Drowned' )
      Scream(drown, SLOT_Pain, 12);
    else if ( FRand() < 0.5 )
      Scream(UWHit1, SLOT_Pain,16,,,Frand()*0.15+0.9);
    else
      Scream(UWHit2, SLOT_Pain,16,,,Frand()*0.15+0.9);
    return;
  }
  damage *= FRand();
  if (frand()<0.2){
    if ((enemy!=none&&oldenemy!=none)||damage>20)
      PlayVoice(1,6); //heavy attack
    else
      PlayVoice(1,4);  //I'm hit
    LastPainSound=CanSpeakTime;
  }
  if (damage < 8)
    Scream(HitSound1, SLOT_Pain,16,,,Frand()*0.2+0.9);
  else if (damage < 25)
  {
    if (FRand() < 0.5)
      Scream(HitSound2, SLOT_Pain,16,,,Frand()*0.15+0.9);
    else
      Scream(HitSound3, SLOT_Pain,16,,,Frand()*0.15+0.9);
  }
  else
    Scream(HitSound4, SLOT_Pain,16,,,Frand()*0.15+0.9);
}

function PlayDyingSound()
{
  local int rnd;

  if ( HeadRegion.Zone.bWaterZone )
  {
    if ( FRand() < 0.5 )
      Scream(UWHit1, SLOT_Pain,16,,,Frand()*0.2+0.9);
    else
      Scream(UWHit2, SLOT_Pain,16,,,Frand()*0.2+0.9);
    return;
  }

  rnd = Rand(6);
  Scream(Deaths[rnd], SLOT_Talk, 16);
  Scream(Deaths[rnd], SLOT_Pain, 16);
}

state TakeHit
{
ignores seeplayer, hearnoise, bump, hitwall;

  function Timer()
  {
    bReadyToAttack = true;
  }
}

defaultproperties
{
     Voice=Class'BotPack.ChallengeVoicePack'
     SpeechFaceTime=0.300000
     Footstep1=Sound'BotPack.FemaleSounds.stone02'
     Footstep2=Sound'BotPack.FemaleSounds.stone04'
     Footstep3=Sound'BotPack.FemaleSounds.stone05'
     Aggressiveness=0.300000
     RefireRate=0.900000
     WalkingSpeed=0.350000
     Roam=Sound'UnrealShare.Nali.breath1n'
     bIsHuman=True
     bIsMultiSkinned=True
     MeleeRange=40.000000
     GroundSpeed=400.000000
     AirSpeed=400.000000
     AccelRate=2048.000000
     AirControl=0.350000
     SightRadius=5000.000000
     BaseEyeHeight=27.000000
     EyeHeight=27.000000
     UnderWaterTime=20.000000
     CollisionRadius=17.000000
     CollisionHeight=39.000000
     Buoyancy=99.000000
     RotationRate=(Pitch=3072,Yaw=30000,Roll=2048)
}
