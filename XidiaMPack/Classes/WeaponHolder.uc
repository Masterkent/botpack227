// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// WeaponHolder : This class is designed for three things:
// A) Have a base class of weapon holders.
// B) Prevent melee attacks.. thus skaarjtrooper is not under here.
// ============================================================

class WeaponHolder expands ScriptedPawn
  abstract;

var () class<weapon> WeaponType; //class of weapon
var () bool bNoDropWeapon;  //xidia thing for cray
var weapon MyWeapon; //my weapon ;p
var float ticker;
var(Sounds) sound FootStep1;

var bool B227_bEvalAttitude; // Prevents infinite recursion

//no drop weapon hack
function Died(pawn Killer, name damageType, vector HitLocation)
{
  bIsPlayer = false;
  // mutator hook to prevent deaths
  // WARNING - don't prevent bot suicides - they suicide when really needed
  //-if ( Level.Game.BaseMutator.PreventDeath(self, Killer, damageType, HitLocation) )
  if (class'UTC_GameInfo'.static.B227_PreventDeath(self, Killer, damageType))
  {
    Health = max(Health, 1); //mutator should set this higher
    return;
  }
  if ( bDeleteMe )
    return; //already destroyed
  if (bNoDropWeapon){
    if (weapon!=none)
      Weapon.Destroy();
    Weapon=none;
  }
  super.Died(Killer,damageType,HitLocation);
}

//// RELATIONS ////////////
simulated function PreBeginPlay(){
  super.PreBeginPlay();
  bHasRangedAttack = false;
  bMovingRangedAttack = false;
}

function eAttitude AttitudeToCreature(Pawn Other)
{
  local EAttitude OtherAttitude;

  // nice to skaarj & other evil ones.
  if (other.IsA('WeaponHolder') || other.isa('skaarj'))
  {
    if (Other.Enemy == none || Other.Enemy.Class != Class)
      return ATTITUDE_Friendly;
    if (ScriptedPawn(other) != none && !B227_bEvalAttitude)
    {
      B227_bEvalAttitude = true;
      OtherAttitude = ScriptedPawn(other).AttitudeTo(self);
      B227_bEvalAttitude = false;
      if (OtherAttitude > ATTITUDE_Ignore)
        return ATTITUDE_Friendly;
      if (OtherAttitude == ATTITUDE_Hate || OtherAttitude == ATTITUDE_Frenzy || OtherAttitude == ATTITUDE_Threaten)
        return ATTITUDE_Hate;
    }
  }
  if (other.attitudetoplayer<=ATTITUDE_Ignore&&other.enemy!=self) //MY ENEMIES ENEMY, SO "TOLERATE" HIM.
    return ATTITUDE_IGNORE;
  return ATTITUDE_HATE; //HE HELPS PLAYER. K33L HIM!
}

//foot step handling:
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
///WEAPON/NO MELEE CODE//////

final function float VsizeSquared(vector A){
  return A dot A;
}
//1337 dodging?  (new-ish code now detects if would jump off a plank.. because that is ghey)
function TryToDuck(vector duckDir, bool bReversed)
{
  local vector HitLocation, HitNormal, Extent, HitLocation2;
  local bool duckLeft;
  local actor HitActor;

  duckDir.Z = 0;
  duckLeft = !bReversed;
  if (bReversed)
    DuckDir *= -1;
  Extent.X = CollisionRadius;
  Extent.Y = CollisionRadius;
  Extent.Z = CollisionHeight;
  HitActor = Trace(HitLocation, HitNormal, Location + 200 * duckDir, Location, false, Extent);
  if (HitActor != None)
  {
    duckLeft = !duckLeft;
    duckDir *= -1;
    HitActor = Trace(HitLocation2, HitNormal, Location + 200 * duckDir, Location, false, Extent);
    if (HitActor != none){
      if (VsizeSquared(HitLocation)>vsizeSquared(HitLocation2)){
        duckLeft = !duckLeft;
        duckDir *= -1;
      }
      else
        HitLocation=HitLocation2;
      if (VsizeSquared(HitLocation-Location)<3200) //would definitely hit wall.. too close
        return;
    }
    else
      HitLocation=HitLocation2;
    HitLocation-=duckdir*(collisionradius+1);
  }
  else
    HitLocation=Location + 200 * duckDir;
  //check if would jump safe
  if (Trace(HitLocation2, HitNormal, HitLocation + 600 * vect(0,0,-1), Hitlocation, false, Extent)==none)
    return;
  SetFall();
  PlayDodge(DuckLeft);
  Velocity = duckDir * GroundSpeed;
  Velocity.Z = 200;
  SetPhysics(PHYS_Falling);
  GotoState('FallingState','Ducking');
}

