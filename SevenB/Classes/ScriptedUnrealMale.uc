// ===============================================================
// SevenB.ScriptedUnrealMale: for unreal I male models
// ===============================================================

class ScriptedUnrealMale extends ScriptedUnrealHuman;

function PostBeginPlay(){
  if (multiskins[0]==none)
    class'oldskool.maleonebot'.static.SetMultiSkin(self,"","",rand(4));
  Super.PostBeginPlay();
}

simulated function PlayMetalStep()    //for male one
{
  local sound step;
  local float decision;

  if ( !bIsWalking && (Level.Game != None) && (Level.Game.Difficulty > 1) && ((Weapon == None) || !Weapon.bPointing) )
    MakeNoise(0.05 * Level.Game.Difficulty);
  if ( FootRegion.Zone.bWaterZone )
  {
    PlaySound(sound 'LSplash', SLOT_Interact, 1, false, 1000.0, 1.0);
    return;
  }

  decision = FRand();
  if ( decision < 0.34 )
    step = sound'MetWalk1';
  else if (decision < 0.67 )
    step = sound'MetWalk2';
  else
    step = sound'MetWalk3';

  if ( bIsWalking )
    PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
  else
    PlaySound(step, SLOT_Interact, 1, false, 800.0, 1.0);
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
    PlayAnim('Dead2',0.7,0.1);
    return;
  }

    // check for big hit
  if ( (Velocity.Z > 250) )
  {
		if ( FRand() < 0.7 )
		{
			PlayAnim('Dead5',0.7,0.1);
			if ( Level.NetMode != NM_Client )
			{
				carc = Spawn(class 'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
				if (carc != None)
				{
					carc.Initfor(self);
					carc.RemoteRole=ROLE_SimulatedProxy;
					carc.Velocity = Velocity + VSize(Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				}
				carc = Spawn(class 'CreatureChunks');
				if (carc != None)
				{
          carc.Mesh = mesh 'CowBody1';
          carc.Initfor(self);
          carc.Velocity = Velocity + VSize(Velocity) * VRand();
          carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				}
				carc = Spawn(class 'Arm1',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
				if (carc != None)
				{
          carc.Initfor(self);
          carc.Velocity = Velocity + VSize(Velocity) * VRand();
          carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				}
      }
    return;
		}
    else{
    PlayAnim('Dead1',0.7,0.1);
		return;
		}
  }

  // check for head hit
  if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.6 * CollisionHeight))
     && !Level.Game.bVeryLowGore )
  {
    DamageType = 'Decapitated';
    PlayAnim('Dead4', 0.7, 0.1);
    if ( Level.NetMode != NM_Client )
    {
      carc = Spawn(class 'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
      if (carc != None)
      {
        carc.Initfor(self);
        carc.Velocity = Velocity + VSize(Velocity) * VRand();
        carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
      }
    }
    return;
  }

  GetAxes(Rotation,X,Y,Z);
  X.Z = 0;
  HitVec = Normal(HitLoc - Location);
  HitVec2D= HitVec;
  HitVec2D.Z = 0;
  dotp = HitVec2D dot X;

  if (Abs(dotp) > 0.71) //then hit in front or back
    PlayAnim('Dead3', 0.7, 0.1);
  else
  {
    dotp = HitVec dot Y;
    if (dotp > 0.0)
      PlayAnim('Dead6', 0.7, 0.1);
    else
      PlayAnim('Dead7', 0.7, 0.1);
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
  if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead3') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('HeadHit', tweentime);
  else
    TweenAnim('Dead3', tweentime);
}

function PlayLeftHit(float tweentime)
{
  if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead6') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('LeftHit', tweentime);
  else
    TweenAnim('Dead6', tweentime);
}

function PlayRightHit(float tweentime)
{
  if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead1') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('RightHit', tweentime);
  else
    TweenAnim('Dead1', tweentime);
}

defaultproperties
{
     Voice=Class'Botpack.VoiceMaleOne'
     drown=Sound'UnrealShare.Male.MDrown1'
     HitSound3=Sound'UnrealShare.Male.MInjur3'
     HitSound4=Sound'UnrealShare.Male.MInjur4'
     Deaths(2)=Sound'UnrealShare.Male.MDeath3'
     Deaths(3)=Sound'UnrealShare.Male.MDeath3'
     Deaths(4)=Sound'UnrealShare.Male.MDeath4'
     UWHit1=Sound'UnrealShare.Male.MUWHit1'
     UWHit2=Sound'UnrealShare.Male.MUWHit2'
     LandGrunt=Sound'UnrealShare.Male.lland01'
     JumpSound=Sound'UnrealShare.Male.MJump1'
     CarcassType=Class'UnrealShare.MaleBody'
     HitSound1=Sound'UnrealShare.Male.MInjur1'
     HitSound2=Sound'UnrealShare.Male.MInjur2'
     Die=Sound'UnrealShare.Male.MDeath1'
     MenuName="Kurgan"
     Mesh=LodMesh'UnrealI.Male1'
}