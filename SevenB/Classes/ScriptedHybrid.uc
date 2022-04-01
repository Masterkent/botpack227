// ===============================================================
// XidiaMPack.ScriptedHybrid: the skaarj hybrid
// ===============================================================

class ScriptedHybrid expands ScriptedMale;
/*
#exec AUDIO IMPORT FILE="Sounds\SkWalk2.wav" NAME="SkWalk" GROUP="Skaarj"
#exec MESH IMPORT MESH=TSkM ANIVFILE=models\TSkM_a.3D DATAFILE=MODELS\TSkM_d.3D LODPARAMS=8
#exec MESH ORIGIN MESH=TSkM X=100 Y=0 Z=-72

#exec MESH SEQUENCE MESH=TSkM SEQ=All       STARTFRAME=14 NUMFRAMES=505
#exec MESH SEQUENCE MESH=TSkM SEQ=AIMDNLG   STARTFRAME=0  NUMFRAMES=1      GROUP=WAITING
#exec MESH SEQUENCE MESH=TSkM SEQ=AIMDNSM   STARTFRAME=1  NUMFRAMES=1      GROUP=WAITING
#exec MESH SEQUENCE MESH=TSkM SEQ=AIMUPLG   STARTFRAME=2  NUMFRAMES=1      GROUP=WAITING
#exec MESH SEQUENCE MESH=TSkM SEQ=AIMUPSM   STARTFRAME=3  NUMFRAMES=1      GROUP=WAITING
#exec MESH SEQUENCE MESH=TSkM SEQ=BACKRUN   STARTFRAME=4  NUMFRAMES=10  RATE=17  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=BREATH1   STARTFRAME=14 NUMFRAMES=19  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=BREATH3   STARTFRAME=14 NUMFRAMES=19  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=BREATH1L  STARTFRAME=14 NUMFRAMES=19  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=CHAT1     STARTFRAME=33 NUMFRAMES=18  RATE=10  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=DEAD1     STARTFRAME=51 NUMFRAMES=21  RATE=10
#exec MESH SEQUENCE MESH=TSkM SEQ=DEAD2     STARTFRAME=72 NUMFRAMES=14  RATE=10
#exec MESH SEQUENCE MESH=TSkM SEQ=DEAD3     STARTFRAME=86 NUMFRAMES=14  RATE=10
#exec MESH SEQUENCE MESH=TSkM SEQ=DEAD4     STARTFRAME=100 NUMFRAMES=12  RATE=10
#exec MESH SEQUENCE MESH=TSkM SEQ=DEAD5     STARTFRAME=112 NUMFRAMES=17  RATE=10
#exec MESH SEQUENCE MESH=TSkM SEQ=DEAD9     STARTFRAME=129 NUMFRAMES=12  RATE=10
#exec MESH SEQUENCE MESH=TSkM SEQ=DEAD9B    STARTFRAME=141 NUMFRAMES=17  RATE=20
#exec MESH SEQUENCE MESH=TSkM SEQ=DODGEB    STARTFRAME=158 NUMFRAMES=1      GROUP=JUMPING
#exec MESH SEQUENCE MESH=TSkM SEQ=DODGEF    STARTFRAME=159 NUMFRAMES=1      GROUP=JUMPING
#exec MESH SEQUENCE MESH=TSkM SEQ=DODGER    STARTFRAME=160 NUMFRAMES=1      GROUP=JUMPING
#exec MESH SEQUENCE MESH=TSkM SEQ=DODGEL    STARTFRAME=161 NUMFRAMES=1      GROUP=JUMPING
#exec MESH SEQUENCE MESH=TSkM SEQ=GUTHIT    STARTFRAME=162 NUMFRAMES=1      GROUP=TAKEHIT
#exec MESH SEQUENCE MESH=TSkM SEQ=HEADHIT   STARTFRAME=163 NUMFRAMES=1      GROUP=TAKEHIT
#exec MESH SEQUENCE MESH=TSkM SEQ=JUMPLGFR  STARTFRAME=164 NUMFRAMES=1      GROUP=JUMPING
#exec MESH SEQUENCE MESH=TSkM SEQ=JUMPSMFR  STARTFRAME=165 NUMFRAMES=1      GROUP=JUMPING
#exec MESH SEQUENCE MESH=TSkM SEQ=LANDLGFR  STARTFRAME=166 NUMFRAMES=1      GROUP=LANDING
#exec MESH SEQUENCE MESH=TSkM SEQ=LANDSMFR  STARTFRAME=167 NUMFRAMES=1      GROUP=LANDING
#exec MESH SEQUENCE MESH=TSkM SEQ=RIGHTHIT   STARTFRAME=168 NUMFRAMES=1      GROUP=TAKEHIT
#exec MESH SEQUENCE MESH=TSkM SEQ=LOOK      STARTFRAME=169 NUMFRAMES=40  RATE=15 Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=LEFTHIT  STARTFRAME=209 NUMFRAMES=1      GROUP=TAKEHIT
#exec MESH SEQUENCE MESH=TSkM SEQ=RUNLG     STARTFRAME=210 NUMFRAMES=10  RATE=17  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=RUNLGFR   STARTFRAME=220 NUMFRAMES=10  RATE=17  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=STILLFRRP STARTFRAME=230 NUMFRAMES=8  RATE=20  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=STILLLGFR STARTFRAME=238 NUMFRAMES=15  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=STILLSMFR STARTFRAME=253 NUMFRAMES=8  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=FIGHTER   STARTFRAME=238 NUMFRAMES=1      GROUP=WAITING
#exec MESH SEQUENCE MESH=TSkM SEQ=STRAFEL   STARTFRAME=261 NUMFRAMES=10  RATE=17  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=STRAFER   STARTFRAME=271 NUMFRAMES=10  RATE=17  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=SWIMLG    STARTFRAME=281 NUMFRAMES=15  RATE=15  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=SWIMSM    STARTFRAME=281 NUMFRAMES=15  RATE=15  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=THRUST    STARTFRAME=296 NUMFRAMES=30  RATE=15  GROUP=GESTURE
#exec MESH SEQUENCE MESH=TSkM SEQ=TAUNT1    STARTFRAME=296 NUMFRAMES=30  RATE=15  GROUP=GESTURE
#exec MESH SEQUENCE MESH=TSkM SEQ=TREADLG   STARTFRAME=326 NUMFRAMES=15  RATE=15  GROUP=WAITING
#exec MESH SEQUENCE MESH=TSkM SEQ=TREADSM   STARTFRAME=326 NUMFRAMES=15  RATE=15  GROUP=WAITING
#exec MESH SEQUENCE MESH=TSkM SEQ=WALKLG    STARTFRAME=341 NUMFRAMES=14  RATE=18  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=WALKLGFR  STARTFRAME=355 NUMFRAMES=14  RATE=18  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=WALK      STARTFRAME=341 NUMFRAMES=14  RATE=18  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=WALKSM    STARTFRAME=341 NUMFRAMES=14  RATE=18  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=WALKSMFR  STARTFRAME=355 NUMFRAMES=14  RATE=18  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=TURNLG    STARTFRAME=355 NUMFRAMES=3  RATE=17
#exec MESH SEQUENCE MESH=TSkM SEQ=TURNSM    STARTFRAME=355 NUMFRAMES=3  RATE=17
#exec MESH SEQUENCE MESH=TSkM SEQ=BREATH2   STARTFRAME=369 NUMFRAMES=9  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=BREATH2L  STARTFRAME=369 NUMFRAMES=9  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=COCKGUN   STARTFRAME=378 NUMFRAMES=22  RATE=12  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=COCKGUNL  STARTFRAME=378 NUMFRAMES=22  RATE=12  Group=Waiting
#exec MESH SEQUENCE MESH=TSkM SEQ=DUCK     STARTFRAME=400 NUMFRAMES=19 RATE=12 Group=Ducking
#exec MESH SEQUENCE MESH=TSkM SEQ=VICTORY1  STARTFRAME=452 NUMFRAMES=19 RATE=12  GROUP=GESTURE
#exec MESH SEQUENCE MESH=TSkM SEQ=WAVE     STARTFRAME=471 NUMFRAMES=15 RATE=15  GROUP=GESTURE
#exec MESH SEQUENCE MESH=TSkM SEQ=DuckWlkL  STARTFRAME=419  NUMFRAMES=13 RATE=15  Group=Ducking
#exec MESH SEQUENCE MESH=TSkM SEQ=DuckWlkS  STARTFRAME=419  NUMFRAMES=13 RATE=15  Group=Ducking
#exec MESH SEQUENCE MESH=TSkM SEQ=FLIP      STARTFRAME=486 NUMFRAMES=11  RATE=15  GROUP=JUMPING
#exec MESH SEQUENCE MESH=TSkM SEQ=RUNSM     STARTFRAME=432 NUMFRAMES=10  RATE=17  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=RUNSMFR   STARTFRAME=442 NUMFRAMES=10  RATE=17  GROUP=MOVINGFIRE
#exec MESH SEQUENCE MESH=TSkM SEQ=ROLLRIGHT STARTFRAME=497 NUMFRAMES=11 RATE=20 GROUP=DODGE
#exec MESH SEQUENCE MESH=TSkM SEQ=ROLLLEFT  STARTFRAME=508 NUMFRAMES=11 RATE=20 GROUP=DODGE

#exec MESH SEQUENCE MESH=TSkM SEQ=DeathEnd     STARTFRAME=69  NUMFRAMES=1
#exec MESH SEQUENCE MESH=TSkM SEQ=DeathEnd2    STARTFRAME=83  NUMFRAMES=1
#exec MESH SEQUENCE MESH=TSkM SEQ=DeathEnd3    STARTFRAME=97  NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=TSkM MESH=TSkM
#exec MESHMAP SCALE MESHMAP=TSkM X=0.065 Y=0.065 Z=0.117

#exec MESH NOTIFY MESH=TSkM SEQ=Dead1  TIME=0.6 FUNCTION=LandThump
#exec MESH NOTIFY MESH=TSkM SEQ=Dead2 TIME=0.55 FUNCTION=LandThump
#exec MESH NOTIFY MESH=TSkM SEQ=Dead3 TIME=0.35 FUNCTION=LandThump
#exec MESH NOTIFY MESH=TSkM SEQ=Dead4 TIME=0.58 FUNCTION=LandThump
#exec MESH NOTIFY MESH=TSkM SEQ=Dead5 TIME=0.65  FUNCTION=LandThump
#exec MESH NOTIFY MESH=TSkM SEQ=Dead9B TIME=0.7  FUNCTION=LandThump
#exec MESH NOTIFY MESH=TSkM SEQ=Walk TIME=0.3 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=Walk TIME=0.8 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=WalkSm  TIME=0.3 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=WalkSm  TIME=0.8 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=WalkLg  TIME=0.3 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=WalkLg  TIME=0.8 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=WalkLgFr TIME=0.3 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=WalkLgFr TIME=0.8 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=WalkSmFr TIME=0.3 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=WalkSmFr TIME=0.8 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=RunLg TIME=0.25 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=RunLg TIME=0.75 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=RunSm TIME=0.25 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=RunSm TIME=0.75 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=RunLgFr TIME=0.25 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=RunLgFr TIME=0.75 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=RunSmFr TIME=0.25 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=RunSmFr TIME=0.75 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=BackRun TIME=0.25 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=BackRun TIME=0.75 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=StrafeL TIME=0.25 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=StrafeL TIME=0.75 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=StrafeR TIME=0.25 FUNCTION=playfootstep
#exec MESH NOTIFY MESH=TSkM SEQ=StrafeR TIME=0.75 FUNCTION=playfootstep

//right now.. only pit fighter imported!
#exec TEXTURE IMPORT NAME=pitf1 FILE=Models\pitf1.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=pitf3 FILE=Models\pitf3.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=pitf4t_3 FILE=Models\pitf4t_3.PCX GROUP=Skins
#exec TEXTURE IMPORT NAME=pitf2Baetal FILE=Models\pitf2Baetal.PCX GROUP=Skins      //face.. choose differently?
*/

