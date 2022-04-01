// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// Follower : The base class of all "friendly" creatures that follow the player around.  Important vars/AI here!
// was originally ripped from the guard tut, but mostly rewritten for much better support
// Follow AI v 3.20 Latest update: Fearspot support
// ============================================================

class Follower expands ScriptedPawn
  abstract;

//run-time vars:
var PlayerPawn pa;  //guy I follow
var playerreplicationinfo PaPRI; //PRI of controller (replication)
var actor temp;     // used in seeplayer() in 'bumpedinto' and 'following' states
var bool bumped;  // used in 'bumpedinto' and 'following' states
//var vector MyPos; // used in bump() in 'bumpedinto' and 'following' states
var vector calc;
var byte movemode;  //tracker of type of movement.  0=waiting 1=walking 2=running
var float myranddist; // a random distance from player for both running and walking.  To make movement work better..
var bool moverdone; //mover AI
var float ticker;   //timer for attack checks.
//var bool btriedjump, bNoJump;

//mapper config vars:
var () bool CanAnger; //can follower be pissed when you shoot it?
var () bool bShouldWait; //wait/follow AI   can be initialized
var () bool bCoward; //doesn't fight. REverts to standard friendly AI (nothing, alarm point, whatever)
var () bool bCheckFriendlyFire; //check for friendly fire before firing? Will abort fire if pal is in the way :)
var () name GreetAnim;  //animation on greet.
var () bool OnlyAttackWhenControlled; //only attack when controlled by player.  Note: they are no longer coward if this is true (just won't follow player)
var () string MyName;  //the actual name of pawn. if "", then is set to menuname. Go Figure.
var name LandAnim;
//for footsteps (note that generally reads from the tvshadow!)
var(Sounds) sound FootStep1;
//replication
replication{
  reliable if (role==role_authority)
    PaPRI, MyName, bCoward;    //HUD info . MyName is replicated due to respawning.
}


//////////////follower relations/other special processing /////////////////////

function bool IsValidTarget(pawn apawn){ //return true if p can become enemy.   override to be friendly to other classes.
  return (apawn.health>0&&(apawn.attitudetoplayer<attitude_friendly)&&(apawn.isa('TeamCannon')||(apawn.IsA('scriptedpawn')&&
    (!Apawn.Isa('follower')||!Follower(Apawn).IsFriend())&&!Apawn.Isa('cow')&&!Apawn.IsA('Nali'))));
}
simulated function bool IsFriend(){ //return true if I am good, false if bad
  return (Enemy==none||!Enemy.bisplayer||AttitudeTo(Enemy)>Attitude_Ignore); //false if fighting a player.
}
//Classes can overload to disallow traveling or handle other options.. Gameinfo sets follower number!
function bool DoTravel(tvplayer Traveler, int ArrayNum){  //returns sucess.
 if (pa==none||!Isfriend())
    return false;
  Traveler.Friendlies[ArrayNum]=health*10;
//  Traveler.FriendlySpeeds[ArrayNum]=groundspeed;
//  Traveler.FriendlyMaxStepHeights[ArrayNum]=maxstepheight;
  Traveler.FriendlyDrawScales[ArrayNum]=drawscale;
  Traveler.FriendlyFatness[ArrayNum]=fatness;
  Traveler.friendlynames[ArrayNum]=Myname;
  return true;
}
//check if on a vector nav point thing:     (50 z allowed off..)
final function bool IsAtPoint (vector testvector){
  return  ((Abs(Location.Y - testvector.Y) < CollisionRadius) //Y
  && (Abs(Location.X - testvector.X) < CollisionRadius) //X
  && (testvector.z - 50 < Location.Z + MaxStepHeight));  //z check (must allow a lot)
}
//saves CPU power:
final function float VsizeSquared(vector A){
  return A dot A;
}
//attitude. Can overload in subclass...
function eAttitude AttitudeToCreature(Pawn Other)
{
  if ((Other.Isa('follower')&&Follower(Other).IsFriend())||Other.IsA('nali'))
    return ATTITUDE_Friendly;
  else if (other.isa('scriptedpawn')&&!other.isa('cow'))  //simply ignores bad mercs.  though will hate if they attack him!
   return ATTITUDE_Hate;
  else
   return ATTITUDE_Ignore;
}
//setup PA (with lists)
final function bool SetPa(actor newpa){
  if (newpa==pa)
    return true;
  if (tvplayer(pa) != none)
    tvplayer(pa).RemoveFromFollowerList(self);
  pa = none;
  PaPRI=none;
  if (PlayerPawn(newpa) != none && (tvplayer(newpa) == none || tvplayer(newpa).AddToFollowerList(self))){
    pa = PlayerPawn(newpa);
    PaPRI = pa.playerreplicationinfo;
  }
  if (pa==newpa)
    return true;
}
simulated function Destroyed(){
  Super.Destroyed();
  if (pa!=none)
    SetPa(none);
}
final function bool IsInPainZone(actor other){ //return true if other is in pain zone.
    if (Other.Region.Zone.bPainZone)
      return true;
    if (Other.Isa('pawn'))
      return (pawn(Other).HeadRegion.Zone.bPainZone||pawn(Other).FootRegion.Zone.bPainZone);
}
function Killed(pawn Killer, pawn Other, name damageType)
{
  Super.Killed(Killer,Other,damagetype);
    if (Other==self)
      SetPA(none);
}

