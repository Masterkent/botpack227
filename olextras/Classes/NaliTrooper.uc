// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// NaliTrooper. By UsAaR33
// A Friendly Nali that follows the player and has a weapon.
// ============================================================

class NaliTrooper expands WeaponHolder;
//UsAaR33: model is the normal nali, yet with a weapon poly added.
//thanks to James Green for sending me the source model
#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

//usaar33: from unreali nali2

var bool bGesture;
var(Sounds) sound syllable1;
var(Sounds) sound syllable2;
var(Sounds) sound syllable3;
var(Sounds) sound syllable4;
var(Sounds) sound syllable5;
var(Sounds) sound syllable6;
var(Sounds) sound urgefollow;
var(Sounds) sound cringe;
var(Sounds) sound cough;
var(Sounds) sound sweat;
var(Sounds) sound bowing;
var(Sounds) sound backup;
var(Sounds) sound pray;
var(Sounds) sound breath;

function PostBeginPlay()
{
  Super.PostBeginPlay();
  bCanSpeak = true;
  if ( Orders == 'Ambushing' )
    AnimSequence = 'Levitate';
}
function SpeakPrayer()
{
  PlaySound(Pray);
}
function PlayFearSound()
{
  if ( (Threaten != None) && (FRand() < 0.4) )
  {
    PlaySound(Threaten, SLOT_Talk,, true);
    return;
  }
  if (Fear != None)
    PlaySound(Fear, SLOT_Talk,, true);
}

function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
  local float adjZ, maxZ;

  TraceDir = Normal(TraceDir);
  HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;

  if ( (GetAnimGroup(AnimSequence) == 'Ducking') && (AnimFrame > -0.03) )
  {
    if ( AnimSequence == 'Bowing' )
      maxZ = Location.Z - 0.2 * CollisionHeight;
    else
      maxZ = Location.Z + 0.25 * CollisionHeight;
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
  }
  return true;
}

simulated function PlayStep()
{
//  local sound ToPlay;
  if (level.netmode==nm_dedicatedserver)
    return;
 /* ToPlay=GetTexSound();
  if (ToPlay!=none){
    PlaySound(ToPlay, SLOT_Interact,2.2,,,1500);
    return;
  }
  */
  //-if (TvPawnShadow(Shadow)!=none&&TvPawnShadow(Shadow).NumSounds!=0)
  //-   PlaySound(TvPawnShadow(Shadow).CurFootSound[rand(TVPawnshadow(shadow).NumSounds)], SLOT_Interact,2.0,,1000);
  //-else
    PlaySound(footstep1, SLOT_Interact,0.5,,1000);
}
simulated function PlayWalkStep()
{
  WalkStep();
}
function PlayWaiting()
{
  local float decision;
  local float animspeed;

  if (region.zone.bwaterzone)
  {
    LoopAnim('Tread');
  }

  animspeed = 0.4 + 0.6 * FRand();
  decision = FRand();
  if ( AnimSequence == 'Breath' )
  {
    if (!bQuiet && (decision < 0.12) )
    {
      PlaySound(Cough,Slot_Talk,1.0,,800);
      LoopAnim('Cough', 0.85);
      return;
    }
    else if (decision < 0.24)
    {
      PlaySound(Sweat,Slot_Talk,0.3,,300);
      LoopAnim('Sweat', animspeed);
      return;
    }
    else if (!bQuiet && (decision < 0.34) )
    {
      PlayAnim('Pray', animspeed, 0.3);
      return;
    }
  }
  else if ( AnimSequence == 'Pray' )
  {
    if (decision < 0.3)
      PlayAnim('Breath', animspeed, 0.3);
    else
    {
      SpeakPrayer();
      PlayAnim('Pray', animspeed);
    }
    return;
  }

  PlaySound(Breath,SLOT_Talk,0.5,true,500,animspeed * 1.5);
   LoopAnim('Breath', animspeed);
}
function PlayPatrolStop()
{
  PlayWaiting();
}

function PlayWaitingAmbush()
{
  if (Region.Zone.bWaterZone)
  {
    PlaySwimming();
    return;
  }

  LoopAnim('Levitate', 0.4 + 0.3 * FRand());
}
function PlayDive()
{
  TweenToSwimming(0.2);
}
function TweenToFighter(float tweentime)
{
  if (Region.Zone.bWaterZone)
    TweenToSwimming(tweentime);
  else if (AnimSequence == 'Bowing')
    PlayAnim('GetUp', 0.4, 0.15);
  else
    TweenAnim('Fighter', tweentime);
}

