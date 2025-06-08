// ============================================================
// OLweapons.OLDMmag: (sub-machine mag)Story:  When I first compiled the lweapons package, this weapon screwed up and had this insane fire rate.  I took the weapon out changed the alternate and killed animation bugs and here it is now!!!!!!
// Psychic_313: unchanged
// ============================================================

class OLSMmag expands UIweapons;

#exec OBJ LOAD FILE="OLweaponsResources.u" PACKAGE=OLweapons

var() int hitdamage;
var float tickyo; //client-stuff.....
var  float AltAccuracy;
var int ClipCount, i;
var vector X,Y,Z, Dir;  //to throw backwards with "shotgun" fire....
var bool bIsDucking, nowfire; //recoil different if pawn is ducking.....
var byte firstfire, newclipanim; //for client stuff.....
replication
{
  // Things the server should send to the client.
  reliable if( bNetOwner && (Role==ROLE_Authority) )
    clipcount;
}

function float RateSelf( out int bUseAltMode )                                   //UsAaR33:  edited eightball botcode
{
  local float EnemyDist, Rating;
  local vector EnemyDir;
  local Pawn P;

  // don't recommend self if out of ammo
  if ( AmmoType.AmmoAmount <=0 )
    return -2;

  // by default use regular mode
  bUseAltMode = 0;
  P = Pawn(Owner);
  if ( P.Enemy == None )
    return AIRating;

  EnemyDir = P.Enemy.Location - Owner.Location;
  EnemyDist = VSize(EnemyDir);
  Rating = AIRating;

  // use alt if fairly close (and we don't need to worry about reload times)
  if ( EnemyDist < 360 &&Clipcount>5)
  bUseAltMode = 1;
  return rating;
  }
function AltFire( float Value )
{
  bPointing=True;
  AltAccuracy = 0.4;
  CheckVisibility();
  bCanClientFire = true;
  if (AmmoType.AmmoAmount>0)
  {
      //Pawn(Owner).PlayRecoil(5 * FiringSpeed);
      if ( PlayerPawn(Owner) != None )
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    //PlayAnim('T1', 1.3, 0.05);
    ClientAltFire(value);
    GotoState('AltFiring');
  }
}

function bool ClientFire( float Value )  //to play sound.....
{
  if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
  {
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
    Owner.PlaySound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
    if ( Role < ROLE_Authority )
      GotoState('ClientFiring');
    return true;
  }
  return false;
}
function Fire(float Value)
{
  if ( AmmoType == None )
  {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if ( AmmoType.UseAmmo(1) )
  {
    clipcount++;
    GotoState('NormalFire');
    bCanClientFire = true;
    bPointing=True;
    ClientFire(value);

      Pawn(Owner).PlayRecoil(5*FiringSpeed);
    TraceFire(0.05);
  //pawn(owner).GetAxes(Rotation, X,Y,Z);    //read rotation...

   GetAxes(pawn(Owner).ViewRotation,x,y,z);
   x=normal(x);
  //Dir = Normal(Acceleration);
  //If (Pawn(Owner).GetAnimGroup(Pawn(Owner).animsequence) != 'ducking'){
  if (pawn(owner).baseeyeheight!=0){
    pawn(Owner).SetLocation(pawn(Owner).Location+vect(0,0,15));                            //kick back.....
    pawn(Owner).Velocity-=(257*X);
  }
  else
    bIsDucking=True;     //ducking
  }
}

function PlayFiring()
{
 loopAnim('Shoot0',5,0.05);
 }


// set which hand is holding weapon
function setHand(float Hand)
{
  Super.SetHand(Hand);
  if ( Hand == 1 )
    Mesh = mesh'AutoMagL';
  else
    Mesh = mesh'AutoMagR';
}

///////////////////////////////////////////////////////
state NormalFire
{
ignores Fire, AltFire, AnimEnd;

function bool SplashJump()
  {
    return true;
  }

Begin:
  //FinishAnim();
  Sleep(0.07); //too fast to be anim based......
  if (ClipCount>35) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) ){
    GotoState('Idle'); }
  else if (ClipCount>=40){ GoToState('NewClip'); }
  else if ( Pawn(Owner).bFire!=0 ) Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0 )Global.AltFire(0);
  GoToState('Idle');
}


