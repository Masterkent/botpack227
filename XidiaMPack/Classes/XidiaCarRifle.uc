// ===============================================================
// XidiaMPack.XidiaCarRifle: imported from Return To Na Pali.. slightly modified.
// ===============================================================

class XidiaCarRifle expands TournamentWeapon;

//#exec OBJ LOAD FILE=..\Textures\FireEffect18.utx PACKAGE=UPak.CARifle

// First Person View

#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack

/*
#exec MESH SEQUENCE MESH=Car1st SEQ=All        STARTFRAME=0 NUMFRAMES=53
#exec MESH SEQUENCE MESH=Car1st SEQ=ALTFIRE   STARTFRAME=0 NUMFRAMES=13
#exec MESH SEQUENCE MESH=Car1st SEQ=ALTRELOAD STARTFRAME=13 NUMFRAMES=5
#exec MESH SEQUENCE MESH=Car1st SEQ=DOWN       STARTFRAME=18 NUMFRAMES=10
#exec MESH SEQUENCE MESH=Car1st SEQ=FIRE       STARTFRAME=28 NUMFRAMES=5
#exec MESH SEQUENCE MESH=Car1st SEQ=SELECT     STARTFRAME=33 NUMFRAMES=15
#exec MESH SEQUENCE MESH=Car1st SEQ=STILL      STARTFRAME=48 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Car1st SEQ=SWAY       STARTFRAME=49 NUMFRAMES=4
//
#exec TEXTURE IMPORT NAME=Jnewcar1 FILE=MODELS\Jnewcar1.pcx Group=Skins Flags=2
#exec TEXTURE IMPORT NAME=Jnewcar2 FILE=MODELS\Jnewcar2.pcx Group=Skins PALETTE=Jnewcar1
#exec TEXTURE IMPORT NAME=Jnewcar3 FILE=MODELS\Jnewcar3.pcx Group=Skins PALETTE=Jnewcar1
//#exec TEXTURE IMPORT NAME=Jnewcar4 FILE=MODELS\CARIFLE\newcar4.pcx Group=Skins PALETTE=Jnewcar1

#exec TEXTURE IMPORT NAME=JCar1st0 FILE=MODELS\JCar1st0.PCX GROUP=Skins FLAGS=2 PALETTE=Effect128// SKIN
//#exec TEXTURE IMPORT NAME=JCar1st1 FILE=MODELS\CARIFLE\Car02.PCX GROUP=Skins PALETTE=JCar1st1 // CAR

#exec MESHMAP NEW   MESHMAP=Car1st MESH=Car1st
#exec MESHMAP SCALE MESHMAP=Car1st X=0.01 Y=0.01 Z=0.02

#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=0 TEXTURE=Jnewcar1
#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=1 TEXTURE=JCar1st0

#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=2 TEXTURE=Jnewcar3
#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=3 TEXTURE=Jnewcar2
//#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=1 TEXTURE=JCARIFLE4

//#exec MESHMAP SETTEXTURE MESHMAP=Car1st NUM=1 TEXTURE=JCar1st1
*/

//new import lines:

//end new import...

// Pickup View

// Third-person view

//#exec TEXTURE IMPORT NAME=JCar3rd1 FILE=MODELS\CARIFLE\Car01.PCX GROUP=Skins PALETTE=JCar3rd1 // Material #25
//#exec TEXTURE IMPORT NAME=JCar3rd1 FILE=MODELS\CARIFLE\CAR-PICK-LOW.PCX GROUP=Skins Flags=2


// Sounds

var float ShotAccuracy, tickcount;
var float Adjuster;        // Used for adjusting aim error, etc.
var int InitialRounds;      // Number of inital rounds fired before bFirstFire becomes false
var bool bFirstFire;      // First pulse has no immediate recoil- this flag determines that
var int TraceCount;
var vector StartingLocation;
var bool bFireDelay; //more reliable than sleep...
var pawn Victim;
var int LightCounter;
//duel-ammo vars:
var() class<ammo> AmmoName2;          // 2nd Type of ammo used.
var() int     PickupAmmo2Count;   // Amount of ammo 2 initially in pick-up item.
var travel ammo  AmmoType2;     //other inv ammo
var travel bool bUseAlt; //using alt ammo
var float LastSwitchTime; //ai..