simulated event PreBeginPlay() //follower skill adjust.  designed so that he sux more at heigher dif. levels.
{
  super.prebeginplay();
  if (MyName=="")  //name stuff.
    MyName=MenuName;
  MenuName=MyName;
  if (menuname!=default.menuname)
    NameArticle=" ";
  if (level.game==none) //on clients
    return;
  if (IsFriend()){
    skill+=-2*level.game.difficulty+3;  //skill-dif+(3-dif)
    skill=fclamp(skill,0,3);
  }
  projectilespeed*=1+0.1*skill; //mult
}
/*   //Caused GPF's...
final function Sound GetTexSound(){ //return shadow sound
//  return none; //GPFs did result. this fix?
  if (TvPawnShadow(Shadow)!=none&&TvPawnShadow(Shadow).NumSounds!=0)
    return TvPawnShadow(Shadow).CurFootSound[rand(TVPawnshadow(shadow).NumSounds)];
}
*/
//sounds:
simulated function Step()
{
//  local sound ToPlay;
  if (level.netmode==nm_dedicatedserver)
    return;
//  ToPlay=GetTexSound();
//  if (ToPlay!=none)
//    PlaySound(ToPlay, SLOT_Interact,2.2,,,1500);
  //-if (TvPawnShadow(Shadow)!=none&&TvPawnShadow(Shadow).NumSounds!=0)
  //-   PlaySound(TvPawnShadow(Shadow).CurFootSound[rand(TVPawnshadow(shadow).NumSounds)], SLOT_Interact,2.2,,1500);
  //-else
    PlaySound(footstep1, SLOT_Interact,,,1500);
}

simulated function WalkStep()
{
//  local sound ToPlay;
  if (level.netmode==nm_dedicatedserver)
    return;
//  ToPlay=GetTexSound();
//  if (ToPlay!=none)
//    PlaySound(ToPlay, SLOT_Interact,0.7,,500);
  //-if (TvPawnShadow(Shadow)!=none&&TvPawnShadow(Shadow).NumSounds!=0)
  //-   PlaySound(TvPawnShadow(Shadow).CurFootSound[rand(TVPawnshadow(shadow).NumSounds)], SLOT_Interact,0.7,,500);
  //-else
    PlaySound(footstep1, SLOT_Interact,0.2,,500);
}

/////////////////////////////  AI /////////////////////////////////////////////////

function UnderLift(Mover M)    //shamelessly ripped from bot....
{
  local NavigationPoint N;

  // find nearest lift exit and go for that
  if ( (MoveTarget != None) && MoveTarget.IsA('LiftCenter') )
    for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
      if ( N.IsA('LiftExit') && (LiftExit(N).LiftTag == M.Tag)
        && ActorReachable(N) )
      {
        MoveTarget = N;
        return;
      }
}
//respond to noises (get attention that way :P)
function HearNoise(float Loudness, Actor NoiseMaker)
{
  if (!Noisemaker.instigator.bisplayer||bcoward||!LineofsightTo(Noisemaker.instigator)){
    Super.HearNoise(Loudness,NoiseMaker);
    return;
  }
  if (IsInState('Greeting'))
    return;
  temp=none;
  SeePlayer(NoiseMaker.Instigator);
  if (temp==none)
    Super.HearNoise(Loudness,Noisemaker);
}

function SeePlayer(actor SeenPlayer){
  local name mystate;
  if (bCoward || !SeenPlayer.IsA('PlayerPawn')){ //act like a nali.
    Super.SeePlayer(Seenplayer);
    return;
  }
  mystate=getstatename();
  if (mystate=='victorydance'||mystate=='fallingstate'||mystate=='hunting'||mystate=='stakeout')
    return; //or else some error of some kind.
  LastSeenPos = SeenPlayer.Location;
  temp = SeenPlayer; //stuff
 // BroadCastMessage(self@"Saw player:"@SeenPlayer@" /Current State:"@GetStateName()); //temp!
  gotostate('greeting');  // This sends us into our custom states
}