function Bump(actor Other)   //nalis have no melee attacks.
{
  local vector VelDir, OtherDir;
  local float speed;
  if (other==enemy){
    breadytoAttack=true;
    LastSeenPos = Enemy.Location;
    gotostate('attacking');
    return;
  }

  if (Pawn(Other) != None)
    {
      AnnoyedBy(Pawn(Other));
      if ( SetEnemy(Pawn(Other)) )
      {
        bReadyToAttack = True; //can melee right away
        PlayAcquisitionSound();
        GotoState('tacticalmove','nocharge');
        return;
      }

    if ( TimerRate <= 0 )
      setTimer(1.0, false);
    if ( bCanSpeak && (ScriptedPawn(Other) != None) && ((TeamLeader == None) || !TeamLeader.bTeamSpeaking) )
      SpeakTo(ScriptedPawn(Other));
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
      if ( Pawn(Other) == None )
      {
        MoveTimer = -1.0;
        HitWall(-1 * OtherDir, Other);
      }
      Velocity.X = VelDir.Y;
      Velocity.Y = -1 * VelDir.X;
      Velocity *= FMax(speed, 280);
    }
  }
  Disable('Bump');
}
//ripped from skaarj trooper for weapon support.
function ChangedWeapon()
{
  Super.ChangedWeapon();
  bIsPlayer = false;
  bMovingRangedAttack = true;
  bHasRangedAttack = true;
  if (Weapon != none)
  {
    Weapon.AimError = 200 + Weapon.default.AimError;
    B227_SetWeaponPosition();
    CombatStyle += FClamp(Weapon.SuggestAttackStyle(), -1.0, 1.0); //set up style by using weapon.
  }
  //Weapon.SetHand(0);
}

function TossWeapon()
{
  if ( Weapon == None )
    return;
  Weapon.FireOffset = Weapon.Default.FireOffset;
  Weapon.PlayerViewOffset = Weapon.Default.PlayerViewOffset;
  Super.TossWeapon();
}

function bool CanFireAtEnemy()    //pretty important, eh?
{
  local vector HitLocation, HitNormal,X,Y,Z, projStart, EnemyDir, EnemyUp;
  local actor HitActor;
  local float EnemyDist;

  EnemyDir = Enemy.Location - Location;
  EnemyDist = VSize(EnemyDir);
  EnemyUp = Enemy.CollisionHeight * vect(0,0,0.8);
  if ( EnemyDist > 300 )
  {
    EnemyDir = 300 * EnemyDir/EnemyDist;
    EnemyUp = 300 * EnemyUp/EnemyDist;
  }

  if ( Weapon == None )
    return false;

  combatstyle=fclamp(weapon.suggestattackstyle(),-1.0,1.0); //set up style by using weapon.

  GetAxes(Rotation,X,Y,Z);
  projStart = Location + Weapon.CalcDrawOffset() + Weapon.FireOffset.X * X + 1.2 * Weapon.FireOffset.Y * Y + Weapon.FireOffset.Z * Z;
  if ( ((Weapon.binstanthit&&baltfire==0)||weapon.baltinstanthit) ||weapon.bmeleeweapon) //non-projectile
    HitActor = Trace(HitLocation, HitNormal, Enemy.Location + EnemyUp, projStart, true);
  else
    HitActor = Trace(HitLocation, HitNormal, projStart + EnemyDir + EnemyUp, projStart, true);

  if ( HitActor == Enemy )
    return true;
  if ( (HitActor != None) && (VSize(HitLocation - Location) < 200) )
    return false;
  if ( (Pawn(HitActor) != None) && (AttitudeTo(Pawn(HitActor)) > ATTITUDE_Ignore) )
    return false;

  return true;
}
function PlayMovingAttack()
{
  //-local int bUseAltMode;

  if (Weapon != None)
  {
    if ( Weapon.AmmoType != None )
      Weapon.AmmoType.AmmoAmount = Weapon.AmmoType.Default.AmmoAmount;
  /*  Weapon.RateSelf(bUseAltMode);
    ViewRotation = Rotation; //+ heheh :P
    if ( bUseAltMode == 0 )
    {
      bFire = 1;
      bAltFire = 0;
      Weapon.Fire(1.0);
    }
    else
    {
      bFire = 0;
      bAltFire = 1;
      Weapon.AltFire(1.0);
    }   */
    FireWeapon();
  }
  else{
    PlayRunning();
    return;
  }
  if (Region.Zone.bWaterZone)
  {
    PlaySwimming();
    return;
  }
  PlayMovingAttackAnim();
}