var int B227_FireEffectCount;

replication{
  reliable if (role==role_authority && bNetOwner)
    AmmoType2;
}

//duel-ammo code:
function SwapAmmo(){
  local ammo tmp;
  tmp=AmmoType;
  AmmoType=AmmoType2;
  AmmoType2=tmp;
  bUseAlt=(AmmoType.class==AmmoName2);
}

function float RateSelf( out int bUseAltMode )
{
  local float EnemyDist, Rating;
  local bool bRetreating;
  local vector EnemyDir;
  local Pawn P;

  // don't recommend self if out of ammo
  if ( AmmoType.AmmoAmount <=0 )
    return -2;

  // by default keep mode
  bUseAltMode = 0;
  P = Pawn(Owner);
  if (P == none || P.Enemy == none)
    return AIRating;

  // if standing on a lift, make sure not about to go around a corner and lose sight of target
  // (don't want to blow up a rocket in bot's face)
  if ( (P.Base != None) && (P.Base.Velocity != vect(0,0,0))
    && !P.CheckFutureSight(0.1) )
    return 0.1;

  EnemyDir = P.Enemy.Location - Owner.Location;
  EnemyDist = VSize(EnemyDir);
  Rating = AIRating;

  // don't pick car is enemy is too close or far
  if ( EnemyDist < 550 || EnemyDist > 2000)
  {
    if ( P.Weapon == self )
    {
      // don't switch away from car unless really bad tactical situation
      if ( (EnemyDist < 350) || ((P.Health < 50) && (P.Health < P.Enemy.Health - 30)) ){
        if (bUseAlt){
          buseAltMode=1;
          LastSwitchTime=level.timeseconds;
        }
        return rating;
      }
    }
    if (bUseAlt)
      bUseAltMode=byte(bool(3*frand()));;
  }

  // increase rating for situations for which rocket launcher is well suited
  if ( P.Enemy.IsA('StationaryPawn') )
    Rating += 0.4;

  // rockets are good if higher than target, bad if lower than target
  if ( Owner.Location.Z > P.Enemy.Location.Z + 120 )
    Rating += 0.25;
  else if ( P.Enemy.Location.Z > Owner.Location.Z + 160 )
    Rating -= 0.35;
  else if ( P.Enemy.Location.Z > Owner.Location.Z + 80 )
    Rating -= 0.05;

  // decide if should use alternate fire (grenades) instead
  if ( (Owner.Physics == PHYS_Falling) || Owner.Region.Zone.bWaterZone ){
    if (bUseAlt)
      bUseAltMode = 1;
  }
  else if ( EnemyDist < -1.5 * EnemyDir.Z && lastSwitchTime-level.timeseconds > 1.5){
     bUseAltMode = int( FRand() < 0.2 );
  }
  else
  {
    // grenades are good covering fire when retreating
    bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );
    bUseAltMode = 0;
    if ( bRetreating && (EnemyDist < 1000) && (FRand() < 0.6) && !bUseAlt && (level.timeseconds-lastSwitchTime) > 1.5)
      bUseAltMode = 1;
  }
  if (bUseAltMode>0)
    LastSwitchTime=level.timeseconds;
  return Rating;
}

event TravelPostAccept() //add ammo 2
{
  Super.TravelPostAccept();

  if ( AmmoName2 != None )
  {
    AmmoType2 = Ammo(Pawn(Owner).FindInventoryType(AmmoName2));
    if ( AmmoType2 == None )
    {
      AmmoType2 = Spawn(AmmoName2);  // Create ammo type required
      Pawn(Owner).AddInventory(AmmoType2);    // and add to player's inventory
      AmmoType2.BecomeItem();
      AmmoType2.AmmoAmount = PickUpAmmo2Count;
      AmmoType2.GotoState('Idle2');
    }
  }
  if (bUseAlt)
    SwapAmmo();
}