function damageAttitudeTo(pawn Other)       //slight override for can anger bool
{
  if ( (Other == Self) || (Other == None) || (FlockPawn(Other) != None) || (other.bisplayer&&!cananger))
    return;
  super.damageattitudeto(other);
}
function PlayGreetAnim(){ //anim and sound on greet.
  PlayAnim(greetanim, 0.4 + 0.6 * FRand(), 0.5);
}
function PreGreeting(){ //called before greeting
  SetMovementPhysics();
  MakeNoise(1.0);
  acceleration=vect(0,0,0);   //no move
  velocity=vect(0,0,0);
}
state Greeting
{
  ignores EnemyNotVisible, AnimEnd, SeePlayer;

  function Bump(actor Other)
  {
    if (pawn(other)!=none&&pawn(other).bisplayer)
      return;
    super.bump(other);
  }

  Begin:
  //weapon support:
  if (temp==none)
    temp=pa;
  PreGreeting();
  if (temp==none){
    Log("temp is none! Doing roam!",'ONP');
    StartRoaming(); //wierd/
  }
  if (NeedToTurn(temp.Location))
  {
    PlayTurning();
    TurnTo(temp.location);
  }
  //  PlayAnim('Talk1', 0.4 + 0.6 * FRand(), 0.5);
  PlayGreetAnim();
  //log(class$ " greeting");
  finishanim();

  Redo:          //keep retesting until can add.
  if ((pa!=none&&pa.health>0)||SetPa(Temp)){ //good
      temp=none;
    if (bshouldwait)
      GotoState('Waiting');
    else
      Gotostate('following');
  }
  if (!IsAnimating())
    PlayWaiting();
  sleep(0.01);
  Goto('Redo');
}
function Bump(actor Other)   //quick over-ride...
{
local vector VelDir, OtherDir;
local float speed;
if (pawn(other)!=none&&pawn(other).bisplayer)
  return;
if (pawn(other)!=none&&attitudeto(pawn(other))>=Attitude_Friendly){
  speed = VSize(Velocity);
  if ( speed > 1 )
  {
    VelDir = Velocity/speed;
    VelDir.Z = 0;
    OtherDir = Other.Location - Location;
    OtherDir.Z = 0;
    OtherDir = Normal(OtherDir);
    if ( (VelDir Dot OtherDir) > 0.8 )
    {
      /*if ( Pawn(Other) == None )
      {
        MoveTimer = -1.0;
        HitWall(-1 * OtherDir, Other);
      } */
      Velocity.X = VelDir.Y;
      Velocity.Y = -1 * VelDir.X;
      Velocity *= FMax(speed, 280);
    }
  }
  Disable('Bump');
}
else
  super.bump(other);
}
//possibly better?
function WhatToDoNext(name LikelyState, name LikelyLabel)
{
  local Pawn aPawn;

  if (enemy==none||enemy.health<=0){
    for (aPawn = Level.PawnList;aPawn != None;aPawn = aPawn.nextPawn)
      if (aPawn !=self&&IsValidTarget(apawn)&&(cansee(aPawn)))
      {
        if ( SetEnemy(aPawn) )
        {
          GotoState('Attacking');
          return;
        }
      }
    //found no enemies... check follower stuff:
    if (!IsInState('Greeting')&&!ISInState('following')&&!IsInState('Waiting')&&pa!=none&&(OldEnemy==none||Oldenemy.health<=0)){
      GotoState('Greeting');
      return;
    }
  }
  Super.WhatToDoNext(LikelyState, LikelyLabel);
}

