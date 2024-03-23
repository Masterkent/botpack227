// ===============================================================
// SevenB.SevenCarRifle: imported from Return To Na Pali.. slightly modified.
// ===============================================================

class SevenCarRifle expands UIweapons;

//#exec OBJ LOAD FILE=..\Textures\FireEffect18.utx PACKAGE=UPak.CARifle

// First Person View

#exec OBJ LOAD FILE="SevenBResources.u" PACKAGE=SevenB

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
var int ClipCount;
var float LastShellSpawn;

var bool bInvGroupChecked;

var float B227_FireEffectTimer;

replication
{
  reliable if (role==role_authority && bNetOwner)
    AmmoType2, clipcount;
}

//duel-ammo code:
function SwapAmmo(){
  local ammo tmp;
  tmp=AmmoType;
  AmmoType=AmmoType2;
  AmmoType2=tmp;
  bUseAlt=(AmmoType.class==AmmoName2);
  if (buseAlt)
  	reFireRate=0.25;
  else
  	reFireRate=default.Refirerate;
}

simulated function ammo GetBulletAmmo(){  //returns "bullet" ammo
  if (AmmoType.class==AmmoName)
	 return AmmoType;
  else
  	return AmmoType2;
}

// if (role<role_authority&&owner!=none&&pawn(owner).weapon==self)
 //   pawn(owner).clientmessage("SMMAG in state"@GetStateName()@"new clip anim is"@newclipanim@"Anim:"@animsequence@"Animating?"@IsAnimating()@"Animdone?"@banimfinished);

simulated function PostRender( canvas Canvas )
{
  local PlayerPawn P;
  local float multiplier;
  local float xf, yf;
  Super.PostRender(Canvas);
  P = PlayerPawn(Owner);
  if  (P != None){
    if(P.Handedness != 1|| p.myhud.isa('challengehud'))
			multiplier=0.8;
		else
			multiplier=0.9;
      Canvas.DrawColor.B = 0;
    if (clipcount > 44 ){       //set colour according to clipcount.....
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 0;}
    else{
    Canvas.DrawColor.R = 0;
    Canvas.DrawColor.G = 255;}
      if(PlayerPawn(Owner).Handedness != 1){
    			Canvas.SetPos(0.05 * Canvas.ClipX , multiplier * Canvas.ClipY);
          Canvas.Style = ERenderStyle.STY_Translucent;
          class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true);  }
        else {
            Canvas.SetPos(0.85 * Canvas.ClipX , multiplier * Canvas.ClipY);
            Canvas.Style = ERenderStyle.STY_Translucent;
            class'FontInfo'.static.B227_SetStaticScaledSmallFont(Canvas, true); }
            Canvas.DrawText("Clip: "$50-clipcount);
					if (ChallengeHud(p.myhud) != none && bUseAlt){
						Canvas.TextSize("Clip: 00",xf,yf);
            if(PlayerPawn(Owner).Handedness != 1)
							Canvas.SetPos(0.05 * Canvas.ClipX +xf, multiplier * Canvas.ClipY-20*challengehud(p.myhud).scale);
            else
							Canvas.SetPos(0.85 * Canvas.ClipX +xf, multiplier * Canvas.ClipY-20*challengehud(p.myhud).scale);
    				Canvas.Style=ERenderStyle.Sty_Translucent;
    				Canvas.DrawRect(Texture'gAmmo',40*challengehud(p.myhud).scale,40*challengehud(p.myhud).scale);
    				Canvas.Style=ERenderStyle.Sty_Normal;
          }
	if (isinstate('clientnewclip')||isinstate('newclip'))
  	bOwnsCrossHair=true;
  else
    bOwnsCrossHair = false;

    Canvas.Reset();
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;
  }
}