function TweenToRunning(float tweentime)
{
  if (Region.Zone.bWaterZone)
    TweenToSwimming(tweentime);
  else if ( ((AnimSequence != 'Run') && (AnimSequence != 'RunFire')) || !bAnimLoop)
  {
    if (AnimSequence == 'Bowing')
      PlayAnim('GetUp', 0.4, 0.15);
    else
      TweenAnim('Run', tweentime);
  }
}

function TweenToWalking(float tweentime)
{
  if (Region.Zone.bWaterZone)
    TweenToSwimming(tweentime);
  else if (AnimSequence == 'Bowing')
    PlayAnim('GetUp', 0.4, 0.15);
  else if ( Weapon != None )
    TweenAnim('WalkTool', tweentime);
  else
    TweenAnim('Walk', tweentime);
}

function TweenToWaiting(float tweentime)
{
  if (Region.Zone.bWaterZone)
    TweenToSwimming(tweentime);
  else if (AnimSequence == 'Bowing')
    PlayAnim('GetUp', 0.4, 0.15);
  else
    TweenAnim('Breath', tweentime);
}

function PlayDodge(bool bDuckLeft){
  PlayAnim('jump', 1.35,0.1);
}
function TweenToPatrolStop(float tweentime)
{
  if (Region.Zone.bWaterZone)
    TweenToSwimming(tweentime);
  else if (AnimSequence == 'Bowing')
    PlayAnim('GetUp', 0.4, 0.15);
  else if ( IsInState('Guarding'))
    TweenAnim('Pray', tweentime);
  else
    TweenAnim('Breath', tweentime);
}

function PlayMovingAttackAnim(){
  LoopAnim('Runfire', -1.0/GroundSpeed,,0.4);
}
function PlayFiring(){
  TweenAnim('stillFire', 0.2);
  Super.PlayFiring();
}

function PlayRetreating()
{
  if (Region.Zone.bWaterZone)
  {
    PlaySwimming();
    return;
  }
  bAvoidLedges = true;
  PlaySound(Backup, SLOT_Talk);
  DesiredRotation = Rotator(Enemy.Location - Location);
  DesiredSpeed = WalkingSpeed;
  Acceleration = AccelRate * Normal(Location - Enemy.Location);
  LoopAnim('Backup');
}

function PlayTurning()
{
  TweenAnim('Walk', 0.3);
}

function PlayDying(name DamageType, vector HitLoc)
{
  //first check for head hit
  if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.5 * CollisionHeight))
     && !Level.Game.bVeryLowGore )
  {
    PlayHeadDeath(DamageType);
    return;
  }
  Super.PlayDying(DamageType, HitLoc);
}

function PlayHeadDeath(name DamageType)
{
  local carcass carc;

  carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
  if (carc != None)
  {
    carc.Mesh = mesh'NaliHead';
    carc.Initfor(self);
    carc.Velocity = Velocity + VSize(Velocity) * VRand();
    carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
  }
  PlaySound(sound'Death2n', SLOT_Talk, 4 * TransientSoundVolume);
  PlayAnim('Dead3',0.5, 0.1);
}
function PlayBigDeath(name DamageType)
{
  PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
  PlayAnim('Dead4',0.7, 0.1);
}

function PlayLeftDeath(name DamageType)
{
  PlaySound(sound'Death2n', SLOT_Talk, 4 * TransientSoundVolume);
  PlayAnim('Dead',0.7, 0.1);
}

function PlayRightDeath(name DamageType)
{
  PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
  PlayAnim('Dead2',0.7, 0.1);
}

function PlayGutDeath(name DamageType)
{
  PlaySound(Die, SLOT_Talk, 4 * TransientSoundVolume);
  if ( FRand() < 0.5 )
    PlayAnim('Dead2',0.7, 0.1);
  else
    PlayAnim('Dead',0.7, 0.1);
}

function PlayChallenge()
{
  if (Region.Zone.bWaterZone)
  {
    PlaySwimming();
    return;
  }
  if ( FRand() < 0.3 )
    PlayWaiting();
  else
    tweenAnim('Fighter',0.2+0.1*frand());
}