function NotifyNewEnemy(scriptedpawn NewEnemy){ //tell an enemy that I am targetting him!  (as seeplayer only supports bisplayer pawns)
  if (NewEnemy.cansee(self)){ //hack
    if (NewEnemy.AttitudeTo(self) == ATTITUDE_Ignore && NewEnemy.Hated==none)
      NewEnemy.Hated=self;            //to return attitude_hate.
    NewEnemy.SeePlayer(self);
  }
}
function tick(float deltatime){ //enemy checks
  local pawn apawn;
  if (!IsFriend()||(bcoward&&OnlyAttackWhenControlled)||(physics==Phys_Falling)||IsInState('fallingstate'))
    return;
  ticker+=deltatime;
  if (ticker<0.2||(enemy!=none&&enemy.health>0&&attitudeto(enemy)<Attitude_Ignore)||(pa==none&&OnlyAttackWhenControlled))
    return;
  ticker=0;
  hated=none; //reset.
  for (aPawn=level.pawnlist;apawn!=none;apawn=apawn.nextpawn)
  {
    if (apawn!=self&&IsValidTarget(apawn)&&(hated==none||!apawn.bisfemale)&&cansee(aPawn))     {
      Hated = aPawn;   //valid target
      if (apawn.target==pa&&!apawn.bisfemale){ //if he is fighting player & no other follower is attacking
        apawn.bisfemale=true;
        SetEnemy(aPawn);
        gotostate('attacking');  // ATTACK!
        NotifyNewEnemy(scriptedpawn(apawn));
        ticker=0.01;
        return;
      }
     }
  }
  if (hated!=none) { //best target.
      hated.bisfemale=true;
      SetEnemy(hated);
      gotostate('attacking');
      NotifyNewEnemy(scriptedpawn(hated));
      ticker=0.01;
      return;
  }
}
function DoRoam(){ //allow roaming here.
    Global.StartRoaming();
}
//following is a rip from tutorial 44 on chimeric: bodyguard   HIGHLY EDITED!
state following
{
  ignores EnemyNotVisible;
  function startroaming(); //force no roam
  function SeePlayer(actor SeenPlayer){ // Now we use SeePlayer() to keep track of the player's location.
    if (pa==none)
      SetPa(SeenPlayer);                      // Global store our player
    LastSeenPos = SeenPlayer.Location;    // Update the last known position of the player
  }
  function EnemyAcquired() //for hearing noises.....
  {
    GotoState('Acquisition');
  }
  function HitWall(vector HitNormal, actor Wall){    //used to try to jump
    //-local vector jumpdiry;
    if (Physics == PHYS_Falling)
      return;
    if (bumped){
      bumped=false;
      enable('tick');
      gotostate('following','moving');
    }
    if (findbestpathtoward(pa))
      return;
    /*
    if (!btriedjump&&!actorreachable(pa)&&checkwaterjump(jumpdiry)){
      Mypos=location;
      gotostate('following','jump');
      Velocity = jumpDiry * -0.1*groundSpeed;
      Acceleration = jumpDiry * -0.1*AccelRate;
      velocity.Z = Jumpz; //set here so physics uses this for remainder of tick
      Playinair();
    }  */
    else  {
      if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
      {
        bSpecialGoal = true;
        if ( SpecialPause > 0 )
          GotoState('following', 'movewait');
        return;
      }
      Focus = Destination;
      if (PickWallAdjust())
        GotoState('following', 'AdjustFromWall');
      else
        MoveTimer = -1.0;
    }
    //bUpAndOut = true;
    //WaitForLanding();
  }
  function Bump(actor Other)  // We can use our own version of Bump() to
                              // steer our bodyguard into another custom state
  {
/*  MyPos = Location;         // Global Where am I?
    if (bumped){
      bumped=false;
      enable('tick');
      gotostate('following','moving');
    }
    if (pa!=none&&lineofsightto(pa)){
      bumpinto(other);
      return;
    }     */
    // if (other.isa('pawn')&&!pawn(other).bisplayer)           //melee if pawn bump (checks stuff of course..)
    bumpinto(other);
     // else
      //gotostate('bumpedinto');     //level or decoration
  }
  function Bumpinto(actor Other){

    local vector VelDir, OtherDir;
    local float speed;

    if (Pawn(Other) != None&&other!=pa&&(!other.isa('Follower')||!Follower(other).IsFriend()))
    {
      AnnoyedBy(Pawn(Other));
      if ( SetEnemy(Pawn(Other)) )
      {
        bReadyToAttack = True; //can melee right away
        PlayAcquisitionSound();
        GotoState('Attacking');
        return;
      }
    }
    if ( TimerRate <= 0 )
      setTimer(1.0, false);
    if ( bCanSpeak && (ScriptedPawn(Other) != None) && ((TeamLeader == None) || !TeamLeader.bTeamSpeaking) )
      SpeakTo(ScriptedPawn(Other));
    else if (bcanspeak && other==pa)
      speak();
    if (other==pa||(other.isa('follower')&&vsize(other.velocity)>0&&pawn(other).bisfemale)){ //back up, as boss wants me to move.
      if (!bumped&&base!=none&&((base.isa('mover')&&mover(base).mymarker!=none)
       ||(pa.base!=none&&pa.base.isa('mover')&&mover(pa.base).mymarker!=none))){ //check mover
        //speed=ticker;
        //ticker=0.45;
        // tick(speed);
        gotostate('following','Hang');
        bumped=true;
        disable('bump');
        return;
      }
      else if (base==none||!base.isa('mover')||mover(base).mymarker==none)
        bumped=false;
      // bumped=true;
      disable('bump');
      temp=pa;
      gotostate('following','backup');
      return;
    }
    speed = VSize(Velocity);
    if ( speed > 1 )
    {
      VelDir = Velocity/speed;
      VelDir.Z = 0;
      OtherDir = Other.Location - Location;
      OtherDir.Z = 0;
      OtherDir = Normal(OtherDir);
      if ( (VelDir Dot OtherDir) > 0.8 )
      {
        /*if ( Pawn(Other) == None )
        {
          MoveTimer = -1.0;
          HitWall(-1 * OtherDir, Other);
        } */
        Velocity.X = VelDir.Y;
        Velocity.Y = -1 * VelDir.X;
        Velocity *= FMax(speed, 280);
        bcanjump=false; //don't let followers push me off!
      }
    }
  }
  function stopwaiting(){ //mover AI
    if (base!=none&&base.isa('mover'))
      moverdone=true;
    global.stopwaiting();
  }

  function tick(float deltatime){  //controls movemodes.
    local bool reachable;
    local byte truemode;
    global.tick(deltatime);  //search for targets.
    //kill:
    if (enemy!=none&&AttitudeTo(enemy)<Attitude_Ignore){
      if (enemy.health<=0)
        Enemy=none;
      else{
        GotoState('Attacking');
        return;
      }
    }
    if (pa==none||pa.health<=0){
      DoRoam();
      pa=none;
      return;
    }
    SetMovementPhysics();
    if (moverdone||ticker!=0||pa==none)
      return; //processing
    Reachable=Actorreachable(pa);    //check actor reachable thing.
    if (((movemode==2)&&(vsize(pa.location-location)>myranddist))||(((pa.base!=none&&pa.base.isa('mover')&&mover(pa.base).mymarker!=none)||(base!=none&&base.isa('mover')&&mover(base).mymarker!=none))&&vsize(pa.location-location)>(collisionradius+pa.collisionradius+5))||!lineofsightto(pa))
      truemode=2;
    else if ((movemode==1)&&vsize(pa.location-location)>myranddist)
      truemode=1;
    else
      truemode=0;
    if (movemode!=truemode)
      gotostate ('following','begin');
  }
//---------------------------------------------------------------------------------
  function UnderLift(Mover M)    //throw into a state as well
  {
    local NavigationPoint N;

    // find nearest lift exit and go for that
    if ( (MoveTarget != None) && MoveTarget.IsA('LiftCenter')&&!actorreachable(pa) )
      for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
        if ( N.IsA('LiftExit') && (LiftExit(N).LiftTag == M.Tag) && ActorReachable(N) )
        {
          MoveTarget = N;
          gotostate('following','underlift');
          return;
        }
  }
  function FearThisSpot(Actor aSpot)  //send into fearing state
  {
    temp=aSpot;
    GotoState('following', 'Backup');
  }
  function endstate()
  {
    groundspeed=default.groundspeed;
    bcanjump=true;
    MaxStepHeight=25;
  }
  //don't jump into lava/slime or off walls.
  function MayFall()
  {
      if (bcanjump){
        if (MoveTarget==None)
           bCanJump=(!IsInPainZone(pa)&&pa.Physics != PHYS_Falling);
        else
          bCanJump = (MoveTarget.Physics != PHYS_Falling && !IsInPainZone(MoveTarget)
           && (MoveTarget!=Pa || (pa.location.z-pa.collisionheight<=location.z-collisionheight+maxstepheight
             || ActorReachable(pa))));
      }
      if (!bcanjump)
        GotoState('Following','Hang');
//      BroadCastMessage(self@"had MayFall() call! Bcanjump is now"@bcanjump$". MoveTarget is"@MoveTarget@"In pain zone?"@IsInPainZone(MoveTarget));
  }

  function PickDestination()   //following destination.
  {
    bcanjump=true;
    if (!Actorreachable(pa)){
      movetarget=FindPathToward(pa);
      ///if (movetarget==none&&IsAtPoint(lastseenpos))
      ///  movetarget=pa;
    }
    else        //see PA, so move toward him.
      movetarget=pa;
  }

  //LABELS FOR MOVEMENT CONTROL:
  Begin:
  enable('tick');

  Moving:
 // if (vsize(location-mypos)>30)
  //  btriedjump=false;
  groundspeed=default.groundspeed;
  SetMovementPhysics();                   // Initialize
  PickDestination(); //get movetarget.

  Movewait:   //wait for mover
  if (specialpause>0){
    disable('tick');
    Acceleration = vect(0,0,0);
    TweenToPatrolStop(0.3);
    Sleep(SpecialPause);
    SpecialPause = 0.0;
    enable('tick');
    TweenToRunning(0.1);
    goto('moving'); //see if I need to keep waiting
  }
  //hack for low step heights when moving to triggers/movers...
  if (MoveTarget!=none&&((MoveTarget.Isa('mover')||MoveTarget.IsA('trigger'))||(MoveTarget==pa&&mover(pa.base)!=none)))
    MaxStepHeight=25;
  else
    MaxStepHeight=64;
  if (location==oldlocation) //stop infinite interators?
    sleep(0.0001);
  if (moverdone){
    playwalking();
    if (vsize(location-pa.location)<=collisionradius+pa.collisionradius+10)
      moveto(location-20*normal(location-pa.location),walkingSpeed); //back up
    moverdone=false;
  }
  //if (!actorreachable(pa)) //try to jump
  //  goto('jump');
  if((movemode==2&&vsize(pa.location-location)>myranddist)||(vsize(pa.location-location)>751)||(((pa.base!=none&&pa.base.isa('mover')&&mover(pa.base).mymarker!=none)||(base!=none&&base.isa('mover')&&mover(base).mymarker!=none))&&vsize(pa.location-location)>(collisionradius+pa.collisionradius+5))||!lineofsightto(pa)) {      // This far?
    if (movemode!=2)
      myranddist=361+collisionradius+100*frand();
    movemode=2;
    goto ('run');
  }
  else if((movemode==1&&(vsize(pa.location-location)>myranddist))||(vsize(pa.location-location)>306)){  // This far?
    if (movemode!=1)
      myranddist=100+collisionradius+40*frand();
    movemode=1;
    goto('Walk');
  }
  else   {
    movemode=0;
    goto('hang');   // He's close enough
  }

  Run:                                            // Running
  groundspeed=fmax(360,default.groundspeed);
  WaitForLanding();
  playrunning();
  bumped=false;
  if (movetarget!=none&&!IsAtPoint(movetarget.location))    //set by pickdestination()
    movetoward(movetarget,groundspeed);
  else if (!IsAtPoint(lastseenpos) && pointReachable(LastSeenPos))
    moveto(lastseenpos,groundspeed);
  else{ //hmm..nothing to do.
    acceleration=vect(0,0,0);
    playwaiting();
    FinishAnim();
  }
  goto('moving');

  Walk:                                           // Walking
  WaitForLanding();
  groundspeed*=walkingspeed;
  playwalking();
  bumped=false;
  if (movetarget!=none&&!IsAtPoint(movetarget.location))    //set by pickdestination()
    movetoward(movetarget,groundspeed);
  else if (!IsAtPoint(lastseenpos) && pointReachable(LastSeenPos))
    moveto(lastseenpos,groundspeed);
  else{ //hmm..nothing to do.
    acceleration=vect(0,0,0);
    playwaiting();
    finishanim();
  }
  goto('moving');

  Hang:                                           // Hangin' out
  WaitForLanding();
  groundspeed=default.groundspeed;
  Acceleration = vect(0,0,0);
  // MoveTo(location, 0);
  if (NeedToTurn(pa.Location))
  {
    setmovementphysics();
    PlayTurning();
    TurnToward(pa);
    enable('bump');
  }
  else{
    if (Physics != PHYS_Falling)
      SetPhysics(PHYS_None);
    PlayWaiting();
    sleep(0.1);
    enable('bump');
    finishanim();
  }
  goto('moving');                        // start over

  Backup:   //backup when bumped by player.
  groundspeed=default.groundspeed;
  disable('tick');
  disable('hitwall');
  bisfemale=true; //flag to detect
  setmovementphysics();
  playrunning();
  if (temp==none)
    temp=pa;
  Acceleration = AccelRate * Normal(Location - temp.Location);
  sleep(0.2); //allow that much time.
  bisfemale=false; //flag to detect
  enable('bump');
  enable('hitwall');
  sleep(0.2);    //enable notifiers and continue moving backwards.
  enable('tick');
  goto('moving');

/*  Jump:   //try to jump
  disable('tick');
  if (animsequence!='walk'&&animsequence!='run');
    playrunning();
  btriedjump=true;
  sleep(0.1);
  velocity=normal(velocity)*-1*groundspeed;
  acceleration=normal(acceleration)*-1*accelrate;
  enable('tick');
  setfall();        */

  AdjustFromWall:   //when hit wall.
  disable('tick');
  disable('hitwall');
  StrafeTo(Destination, Focus);
  Destination = Focus;
  enable('hitwall');
  enable('tick');
  Goto('Moving');

  Underlift: //when under lift.
  groundspeed=fmax(360,default.groundspeed);
  disable('tick');
  setmovementphysics();
  playrunning();
  movetoward(movetarget,groundspeed);
  enable('tick');
  goto('moving');

  /*
  Jump:               //attempt to jump up to player.
  if ( bCanWalk && (Abs(Acceleration.X) + Abs(Acceleration.Y) > 0) && CheckWaterJump(jumpDiry) ){
    Falling();
    Velocity = jumpDiry * groundSpeed;
    Acceleration = jumpDiry * AccelRate;
    velocity.Z = 380; //set here so physics uses this for remainder of tick
    Playinair();
    bUpAndOut = true;
    //WaitForLanding();
  }
  groundspeed=default.groundspeed;
  if((movemode==2&&vsize(pa.location-location)>myranddist)||(vsize(pa.location-location)>751)||!lineofsightto(pa)) {      // This far?
    if (movemode!=2)
      myranddist=681+70*frand();
    movemode=2;
    goto ('run');
  }
  else if((movemode==1&&(vsize(pa.location-location)>myranddist))||(vsize(pa.location-location)>306)||((pa.base.isa('mover')||base.isa('mover'))&&vsize(pa.location-location)>(collisionradius+pa.collisionradius+5))){  // This far?
    if (movemode!=1)
      myranddist=266+40*frand();
    movemode=1;
    goto('Walk');
  }
  else   {
    movemode=0;
    goto('hang');
  } */
}
/// END STATE /////////