function bool HandleNoAmmo(){ //go to other ammo if available
  if (role<role_authority){
    if (AmmoType2.AmmoAmount>0){
      global.ClientAltFire(0);
      return true;
    }
    return false;
  }
  if (AmmoType2.AmmoAmount>0){
    global.AltFire(0);
    return true;
  }
  else if (Pawn(Owner) != none)
    Pawn(Owner).SwitchToBestWeapon();
}

function GiveAmmo( Pawn Other )
{
  super.GiveAmmo(Other);
  if ( AmmoName2 == None )
    return;
  AmmoType2 = Ammo(Other.FindInventoryType(AmmoName2));
  if (AmmoType2 !=none)
    AmmoType2.AddAmmo(PickUpAmmo2Count);
  else{
    AmmoType2 = Spawn(AmmoName2);  // Create ammo type required
    Other.AddInventory(AmmoType2);    // and add to player's inventory
    AmmoType2.AmmoAmount = PickUpAmmo2Count;
    AmmoType2.BecomeItem();
    AmmoType2.GotoState('Idle2');
  }
}

function bool HandlePickupQuery( inventory Item )
{
  local int OldAmmo;
  local Pawn P;
  local bool bwasswap;

  if (Item.Class == Class)
  {
    if ( Weapon(item).bWeaponStay && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut) )
      return true;
    bwasSwap=bUseAlt;
    if (bUseAlt)
      SwapAmmo();
    P = Pawn(Owner);
    if ( AmmoType != None )
    {
      OldAmmo = AmmoType.AmmoAmount;
      if ( AmmoType.AddAmmo(Weapon(Item).PickupAmmoCount) && (OldAmmo == 0)
        && (P.Weapon == none || P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
          WeaponSet(P);
    }
    if ( AmmoType2 != None )
    {
      OldAmmo = AmmoType2.AmmoAmount;
      if ( AmmoType2.AddAmmo(XidiaCarRifle(Item).PickupAmmo2Count) && (OldAmmo == 0)
        && (P.Weapon == none || P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
          WeaponSet(P);
    }
    if (bWasSwap)
       SwapAmmo();
    if (Level.Game.LocalLog != None)
      Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
    if (Level.Game.WorldLog != None)
      Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
    if (PickupMessageClass == None)
      P.ClientMessage(Item.PickupMessage, 'Pickup');
    else
      class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, PickupMessageClass, 0, None, None, Item.Class);
    Item.PlaySound(Item.PickupSound);
    Item.SetRespawn();
    return true;
  }
  if ( Inventory == None )
    return false;

  return Inventory.HandlePickupQuery(Item);
}


// Toss this weapon out
function DropFrom(vector StartLocation)
{
  if ( !SetLocation(StartLocation) )
    return;
  if (bUseAlt)
    SwapAmmo();
  if ( AmmoType2 != None )
  {
    PickupAmmo2Count = AmmoType2.AmmoAmount;
    AmmoType2.AmmoAmount = 0;
  }
  Super.DropFrom(StartLocation);
}

simulated function PostBeginPlay()
{
  bFirstFire = True;
  Super.PostBeginPlay();
}

function SetUpProjectile()
{
  if( AmmoType.UseAmmo( 1 ) )
    TraceFire( 0.35 );
  else
    GotoState( 'FinishFire' );
}

simulated function ShakePlayer( float ShakeMod )
{
  local actor a;

  if( PlayerPawn( Owner ) != None && InitialRounds >= 10 && bFirstFire )
  {
    bFirstFire = false;
  }
  else
  {
    PlayerPawn(Owner).ShakeTimer = 0.01;
    PlayerPawn(Owner).maxshake = 20 * ShakeMod;
    PlayerPawn(Owner).ShakeMag = 0;
    PlayerPawn(Owner).verttimer = 0.001;
  }

  if( Level.NetMode != NM_DedicatedServer && LightCounter >= 5 )
  {
    //a=spawn(class'WeaponLight',self,,Owner.Location+CalcDrawOffset()+X*25+Z*15,rot(0,0,0));
    a=spawn(class'WeaponLight',self,,Owner.Location+CalcDrawOffset());
    a.RemoteRole=ROLE_None;
    LightCounter = 0;
  }
  LightCounter++;
}


function Finish()
{
  if( bChangeWeapon )
  {
    GotoState( 'DownWeapon' );
    return;
  }

  if( PlayerPawn( Owner ) == None )
  {
    if( AmmoType.AmmoAmount <= 0 )
    {
      Pawn( Owner ).StopFiring();

      HandleNoAmmo();

      if( bChangeWeapon )
      {
        GotoState( 'DownWeapon' );
      }
    }

    else if( Pawn( Owner ).bFire != 0 && (bUseAlt || !owner.region.zone.bWaterZone))
    {
      Global.Fire( 0 );
    }

    else if( (Pawn( Owner ).bAltFire != 0 ) && ( FRand() < AltRefireRate ) )
    {
      Global.AltFire( 0 );
    }

    else
    {
      Pawn( Owner ).StopFiring();
      GotoState( 'Idle' );
    }
    return;
  }

  if( AmmoType.AmmoAmount <= 0){
    if (!HandleNoAmmo())
       GotoState('Idle');
  }

  else if (Pawn( Owner ).Weapon != self )
  {
    GotoState( 'Idle' );
  }

  else if( Pawn( Owner ).bFire != 0 && (bUseAlt || !owner.region.zone.bWaterZone))
  {
    Global.Fire( 0 );
  }

  else if( Pawn( Owner ).bAltFire != 0 )
  {
    Global.AltFire( 0 );
  }

  else
  {
    GotoState( 'Idle' );
  }
}


function TraceFire( float Accuracy )
{
  local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
  local actor Other;
  local float OldAccuracy;
  local vector AimDir;

  Owner.MakeNoise(Pawn(Owner).SoundDampening);
  GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
  if( VSize(Owner.Velocity ) > 200)
      Accuracy += vsize(owner.velocity) / 2400;

  StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * (X) + FireOffset.Y * Y + FireOffset.Z * Z;
  AdjustedAim = Pawn(Owner).AdjustAim( 1000000, StartTrace, 2.75 * AimError, False, False );
  EndTrace = StartTrace + ( Accuracy+Adjuster ) * ( FRand() - 0.5 )* Y * 1000 + Accuracy * ( FRand() - 0.5 ) * Z * 1000 ;
  EndTrace += ( 10000 * vector( AdjustedAim ) );
  Other = Pawn( Owner ).TraceShot( HitLocation, HitNormal, EndTrace, StartTrace );
  AimDir = vector( AdjustedAim );
  if ( VSize(HitLocation - StartTrace) > 250 && TraceCount == 4 )
  {
    Spawn(class'CARTracer',,, StartTrace + 125 * AimDir,rotator(EndTrace - StartTrace));
    TraceCount = 0;
  }
  TraceCount++;
  ProcessTraceHit( Other, HitLocation, HitNormal, vector( AdjustedAim ), Y, Z );
  Accuracy = OldAccuracy;
  // Increment Adjuster, which affects accuracy based on how long you've been firing.
  if( Adjuster <= 0.45 )
  {
    Adjuster += 0.025;
  }
}




function ProcessTraceHit( Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z )
{
  local int rndDam;
  local WallHitEffect WallHit;
  local SpriteSmokePuff Puff;

  if( PlayerPawn( Owner ) != None )
  {
    if (Viewport(PlayerPawn(Owner).player)!=none)
      ShakePlayer( 1 );
    InitialRounds++;
  }

  if (Other==None)
    return;

  if( Other == Level )
  {
    if( FRand() < 0.5 )
    {
      WallHit = Spawn( class'CARWallHitEffect2',,, HitLocation + HitNormal * 9, Rotator( HitNormal ) );
    }

    else
    {
      WallHit = Spawn( class'CARWallHitEffect',,, HitLocation + HitNormal * 9, Rotator( HitNormal ) );
    }

    WallHit.DrawScale -= FRand();
  }
  else if( Other != Self && Other != Owner )
  {
    if( Other != None && !Other.IsA( 'Pawn' ) && !Other.IsA( 'Carcass' ) )
    {
      if( FRand() < 0.01 )
      {
        Puff = spawn( class'SpriteSmokePuff',,, HitLocation + HitNormal * 9 );
        Puff.DrawScale -= FRand();
      }
    }

    rndDam = Rand(5) + 5;
    if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (Bot(instigator) != none && !Bot(Instigator).bNovice)||
        (ScriptedPawn(Other) != none && (ScriptedPawn(Other).bIsBoss || level.game.difficulty>=3))) ){
        MyDamageType='Decapitated';
        rndDam*=2;
    }
    else
      MyDamageType='shot';
    Other.TakeDamage( rndDam, Pawn(Owner), HitLocation, rndDam * 250.0 * X, MyDamageType );
  }

}