#exec OBJ LOAD FILE="EpicCustomModels.u"

var(Sounds) sound syllable1;
var(Sounds) sound syllable2;
var(Sounds) sound syllable3;
var(Sounds) sound syllable4;
var(Sounds) sound syllable5;
var(Sounds) sound syllable6;
var    float  voicePitch;

function PostBeginPlay(){
  if (multiskins[0]==none)
    class'multimesh.TSkaarj'.static.SetMultiSkin(self,"","",rand(4));
  Super(ScriptedHuman).PostBeginPlay();
}
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
     Footstep1=Sound'multimesh.Skaarj.SkWalk'
     Footstep2=Sound'multimesh.Skaarj.SkWalk'
     Footstep3=Sound'multimesh.Skaarj.SkWalk'
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
     CarcassType=Class'UnrealShare.SkaarjCarcass'
     Acquire=Sound'UnrealShare.Skaarj.chalnge1s'
     Roam=Sound'UnrealShare.Skaarj.roam11s'
     Threaten=Sound'UnrealShare.Skaarj.chalnge3s'
     AccelRate=1200.000000
     HitSound1=Sound'UnrealI.Skaarj.SKPInjur1'
     HitSound2=Sound'UnrealI.Skaarj.SKPInjur2'
     MenuName="Skaarj Hybrid"
     LODBias=4.000000
     AmbientSound=Sound'UnrealShare.Skaarj.amb1sk'
     Mesh=LodMesh'EpicCustomModels.TSkM'
     DrawScale=1.300000
     CollisionRadius=22.000000
     CollisionHeight=50.700001
}