function PlaySwimming(); //subclass?
function PlayMovingAttackAnim(); //in subclass

function PlayRangedAttack()
{
  PlayFiring();
}

function PlayFiring()
{
  if ( (Weapon != None) && (Weapon.AmmoType != None) )
    Weapon.AmmoType.AmmoAmount = Weapon.AmmoType.Default.AmmoAmount;
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;
  function PlayRangedAttack()
  {
   FireWeapon();

  }
Challenge:
  Disable('AnimEnd');
  Acceleration = vect(0,0,0); //stop
  DesiredRotation = Rotator(Enemy.Location - Location);
  PlayChallenge();
  FinishAnim();
  if ( bCrouching && !Region.Zone.bWaterZone )
    Sleep(0.8 + FRand());
  bCrouching = false;
  TweenToFighter(0.1);
  Goto('FaceTarget');

Begin:
  if ( Enemy == None )
    GotoState('Attacking');

  Acceleration = vect(0,0,0); //stop
  DesiredRotation = Rotator(Enemy.Location - Location);
  TweenToFighter(0.15);

FaceTarget:
  Disable('AnimEnd');
  if (NeedToTurn(Enemy.Location))
  {
    PlayTurning();
    TurnToward(Enemy);
    TweenToFighter(0.1);
  }
  FinishAnim();

ReadyToAttack:
  if (!bHasRangedAttack)
    GotoState('Attacking');
  DesiredRotation = Rotator(Enemy.Location - Location);
  PlayRangedAttack();
  Enable('AnimEnd');
Firing:
  if (Enemy == None )
    GotoState('Attacking');
  TurnToward(Enemy);
  //Goto('Firing');
  finishanim();  //changed due to some problems
DoneFiring:
  Disable('AnimEnd');
  KeepAttacking();
  Goto('FaceTarget');

}
state TacticalMove
{
ignores SeePlayer, HearNoise;

function Timer()
  {
    bReadyToAttack = True;
    Enable('Bump');
    Target = Enemy;
    if ( bHasRangedAttack && ((!bMovingRangedAttack && (FRand() < 0.8)) || (FRand() > 0.5 + 0.17 * skill)) )
      GotoState('RangedAttack');
  }
  function EndState()
  {
    bFire = 0;
    bAltFire = 0;
    Super.EndState();
  }
}