//GLOBALS:
function SetFall()   //this is needed so this creature doesn't walk in air.
{
  if (Enemy != None)
    super.setfall();
  else if (pa!=none){
    nextstate = 'following';
    nextanim = LandAnim;
    nextlabel= 'moving';
    GotoState('FallingState');
  }
}
//WAITING SYSTEM:
state Waiting
{
  function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
              Vector momentum, name damageType)
  {
    if (enemy==pa)                         //occasionally happens...
      enemy=none;
    super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

  }

  function AnimEnd() //no statis.
  {
    bstasis=(pa==none);
    if (pa!=none&& needtoturn(pa.location))
      gotostate('Waiting','PlayerTurn');
    else
      PlayWaiting();
  }

  function Landed(vector HitNormal)
  {
    SetPhysics(PHYS_None);
  }

  function BeginState()
  {
    Enemy = None;
    bStasis = false;
    Acceleration = vect(0,0,0);
    SetAlertness(0.0);
  }

  function Bump(actor Other)
  {
    if (Pawn(Other) != None&&other!=pa&&(!other.isa('Follower')||!Follower(other).IsFriend()))
    {
      if (Enemy == Other)
        bReadyToAttack = True; //can melee right away
      SetEnemy(Pawn(Other));
    }
    else if (pawn(other)!=none){
      bumpinto(other);
      return;
    }
    if ( TimerRate <= 0 )
      setTimer(1.5, false);
    Disable('Bump');
  }
  function Bumpinto(actor Other)
  {
    if ( bCanSpeak && (ScriptedPawn(Other) != None) && ((TeamLeader == None) || !TeamLeader.bTeamSpeaking) )
      SpeakTo(ScriptedPawn(Other));
    else if (bcanspeak && other==pa)
      speak();

    if (Pawn(Other) != None&&(other==pa||((other.isa('Follower')&&Follower(other).IsFriend())&&vsize(other.velocity)>0&&pawn(other).bisfemale))){ //back up, as boss wants me to move.
      // bumped=true;
      disable('bump');
      gotostate('waiting','backup');
      return;
    }
  }

  function seeplayer(actor a){ //check wait
    if (bshouldwait&&pa!=none){
      SetPa(a);
      PlayGreetAnim();
      disable('seeplayer');
    }
    else
      global.seeplayer(a);
  }

  function EndState(){
    Enable('SeePlayer');
  }

  //STATE CONTROL:
  Backup:
  groundspeed=default.groundspeed;
  setmovementphysics();
  bisfemale=true; //flag to detect
  playrunning();
  Acceleration = AccelRate * Normal(Location - pa.Location);
  disable('timer');
  sleep(0.2); //allow that much time.
  bisfemale=false; //flag to detect
  enable('bump');
  enable('timer');
  sleep(0.2);    //enable notifiers and continue moving backwards.
  goto('begin');

  OrderChange:
    Disable('seeplayer');

  TurnFromWall: //hit wall
  if ( NearWall(2 * CollisionRadius + 50) )
  {
    PlayTurning();
    TurnTo(Focus);
  }

  Begin:  //entry
  TweenToWaiting(0.4);
  bReadyToAttack = false;
  if (pa==none){
    DesiredRotation = rot(0,0,0);
    DesiredRotation.Yaw = Rotation.Yaw;
    SetRotation(DesiredRotation);
  }
  else{
    sleep(0.4);
    playwaiting();
  }
  if (Physics != PHYS_Falling)
    SetPhysics(PHYS_None);

  KeepWaiting:  //nothing special...
  NextAnim = '';

  PlayerTurn:  //to face player.
  if (pa!=none&& needtoturn(pa.location))
  {
    setmovementphysics();
    PlayTurning();
    TurnToward(pa);
    TweenToWaiting(0.4);
    if (Physics != PHYS_Falling)
      SetPhysics(PHYS_None);
  }
  enable('bump');
}
function startroaming(){ //wait if ordered.
  if (bshouldwait)
    gotostate('waiting');
  else
    super.startRoaming();
}
//auto-go-to-Pa from level travel.
auto state StartUp
{
  function SetHome(){
    Super.SetHome();
    if (pa!=none)
      GotoState('Following');
  }
}

