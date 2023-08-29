// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// ScriptedFemale : Class that holds various female properties.  Set the mesh and such properties to initialize it.
// ===============================================================

class ScriptedFemale expands ScriptedHuman;

function PostBeginPlay(){
  if (multiskins[0]==none)
    class'TFemale1Bot'.static.SetMultiSkin(self,"","",rand(4));
  Super.PostBeginPlay();
}
function PlayRightHit(float tweentime)
{
  if ( AnimSequence == 'RightHit' )
    TweenAnim('GutHit', tweentime);
  else
    TweenAnim('RightHit', tweentime);
}

function PlayChallenge()
{
  TweenToWaiting(0.17);
}
function PlayDying(name DamageType, vector HitLoc)
{
  local carcass carc;

  BaseEyeHeight = Default.BaseEyeHeight;
  PlayDyingSound();

  if ( DamageType == 'Suicided' )
  {
    PlayAnim('Dead3',, 0.1);
    return;
  }

  // check for head hit
  if ( (DamageType == 'Decapitated') && !Level.Game.bVeryLowGore )
  {
    PlayDecap();
    return;
  }

  // check for big hit
  if ( (Velocity.Z > 280) && (FRand() < 0.75) )
  {
    if ( (HitLoc.Z < Location.Z) && !Level.Game.bVeryLowGore && (FRand() < 0.6) )
    {
      PlayAnim('Dead5',,0.05);
      if ( Level.NetMode != NM_Client )
      {
        carc = Spawn(class 'UT_FemaleFoot',,, Location - CollisionHeight * vect(0,0,0.5));
        if (carc != None)
        {
          carc.Initfor(self);
          carc.Velocity = Velocity + VSize(Velocity) * VRand();
          carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
          carc.remoterole=role_simulatedproxy;
        }
      }
    }
    else
      PlayAnim('Dead2',, 0.1);
    return;
  }

  // check for repeater death
  if ( (Health > -50) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
  {
    PlayAnim('Dead9',, 0.1);
    return;
  }

	if ( FRand() < 0.15 )
  {
    PlayAnim('Dead7',,0.1);
    return;
  }

  if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !Level.Game.bVeryLowGore )
  {
    if ( FRand() < 0.5 )
      PlayDecap();
    else
      PlayAnim('Dead3',, 0.1);
    return;
  }

  //then hit in front or back
  if ( FRand() < 0.5 )
    PlayAnim('Dead4',, 0.1);
  else
    PlayAnim('Dead1',, 0.1);
}

function PlayDecap()
{
  local carcass carc;

  PlayAnim('Dead6',, 0.1);
  if ( Level.NetMode != NM_Client )
  {
    carc = Spawn(class 'UT_HeadFemale',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.Initfor(self);
      carc.Velocity = Velocity + VSize(Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
    }
  }
}

defaultproperties
{
     Voice=Class'Botpack.VoiceFemaleOne'
     drown=Sound'UnrealShare.Female.mdrown2fem'
     HitSound3=Sound'Botpack.FemaleSounds.linjur4'
     HitSound4=Sound'Botpack.FemaleSounds.hinjur4'
     Deaths(0)=Sound'Botpack.FemaleSounds.death1d'
     Deaths(1)=Sound'Botpack.FemaleSounds.death2a'
     Deaths(2)=Sound'Botpack.FemaleSounds.death3c'
     Deaths(3)=Sound'Botpack.FemaleSounds.decap01'
     Deaths(4)=Sound'Botpack.FemaleSounds.death41'
     Deaths(5)=Sound'Botpack.FemaleSounds.death42'
     UWHit1=Sound'Botpack.FemaleSounds.UWhit01'
     UWHit2=Sound'Botpack.FemaleSounds.UWhit01'
     JumpSound=Sound'Botpack.FemaleSounds.Fjump1'
     CarcassType=Class'Botpack.TFemale1Carcass'
     bIsFemale=True
     HitSound1=Sound'Botpack.FemaleSounds.linjur2'
     HitSound2=Sound'Botpack.FemaleSounds.linjur3'
     Die=Sound'Botpack.FemaleSounds.death1d'
     MenuName="Female Commando"
     Mesh=LodMesh'Botpack.FCommando'
}