////////////////////////////////////////////////////////
function playeject(){
  PlayAnim('Eject',1.375,0.05);
  Owner.PlaySound(Misc2Sound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
  newclipanim=1;
}

function playdownclip(){
  PlayAnim('Down',1.1,0.05);
  newclipanim=2;
}

function playselectclip(){
  Owner.PlaySound(SelectSound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
  PlayAnim('Select',1.4666667,0.07);
  newclipanim=3;
}
state NewClip
{
ignores Fire, AltFire;
 begin:
  //bcanclientfire=false;
  //hack sorta to play cockgun (only works if the mesh is in wating state).  I like Hasanim!!!!
  if ((pawn(owner)!=None)&&(pawn(owner).GetAnimGroup(pawn(owner).AnimSequence) == 'waiting')&&(pawn(owner).hasanim('cockgun')))
  Pawn(owner).PlayAnim('CockGun',, 0.3);
  Playeject();
  FinishAnim();
  Playdownclip();
  FinishAnim();
  If (39<ammotype.ammoamount)
  ClipCount = 0;
  else
  ClipCount = 40-ammotype.ammoamount;
  Playselectclip();
  FinishAnim();
//  bcanclientfire=true;
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( Pawn(Owner).bFire!=0 )
    Global.Fire(0);
  else if ( Pawn(Owner).bAltFire!=0 )
    Global.AltFire(0);
  else GotoState('Idle');
}

////////////////////////////////////////////////////////
function PlayAltFiring()
{
 PlayAnim('T1', 1.3, 0.05);
 firstfire=1;
}

function PlayAltstart()
{
PlayAnim('Shot2a', 1.2, 0.05);
firstfire=0;
}
function Playaltend(){
PlayAnim('Shot2c', 0.9, 0.05);
firstfire=3;
}

function PlayShotGunFiring()
{
  if ( Affector != None )
    Affector.FireEffect();
  if ( PlayerPawn(Owner) != None &&playerpawn(owner).player.isa('ViewPort'))
  {
    PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
  }
  //bMuzzleFlash++;
Owner.PlaySound(AltFireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
  PlayAnim('Shot2b', 0.4, 0.05);
firstfire=2;
}

state AltFiring
{
ignores Fire, AltFire, animend;

Begin:
  FinishAnim();
Repeater:
  if (AmmoType.ammoamount>0)
  {
    Playaltstart();
  FinishAnim();
    GetAxes(pawn(Owner).ViewRotation,x,y,z);
    x=normal(x);
    //X=(FRand()+5)*10;
    //If(pawn(owner).GetAnimGroup(Pawn(Owner).animsequence) != 'ducking'){ //only happens if standing up.....
    if (pawn(owner).baseeyeheight!=0){
      pawn(Owner).SetLocation(pawn(Owner).Location+vect(0,0,15));
      pawn(Owner).Velocity-=(849*X); //simple little thingy.....
    }
    if ( PlayerPawn(Owner) != None )
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    ClipCount++;
    TraceFire(AltAccuracy);
    AmmoType.UseAmmo(1);
    for (i = 0; i< 9; i++){
    If (ClipCount<40){
    AmmoType.UseAmmo(1);
    clipcount++; //if there is stuff in the clip then there's ammo...
    AltAccuracy = (frand()+1)*1.62;//wierd accuracy calculation....spices up the accuracy even more :D
    //If(Pawn(Owner).GetAnimGroup(Pawn(Owner).animsequence) == 'ducking')        //aim becomes a little better
    if (pawn(owner).baseeyeheight==0)
      AltAccuracy/=2.5;
    TraceFire(AltAccuracy);
    }}

    PlayShotGunFiring();
    //throw backwards.....
    FinishAnim();
  }
  if ( AltAccuracy < 3 )
    AltAccuracy += 0.5;
  //if (ClipCount>15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
  Playaltend();
  FinishAnim();
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( Pawn(Owner).Weapon != Self )
    GotoState('Idle');
  else if ((Pawn(Owner).bAltFire!=0)
    && AmmoType.AmmoAmount>0 && ClipCount<40)
  {
    //if ( PlayerPawn(Owner) == None )
      //Pawn(Owner).bAltFire = int( FRand() < AltReFireRate );
       Goto('Repeater');
  }
  PlayAnim('T2', 0.9, 0.05);
  FinishAnim();
  Finish();
}


function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
  local shellcase s;
  local vector realLoc;

  realLoc = Owner.Location + CalcDrawOffset();
  if (frand()<0.31415926){     //we don't want too many shell cases....
  s = Spawn(class'ShellCase',Pawn(Owner), '', realLoc + 20 * X + FireOffset.Y * Y + Z);
  if ( s != None )
    s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);}

  if (B227_ShouldTraceFireThroughWarpZones())
    B227_WarpedTraceFire(self, B227_FireStartTrace, B227_FireEndTrace, 8, Other, HitLocation, HitNormal, X);

  if (Other == Level)
    Spawn(class'OSHeavyWallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
  else if ((Other != self) && (Other != Owner) && (Other != None) )
  {
    if ( FRand() < 0.2 )
      X *= 5;
    Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0*X, 'shot');
    if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
      spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
  }
}

simulated function PostRender( canvas Canvas )  //show clip
{
  local float multiplier;
  Super.PostRender(Canvas);
  if (PlayerPawn(Owner) != None)
  {       //HUD only for playerpawns.....
      if (playerpawn(owner).myhud.isa('challengehud'))
      multiplier=0.8;
      else
      multiplier=0.9;
      Canvas.DrawColor.B = 0;
    if (clipcount > 30 ){       //set colour according to clipcount.....
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
            Canvas.DrawText("Clip: "$40-clipcount);

    Canvas.Reset();
    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;
  }
}

 //so its immediately called
state Active
{
    function bool PutDown()
  {
    if ( bWeaponUp || (AnimFrame < 0.75) )
      GotoState('DownWeapon');
    else
      bChangeWeapon = true;
    return True;
  }

  function BeginState()
  {
    bChangeWeapon = false;
  }
Begin:
If (39<ammotype.ammoamount)                   //gotta make sure we have enough ammo to fill the clips....
  ClipCount = 0;
  else
  ClipCount = 40-ammotype.ammoamount;
  FinishAnim();
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  bWeaponUp = True;
  bCanClientFire = true;

  /*-if ( (Level.Netmode != NM_Standalone) && Owner.IsA('TournamentPlayer')
    && (PlayerPawn(Owner).Player != None)
    && !PlayerPawn(Owner).Player.IsA('ViewPort') )
  {
    if ( bForceFire || (Pawn(Owner).bFire != 0) )
      TournamentPlayer(Owner).SendFire(self);
    else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
      TournamentPlayer(Owner).SendAltFire(self);
    else if ( !bChangeWeapon )
      TournamentPlayer(Owner).UpdateRealWeapon(self);
  }*/
  Finish();
}

function Finish()
{
  if ( bChangeWeapon )
    GotoState('DownWeapon');
  else if ( PlayerPawn(Owner) == None )
    Super.Finish();
  else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
    GotoState('Idle');
  else if (ClipCount>=40) GoToState('NewClip');
  else if ( Pawn(Owner).bFire!=0 )
    Global.Fire(0);
  else if (Pawn(Owner).bAltFire!=0 )
    Global.AltFire(0);
  else
    GotoState('Idle');
}

function PlayIdleAnim()
{
local float randy;
  if ( Mesh == PickupViewMesh )
    return;
    randy=frand();
    if (randy>0.95 ) PlayAnim('Twiddle',0.6,0.3);
    else if (randy>0.9 ) PlayAnim('Twirl',0.6);                     //I utilitized the unused twirl animation....
    else LoopAnim('Sway1',0.02, 0.3);
    }
state Idle
{
  function AnimEnd()
  {
    PlayIdleAnim();
  }

  function bool PutDown()
  {
    GotoState('DownWeapon');
    return True;
  }

  event Tick(float DeltaTime) {


     If (Pawn(Owner)!=None&&ammotype!=none) {
      If(PlayerPawn(Owner)!=None){
      //bextra3...only used by mods... same reload key as serpentine..... that ain't in UT, though...so its a unique key :D
      If ((40-clipcount<AmmoType.AmmoAmount)&&(playerpawn(owner).bextra3!=0)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');   }          //just reload the damn thing......

      else {//cheesy botcode..... anyone else who has this that isn't a player is a bot or scripted pawn....
      //no one's pissing this guy off and he doesn't have a full clip... might as well reload
      If ((40-clipcount<AmmoType.AmmoAmount)&&(Pawn(Owner).enemy==None)&&(clipcount!=0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');  }           //just reload the damn thing......
      }
  }

Begin:
  bPointing=False;
  if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
    Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  LoopAnim('Sway1',0.02, 0.1);
  //SetTimer(1.5,True);
  if ( /*bFireMem ||*/ Pawn(Owner).bFire!=0 ) Global.Fire(0.0);
  if ( /*bAltFireMem ||*/ Pawn(Owner).bAltFire!=0 ) Global.AltFire(0.0);
}

defaultproperties
{
     hitdamage=17
     wepcanreload=True
     WeaponDescription="Classification: Sub-Machine Pistol\n\nPrimary Fire: Extremely rapid shots.  Fairly accurate.\n\nSecondary Fire: Fire 10 bullets out at once! Extremely unaccurate however.\n\nTechniques: Remember that the huge recoil will slow you down.  Also, firing when crouching will enable you to control the weapon better, resulting in greater accuracy and less recoil."
     AmmoName=Class'OLweapons.osmagammo'
     PickupAmmoCount=400
     bInstantHit=True
     bAltInstantHit=True
     FiringSpeed=1.500000
     FireOffset=(Y=-10.000000,Z=-4.000000)
     MyDamageType=shot
     shakemag=200.000000
     shakevert=4.000000
     AIRating=0.900000
     RefireRate=0.700000
     AltRefireRate=0.900000
     FireSound=Sound'UnrealShare.AutoMag.shot'
     AltFireSound=Sound'UnrealShare.Stinger.StingerAltFire'
     CockingSound=Sound'UnrealShare.AutoMag.Cocking'
     SelectSound=Sound'UnrealShare.AutoMag.Cocking'
     Misc1Sound=Sound'UnrealShare.flak.Click'
     Misc2Sound=Sound'UnrealShare.AutoMag.Reload'
     DeathMessage="%o stood no chance against %k's %w."
     AutoSwitchPriority=10
     InventoryGroup=10
     PickupMessage="You got the SMP 7243.  Now kick some @$$!"
     ItemName="SMP 7243"
     PlayerViewOffset=(X=4.800000,Y=-1.700000,Z=-2.700000)
     PlayerViewMesh=LodMesh'UnrealShare.AutoMagL'
     PickupViewMesh=LodMesh'UnrealShare.AutoMagPickup'
     ThirdPersonMesh=LodMesh'UnrealShare.auto3rd'
     StatusIcon=Texture'botpack.Icons.UseAutoM'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'botpack.Icons.UseAutoM'
     Mesh=LodMesh'UnrealShare.AutoMagPickup'
     bNoSmooth=False
     MultiSkins(1)=Texture'OLweapons.newmagskin'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
     Mass=19.000000
}