//MISCELLANEOUS
state Threatening   //problems with palyer enemy attacking?
{
ignores falling, landed; //fixme
function Trigger( actor Other, pawn EventInstigator ){
 if (bcoward)
  Super.Trigger(other,EventInstigator);
}
}
state FallingState
{
ignores Bump, Hitwall, WarnTarget;
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
              Vector momentum, name damageType)
  {
    Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
    if ( health <= 0 )
      return;
    if (Enemy == None&&InstigatedBy!=none&&(AttitudeTo(InstigatedBy)<ATTITUDE_FRIENDLY||cananger))
    {
      SetEnemy(InstigatedBy);
    }
    if (Enemy != None)
      LastSeenPos = Enemy.Location;
    if (NextState == 'TakeHit')
    {
      if (Enemy!=none||pa==none){
        NextState = 'Attacking';
        NextLabel = 'Begin';
      }
      else if (bshouldwait){
        NextState = 'Waiting';
        NextLabel = 'Begin';
      }
      else{
        NextState = 'Following';
        NextLabel = 'Moving';
      }

      GotoState('TakeHit');
    }
  }
}

state TriggerAlarm
{
  ignores HearNoise, SeePlayer;

  function Bump(actor Other)
  {
    if ( (Pawn(Other) != None) && Pawn(Other).bIsPlayer
      && (AttitudeToPlayer == ATTITUDE_Friendly) )
      return;

    Super.Bump(Other);
  }
}
state VictoryDance
{
ignores EnemyNotVisible;
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
              Vector momentum, name damageType)
  {
    Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
    if ( health <= 0 )
      return;
    if (InstigatedBy!=self&&InstigatedBy!=none&&instigatedby.health>0&&(AttitudeTo(InstigatedBy)<ATTITUDE_FRIENDLY||cananger))
      SetEnemy(instigatedBy);
//    else
//      return;
    if ( NextState == 'TakeHit' )
    {
      NextState = 'Attacking'; //default
      NextLabel = 'Begin';
      GotoState('TakeHit');
    }
    else if (health > 0 && enemy!=none)
      GotoState('Attacking');
  }
}

