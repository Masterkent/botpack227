// ===============================================================
// XidiaMPack.ScriptedHybrid: the skaarj hybrid
// ===============================================================

class ScriptedHybrid expands ScriptedMale;

#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack

//right now.. only pit fighter imported!

var(Sounds) sound syllable1;
var(Sounds) sound syllable2;
var(Sounds) sound syllable3;
var(Sounds) sound syllable4;
var(Sounds) sound syllable5;
var(Sounds) sound syllable6;
var    float  voicePitch;

function PreBeginPlay()
{
  Super.PreBeginPlay();
  voicePitch = Default.voicePitch + 0.6 * Default.voicePitch * FRand();
}
// don't make assumptions deaths will also work as certain type of hit anim
function PlayGutHit(float tweentime)
{
  if ( AnimSequence == 'GutHit' )
  {
    if (FRand() < 0.5)
      TweenAnim('LeftHit', tweentime);
    else
      TweenAnim('RightHit', tweentime);
  }
  else
    TweenAnim('GutHit', tweentime);
}

function PlayHeadHit(float tweentime)
{
  if ( AnimSequence == 'HeadHit' )
    TweenAnim('GutHit', tweentime);
  else
    TweenAnim('HeadHit', tweentime);
}

function PlayLeftHit(float tweentime)
{
  if ( AnimSequence == 'LeftHit' )
    TweenAnim('GutHit', tweentime);
  else
    TweenAnim('LeftHit', tweentime);
}

function PlayRightHit(float tweentime)
{
  if ( AnimSequence == 'RightHit' )
    TweenAnim('GutHit', tweentime);
  else
    TweenAnim('RightHit', tweentime);
}

function PlayInAir()
{
  local float TweenTime;

  BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
  if ( AnimSequence == 'DodgeF' )
    TweenTime = 2;
  else if ( GetAnimGroup(AnimSequence) == 'Jumping' )
  {
    TweenAnim('DodgeF', 2);
    return;
  }
  else
    TweenTime = 0.7;

  if ( (Weapon == None) || (Weapon.Mass < 20) )
    TweenAnim('JumpSMFR', TweenTime);
  else
    TweenAnim('JumpLGFR', TweenTime);
}

function PlayDodge(bool bDuckLeft)
{
  bCanDuck = false;
  Velocity.Z = 200;
  if ( bDuckLeft )
    PlayAnim('RollLeft', 1.35, 0.06);
  else
    PlayAnim('RollRight', 1.35, 0.06);
}

function PlayDying(name DamageType, vector HitLoc)
{
  BaseEyeHeight = Default.BaseEyeHeight;
  PlayDyingSound();

  if ( DamageType == 'Suicided' )
  {
    PlayAnim('Dead1',, 0.1);
    return;
  }

  // check for head hit
  if ( DamageType == 'Decapitated' )
  {
    PlaySkaarjDecap();
    return;
  }

  // check for big hit
  if ( Velocity.Z > 200 )
  {
    if ( FRand() < 0.65 )
      PlayAnim('Dead4',,0.1);
    else if ( FRand() < 0.5 )
      PlayAnim('Dead2',, 0.1);
    else
      PlayAnim('Dead3',, 0.1);
    return;
  }

  // check for repeater death
  if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
  {
    PlayAnim('Dead9',, 0.1);
    return;
  }

  if ( HitLoc.Z - Location.Z > 0.7 * CollisionHeight )
  {
    if ( FRand() < 0.35  )
      PlaySkaarjDecap();
    else
      PlayAnim('Dead2',, 0.1);
    return;
  }

  if ( FRand() < 0.6 ) //then hit in front or back
    PlayAnim('Dead1',, 0.1);
  else
    PlayAnim('Dead3',, 0.1);
}