function PlayFiring(){
    if (!bUseAlt){
      Owner.PlaySound( sound'ChainStart3', SLOT_Misc, 3.0 * Pawn( Owner ).SoundDampening, True ); //looping wave?
      SoundVolume = 255 * Pawn( Owner ).SoundDampening;
      LoopAnim( 'Fire', 1.98, 0.05 );
    }
    else{
      PlayAnim( 'AltFire', 1.5);
      Owner.PlaySound(sound'CARifleShell', SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
      SoundVolume = 255 * Pawn( Owner ).SoundDampening;
      if( PlayerPawn( Owner ) != None && Viewport(PlayerPawn(Owner).player)!=none)
      {
        ShakePlayer( 1.2 );
      }
    }
}

function Fire( float Value )
{
  Enable( 'Tick' );

  if (AmmoType.AmmoAmount <=0){
    if (!HandleNoAmmo())
      GotoState('Idle');
  }

  else if(!bUseAlt )
  {
    if (owner.region.zone.bwaterzone){
      GotoState('Idle');
      return;
    }
    CheckVisibility();

    bPointing = True;
    ShotAccuracy = 0.3;
    bCanClientFire = true;
    ClientFire(Value);
    Pawn(Owner).PlayRecoil(FiringSpeed);
    GotoState( 'NormalFire' );
  }
  else if(AmmoType.UseAmmo(1) )
  {
    CheckVisibility();
    bPointing = True;
    ShotAccuracy = 0.0;
    bCanClientFire = true;
    ClientFire(Value);
    GotoState( 'AltFiring' );
  }
  else
  {
    GoToState( 'Idle' );
  }

}

function bool ClientFire( float Value )
{
  if ( Role < ROLE_Authority )
    bUseAlt=(AmmoType.class==AmmoName2);
  if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
  {
    if (owner.region.zone.bwaterzone && !bUseAlt){
      return false;
    }
    if ( (PlayerPawn(Owner) != None)
      && ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
    {
      if ( InstFlash != 0.0 )
        PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    }
    if ( Affector != None )
    {
      Affector.FireEffect();
      B227_FireEffectCount = 0;
    }

    PlayFiring();
    if ( Role < ROLE_Authority ){
      if (!bUseAlt)
        GotoState('ClientFiring');
      else
        GotoState('ClientAltFiring');
    }
    return true;
  }
  return false;
}

function bool ClientAltFire(float Value) //change states later!
{
  if ( bCanClientFire && AmmoType2.AmmoAmount > 0)
  {
    if ( Affector != None )
    {
      Affector.FireEffect();
      B227_FireEffectCount = 0;
    }
    PlayAltFiring();
    GotoState('AmmoToggle');
    return true;
  }
  return false;
}

function AltFire( float Value )
{
  bCanClientFire = true;
  ClientAltFire(Value);
}

state AmmoToggle{
  ignores Fire, AltFire, AnimEnd, ClientFire, ClientAltFire;
  Begin:
     finishanim();
     pawn(owner).baltfire=0;
     //-if (role==role_authority){
       SwapAmmo();
       finish();
     //-}
     //-else
     //- ClientFinish();
}

function PlayAltFiring() //whatever
{
  PlayAnim( 'AltReload', 0.8 );
  Owner.PlaySound( sound'CARifleLoad', SLOT_Misc, 3.0 * Pawn( Owner ).SoundDampening/*, True */);
}



// ================================================================================================
// FinishFire State
// ================================================================================================

state FinishFire
{

  function AltFire( float F );


Begin:
//  Pawn(Owner).bAltFire = 0;
  if (Pawn(Owner) == none || Pawn(Owner).bFire == 0)
  {
    Adjuster = 0;
    InitialRounds = 0;
    FinishAnim();
    bFirstFire = True;
    if (Pawn(Owner) == none)
      stop;
    if ( (AmmoType != None) && ( AmmoType.AmmoAmount <= 0 ) )
      Pawn( Owner ).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  }
  if( ( AmmoType != None ) && ( AmmoType.AmmoAmount <= 0 ) )
  {
    FinishAnim();
    HandleNoAmmo();  //Goto Weapon that has Ammo
  }
  Finish();
}


// ================================================================================================
// NormalFire State
// ================================================================================================

state NormalFire
{
  ignores Fire;
  function Tick( float DeltaTime )
  {
    tickCount+=deltatime;
    if (tickCount>=0.06){
      TickCount-=0.06;
      bFireDelay=false;
    }
    if( Owner == None )
    {
      AmbientSound = None;
    }
    else
      SoundVolume = 255 * B227_SoundDampening();
  }


  function AnimEnd()
  {
    if (Pawn(Owner) == none)
      return;

    if( AnimSequence != 'AltFire' || !bAnimLoop )
    {
      if (Pawn(Owner).bFire != 0)
      {
        LoopAnim('Fire', 1.95 );
        if (Affector != none && ++B227_FireEffectCount >= 3)
        {
          Affector.FireEffect();
          B227_FireEffectCount = 0;
        }
      }
    }

    if (Pawn(Owner).bFire == 0 || AmmoType.AmmoAmount <= 0)
    {
      GotoState( 'FinishFire' );
    }
  }




/*  function AltFire( float Value )
  {
    Enable( 'Tick' );

    if(bAltFireReady )
    {
      CheckVisibility();
      if( PlayerPawn( Owner ) != None )
      {
        PlayerPawn( Owner ).ShakeView( 0.35, 250, 5 );
      }
      SoundVolume = 255 * Pawn( Owner ).SoundDampening;
      bPointing = True;
      ShotAccuracy = 0.0;
      PlayAltFiring();
      GotoState( 'AltFiring' );
    }
    else
    {
      Pawn( Owner ).bAltFire = 0;
      if (Pawn(Owner).bFire==0)
       GoToState( 'Idle' );
    }
  }
   */



  function BeginState()
  {
    AmbientSound = FireSound;
    tickcount=0;
    bFireDelay=true;
    Enable('tick');
  }




  function EndState()
  {
    local float Damping;

    if( Pawn(Owner) == None )
    {
      Damping = 1;
    }
    else
    {
      Damping = Pawn( Owner) .SoundDampening;
    }

    AmbientSound = None;
    if (Owner != none)
      Owner.PlaySound(sound'ChainEnd3', SLOT_Misc, 3.0 * Damping);
    else
      PlaySound(sound'ChainEnd3', SLOT_Misc, 3.0 * Damping);
    Super.EndState();
  }


Begin:
  SetLocation( Owner.Location );
  while (bFireDelay) //hold..
    Sleep(0.0);
  bFireDelay=true;
  Tick(0.0); //hack for high deltas...
  SetUpProjectile();

  if (Pawn(Owner) == none || Pawn(Owner).bFire == 0 || AmmoType.AmmoAmount <= 0 || owner.region.zone.bwaterzone)
  {
    GotoState( 'FinishFire' );
  }

  Goto( 'Begin' );
}

// ================================================================================================
// AltFiring State
// ================================================================================================

state AltFiring
{
  ignores Fire, AltFire, AnimEnd;

  function ShortFire()
  {
    ProjectileFire( AltProjectileClass, AltProjectileSpeed, true );
    Pawn( Owner ).bFire = 0;
  }

  function Tick( float DeltaTime )
  {
    if( Owner == None )
    {
      AmbientSound = None;
    }

    if (Pawn(Owner) != none && PlayerPawn(Owner) == none && FRand() > AltReFireRate)
    {
      Pawn(Owner).bFire = 0;
    }
  }

  function EndState()
  {
    AmbientSound = None;
  }

Begin:
  if (Owner != none)
    SetLocation(Owner.Location);
  ShortFire();
  FinishAnim();
  PlayAnim( 'Still' );
  sleep(1.0);
  PlayAltFiring();
  FinishAnim();
  Finish();
}

// ================================================================================================
// Idle State
// ================================================================================================

state Idle
{

Begin:
  FinishAnim();
  if (Pawn(Owner) == none)
    stop;
  if( ( AmmoType != None ) && ( AmmoType.AmmoAmount <= 0 ) )
  {
    FinishAnim();
    Pawn( Owner ).StopFiring();
    HandleNoAmmo();  //Goto Weapon that has Ammo
  }

  if( Pawn( Owner ).bFire != 0 && AmmoType.AmmoAmount > 0 && !owner.region.zone.bwaterzone)
    Fire( 0.0 );

  if( Pawn( Owner ).bAltFire != 0 && AmmoType2.AmmoAmount > 0  )
    AltFire( 0.0 );

  PlayAnim( 'Still' );
  bPointing = False;
  Disable( 'AnimEnd' );
  PlayIdleAnim();
}

defaultproperties
{
     AmmoName2=Class'XidiaMPack.CarGrenadeAmmo'
     PickupAmmo2Count=6
     AmmoName=Class'XidiaMPack.CARifleClip'
     PickupAmmoCount=300
     bInstantHit=True
     bRapidFire=True
     FireOffset=(X=10.000000)
     AltProjectileClass=Class'XidiaMPack.Xidiagrenade'
     shakemag=200.000000
     shaketime=0.000500
     shakevert=16.000000
     AIRating=0.400000
     RefireRate=30.000000
     AltRefireRate=0.300000
     FireSound=Sound'XidiaMPack.CARifle.ChainGun3'
     AltFireSound=Sound'XidiaMPack.CARifle.CARifleShell'
     SelectSound=Sound'XidiaMPack.CARifle.CARifleSelect'
     AutoSwitchPriority=4
     InventoryGroup=3
     PickupMessage="You got the Combat Assault Rifle v 2.0"
     ItemName="Combat Assault Rifle"
     PlayerViewOffset=(X=3.250000,Y=-0.900000,Z=-1.450000)
     PlayerViewMesh=LodMesh'XidiaMPack.Car1st'
     PickupViewMesh=LodMesh'XidiaMPack.CARpickup'
     ThirdPersonMesh=LodMesh'XidiaMPack.Car3rd'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     LODBias=4.000000
     Mesh=LodMesh'XidiaMPack.CARpickup'
     bNoSmooth=False
     CollisionHeight=8.000000
}