//let cannons be enemies
function bool SetEnemy( Pawn NewEnemy )
{
  local bool result;
  local eAttitude newAttitude, oldAttitude;
  local bool noOldEnemy;
  local float newStrength;

  if ( (NewEnemy == Self) || (NewEnemy == None) || (NewEnemy.Health <= 0) )
    return false;
  if ( !bCanWalk && !bCanFly && !NewEnemy.FootRegion.Zone.bWaterZone )
    return false;
  if ( (!NewEnemy.bisplayer) && (ScriptedPawn(NewEnemy) == None) && (TeamCannon(newenemy) ==none))
    return false;

  noOldEnemy = (Enemy == None);
  result = false;
  newAttitude = AttitudeTo(NewEnemy);
  //log ("Attitude to potential enemy is "$newAttitude);
  if ( !noOldEnemy )
  {
    if (Enemy == NewEnemy)
      return true;
    else if ( NewEnemy.bIsPlayer && (AlarmTag != '') )
    {
      OldEnemy = Enemy;
      Enemy = NewEnemy;
      result = true;
    }
    else if ( newAttitude == ATTITUDE_Friendly )
    {
      if ( bIgnoreFriends )
        return false;
      if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) )
      {
        if ( NewEnemy.Enemy.bIsPlayer && (NewEnemy.AttitudeToPlayer < AttitudeToPlayer)&&!IsFriend())
          AttitudeToPlayer = NewEnemy.AttitudeToPlayer;
        if ( AttitudeTo(NewEnemy.Enemy) < AttitudeTo(Enemy))
        {
          OldEnemy = Enemy;
          Enemy = NewEnemy.Enemy;
          result = true;
        }
      }
    }
    else
    {
      oldAttitude = AttitudeTo(Enemy);
      if ( (newAttitude < oldAttitude) ||
        ( (newAttitude == oldAttitude)
          && ((VSize(NewEnemy.Location - Location) < VSize(Enemy.Location - Location))
            || !LineOfSightTo(Enemy)) ) )
      {
        if ( bIsPlayer && Enemy.IsA('PlayerPawn') && !NewEnemy.IsA('PlayerPawn') )
        {
          newStrength = relativeStrength(NewEnemy);
          if ( (newStrength < 0.2) && (relativeStrength(Enemy) < FMin(0, newStrength))
            && (IsInState('Hunting')) && (Level.TimeSeconds - HuntStartTime < 5) )
            result = false;
          else
          {
            result = true;
            OldEnemy = Enemy;
            Enemy = NewEnemy;
          }
        }
        else
        {
          result = true;
          OldEnemy = Enemy;
          Enemy = NewEnemy;
        }
      }
    }
  }
  else if ( newAttitude < ATTITUDE_Ignore )
  {
    result = true;
    Enemy = NewEnemy;
  }
  else if ( newAttitude == ATTITUDE_Friendly ) //your enemy is my enemy
  {
    //this part=fux0red
    if ( NewEnemy.bIsPlayer && (AlarmTag != ''))
    {
      Enemy = NewEnemy;
      result = true;
    }
    if (bIgnoreFriends)
      return false;

    if ( (NewEnemy.Enemy != None) && (NewEnemy.Enemy.Health > 0) && AttitudeTO(NewEnemy.Enemy)<ATTITUDE_Friendly)
    {
      if (NewEnemy.Enemy.bisplayer&&IsFriend())
        return false;
      result = true;
      //log("his enemy is my enemy");
      Enemy = NewEnemy.Enemy;
      if (Enemy.bIsPlayer)
        AttitudeToPlayer = ScriptedPawn(NewEnemy).AttitudeToPlayer;
      else if ( (ScriptedPawn(NewEnemy) != None) && (ScriptedPawn(NewEnemy).Hated == Enemy) )
        Hated = Enemy;
    }
  }

  if ( result )
  {
    //log(class$" has new enemy - "$enemy.class);
    LastSeenPos = Enemy.Location;
    LastSeeingPos = Location;
    EnemyAcquired();
    if ( !bFirstHatePlayer && Enemy.bIsPlayer && (FirstHatePlayerEvent != '') )
      TriggerFirstHate();
  }
  else if ( NewEnemy.bIsPlayer && (NewAttitude < ATTITUDE_Threaten) )
    OldEnemy = NewEnemy;

  return result;
}
simulated function postnetbeginplay(){ //better prediction
  super.postnetbeginplay();
  bisplayer=true;
}
//Friendly Fire Stuff/
//Determine if projectile would probably hit player.
function bool FireBad(optional vector firerot, optional vector ProjStart){
  local vector X,Y,Z, ploc;
  GetAxes(Rotation,X,Y,Z);
  if (ProjStart==vect(0,0,0))
    projStart = Location + 0.9 * CollisionRadius * X
          -0.4 * CollisionRadius * Y;
  if (pa==none)
    return false;
  if (firerot==vect(0,0,0))    //approximate?
    firerot=vector(viewrotation);
  ploc=pa.Location + pa.Velocity* vsize(pa.Location-projstart) / ProjectileSpeed;
  if (bCheckFriendlyFire&&vsize(ploc-projstart)<projectilespeed-1&&
  fasttrace(ploc,projstart)&&(ploc-projstart) dot firerot <(0.3/projectilespeed)*vsize(ploc-projstart)+0.7)
     return true;
}