function float RateSelf( out int bUseAltMode )
{
  local float EnemyDist, Rating;
  local bool bRetreating;
  local vector EnemyDir;
  local Pawn P;

  // don't recommend self if out of ammo
  if ( AmmoType.AmmoAmount <=0 ||(!bUseAlt && owner.region.zone.bwaterzone)){
  	if (AmmoType2.AmmoAmount<=0)
	    return -2;
	  else
	  	bUseAltMode=1;
	}

  // by default keep mode
  bUseAltMode = 0;
  P = Pawn(Owner);
  if ( P.Enemy == None )
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
    if (!bUseAlt)
      bUseAltMode = 1;
  }
  else if ( EnemyDist < -1.5 * EnemyDir.Z && lastSwitchTime-level.timeseconds > 1.5){
     bUseAltMode = int( FRand() < 0.1 );
  }
  else
  {
    // grenades are good covering fire when retreating
    bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );
    bUseAltMode = 0;
    if ( bRetreating && (EnemyDist < 1000) && (FRand() < 0.6) && !bUseAlt && (level.timeseconds-lastSwitchTime) > 1.5)
      bUseAltMode = 1;
  }
  //verify ammo!
  if (bUseAltMode==1){
  	if (AmmoType2.AmmoAmount<=0)
  		bUseAltMode=0;
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
  if (AmmoType2.AmmoAmount>0){
    global.AltFire(0);
    return true;
  }
  else
    Pawn( Owner ).SwitchToBestWeapon();
}