auto state Startup
{
  function BeginState()
  {
    Super.BeginState();
    //-bIsPlayer = true; // temporarily, till have weapon
  }

  function SetHome()
  {
    local Weapon ReplacingWeapon;

    Super.SetHome();
    if (WeaponType==class'enforcer') //quick hack
      WeaponType=class'Spenf';
    else if (WeaponType==class'automag')
       WeaponType=class'XidiaAutomag';
 //   else if (WeaponType==class'oldpistol') //quick hack
  //    WeaponType=class'NoammoDpistol';
    else if (WeaponType==class'pulsegun'||WeaponType==class'OSpulsegun') //quick hack
      WeaponType=class'TVPulsegun';
    else if (WeaponType==class'ShockRifle') //quick hack
      WeaponType=class'XidiaShockRifle';
    else if (WeaponType==class'SniperRifle') //quick hack
      WeaponType=class'XidiaSniperRifle';
    else if (WeaponType==class'UT_eightball')
      WeaponType=class'TVEightball';

    if ( WeaponType != None )
    {
      MyWeapon = Spawn(WeaponType);
      if (MyWeapon == none)
        foreach AllActors(class'Weapon', ReplacingWeapon)
          if (ReplacingWeapon.Instigator == self && ReplacingWeapon.IsInState('Pickup'))
          {
            MyWeapon = ReplacingWeapon;
            break;
          }
    }
    if ( MyWeapon != None )
    {
      MyWeapon.RespawnTime = 0;
      MyWeapon.LifeSpan = MyWeapon.default.LifeSpan; // prevents destruction when spawning in destructive zones
      MyWeapon.Instigator = self;
      MyWeapon.BecomeItem();
      AddInventory(MyWeapon);
      MyWeapon.BringUp();
      MyWeapon.GiveAmmo(self);
      MyWeapon.WeaponSet(self);
    }
    else{
      bIsPlayer=false;
      CombatStyle=-1.0;
      Aggressiveness=-10.000000;
    }
  }
}
//swimming :P
function ZoneChange(ZoneInfo newZone)
{
  bCanSwim = newZone.bWaterZone; //only when it must
  Super.ZoneChange(newZone);
}

function PlayMeleeAttack()     //no melee!
{
 PlayFiring();
 FireWeapon();
}

state Retreating
{
  ignores HearNoise, Bump, AnimEnd;
  function EndState()
  {
    bFire = 0;
    bAltFire = 0;
    Super.EndState();
  }
   function Bump(actor Other) //no melee
  {
    local vector VelDir, OtherDir;
    local float speed;

    //log(Other.class$" bumped "$class);
    if (Pawn(Other) != None)
    {
      if ( SetEnemy(Pawn(Other)) )
        GotoState('RangedAttack');
      else if ( (HomeBase(Home) != None)
        && (VSize(Location - Home.Location) < HomeBase(Home).Extent) )
        ReachedHome();
      return;
    }
    if ( TimerRate <= 0 )
      setTimer(1.0, false);

    speed = VSize(Velocity);
    if ( speed > 1 )
    {
      VelDir = Velocity/speed;
      VelDir.Z = 0;
      OtherDir = Other.Location - Location;
      OtherDir.Z = 0;
      OtherDir = Normal(OtherDir);
      if ( (VelDir Dot OtherDir) > 0.9 )
      {
        Velocity.X = VelDir.Y;
        Velocity.Y = -1 * VelDir.X;
        Velocity *= FMax(speed, 200);
      }
    }
    Disable('Bump');
  }
}

function SetMovementPhysics()
{
  if ( Region.Zone.bWaterZone )
    SetPhysics(PHYS_Swimming);
  else if (Physics != PHYS_Walking)
    SetPhysics(PHYS_Walking);
}