function PlaySkaarjDecap()
{
  local carcass carc;

  if ( class'GameInfo'.Default.bVeryLowGore )
  {
    PlayAnim('Dead2',, 0.1);
    return;
  }

  PlayAnim('Dead5',, 0.1);
  if ( Level.NetMode != NM_Client )
  {
    carc = Spawn(class 'CreatureChunks',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.Mesh = mesh'SkaarjHead';
      carc.Initfor(self);
      carc.Velocity = Velocity + VSize(Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
    }
  }
}
//alter pitch
function PlayVoice(int Mode, int Num, optional bool bImportant){
  local sound ToPlay;
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

  PlaySound(ToPlay, SLOT_Talk,,,,0.7);
  if (level.netmode!=nm_standalone) //replication would screw up
    return;
  CanSpeakTime=GetSoundDuration(ToPlay)+level.timeseconds;
  SpeechTimeCur=SpeechFaceTime;
  SpeechTimer(); //move mouth now
}

//skaarj:
function SkaarjSound()
{
  local float decision, inflection, pitch;
  if ( FRand() < 0.65)
  {
    inflection = 0.6 + 0.5 * FRand();
    pitch = voicePitch + 0.4 * FRand();
  }
  else
  {
    inflection = 1.3 + 0.5 * FRand();
    pitch = voicePitch + 0.8 * FRand();
  }
  decision = FRand();
  if (TeamLeader != None)
    TeamLeader.bTeamSpeaking = true;
  if (decision < 0.167)
    PlaySound(Syllable1,SLOT_Talk,inflection,,, pitch);
  else if (decision < 0.333)
    PlaySound(Syllable2,SLOT_Talk,inflection,,, pitch);
  else if (decision < 0.5)
    PlaySound(Syllable3,SLOT_Talk,inflection,,, pitch);
  else if (decision < 0.667)
    PlaySound(Syllable4,SLOT_Talk,inflection,,, pitch);
  else if (decision < 0.833)
    PlaySound(Syllable5,SLOT_Talk,inflection,,, pitch);
  else
    PlaySound(Syllable6,SLOT_Talk,inflection,,, pitch);
}

function PlayThreateningSound()
{
  if ( (FRand() < 0.6) && ((TeamLeader == None) || !TeamLeader.bTeamSpeaking) )
  {
    SkaarjSound();
    return;
  }
  Super(ScriptedPawn).PlayThreateningSound();
}

function PlayAcquisitionSound()
{
  super(ScriptedPawn).PlayAcquisitionsound();
}

function PlayFearSound()
{
  if ( TeamLeader != None && !TeamLeader.bTeamSpeaking )
  {
    SkaarjSound();
    return;
  }
  Super(ScriptedPawn).PlayFearSound();

}

defaultproperties
{
     syllable1=Sound'UnrealShare.Skaarj.syl07sk'
     syllable2=Sound'UnrealShare.Skaarj.syl09sk'
     syllable3=Sound'UnrealShare.Skaarj.syl11sk'
     syllable4=Sound'UnrealShare.Skaarj.syl12sk'
     syllable5=Sound'UnrealShare.Skaarj.syl13sk'
     syllable6=Sound'UnrealShare.Skaarj.syl15sk'
     VoicePitch=0.500000
     drown=Sound'UnrealI.Skaarj.SKPDrown1'
     Footstep1=Sound'XidiaMPack.Skaarj.SkWalk'
     Footstep2=Sound'XidiaMPack.Skaarj.SkWalk'
     Footstep3=Sound'XidiaMPack.Skaarj.SkWalk'
     HitSound3=Sound'UnrealI.Skaarj.SKPInjur3'
     HitSound4=Sound'UnrealI.Skaarj.SKPInjur4'
     Deaths(0)=Sound'UnrealI.Skaarj.SKPDeath1'
     Deaths(1)=Sound'UnrealI.Skaarj.SKPDeath2'
     Deaths(2)=Sound'UnrealI.Skaarj.SKPDeath3'
     Deaths(3)=Sound'UnrealI.Skaarj.SKPDeath3'
     Deaths(4)=Sound'UnrealI.Skaarj.SKPDeath1'
     Deaths(5)=Sound'UnrealI.Skaarj.SKPDeath3'
     UWHit1=Sound'UnrealShare.Male.MUWHit1'
     UWHit2=Sound'UnrealShare.Male.MUWHit2'
     LandGrunt=Sound'UnrealI.Skaarj.Land1SK'
     JumpSound=Sound'UnrealI.Skaarj.SKPJump1'
     ///CarcassType=Class'UnrealShare.SkaarjCarcass'
     Acquire=Sound'UnrealShare.Skaarj.chalnge1s'
     Roam=Sound'UnrealShare.Skaarj.roam11s'
     Threaten=Sound'UnrealShare.Skaarj.chalnge3s'
     AccelRate=1200.000000
     HitSound1=Sound'UnrealI.Skaarj.SKPInjur1'
     HitSound2=Sound'UnrealI.Skaarj.SKPInjur2'
     MenuName="Skaarj Hybrid"
     LODBias=4.000000
     AmbientSound=Sound'UnrealShare.Skaarj.amb1sk'
     Mesh=LodMesh'XidiaMPack.TSkM'
     DrawScale=1.300000
     MultiSkins(0)=Texture'XidiaMPack.Skins.pitf1'
     MultiSkins(1)=Texture'XidiaMPack.Skins.pitf2Baetal'
     MultiSkins(2)=Texture'XidiaMPack.Skins.pitf3'
     MultiSkins(3)=Texture'XidiaMPack.Skins.pitf4t_3'
     CollisionRadius=22.000000
     CollisionHeight=50.700001
}