function BotVoiceMessage(name messagetype, byte messageID, Pawn Sender)
{
	if (pa != none &&
		pa == Sender &&
		tvplayer(pa) == none &&
		messagetype == 'ORDER' &&
		(messageID == 1 || messageID == 3 || messageID == 4))
	{
		bShouldWait = messageID == 1;
		if (Enemy != none)
			return;
		if (IsInState('TakeHit') || IsInState('FallingState'))
		{
			if (messageID == 1)
			{
				NextState = 'Waiting';
				NextLabel = 'OrderChange';
			}
			else
				NextState = 'Following';
		}
		else if (messageID == 1)
			GotoState('Waiting', 'OrderChange');
		else if (messageID == 3)
			GotoState('Following');
		else
			FollowerFreelance();
	}
}

function FollowerFreelance()
{
	local PlayerPawn PP, NearestPP;
	local bool bIsAmbientCreatureSupported;
	local float NearestDist;

	bIsAmbientCreatureSupported = DynamicLoadObject("Engine.Pawn.bIsAmbientCreature", class'Object', true) != none;

	foreach AllActors(class'PlayerPawn', PP)
		if (!PP.bHidden &&
			PP.Health > 0 &&
			PP != pa &&
			(!bIsAmbientCreatureSupported || !bool(PP.GetPropertyText("bIsAmbientCreature"))) &&
			(NearestPP == none || VSize(Location - PP.Location) < NearestDist) &&
			CanSee(PP))
		{
			NearestPP = PP;
			NearestDist = VSize(Location - PP.Location);
		}

	if (NearestPP == none && pa != none && LineOfSightTo(pa))
		return;
	if (Enemy == pa)
		Enemy = NearestPP;
	SetPa(NearestPP);

	if (NearestPP != none)
		GotoState('Greeting');
	else
		DoRoam();
}

defaultproperties
{
     bCheckFriendlyFire=True
     LandAnim=Land
     Footstep1=Sound'UnrealShare.Cow.walkC'
     WalkingSpeed=0.500000
     bCanJump=True
     bAutoActivate=True
     AttitudeToPlayer=ATTITUDE_Friendly
     Intelligence=BRAINS_HUMAN
     DrawType=DT_Mesh
     NetPriority=2.700000
}