function GiveAmmo( Pawn Other )
{
	super.GiveAmmo(Other);
	if ( AmmoName2 != None ){
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
	/*clip stuff*/
  If (49<GetBulletAmmo().ammoamount)                   //gotta make sure we have enough ammo to fill the clips....
  	ClipCount = 0;
  else
  	ClipCount = 50-GetBulletAmmo().ammoamount;
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
        && (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
          WeaponSet(P);
    }
    if ( AmmoType2 != None )
    {
      OldAmmo = AmmoType2.AmmoAmount;
      if ( AmmoType2.AddAmmo(SevenCarRifle(Item).PickupAmmo2Count) && (OldAmmo == 0)
        && (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup )
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
      class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(P, PickupMessageClass, 0, None, None, item.Class );
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
	if (Level.Game != none)
	{
		bInvGroupChecked = true;
		if (Level.Game.bDeathMatch)
			InventoryGroup = 3;
		else if (tvsp(Level.Game) != none || tvcoop(Level.Game) != none)
			InventoryGroup = 10;
	}
}

function SetUpProjectile()
{
  if( ClipCount<50&&AmmoType.UseAmmo( 1 ) &&!owner.region.zone.bwaterzone){
    ClipCount++;
	TraceFire( 0.35 );
  }
  else
    GotoState( 'FinishFire' );
}

function ShakePlayer( float ShakeMod )
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
    else if (ClipCount>=50 && !bUseAlt)
			GoToState('NewClip');
    else if( Pawn( Owner ).bFire != 0 && (bUseAlt || !owner.region.zone.bWaterZone))
    {
      Global.Fire( 0 );
    }

    else if( (Pawn( Owner ).bAltFire != 0 ) ) //force fire
    {
      Pawn( Owner ).bAltFire = 0;
      Pawn( Owner ).bFire = 1;
			Global.Fire( 0 );
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
  else if (ClipCount>=50 && !bUseAlt)
		GoToState('NewClip');
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
  local vector realLoc;
  local LongShellCase s;

    realLoc = Owner.Location + CalcDrawOffset();
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

    rndDam = Rand(6) + 6;   //average = 8.5
    if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
      && (instigator.IsA('PlayerPawn') || (Bot(instigator) != none && !Bot(Instigator).bNovice)||
        (ScriptedPawn(Other) != none && (ScriptedPawn(Other).bIsBoss || level.game.difficulty>=3))) ){
        MyDamageType='Decapitated';
        rndDam*=2.2;
    }
    else
      MyDamageType='shot';
    Other.TakeDamage( rndDam, Pawn(Owner), HitLocation, rndDam * 250.0 * X, MyDamageType );
  }
	//fire cases:
	if (Level.bHighDetailMode && (Level.TimeSeconds - LastShellSpawn > 0.125)
    && (Level.Pauser=="") )
  {
	  LastShellSpawn = level.timeseconds;
		s = Spawn(class'LongShellCase',Pawn(Owner), '', realLoc + 20 * X + FireOffset.Y * Y + Z);
	  if ( s != None )
  	  s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
  }
}


function PlayFiring(){
    if (!bUseAlt){
      Owner.PlaySound( sound'ChainStart3', SLOT_Misc, 3.0 * Pawn( Owner ).SoundDampening, True ); //looping wave?
      SoundVolume = 255 * Pawn( Owner ).SoundDampening;
      LoopAnim( 'Fire', 1.98, 0.05 );
    }
    else{
      PlayAnim( 'AltFire', 1.5, 0.05);
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
      Affector.FireEffect();

    PlayFiring();
    /*-if ( Role < ROLE_Authority ){
      if (bUseAlt)
        GotoState('ClientAltFiring');
			else if (clipcount<50)
				GotoState('ClientFiring');
      else
				GotoState('ClientNewClip');
    }*/
    return true;
  }
  return false;
}

function bool ClientAltFire(float Value)
{
  if (AmmoType2!=none && AmmoType2.AmmoAmount > 0)
  {
//    if ( Affector != None )
//      Affector.FireEffect();
    PlayAltFiring();
    if (bCanClientFire||role==role_authority)
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
  ignores Fire, AltFire, AnimEnd;

  function bool ClientFire(float Value)
  {
    return false;
  }

  function bool ClientAltFire(float Value)
  {
    return false;
  }
  Begin:
     if (playerpawn(owner)!=none&&viewport(playerpawn(owner).player)==none&&role==role_authority) //on net must swap earlier!
       SwapAmmo();
		 finishanim();
     pawn(owner).baltfire=0;
     //-if (role==role_authority){
       if (!(playerpawn(owner)!=none&&viewport(playerpawn(owner).player)==none))
				 SwapAmmo();
       finish();
     //-}
     //-else
     //- ClientFinish();
}

function PlayAltFiring() //whatever
{
  PlayAnim( 'AltReload', 0.8, 0.05 );
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
  if( Pawn(Owner).bFire == 0 || (!bUseAlt && owner.region.zone.bWaterZone)|| clipcount>=50)
  {
    Adjuster = 0;
    InitialRounds = 0;
    FinishAnim();
    bFirstFire = True;
    if ( (AmmoType != None) && ( AmmoType.AmmoAmount <= 0 ) && (AmmoType2 != None) && ( AmmoType2.AmmoAmount <= 0 ))
      Pawn( Owner ).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  }
  if( clipcount<50 && ( AmmoType != None ) && ( AmmoType.AmmoAmount <= 0 ) )
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
    tickCount+=10*deltatime;
    if (tickCount>=0.65){
      TickCount-=0.65;
      bFireDelay=false;
    }
    if( Owner == None )
    {
      AmbientSound = None;
    }
    else
      SoundVolume = 255 * B227_SoundDampening();
    if ( Affector != None )
    {
      B227_FireEffectTimer += DeltaTime;
      if (B227_FireEffectTimer > 0.2)
      {
          B227_FireEffectTimer -= 0.2;
          Affector.FireEffect();
      }
    }
  }


  function AnimEnd()
  {
    if( AnimSequence != 'AltFire' || !bAnimLoop )
    {
      if( Pawn( Owner ).bFire != 0 )
      {
        LoopAnim('Fire', 1.95 );
      }
    }

    if( Pawn(Owner).bFire == 0 || AmmoType.AmmoAmount <= 0 )
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
    Owner.PlaySound( sound'ChainEnd3', SLOT_Misc, 3.0 * Damping);
    Super.EndState();
  }


Begin:
  SetLocation( Owner.Location );
  while (bFireDelay) //hold..
    Sleep(0.0);
  bFireDelay=true;
  Tick(0.0); //hack for high deltas...
  SetUpProjectile();

  if( Pawn(Owner).bFire == 0 || AmmoType.AmmoAmount <= 0 || owner.region.zone.bwaterzone || clipcount>=50)
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

    if( PlayerPawn( Owner ) == None && ( FRand() > AltReFireRate ) )
    {
      Pawn(Owner).bFire = 0;
    }
  }

  function EndState()
  {
    AmbientSound = None;
  }

Begin:
  SetLocation( Owner.Location );
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
  event Tick(float DeltaTime) {


     If (Pawn(Owner)!=None&&GetBulletAmmo()!=none) {
      If(PlayerPawn(Owner)!=None){
      //bextra3...only used by mods... same reload key as serpentine..... that ain't in UT, though...so its a unique key :D
      If ((50-clipcount<GetBulletAmmo().AmmoAmount)&&(playerpawn(owner).bextra3!=0)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');   }          //just reload the damn thing......

      else {//cheesy botcode..... anyone else who has this that isn't a player is a bot or scripted pawn....
      //no one's pissing this guy off and he doesn't have a full clip... might as well reload
      If ((50-clipcount<GetBulletAmmo().AmmoAmount)&&(Pawn(Owner).enemy==None)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');  }           //just reload the damn thing......
      }
  }

Begin:
  FinishAnim();
  if( ( AmmoType != None ) && ( AmmoType.AmmoAmount <= 0 ) )
  {
    FinishAnim();
    Pawn( Owner ).StopFiring();
    HandleNoAmmo();  //Goto Weapon that has Ammo
  }

  if( Pawn( Owner ).bFire != 0 && AmmoType.AmmoAmount > 0 && !owner.region.zone.bwaterzone && (clipcount<50 || bUseAlt))
    Fire( 0.0 );

  if( Pawn( Owner ).bAltFire != 0 && AmmoType2.AmmoAmount > 0  )
    AltFire( 0.0 );

  PlayAnim( 'Still' );
  bPointing = False;
  Disable( 'AnimEnd' );
  PlayIdleAnim();
}


//reloading stuff:

function PlayIdleAnim()
{
  if ( Mesh != PickupViewMesh )
    LoopAnim('Sway',0.01, 0.05);
}

//reloading:
function playdownclip(){
  PlayAnim('Down',1,0.05);
}

function playselectclip(){
  PlayAnim('Select',1,0);
}

state NewClip
{
ignores Fire, AltFire;
 begin:
  Playdownclip();
  FinishAnim();
  if ((pawn(owner)!=None)&&owner.animsequence!=''&&(pawn(owner).GetAnimGroup(pawn(owner).AnimSequence) == 'waiting')&&(pawn(owner).hasanim('cockgunL')))
    Pawn(owner).PlayAnim('CockGunL',, 0.3);
  sleep(0.2);
  If (49<GetBulletAmmo().ammoamount)
  	ClipCount = 0;
  else
  	ClipCount = 50-GetBulletAmmo().ammoamount;
  Owner.PlaySound(Sound'UnrealShare.Cocking', SLOT_None,1.0*Pawn(Owner).SoundDampening);
	sleep(0.3);
 	Playselectclip();
  FinishAnim();
  if (!bUseAlt){
		PlayAltFiring(); //why not? ;p
  	FinishAnim();
  }
//  bcanclientfire=true;
  if ( bChangeWeapon ){
    GotoState('DownWeapon');
  }
	if ( Pawn(Owner).bFire!=0 && !owner.region.zone.bwaterzone)
    Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0)
    Global.AltFire(0);
  else GotoState('Idle');
}

//temp: remove later
exec function CarDebug(){
	playerpawn(owner).clientMessage("Car in state"@GetSTateName()$".  Anim is"@AnimSequence$". bAnimLoop="$bAnimLoop);
}

defaultproperties
{
     AmmoName2=Class'SevenB.CarGrenadeAmmo'
     PickupAmmo2Count=6
     WeaponDescription="Classification: Automatic Rifle/Grenade Launcher\n\nRegular Fire Mode 1: Rifle - Fires rapid, accurate Spream of Bullets. \n\nRegular Fire Mode 2: Grenade Launcher - Launches a timed grenade that also detonates on impact with tissue.  Slow reload times\n\nSecondary Fire: Toggle Modes\n\nTechniques:  The clip drains rapidly - be sure to reload once a firefight has ended."
     AmmoName=Class'SevenB.CARifleClip'
     PickupAmmoCount=300
     bInstantHit=True
     bRapidFire=True
     FireOffset=(X=10.000000)
     AltProjectileClass=Class'SevenB.SBCarGrenade'
     shakemag=200.000000
     shaketime=0.000500
     shakevert=16.000000
     AIRating=0.680000
     RefireRate=0.990000
     AltRefireRate=0.000000
     FireSound=Sound'SevenB.CARifle.ChainGun3'
     AltFireSound=Sound'SevenB.CARifle.CARifleShell'
     SelectSound=Sound'SevenB.CARifle.CARifleSelect'
     AutoSwitchPriority=4
     InventoryGroup=3
     bAmbientGlow=False
     PickupMessage="You got the Combat Assault Rifle v 3.0"
     ItemName="Combat Assault Rifle"
     PlayerViewOffset=(X=3.250000,Y=-0.900000,Z=-1.450000)
     PlayerViewMesh=LodMesh'SevenB.Car1st'
     PickupViewMesh=LodMesh'SevenB.CARpickup'
     ThirdPersonMesh=LodMesh'SevenB.Car3rd'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     LODBias=4.000000
     Mesh=LodMesh'SevenB.CARpickup'
     bNoSmooth=False
     CollisionHeight=8.000000
     RotationRate=(Yaw=0)
}
