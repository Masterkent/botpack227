// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
//loopattach.  Simply allows this loop mover to attach to something.
// Also can smoke
// ============================================================

class LoopAttach expands Mover;
var(Attachment) name AttachTag;
var(Smoke) bool bSmoke; //smoke or not?
var(Smoke) float SmokeDelay;    // pause between drips
var(Smoke) float SizeVariance;    // how different each drip is
var(Smoke) float BasePuffSize;
var(Smoke) float RisingVelocity;
var(Smoke) class<effects> GenerationType;
var(Smoke) Vector OffSet[4];
var(Smoke) byte Trails; //amount of trails

replication{  //needed, I assume
  reliable if (role==Role_Authority)
    bSmoke, SmokeDelay, SizeVariance, BasePuffSize, RisingVelocity, GenerationType, Offset, Trails;
}

var float i;
var int NextKeyNum;

function BeginPlay()
{
  KeyNum = 0;
  Super.BeginPlay();
}


function DoOpen()
{
  // Move to the next keyframe.
  //
  bOpening = true;
  bDelaying = false;
  InterpolateTo( NextKeyNum, MoveTime );
  PlaySound( OpeningSound );
  AmbientSound = MoveAmbientSound;
}

state() LoopMove
{
  function Trigger( actor Other, pawn EventInstigator )
  {
    SavedTrigger = Other;
    Instigator = EventInstigator;
    SavedTrigger.BeginEvent();
    GotoState( 'LoopMove', 'Open' );
  }

  function UnTrigger( actor Other, pawn EventInstigator )
  {
    Enable( 'Trigger' );
    SavedTrigger = Other;
    Instigator = EventInstigator;
    GotoState( 'LoopMove', 'InactiveState' );
  }

  function InterpolateEnd(actor Other)
  {
  }

  function BeginState()
  {
    bOpening = false;
  }

Open:
  Disable ('Trigger');
  NextKeyNum = KeyNum + 1;
  if( NextKeyNum >= NumKeys ) NextKeyNum = 0;
  DoOpen();
  FinishInterpolation();
  FinishedOpening();

  // Loop forever
  GotoState( 'LoopMove', 'Open' );
InactiveState:
  FinishInterpolation();
  FinishedOpening();
  Stop;
}

// Immediately after mover enters gameplay.
function PostBeginPlay()
{
  local Actor Act;
  local Mover Mov;

  Super.PostBeginPlay();
  if (bSmoke&&level.netmode==nm_standalone){
    i=smokedelay;
//    bstasis=true;
//    bforcestasis=true;
  }
  if (!bsmoke||trails==0||level.netmode==NM_dedicatedserver)  //don't spawn smoke on dedicated servrs.
    disable('tick');
  // Initialize all slaves.
  if ( AttachTag != '' )
    foreach AllActors( class 'Actor', Act, AttachTag )
    {
      Mov = Mover(Act);
      if (Mov == None) {

        Act.SetBase( Self );
      }
      else if (Mov.bSlave) {

        Mov.GotoState('');
        Mov.SetBase( Self );
      }
    }
}
simulated function Tick(float delta)  //timer is already used :(
{
  local Effects d;
  local byte j;
  super.tick(delta);
  if (!bsmoke)
    return;
  i+=delta;
  if (i<Smokedelay)
  return;
/*  if (nosmoke&&i<1)
  return;
  if (nosmoke&&playercanseeme())   //player can see me checks.
  nosmoke=false;
//  else if (!playercanseeme())
 // nosmoke=true;
  i=0;
  if (nosmoke)
  return;       */
  i=0;
  for (j=0;j<Trails;j++){
    d = Spawn(GenerationType,,,location+(Offset[j]>>rotation));
    d.DrawScale = BasePuffSize+FRand()*SizeVariance;
    if (SpriteSmokePuff(d)!=None)
      SpriteSmokePuff(d).RisingRate = RisingVelocity;
    if (UT_SpriteSmokePuff(D)!=none)
      UT_SpriteSmokePuff(d).RisingRate = RisingVelocity;
    d.remoterole=role_none; //client side spawned.
  }
}

defaultproperties
{
     SmokeDelay=0.050000
     SizeVariance=2.000000
     BasePuffSize=2.000000
     RisingVelocity=300.000000
     GenerationType=Class'Botpack.UT_SpriteSmokePuff'
     Trails=1
}