state Charging
{
ignores SeePlayer, HearNoise;
  function Timer()
  {
  if ( Enemy == None )
    {
      GotoState('Attacking');
      return;
    }
    if ( (VSize(Enemy.Location - Location)
        <= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
      || ((Weapon != None) && !Weapon.bMeleeWeapon && (FRand() > 0.7 + 0.1 * skill)) )
      GotoState('RangedAttack');
  }
  function EndState()
  {
    bFire = 0;
    bAltFire = 0;
    Super.EndState();
  }
AdjustFromWall:
  StrafeTo(Destination, Focus);
  Goto('CloseIn');

ResumeCharge:
  PlayRunning();
  Goto('Charge');

Begin:
  TweenToRunning(0.15);

Charge:
  bFromWall = false;

CloseIn:
  if ( (Enemy == None) || (Enemy.Health <=0) )
    GotoState('Attacking');

  if ( Enemy.Region.Zone.bWaterZone )
  {
    if (!bCanSwim)
      GotoState('TacticalMove', 'NoCharge');
  }
  else if (!bCanFly && !bCanWalk)
    GotoState('TacticalMove', 'NoCharge');

  if (Physics == PHYS_Falling)
  {
    DesiredRotation = Rotator(Enemy.Location - Location);
    Focus = Enemy.Location;
    Destination = Enemy.Location;
    WaitForLanding();
  }
  if( (Intelligence <= BRAINS_Reptile) || actorReachable(Enemy) )
  {
    bCanFire = true;
    if ( FRand() < 0.3 )
      PlayThreateningSound();
    MoveToward(Enemy);
    if (bFromWall)
    {
      bFromWall = false;
      if (PickWallAdjust())
        StrafeFacing(Destination, Enemy);
      else
        GotoState('TacticalMove', 'NoCharge');
    }
  }
  else
  {
NoReach:
    bCanFire = false;
    bFromWall = false;
    //log("route to enemy "$Enemy);
    if (!FindBestPathToward(Enemy))
    {
      Sleep(0.0);
      GotoState('TacticalMove', 'NoCharge');
    }
SpecialNavig:
    if ( SpecialPause > 0.0 )
    {
      Target = Enemy;
      bFiringPaused = true;
      NextState = 'Charging';
      NextLabel = 'Begin';
      GotoState('RangedAttack');
    }
Moving:
    if (VSize(MoveTarget.Location - Location) < 2.5 * CollisionRadius)
    {
      bCanFire = true;
      StrafeFacing(MoveTarget.Location, Enemy);
    }
    else
    {
      if ( !bCanStrafe || !LineOfSightTo(Enemy) ||
        (Skill - 2 * FRand() + (Normal(Enemy.Location - Location - vect(0,0,1) * (Enemy.Location.Z - Location.Z))
          Dot Normal(MoveTarget.Location - Location - vect(0,0,1) * (MoveTarget.Location.Z - Location.Z))) < 0) )
      {
        if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
        {
          AnimSequence = '';
          TweenToRunning(0.12);
        }
        MoveToward(MoveTarget);
      }
      else
      {
        bCanFire = true;
        StrafeFacing(MoveTarget.Location, Enemy);
      }
      if ( !bFromWall && (FRand() < 0.5) )
        PlayThreateningSound();
    }
  }
  //log("finished move");
  //if ( bIsPlayer || (!bFromWall && bHasRangedAttack && (FRand() > CombatStyle + 0.1)) )
  if (VSize(Location - Enemy.Location) < CollisionRadius + Enemy.CollisionRadius + MeleeRange)
    Goto('GotThere');
    else
    GotoState('Attacking');
    //GotoState('Attacking');

GotThere:
  Target = Enemy;
  if ( !Weapon.bMeleeWeapon )
    GotoState('RangedAttack');
  Sleep(0.1 - 0.02 * Skill );
  Goto('Charge');

TakeHit:
  TweenToRunning(0.12);
  if (MoveTarget == Enemy)
  {
    bCanFire = true;
    MoveToward(MoveTarget);
  }

  Goto('Charge');
}
state Attacking
{
ignores SeePlayer, HearNoise, Bump, HitWall;
function ChooseAttackMode()
  {
    local eAttitude AttitudeToEnemy;
    local pawn changeEn;

    if (Enemy == none || Enemy.bDeleteMe || Enemy.Health <= 0 || Enemy == self)
    {
      Enemy = none;
      if (Orders == 'Attacking')
        Orders = '';
      WhatToDoNext('','');
      return;
    }

    if ( (AlarmTag != '') && Enemy.bIsPlayer )
    {
      if (AttitudeToPlayer > ATTITUDE_Ignore)
      {
        GotoState('AlarmPaused', 'WaitForPlayer');
        return;
      }
      else if ( (AttitudeToPlayer != ATTITUDE_Fear) || bInitialFear )
      {
        GotoState('TriggerAlarm');
        return;
      }
    }

    AttitudeToEnemy = AttitudeTo(Enemy);

    if (AttitudeToEnemy == ATTITUDE_Fear)
    {
      GotoState('Retreating');
      return;
    }

    else if (AttitudeToEnemy == ATTITUDE_Threaten)
    {
      GotoState('Threatening');
      return;
    }

    else if (AttitudeToEnemy == ATTITUDE_Friendly)
    {
      if (Enemy.bIsPlayer)
        GotoState('Greeting');
      else
        WhatToDoNext('','');
      return;
    }

    else if (!LineOfSightTo(Enemy))
    {
      if ( (OldEnemy != None)
        && (AttitudeTo(OldEnemy) == ATTITUDE_Hate) && LineOfSightTo(OldEnemy) )
      {
        changeEn = enemy;
        enemy = oldenemy;
        oldenemy = changeEn;
      }
      else
      {
        if ( (Orders == 'Guarding') && !LineOfSightTo(OrderObject) )
          GotoState('Guarding');
        else if ( !bHasRangedAttack || VSize(Enemy.Location - Location)
              > 600 + (FRand() * RelativeStrength(Enemy) - CombatStyle) * 600 )
          GotoState('Hunting');
        else if ( bIsBoss || (Intelligence > BRAINS_None) )
        {
          HuntStartTime = Level.TimeSeconds;
          NumHuntPaths = 0;
          GotoState('StakeOut');
        }
        else
          WhatToDoNext('Waiting', 'TurnFromWall');
        return;
      }
    }

    else if ( (TeamLeader != None) && TeamLeader.ChooseTeamAttackFor(self) )
      return;

    if (bReadyToAttack)
    {
      ////log("Attack!");
      Target = Enemy;
      if (bMovingRangedAttack)
        SetTimer(TimeBetweenAttacks, False);
      else if (bHasRangedAttack && (bIsPlayer || enemy.bIsPlayer) && CanFireAtEnemy() )
      {
        if (!bIsPlayer || (2.5 * FRand() > Skill) )
        {
          GotoState('RangedAttack');
          return;
        }
      }
    }

    GotoState('TacticalMove');
    //log("Next state is "$state);
  }
  Begin:
  //log(class$" choose Attack");
  ChooseAttackMode();
  //why am I still here?  get out of here!
  if (enemy!=none&&enemy.health>0&&cansee(enemy))
    gotostate('tacticalmove');
  else
    startroaming();
}

state acquisition{    //really stupid bug!!!  makes no sense at all really.
ignores falling, landed; //fixme
function WhatToDoNext(name LikelyState, name LikelyLabel)
{
  bQuiet = false;
  if ( OldEnemy != None )
  {
    Enemy = OldEnemy;
    OldEnemy = None;
    GotoState('Attacking');
  }
  else if (enemy!=none)   //needed to add this.
   GotoState('Attacking');
  else if (Orders == 'Patroling')
    GotoState('Patroling');
  else if (Orders == 'Guarding')
    GotoState('Guarding');
  else if ( Orders == 'Ambushing' )
    GotoState('Ambushing','FindAmbushSpot');
  else if ( (LikelyState != '') && (FRand() < 0.35) )
    GotoState(LikelyState, LikelyLabel);
  else
    StartRoaming();
}
}

state TakeHit
{
ignores seeplayer, hearnoise, bump, hitwall;

  function BeginState()
  {
    bFire = 0;
    bAltFire = 0;
    Super.BeginState();
  }
}

state hunting{
ignores enemynotvisible;   //really stupid bug!!!  makes no sense at all really.

  function tick(float deltatime){    //update tick for searching for enemy (don't want to get to close)
    super.tick(deltatime);
    ticker+=deltatime;
    if (ticker<0.3)
      return;
    ticker-=0.3;
    if (cansee(enemy)){
      bReadyToAttack = true;
      DesiredRotation = Rotator(Enemy.Location - Location);
      GotoState('Attacking');
      }
  }

  function EndState()
  {
    bFire = 0;
    bAltFire = 0;
    bCanSwim = Region.Zone.bWaterZone ;
    Super.EndState();
  }

  function BeginState()
  {
    enable('tick'); //no screw with me!
    bCanSwim = true;
    enable('bump');
    Super.BeginState();
  }
  function WhatToDoNext(name LikelyState, name LikelyLabel)
{
  bQuiet = false;
  if ( OldEnemy != None )
  {
    Enemy = OldEnemy;
    OldEnemy = None;
    GotoState('Attacking');
  }
  else if (enemy!=none)   //needed to add this.
   GotoState('Attacking');
  else if (Orders == 'Patroling')
    GotoState('Patroling');
  else if (Orders == 'Guarding')
    GotoState('Guarding');
  else if ( Orders == 'Ambushing' )
    GotoState('Ambushing','FindAmbushSpot');
  else if ( (LikelyState != '') && (FRand() < 0.35) )
    GotoState(LikelyState, LikelyLabel);
  else
    StartRoaming();
}
 function bool SetEnemy(Pawn NewEnemy)  //don't charge
  {
    local float rnd;

    if (Global.SetEnemy(NewEnemy))
    {
      rnd = FRand();
      if ( bReadyToAttack )
      {
        if (rnd < 0.3)
          PlayAcquisitionSound();
        else if (rnd < 0.6)
          PlayThreateningSound();
      }
      bReadyToAttack = true;
      DesiredRotation = Rotator(Enemy.Location - Location);
      GotoState('Attacking');
      return true;
    }
    return false;
  }

}

//more no meleeing
function bool ChooseTeamAttackFor(ScriptedPawn TeamMember)
{
  if ( (Enemy == None) && (TeamMember.Enemy != None) && LineOfSightTo(TeamMember) )
  {
    if (SetEnemy(TeamMember.Enemy))
      MakeNoise(1.0);
  }

  // speak order
  if ( !bTeamSpeaking )
    SpeakOrderTo(TeamMember);

  // set CombatStyle and Aggressiveness of TeamMember
  if ( TeamMember == Self )
  {
    ChooseLeaderAttack();
    return true;
  }

  if ( TeamMember.bReadyToAttack )
  {
    ////log("Attack!");
    TeamMember.Target = TeamMember.Enemy;
    if (TeamMember.bMovingRangedAttack || (TeamMember.TeamID == 1) )
      TeamMember.SetTimer(TimeBetweenAttacks, False);
    else if (TeamMember.bHasRangedAttack && (TeamMember.bIsPlayer || TeamMember.Enemy.bIsPlayer) && TeamMember.CanFireAtEnemy() )
    {
      if ( !TeamMember.bIsPlayer || (3 * FRand() > Skill) )
      {
        TeamMember.GotoState('RangedAttack');
        return true;
      }
    }
  }

  if ( !TeamMember.bHasRangedAttack || (TeamMember.TeamID == 1) )
    TeamMember.GotoState('Charging');
  else if ( TeamMember.TeamID == 2 )
  {
    TeamMember.bStrafeDir = true;
    TeamMember.GotoState('TacticalMove', 'NoCharge');
  }
  else if ( TeamMember.TeamID == 3 )
  {
    TeamMember.bStrafeDir = false;
    TeamMember.GotoState('TacticalMove', 'NoCharge');
  }
  else
    TeamMember.GotoState('TacticalMove');

  return true;
}
function PlayDodge(bool bDuckLeft);


function Killed(Pawn Killer, Pawn Other, name DamageType)
{
	if (Enemy == Other)
	{
		bFire = 0;
		bAltFire = 0;
	}
	super.Killed(Killer, Other, DamageType);
}

function B227_SetWeaponPosition()
{
	///Weapon.FireOffset = Weapon.default.FireOffset * 1.5 * DrawScale;
	///Weapon.PlayerViewOffset = Weapon.default.PlayerViewOffset * 1.5 * DrawScale;
	Weapon.FireOffset = Weapon.default.FireOffset;
	Weapon.PlayerViewOffset = Weapon.default.PlayerViewOffset;
	Weapon.SetHand(-1);
}

defaultproperties
{
     WeaponType=Class'olweapons.OLDpistol'
     Footstep1=Sound'UnrealShare.Cow.walkC'
     Aggressiveness=0.400000
     bCanDuck=True
     bCanStrafe=True
     bAutoActivate=True
     Intelligence=BRAINS_HUMAN
     DrawType=DT_Mesh
     RotationRate=(Pitch=2048,Yaw=55000,Roll=0)
}