function PlayVictoryDance()  //based on player nali
{
  PlaySound(pray, SLOT_Talk);
  PlayAnim('pray', 1.0, 0.1);
}

//this nali can swim :P
function playrunning(){
  if ( region.zone.bwaterzone)
  {
    if ( (vector(Rotation) Dot Acceleration) > 0 )
      PlaySwimming();
    else
      PlayWaiting();
    return;
  }
  LoopAnim('Run', -1.0/GroundSpeed,,0.4);
}

function playwalking(){
  if (region.zone.bwaterzone)
  {
    if ( (vector(Rotation) Dot Acceleration) > 0 )
      PlaySwimming();
    else
      PlayWaiting();
    return;
  }
   if ( Weapon != None )
    LoopAnim('WalkTool', 1.5,,0.4);
  else
    LoopAnim('Walk', 1.5,,0.4);
}
function PlaySwimming()
{
LoopAnim('Swim', -1.0/WaterSpeed,, 0.5);
}

function PlayGreetAnim(){
  Playanim (greetanim,0.5+0.4*frand(),0.2);
  SpeakPrayer();
}

function PlayOutOfWater()
{
  TweenAnim('Land', 0.8);
}
function TweenToFalling()
{
  TweenAnim('Jump', 0.35);
}

function PlayInAir()
{
  TweenAnim('Jump', 0.2);
}

function PlayLanded(float impactVel)
{
  TweenAnim('Land', 0.1);
}

function PlayThreatening()    //this nali ain't a coward
{
  local float decision, animspeed;

  if (Region.Zone.bWaterZone)
  {
    PlaySwimming();
    return;
  }
  decision = FRand();
  animspeed = 0.6 + 0.4 * FRand();

  if ( decision < 0.3 )
    PlayAnim('Breath', animspeed, 0.25);
  else if ( decision < 0.45 )
    PlayAnim('follow', animspeed, 0.25);
  else
  {
    PlayThreateningSound();
    if ( decision < 0.65 )
      PlayAnim('spell', animspeed, 0.25);
    else
      PlayAnim('cough', animspeed, 0.25);
  }
}

function TweenToSwimming(float TweenTime)
{
 if (AnimSequence != 'Swim' || !bAnimLoop)
    TweenAnim('Swim', tweentime);
}
state AlarmPaused
{
  ignores HearNoise, Bump;

  function PlayWaiting()
  {
    if ( !bGesture || (FRand() < 0.3) ) //pick first waiting animation
    {
      bGesture = true;
      PlaySound(UrgeFollow, SLOT_Talk);
      NextAnim = 'Follow';
       LoopAnim(NextAnim, 0.4 + 0.6 * FRand());
    }
    else
      Global.PlayWaiting();
  }

  function PlayWaitAround()
  {
    if ( (AnimSequence == 'Bowing') || (AnimSequence == 'GetDown') )
      PlayAnim('Bowing', 0.75, 0.1);
    else
      PlayAnim('GetDown', 0.7, 0.25);
  }

  function BeginState()
  {
    bGesture = false;
    Super.BeginState();
  }
}

state Guarding
{
  function PlayPatrolStop()
  {
    local float decision;
    local float animspeed;
    animspeed = 0.2 + 0.6 * FRand();
    decision = FRand();

    if ( AnimSequence == 'Breath' )
    {
      if (!bQuiet && (decision < 0.12) )
      {
        PlaySound(Cough,Slot_Talk,1.0,,800);
        LoopAnim('Cough', 0.85);
        return;
      }
      else if (decision < 0.24)
      {
        PlaySound(Sweat,Slot_Talk,0.3,,300);
        LoopAnim('Sweat', animspeed);
        return;
      }
      else if (!bQuiet && (decision < 0.65) )
      {
        PlayAnim('Pray', animspeed, 0.3);
        return;
      }
      else if ( decision < 0.8 )
      {
        PlayAnim('GetDown', 0.4, 0.1);
        return;
      }
    }
    else if ( AnimSequence == 'Pray' )
    {
      if (decision < 0.2)
        PlayAnim('Breath', animspeed, 0.3);
      else if ( decision < 0.35 )
        PlayAnim('GetDown', 0.4, 0.1);
      else
      {
        SpeakPrayer();
        PlayAnim('Pray', animspeed);
      }
      return;
    }
    else if ( AnimSequence == 'GetDown')
    {
      PlaySound(Bowing, SLOT_Talk);
      LoopAnim('Bowing', animspeed, 0.1);
      return;
    }
    else if ( AnimSequence == 'GetUp' )
      PlayAnim('Pray', animspeed, 0.1);
    else if ( AnimSequence == 'Bowing' )
    {
      if ( decision < 0.15 )
        PlayAnim('GetUp', 0.4);
      else
      {
        PlaySound(Bowing, SLOT_Talk);
        LoopAnim('Bowing', animspeed);
      }
      return;
    }
    PlaySound(Breath,SLOT_Talk,0.5,true,500,animspeed * 1.5);
     LoopAnim('Breath', animspeed);
  }
}


