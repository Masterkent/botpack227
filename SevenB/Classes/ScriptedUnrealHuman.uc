// ===============================================================
// SevenB.ScriptedUnrealHuman: unreal I animation support
// ===============================================================

class ScriptedUnrealHuman extends ScriptedHuman
abstract;

function PlayDodge(bool bDuckLeft)
{
  PlayDuck();
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
      if ( Weapon.Mass < 20 )
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
          if ( Health > 50 )
            newAnim = 'Breath1';
          else
            newAnim = 'Breath2';
        }
        else
        {
          if ( Health > 50 )
            newAnim = 'Breath1L';
          else
            newAnim = 'Breath2L';
        }

        if ( AnimSequence == newAnim )
          LoopAnim(newAnim, 0.3 + 0.7 * FRand());
        else
          PlayAnim(newAnim, 0.3 + 0.7 * FRand(), 0.25);
      }
    }
  }
}

function PlayFiring()
{
  // switch animation sequence mid-stream if needed
  if (AnimSequence == 'RunLG')
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
    else
      TweenAnim('StillFRRP', 0.02);
  }
}

function playflip(){   //use like unreal botz
	playinair();
}

function PlayRunning()
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
    LoopAnim('RunSM');
  else if ( Weapon.bPointing )
  {
    if (Weapon.Mass < 20)
      LoopAnim('RunSMFR');
    else
      LoopAnim('RunLGFR');
  }
  else
  {
    if (Weapon.Mass < 20)
      LoopAnim('RunSM');
    else
      LoopAnim('RunLG');
  }
}

function PlayVictoryDance()
{
  local float decision;

  decision = FRand();

  if ( (Weapon == None) || (Weapon.Mass < 20) )
  {
    if ( decision < 0.5 )
      PlayAnim('Victory1',0.7, 0.2);
    else
      PlayAnim('Taunt1',0.7, 0.2);
  }
  else
  {
    if ( decision < 0.5 )
      PlayAnim('Victory1L',0.7, 0.2);
    else
      PlayAnim('Taunt1L',0.7, 0.2);
  }
}

function PlayDying(name DamageType, vector HitLoc)
{
  local vector X,Y,Z, HitVec, HitVec2D;
  local float dotp;
  local carcass carc;

  BaseEyeHeight = Default.BaseEyeHeight;
  PlayDyingSound();

  if ( FRand() < 0.15 )
  {
    PlayAnim('Dead3',0.7,0.1);
    return;
  }

  // check for big hit
  if ( (Velocity.Z > 250) && (FRand() < 0.7) )
  {
    PlayAnim('Dead2', 0.7, 0.1);
    return;
  }

  // check for head hit
  if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.6 * CollisionHeight))
     && !Level.Game.bVeryLowGore )
  {
    DamageType = 'Decapitated';
    if ( Level.NetMode != NM_Client )
    {
      carc = Spawn(class 'FemaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
      if (carc != None)
      {
        carc.Initfor(self);
        carc.Velocity = Velocity + VSize(Velocity) * VRand();
        carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
      }
    }
    PlayAnim('Dead6', 0.7, 0.1);
    return;
  }


  if ( FRand() < 0.15)
  {
    PlayAnim('Dead1', 0.7, 0.1);
    return;
  }

  GetAxes(Rotation,X,Y,Z);
  X.Z = 0;
  HitVec = Normal(HitLoc - Location);
  HitVec2D= HitVec;
  HitVec2D.Z = 0;
  dotp = HitVec2D dot X;

  if (Abs(dotp) > 0.71) //then hit in front or back
    PlayAnim('Dead4', 0.7, 0.1);
  else
  {
    dotp = HitVec dot Y;
    if ( (dotp > 0.0) && !Level.Game.bVeryLowGore )
    {
      PlayAnim('Dead7', 0.7, 0.1);
      carc = Spawn(class 'Arm1');
      if (carc != None)
      {
        carc.Initfor(self);
        carc.Velocity = Velocity + VSize(Velocity) * VRand();
        carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
      }
    }
    else
      PlayAnim('Dead5', 0.7, 0.1);
  }
}

function PlayGutHit(float tweentime)
{
  if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
  {
    if (FRand() < 0.5)
      TweenAnim('LeftHit', tweentime);
    else
      TweenAnim('RightHit', tweentime);
  }
  else if ( FRand() < 0.6 )
    TweenAnim('GutHit', tweentime);
  else
    TweenAnim('Dead2', tweentime);

}

function PlayHeadHit(float tweentime)
{
  if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead4') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('HeadHit', tweentime);
  else
    TweenAnim('Dead4', tweentime);
}

function PlayLeftHit(float tweentime)
{
  if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead3') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('LeftHit', tweentime);
  else
    TweenAnim('Dead3', tweentime);
}

function PlayRightHit(float tweentime)
{
  if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead5') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('RightHit', tweentime);
  else
    TweenAnim('Dead5', tweentime);
}

function B227_SetWeaponPosition()
{
	super.B227_SetWeaponPosition();
	Weapon.SetHand(0);
}

defaultproperties
{
     Footstep1=Sound'UnrealShare.Female.stwalk1'
     Footstep2=Sound'UnrealShare.Female.stwalk2'
     Footstep3=Sound'UnrealShare.Female.stwalk3'
}