function eAttitude AttitudeTo(Pawn Other)
{
  if (Other.bIsPlayer)
  {
    if ( !cananger )
      return ATTITUDE_Friendly;
    else if ( (Intelligence > BRAINS_None) &&
      ((AttitudeToPlayer == ATTITUDE_Hate) || (AttitudeToPlayer == ATTITUDE_Threaten)
        || (AttitudeToPlayer == ATTITUDE_Fear)) ) //check if afraid
    {
      if (RelativeStrength(Other) > Aggressiveness)
        AttitudeToPlayer = AttitudeWithFear();
      else if (AttitudeToPlayer == ATTITUDE_Fear)
        AttitudeToPlayer = ATTITUDE_Hate;
    }
    return AttitudeToPlayer;
  }
  else if (Hated == Other)
  {
    if (RelativeStrength(Other) >= Aggressiveness)
      return AttitudeWithFear();
    else
      return ATTITUDE_Hate;
  }
  else if ( (TeamTag != '') && (ScriptedPawn(Other) != None) && (TeamTag == ScriptedPawn(Other).TeamTag) )
    return ATTITUDE_Friendly;
  else
    return AttitudeToCreature(Other);
}

function B227_SetWeaponPosition()
{
	super.B227_SetWeaponPosition();

	Weapon.SetHand(-1);
	if (PulseGun(Weapon) != none)
	{
		if (class'PulseGun'.static.B227_ShouldGuideBeam())
		{
			Weapon.PlayerViewOffset *= DrawScale;
			Weapon.PlayerViewOffset.Z -= 1200 * DrawScale;
			Weapon.FireOffset.Y *= 0.5;
		}
		else
			Weapon.SetHand(0);
	}
}

defaultproperties
{
     syllable1=Sound'UnrealShare.Nali.syl1n'
     syllable2=Sound'UnrealShare.Nali.syl2n'
     syllable3=Sound'UnrealShare.Nali.syl3n'
     syllable4=Sound'UnrealShare.Nali.syl4n'
     syllable5=Sound'UnrealShare.Nali.syl5n'
     syllable6=Sound'UnrealShare.Nali.syl6n'
     urgefollow=Sound'UnrealShare.Nali.follow1n'
     Cringe=Sound'UnrealShare.Nali.cringe2n'
     Cough=Sound'UnrealShare.Nali.cough1n'
     Sweat=Sound'UnrealShare.Nali.sweat1n'
     Bowing=Sound'UnrealShare.Nali.bowing1n'
     Backup=Sound'UnrealShare.Nali.backup2n'
     pray=Sound'UnrealShare.Nali.pray1n'
     Breath=Sound'UnrealShare.Nali.breath1n'
     WeaponType=Class'olextras.TVPulseGun'
     GreetAnim=Bowing
     CarcassType=Class'UnrealShare.NaliCarcass'
     TimeBetweenAttacks=0.500000
     RefireRate=0.500000
     Acquire=Sound'UnrealShare.Nali.contct1n'
     Fear=Sound'UnrealShare.Nali.fear1n'
     Roam=Sound'UnrealShare.Nali.breath1n'
     Threaten=Sound'UnrealShare.Nali.contct3n'
     MeleeRange=40.000000
     GroundSpeed=300.000000
     WaterSpeed=100.000000
     AccelRate=900.000000
     Health=160
     UnderWaterTime=6.000000
     HitSound1=Sound'UnrealShare.Nali.injur1n'
     HitSound2=Sound'UnrealShare.Nali.injur2n'
     Die=Sound'UnrealShare.Nali.death1n'
     Mesh=LodMesh'olextras.nalit'
     CollisionRadius=24.000000
     CollisionHeight=48.000000
     Buoyancy=99.000000
     RotationRate=(Yaw=40000)
}
