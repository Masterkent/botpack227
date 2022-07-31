// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvPlayer.
// The purpose of this playerpawn is to allow several features.
// 1. Ducking that affects collision.  Note that this IS possible with an inv item, but unfortunately, there is no way to stop the player from getting stuck then
// 2. Anti-telefrag:  This is easily the best way to handle it.
// 3. The ship mode.  Player flying a ship. fun..
// ============================================================

class TVPlayer expands TournamentPlayer;
//order imports:
#exec OBJ LOAD FILE="OlextrasResources.u" PACKAGE=olextras

//#exec AUDIO IMPORT FILE="Sounds\fall3.WAV" NAME="OLFALL3"

//#exec AUDIO IMPORT FILE="Sounds\fall4.WAV" NAME="OLFALL4"

//ship model:

//#exec meshmap scale meshmap=shuttle x=0.50195 y=0.50195 z=1.00391

var bool checkwall;
var (Ship) int MaxSpeed, MinSpeed;
var float SmokeRate; //smoke stuff
var bool bForceDuck; //ya, Deus Exy.  if player cannot stand up because of too small an area.
var(Sounds) sound JumpSounds[3]; //for jump altering
//Friendly traveling:
var travel int Friendlies[8]; //this is the health of friendlies.  The last digit (ones) is the type
var travel string friendlynames[8]; //the menu name of each friendly.
var /*travel */int FriendlySpeeds[8]; //groundspeed. not much is lost...  (no longer used.. not deleting as dangerous w/ bin compatibility)
var /*travel */int FriendlyMaxStepHeights[8]; //max step heights. again little is lost with conversion.        (not used anymore)
var travel float FriendlyDrawScales[8]; //size of friendly.
var travel byte FriendlyFatness[8]; //fatness
//follower special arrays:
// 0=Mercenary
// 1=1337 Mercenary
// 2=Nali Trooper
// 3=Rebel Skaarj
// 4=Rebel Skaarj Trooper
// If it is a nali/skaarj trooper then the second to last digit (tens) is a code for weapon
// 1=Dpistol 2=enf 3=bio 4=shock 5=pulse 6=rip 7=mini 8=flak 9=eightball 0=rifle
var Follower Follower[8];
var string FollowerInfo[8]; //rep'd string. tells name&type.
var int FollowerHealth[8]; //rep'd health updated each tick.
var ONPLevelInfo LInfo; //info for some options. set on server, but client must get it manually.....
var int OldHealth; //used for playership...
var bool sdump;
var float realspeed; //rep has problems
var bool bFlipped; //for support of flipping with eulers (not enough time to transfer jet to vehicle class that has quaternion support)
var vector oldvelocity; //hack for zonevelocity stuff.
var bool bDidJump;
/*var enum EPlayerMovement{
0: //normal movement
1: //complete freeze of motion.  HUD is disabled in this case.
2:  //keys are inverted.
}
*/
var byte PlayerMod;

//player vehical thing:
var TVVehicle Vehicle;

//var sound MP3; //backed up for no replication.

var float MyTime; //current level time.
var TVScoreKeeper ScoreHolder; //scoring (sp only)

var B227_PlayerShipEffects B227_PlayerShipEffects;

//STATE PLAYERSHIP: This is a state which simulates the player flying a ship.
replication{
reliable if (role==role_authority&&bnetowner) //server -> client functions & varz
  dointerpolate, ClientSetMP3, FollowerInfo, FollowerHealth, PlayerMod, Vehicle, minspeed;
reliable if (role==role_authority&&!bdemorecording) //only in net game.. not demo
  TouchTrans;
reliable if ( (!bDemoRecording || (Level.NetMode==NM_Standalone)) && Role == ROLE_Authority )
    SayMessage; //new say.
reliable if (role<role_authority)  //client -> server functions.
  FollowOrder, smovedump, CodeSend;   //ordering followers: debug stuff; console stuff respectfully.
unreliable if (role<role_authority) //unreliable server move.
  ServerJetMove;
}
Function RemoveFromFollowerList (Follower aFollower){
  local int i;
  for (i=0;i<8;i++)
    if (Follower[i]==aFollower)
      break;
  if (i==8)
    return; //not here.
  while (i<7){ //copy over
    Follower[i]=Follower[i+1];
    FollowerInfo[i]=FollowerInfo[i+1];
    FollowerHealth[i]=followerHealth[i+1];
    i++;
  }
  //final stuff:
  Follower[i]=None;
  FollowerInfo[i]="";
  FollowerHealth[i]=0;
}
//HACK FOR TELSA!
function AddVelocity( vector NewVelocity){
  ///if (Velocity!=vect(0,0,0))
     Super.AddVelocity(NewVelocity);
}
function ClientPlayTakeHit(vector HitLoc, byte Damage, bool bServerGuessWeapon){
  Super.ClientPlayTakeHit(HitLoc,Damage,bServerGuessWeapon);
  if (TVHUD(myHud)!=none)
    TVHUD(myHud).DeActivateTranslator();
}
//no damage or momentum transfer in cutscenes.
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
            Vector momentum, name damageType)
{
  if (PlayerMod!=1)
    Super.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
}

Function bool AddToFollowerList(Follower aFollower){
  local int i, j;
  for (i=0;i<8;i++){
    if (Follower[i]==none)
      break;
    if (Follower[i]==aFollower)
      return true; //already added successfully.
   }
  if (i==8)     //no space
    return false;
  Follower[i]=aFollower;
  if (aFollower.Isa('scriptedhuman'))
    j=5;
  else{
    switch (aFollower.class){
      Case class'followingmercenaryelite':
        j=1;
        break;
      Case class'NaliTrooper':
        j=2;
        break;
      Case class'RebelSkaarj':
        j=3;
        break;
      Case class'RebelSkaarjtrooper':
        j=4;
        break;
      Case class'FollowingKrall':
        j=6;
        break;
      Case class'FollowingKrallElite':
        j=7;
        break;
    }
  }
  FollowerInfo[i]=j$aFollower.MyName;
  if (j==5)
    FollowerInfo[i]=FollowerInfo[i]$chr(16)$string(ScriptedHuman(aFollower).FollowerIcon);
  FollowerHealth[i]=aFollower.Health;
  return true;
}
/*
event Possess() //handle tree shadow decal spawning
{
  local class<decal> Shadow;
  local leetpalm Tree;
  Super.Possess();
  if (level.NetMode==NM_DedicatedServer)
    return;
  if (!Player.Isa('WindowsViewport')){
    log ("WARNING: Tree Shadows not supported on Non-Windows systems.",'ONP');
    return;
  }
  if (level.EngineVersion!="432"&&Level.EngineVersion !="436"){
    log ("WARNING: Tree Shadows not supported on versions other than 432 and 436",'ONP');
    return;
  }
  Shadow=Class<Decal>(DynamicLoadObject("PalmShadow.TreeShadow",Class'class',true));
  if (Shadow==none){
    log ("WARNING: Could not locate valid PalmShadow.U package!",'ONP');
    return;
  }
  log ("Generating shadows for trees.",'ONP');
  ForEach AllActors(class'leetpalm',Tree)
    Tree.SpawnShadow(Shadow);
}
*/
//HACK for weapon power-ups
function Inventory FindInventoryType( class DesiredClass )
{
  if (DesiredClass==class'OldPistol')
    DesiredClass=class'NoAmmoDPistol';
  return Super.FindInventoryType(DesiredClass);
}

event UpdateEyeHeight(float DeltaTime){ //update follower info on server
  local int i;
  Super.UpdateEyeheight(deltatime);
  if (role<role_authority)
    return;
  for (i=0;i<8;i++){
    if (follower[i]!=none)
      Followerhealth[i]=Follower[i].health;
    else
      Followerhealth[i]=0;
  }
}


simulated function PostBeginPlay() //new shadow
{
  Super(playerpawn).PostBeginPlay();
  //-if ( Level.NetMode != NM_DedicatedServer )
  //-  Shadow = Spawn(class'TVshadow',self);
  if (Level.NetMode != NM_DedicatedServer)
    class'UTC_Pawn'.static.B227_InitPawnShadow(self);
  if ( (Role == ROLE_Authority) && (Level.NetMode != NM_Standalone) )
    BossRef = class<Actor>(DynamicLoadObject("Botpack.TBoss",class'Class'));

  b3DSound = bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3dHardware"));
}

simulated function FootStepping()
{
  if ( FootRegion.Zone.bWaterZone )
  {
    PlaySound(WaterStep, SLOT_Interact, 1, false, 1000.0, 1.0);
    return;
  }
  //-if (TvShadow(shadow)!=none&&tvshadow(shadow).NumSounds!=0)
  //-  PlaySound(TVshadow(shadow).CurFootSound[rand(TVshadow(shadow).NumSounds)], SLOT_Interact, 2.2, false, 1000.0, 1.0);
  //else
    Super.FootStepping();
}

event TravelPostAccept(){ //followers (needed here for co-op)
  super.TravelPostAccept();
  if (level.game==none)
    return;
  if (level.game.isa('TVsp'))
    TVSp(level.game).LoadFriendlies(self);
  else if (level.game.isa('tvcoop'))
    TvCoop(level.game).LoadFriendlies(self);
}
simulated function timer(){ //smoke timer
local ut_SpriteSmokePuff b;
local vector X, Y, Z;
  if (!bcanfly){
    if (role==role_simulatedproxy)
      SetTimer(0.3,false); //try again later if other playerpawn.
    return;
  }

  if ( Region.Zone.bWaterZone )
  {
    SetTimer(0.3, false);
    Return;
  }
  //-if (shadow!=none){
  //-  shadow.destroy();
  //-  shadow=none;
  //-}
  GetAxes(rotation,X,Y,Z);
  X=location-X*(0.8*collisionradius-collisionheight*airspeed/350);
  Y*=collisionradius/7; //offset of engines.
  Z*=collisionheight/7;
  if ( Level.bHighDetailMode )
  {
    if ( Level.bDropDetail ){
      Spawn(class'LightSmokeTrail',,,X+Y-Z);
      Spawn(class'LightSmokeTrail',,,X-Y-Z);
    }
    else{
      Spawn(class'UTSmokeTrail',,,X+Y-Z);
      Spawn(class'UTSmokeTrail',,,X-Y-Z);
    }
    SmokeRate = 70/AirSpeed;
  }
  else
  {
    SmokeRate = 0.1;
    b = Spawn(class'ut_SpriteSmokePuff',,,X+Y-Z);
    b.RemoteRole = ROLE_None;
    b = Spawn(class'ut_SpriteSmokePuff',,,X-Y-Z);
    b.RemoteRole = ROLE_None;

  }
  SetTimer(SmokeRate, false);
}
function TouchTrans(TvTranslatorEvent Trans,optional bool bUnTouch){
  if (Trans==none)
    return;
  if (bUnTouch)
    Trans.UnTouch(self);
  else
    Trans.Touch(self);
}
//invert stuff:
event PlayerInput( float DeltaTime )
{
  local byte btemp;
  if (PlayerMod==2){
    aBaseY*=-1;
    aBaseX*=-1;
    aStrafe*=-1;
    aMouseX*=-1;
    aMouseY*=-1;
    aTurn*=-1;
    bpressedjump=(aup<0&&!bDidJump);  //special jump/duck stuff...
    bDidJump=(aup<0);
    bduck=byte(aup>0);
    aUp*=-1;  //now invert it :)
    btemp=bfire;
    bfire=baltfire;
    baltfire=btemp;
  }
  Super.PlayerInput(deltatime);
  if (Level.Pauser!=""||level.netmode!=nm_standalone||PlayerMod==1||Health==0||IsInState('GameEnded'))
    return;
  //time stuff is here as easiest place to get delta
  MyTime+=deltatime;
  if (ScoreHolder==none)
    return;
  if (IsInState('CheatFlying'))
    ScoreHolder.AddPoints(-400*deltatime); //cheater punishing.
  if (Health>0&&Weapon!=none){
    if (Weapon.IsA('Translocator'))
      bTemp=10;
    else if (Weapon.IsA('SuperShockRifle'))
      bTemp=11;
    else
      bTemp=Weapon.InventoryGroup%10;
    ScoreHolder.Weapons[btemp].TimeHeld+=deltatime;
  }
}
exec function Summon( string ClassName )
{
  if (ScoreHolder!=none)
    ScoreHolder.AddPoints(-10000); //cheater punishing.
  Super.Summon (ClassName);
}
exec function CheatView( class<actor> aClass )
{
  Super.CheatView(aClass);
  if (ScoreHolder!=none)
    ScoreHolder.AddPoints(-3000); //cheater punishing.
}
exec function Amphibious()
{
  Super.Amphibious();
  if (ScoreHolder!=none)
    ScoreHolder.AddPoints(-5200); //cheater punishing.
}
exec function AllAmmo()
{
  Super.AllAmmo();
  if (ScoreHolder!=none)
    ScoreHolder.AddPoints(-8900*(rand(5)+10)); //cheater punishing.
}
exec function KillAll(class<actor> aClass)
{
  Super.KillAll(aClass);
  if (ScoreHolder!=none)
    ScoreHolder.AddPoints(-12000*(rand(2)+5));
}
exec function KillPawns()
{
  Super.KillPawns();
  if (ScoreHolder!=none)
    ScoreHolder.AddPoints(-12000*(rand(2)+5));
}
simulated function postnetbeginplay(){ //client smoke timer for non-autonomous proxies.
super.postnetbeginplay();
//-if (role==role_simulatedproxy)
//-  SetTimer(0.3,false); //smoke crap
}
exec function smovedump() //testing
{
  sdump=!sdump;
}
//hack to detect player talk time.
simulated function UTF_ClientPlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl)
{
  local actor SoundPlayer;
  local float vol;
  vol=16.0;
  LastPlaySound = Level.TimeSeconds;  // so voice messages won't overlap
  if (!bInterrupt){
    if (Health<=0)
      return;
    LastPlaySound+=GetSoundDuration(Asound);
    if (bVolumeControl)
      vol=32.0;
  }

  if ( ViewTarget != None )
    SoundPlayer = ViewTarget;
  else
    SoundPlayer = self;

  SoundPlayer.PlaySound(ASound, SLOT_None, vol, bInterrupt);
  SoundPlayer.PlaySound(ASound, SLOT_Interface, vol, bInterrupt);
  SoundPlayer.PlaySound(ASound, SLOT_Misc, vol, bInterrupt);
  SoundPlayer.PlaySound(ASound, SLOT_Talk, vol, bInterrupt);
}
//Player Jumped
function DoJump( optional float F )
{
  if ( CarriedDecoration != None )
    return;
  if ( !bIsCrouching && (Physics == PHYS_Walking) )
  {
    if ( !bUpdating&&lastplaysound<level.timeseconds)  //rand sounz
      PlaySound(JumpSounds[rand(2)], SLOT_Talk, 1.5, true, 1200, 1.0 );
      //-PlaySound(JumpSounds[rand(3)], SLOT_Talk, 1.5, true, 1200, 1.0 );
    if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
      MakeNoise(0.1 * Level.Game.Difficulty);
    PlayInAir();
    if ( bCountJumps && (Role == ROLE_Authority) && (Inventory != None) )
      Inventory.OwnerJumped();
    Velocity.Z = JumpZ;
    if ( (Base != Level) && (Base != None) )
      Velocity += Base.Velocity;
    SetPhysics(PHYS_Falling);
  }
}
//used in playerjet state:
function ServerJetMove
(
  float TimeStamp,
  vector InAccel,
  vector ClientLoc,
  int Speed,
  bool bIsFlipped,
  optional byte OldTimeDelta,
  optional int OldAccel
);
//int based
static final operator(18) int mod  ( int A, int B )
{
  if( (A % B) >= 0 )
    return A % B ;
  else
    return  (A % B ) + B ;
}
final static function Approach (out int value, float toAdd, int Approach){
  if (value>Approach){
    value-=toAdd;
    if (value<Approach)
      value=Approach;
  }
  else if (value<Approach){
    value+=toadd;
    if (value>Approach)
      value=Approach;
  }
}
//also used: (for acceleration) (returns goal as a delta!!!!!!!) rate MUST be positive!
static function ApproachAngle (out int Angle, out int Goal, float Rate){
  local int oldangle;
  OldAngle=Angle;
  Goal=SetAngleDifference(Goal,Angle);
  Approach(angle,Rate,Goal);
  Goal=Angle-OldAngle;
  Angle=Angle mod 65536;
}
static function int SetAngleDifference(int Angle1, int Angle2){   //sets up subtraction
  local bool bUp;
  if (((Angle1-Angle2) mod 65536) <32768)
    bUp=true;
  if (bUp&&Angle1<Angle2)
    Angle1+=65536;
  else if (!bUp&&Angle1>Angle2)
    Angle1-=65536;
  return Angle1;
}
static function int AngleDifference(int Angle1, int Angle2){ //actual subtractor
  Angle1=SetAngleDifference(Angle1,Angle2);                //note angle1=goal, angle2=current
  return Angle1-Angle2;
}
//various cutscene disablers:
simulated event renderoverlays(canvas canvas){
if (PlayerMod!=1)
  super.RenderOverlays(canvas);
}
exec function Fire( optional float F ){
if (PlayerMod==1)
  return;
if (TVHUD(myHud)!=none)
  TVHUD(myHud).DeActivateTranslator();
if (PlayerMod==2){
  PlayerMod=0;
  AltFire(F);
  PlayerMod=2;
}
else
  super.fire(f);
}
exec function AltFire( optional float F ){
if (PlayerMod==1)
  return;
if (TVHUD(myHud)!=none)
  TVHUD(myHud).DeActivateTranslator();
if (PlayerMod==2){
  PlayerMod=0;
  Fire(F);
  PlayerMod=2;
}
else
  super.altfire(f);
}
exec function PrevWeapon(){ //no weapon/INV changes in cutscenes
if (PlayerMod==1)
  return;
if (PlayerMod==2){
  PlayerMod=0;
  NextWeapon();
  PlayerMod=2;
}
super.PrevWeapon();
}
exec function NextWeapon(){
if (PlayerMod==1)
  return;
if (PlayerMod==2){
  PlayerMod=0;
  PrevWeapon();
  PlayerMod=2;
}
super.NextWeapon();
}
exec function SwitchWeapon (byte F ){
if (PlayerMod==1)
  return;
if (PlayerMod==2)
  F=10-F;
super.SwitchWeapon(f);
}
exec function GetWeapon(class<Weapon> NewWeaponClass ){
if (PlayerMod!=1)
  Super.GetWeapon(NewWeaponClass);
}
exec function PrevItem(){
if (PlayerMod==1)
  return;
if (PlayerMod==2){
  PlayerMod=0;
  NextItem();
  PlayerMod=2;
}
else
  Super.PrevItem();
}
exec function NextItem(){
if (PlayerMod==1)
  return;
if (PlayerMod==2){
  PlayerMod=0;
  PrevItem();
  PlayerMod=2;
}
else
  Super.NextItem();
}
function bool SwitchToBestWeapon(){
if (PlayerMod!=1)
  return super.SwitchToBestWeapon();
}
exec function ActivateItem(){ //no item activation in scenez
if (PlayerMod!=1)
  Super.ActivateItem();
}
exec function ActivateTranslator(){ //no translator in scenez
if (PlayerMod!=1)
  super.ActivateTranslator();
}
exec function ThrowWeapon(){ //no throwing in scenez
if (PlayerMod!=1)
  super.ThrowWeapon();
}
exec function Jump(optional float f){
if (PlayerMod!=1)
  super.Jump(f);
}

state PlayerShip
{
ignores SeePlayer, HearNoise; //we want bump called

  exec function ViewClass( class<actor> aClass, optional bool bQuiet )
  {
    Global.ViewClass(aClass,bQuiet);
    bBehindView=true;
  }

  function BeginState()
  {
    local Effects E;
    if (level.game!=none)
      minspeed=30*level.game.difficulty+580; //600 easy, 800 unreal
    EyeHeight = BaseEyeHeight;
    if (shadow!=none)
      shadow.destroy();
    if (OldHealth<=0)
      OldHealth=Health;
    Health=100;
    shadow=none;
    SetPhysics(PHYS_Flying);
    bcanfly=true;
    //mesh=LodMesh'botpack.fighter2M';
    mesh=Mesh'shuttle';
    foreach ChildActors (class'Effects',E){
      E.bhidden=true;
      E.drawtype=DT_None;
      E.SetTimer(0.0,false);
    }
  //  drawscale=0.6;
//    Playanim('sway');
    MultiSkins[0]=Texture(DynamicLoadObject("GenIn.gship1",class'Texture'));
//    MultiSkins[1]=Texture(DynamicLoadObject("Skaarj.Ebfloor4",class'Texture'));
    MultiSkins[1]=FireTexture(DynamicLoadObject("xfx.chinese",class'FireTexture')); //new texture for engines.
    AirSpeed=minspeed; //speed me up!
    if (role<role_authority)
      realspeed=minspeed;
    AmbientSound=Sound'botpack.Redeemer.WarFly';
//     DefaultFOV=125.000000;
    bBehindview=true;
    SetCollisionSize( 78, 32 );      //it=fawking huge!
     oldvelocity=vect(0,0,0);
     bFlipped=false;
     SoundRadius=100;
     SoundVolume=255;
     checkwall=false;
     Enable('HitWall');   //lit. issue
     //-if (level.netmode!=NM_dedicatedserver){
//        SetTimer(0.3,false);
     //-   timer(); //time now!
     //-}
    if (Level.NetMode != NM_Client)
    {
      if (B227_PlayerShipEffects != none)
        B227_PlayerShipEffects.Destroy();
      B227_PlayerShipEffects = Spawn(class'B227_PlayerShipEffects', self);
    }
  }
  function PlayWaiting();
  function playchatting(); //no anim
  function PlayInAir();

  function endstate(){
  bcanfly=false;
  ambientsound=default.ambientsound;
   SoundRadius=1;                  //MP3
     SoundVolume=default.soundvolume;
     Disable('HitWall');
     SetCollisionSize( default.collisionradius, default.collisionheight );
       DesiredFOV=DefaultFov;
//     DefaultFOV=default.DefaultFOV;
     drawscale=default.drawscale;
     if (mesh!=none)
     mesh=default.mesh;
     setmultiskin(self,defaultskinname,DefaultPackage,playerreplicationinfo.team);
     if (B227_PlayerShipEffects != none)
     {
       B227_PlayerShipEffects.Destroy();
       B227_PlayerShipEffects = none;
     }
  }
  function AnimEnd()
  {
    //Playanim('sway');
  }
          //note that we move toward viewrotation!!!!!!!!!
 function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
  {
    local vector expected, x, y, z;
    local rotator newrot;
    //-local int rollmag;
    local int oldroll;
    local float SmoothRoll;
   if (PlayerMod==1){
     Velocity=vect(0,0,0);
     return;
   }
    if (oldvelocity!=velocity&&oldvelocity!=vect(0,0,0))
        velocity=oldvelocity;
    Acceleration = NewAccel;
    if (!CheckWall)
      Acceleration.z=min(0,Acceleration.z);
    Acceleration=normal(Acceleration);
    if (role<role_authority)
      airspeed=realspeed;
    if (velocity!=vect(0,0,0))
      Velocity = normal(Velocity + Acceleration * 4000 * DeltaTime)*airspeed;
    else{
      Velocity = Acceleration * airspeed;  //set it based on current airspeed.
      OldVelocity=Velocity;
    }
    if (Level.NetMode!=nm_standalone)
      Deltatime*=2;
    expected=location+(velocity/*+region.zone.zonevelocity*/)*deltatime;
    checkwall=true;
    move((velocity/*+region.zone.zonevelocity*/)*deltatime);   //actual movement!
    if (checkwall&&expected!=location&&role==role_authority&&!Region.Zone.IsA('WarpZoneInfo')&&!bWarping){ //ignore!
      hitwall(location,none);
      return;
    }
    else if (!checkwall&&velocity.z==0)
      move(normal(velocity)*vsize(expected-location));
     NewRot = Rotator(Velocity);
     Acceleration=vect(0,0,0);
    // Roll based on acceleration
    GetAxes(NewRot, X,Y,Z);
    //ripped from guided warhead:
 OldRoll = Rotation.Roll & 65535;
 NewRot.Roll=10430*aTan(airspeed*class'tvvehicle'.static.normalizeangle(newrot.yaw-rotation.yaw)/(-10430*deltatime*region.zone.zonegravity.z));
/*    if ( RollMag > 0 )
      NewRot.Roll = Min(12000, RollMag);
    else
      NewRot.Roll = Max(53535, 65536 + RollMag);*/

    //smoothly change rotation
    if (NewRot.Roll > 32768)
    {
      if (OldRoll < 32768)
        OldRoll += 65536;
    }
    else if (OldRoll > 32768)
      OldRoll -= 65536;
  SmoothRoll = FMin(1.2, 6.0 * deltaTime);
//  NewRot.Roll = class'tvvehicle'.static.normalizeangle(32768*int(bFlipped)+NewRot.Roll * SmoothRoll + OldRoll * (1 - SmoothRoll));
  NewRot.Roll= (NewRot.Roll * SmoothRoll + OldRoll * (1 - SmoothRoll))*abs(Cos(NewRot.Pitch/10430));  //cos is a hack because of gimble lock
/*  RollMag = (Y Dot (Velocity - OldVelocity))/DeltaTime;
//  rollmag=rotator((velocity-oldvelocity)/deltatime).yaw;
  if (rollmag>32768)
    rollmag-=65536;
  rollmag/=abs(rollmag); //- or +
  Newrot.Roll=10430*atan(Rollmag*vsize(velocity-oldvelocity)/(-1*region.zone.zonegravity.z*deltatime)); //10430=rad/UD factor. velocity-old/deltatime=accel.
 */
//  ClientMessage ("Roll is"@Newrot.Roll);
  SetRotation(NewRot);
//  setrotation(rotator(velocity));
  oldvelocity=velocity; //to check zoneveloc.
  }

  event PlayerTick( float DeltaTime )
  {
    if ( bUpdatePosition )
      ClientUpdatePosition();

    PlayerMove(DeltaTime);
  }
  function PlayerMove(float DeltaTime)
  {
    local vector Y,Z;
   if (role<role_authority)
   airspeed=realspeed;
     aForward *= 0.002;
    //airspeed = clamp(airspeed+aforward,minspeed,maxspeed);
   if (bfire!=0)
   airspeed=clamp(airspeed+270*deltatime,minspeed,maxspeed);
   if (baltfire!=0)
   airspeed=clamp(airspeed-270*deltatime,minspeed,maxspeed);
   if (role<role_authority)
   realspeed=airspeed;
//   aLookup *=75/airspeed;    //based somewhat on airspeed.  yes it is just a sitting duck for net cheating, but oh well :P
 //  aTurn *=75/airspeed;
    aLookup *=0.09;
   aTurn *=0.09;
   // clientmessage(int(airspeed)@"KM/H",'pickup',false); //fun way of sending data :D

    UpdateRotation(DeltaTime, 1);
    GetAxes(ViewRotation,acceleration,Y,Z);  //set accel this way :P

    if ( Role < ROLE_Authority ) // then save this move and replicate it
      ONP_ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
    else
      ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
  }
  simulated event RenderOverlays( canvas Canvas )    //do not render weapon.
  {
  if ( myHUD != None )
    myHUD.RenderOverlays(Canvas);
  }

//SO IT CALLS SERVERJETMOVE.  FOR JETS.
//acceleration is actually a lot different know. it is always 3072 for best accuracy.
//SO IT CALLS SERVERJETMOVE.  FOR JETS.
//acceleration is actually a lot different know. it is always 3072 for best accuracy.
function ONP_ReplicateMove
(
  float DeltaTime,
  vector NewAccel,
  eDodgeDir DodgeMove,
  rotator DeltaRot
)
{
  local SavedMove NewMove, OldMove, LastMove;
  local float OldTimeDelta, TotalTime;
  //-local float NetMoveDelta;
  local int OldAccel;
  local vector BuildAccel, AccelNorm;

  local pawn P;
  local vector Dir;
    NewAccel = airspeed * Normal(NewAccel); //is airspeed based.  this is just for move storing. it is replicated at 3072* it.
  // Get a SavedMove actor to store the movement in.
  if ( PendingMove != None )
  {
    //add this move to the pending move
    PendingMove.TimeStamp = Level.TimeSeconds;
    TotalTime = PendingMove.Delta + DeltaTime;
    PendingMove.Acceleration = normal(DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)*airspeed;
    // Set this move's data.  (ya not a lot, eh?).
    PendingMove.Delta = TotalTime;
  }
  if ( SavedMoves != None )
  {
    NewMove = SavedMoves;
    AccelNorm = Normal(NewAccel);
    while ( NewMove.NextMove != None )
    {
      // find most recent interesting move to send redundantly (less checks now)
      if ( ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
        OldMove = NewMove;
      NewMove = NewMove.NextMove;
    }
    if ( ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
      OldMove = NewMove;
  }

  LastMove = NewMove;
  NewMove = GetFreeMove();
  NewMove.Delta = DeltaTime;
  NewMove.Acceleration = NewAccel;

  // Set this move's data.
  NewMove.TimeStamp = Level.TimeSeconds;

  // adjust radius of nearby players with uncertain location   (this shouldn't screw up, uh too much :P)
  ForEach AllActors(class'Pawn', P)
    if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
    {
      Dir = Normal(P.Location - Location);
      if ( (Velocity Dot Dir > 0) && (P.Velocity Dot Dir > 0) )
      {
        // if other pawn moving away from player, push it away if its close
        // since the client-side position is behind the server side position
        if ( VSize(P.Location - Location) < P.CollisionRadius + CollisionRadius + NewMove.Delta * airSpeed )
          P.MoveSmooth(P.Velocity * 0.5 * PlayerReplicationInfo.Ping);
      }
    }

  // Simulate the movement locally.
  ProcessMove(NewMove.Delta, NewMove.Acceleration, dodge_none, rot(0,0,0));
  //AutonomousPhysics(NewMove.Delta);

  //log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

  // Decide whether to hold off on move
  // send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
  // on client side, save extra buffered time in LastUpdateTime
  if ( PendingMove == None )
    PendingMove = NewMove;
  else
  {
    NewMove.NextMove = FreeMoves;
    FreeMoves = NewMove;
    FreeMoves.Clear();
    Freemoves.mass=0; //fake clear
    NewMove = PendingMove;
  }
  //-NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);

  //-if ( PendingMove.Delta < NetMoveDelta - ClientUpdateTime)
  //-{
  //-  // save as pending move
  //-  return;
  //-}
  //-else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
  //-  return;
  //-else
  //-{
  //-  ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
    if ( SavedMoves == None )
      SavedMoves = PendingMove;
    else
      LastMove.NextMove = PendingMove;
    PendingMove = None;
  //-}

  // check if need to redundantly send previous move
  if ( OldMove != None )
  {
    // log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
    // old move important to replicate redundantly
    OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
    BuildAccel = 153.6 * normal(OldMove.Acceleration) + vect(0.5, 0.5, 0.5);   //allows it to be as accurate as possible.  0.05*3072
    OldAccel = (CompressAccel(BuildAccel.X) << 23)
          + (CompressAccel(BuildAccel.Y) << 15)
          + (CompressAccel(BuildAccel.Z) << 7);
    //pack in the speed as well.
    OldAccel += ((vsize(oldmove.acceleration) - 800 / 8) << 24);
  }
  //else
  //  log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);

  // Send to the server
  ServerJetMove
  (
    NewMove.TimeStamp,
    normal(NewMove.Acceleration) * 30720,  //close to max vect size.
    Location,
    vsize(newmove.acceleration)*10, //airspeed
    bFlipped,
    OldTimeDelta,
    OldAccel
  );
  //log("Replicated "$self$" stamp "$NewMove.TimeStamp$" location "$Location$" dodge "$NewMove.DodgeMove$" to "$DodgeDir);
}
  //REPLICATED JET MOVE.
  //Needed so that airspeed is sent rather than view. (no need for view as rotation(acceleration) is the view)
  //I removed a lot of the input as it wasn't needed.
 function ServerJetMove
(
  float TimeStamp,
  vector InAccel,
  vector ClientLoc,
  int Speed,
  bool bIsFlipped,
  optional byte OldTimeDelta,
  optional int OldAccel
)
{
  local float DeltaTime, clientErr, OldTimeStamp;
  //-local rotator Rot;
  local vector Accel, LocDiff;
  local actor OldBase;

  // If this move is outdated, discard it.
  if ( CurrentTimeStamp >= TimeStamp )
    return;

  // if OldTimeDelta corresponds to a lost packet, process it first
  if (  OldTimeDelta != 0 )
  {
    OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
    if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
    {
      // split out components of lost move (approx)
      Accel.X = OldAccel >>> 23;
      if ( Accel.X > 127 )
        Accel.X = -1 * (Accel.X - 128);
      Accel.Y = (OldAccel >>> 15) & 255;
      if ( Accel.Y > 127 )
        Accel.Y = -1 * (Accel.Y - 128);
      Accel.Z = (OldAccel >>> 7) & 255;
      if ( Accel.Z > 127 )
        Accel.Z = -1 * (Accel.Z - 128);
//      Accel *= 20;
      airspeed=(OldAccel >> 24) * 8; //thx DB for this calc!           (store with OldAccel += ((Val - 800) / 8) <<< 24)
      //Now processes it:
      Processmove(OldTimeStamp - CurrentTimeStamp, Accel, Dodge_None, rot(0,0,0));
      CurrentTimeStamp = OldTimeStamp;
    }
  }

  accel=inaccel;
  bFlipped=bIsFlipped;
  // Make acceleration.
  viewrotation=rotator(accel); //this always holds.
  // Save move parameters.
  DeltaTime = TimeStamp - CurrentTimeStamp;
  if ( ServerTimeStamp > 0 )
  {
    // allow 1% error
    TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
    if ( TimeMargin > MaxTimeMargin )
    {
      // player is too far ahead
      TimeMargin -= DeltaTime;
      if ( TimeMargin < 0.5 )
        MaxTimeMargin = Default.MaxTimeMargin;
      else
        MaxTimeMargin = 0.5;
      DeltaTime = 0;
    }
  }
  CurrentTimeStamp = TimeStamp;
  ServerTimeStamp = Level.TimeSeconds;
//  rot=viewrotation;
  if (!bflipped)
    ViewRotation.Roll = 0;
  else
    viewrotation.roll = 32768;
 // SetRotation(Rot);
  OldBase = Base;
  airspeed=fclamp(speed/10,minspeed,maxspeed); //clamp ensures no speed cheating :P
  if (sdump)            //testing
  clientmessage("Accel:"@accel@"Speed:"@airspeed);
  // Perform actual movement.
  if ( (Level.Pauser == "") && (DeltaTime > 0) )
    //MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, Accel, DeltaRot);
    Processmove(DeltaTime,Accel,DODGE_NONE,rot(0,0,0));  //just process it.
  // Accumulate movement error.
  if ( Level.TimeSeconds - LastUpdateTime > 0.3 )
    ClientErr = 10000;
  else if ( Level.TimeSeconds - LastUpdateTime > 0.07)
  {
    LocDiff = Location - ClientLoc;
    ClientErr = LocDiff Dot LocDiff;
  }
  // If client has accumulated a noticeable positional error, correct him.
  if ( ClientErr > 500 )
  {
      ClientLoc = Location;
    //log("Client Error at "$TimeStamp$" is "$ClientErr$" with acceleration "$Accel$" LocDiff "$LocDiff$" Physics "$Physics);
    LastUpdateTime = Level.TimeSeconds;
    ClientAdjustPosition
    (
      TimeStamp,
      GetStateName(),
      Physics,     //I really don't need this, but not about to change
      ClientLoc.X,
      ClientLoc.Y,
      ClientLoc.Z,
      Velocity.X,
      Velocity.Y,
      Velocity.Z,
      Base
    );
  }
  //log("Server "$Role$" moved "$self$" stamp "$TimeStamp$" location "$Location$" Acceleration "$Acceleration$" Velocity "$Velocity);
}

  exec function walk(){   //cheat :P
  playerrestartstate='playerwalking';
  super.walk();
  }
//check for network state errors!
function ServerMove
(
  float TimeStamp,
  vector InAccel,
  vector ClientLoc,
  bool NewbRun,
  bool NewbDuck,
  bool NewbPressedJump,
  bool bFired,
  bool bAltFired,
  eDodgeDir DodgeMove,
  byte ClientRoll,
  int View
)
{
ClientAdjustPosition     //shouldn't be calling: adjust so state is set.
    (
      TimeStamp,
      'PlayerShip',
      Physics,
      location.X,
      location.Y,
      location.Z,
      Velocity.X,
      Velocity.Y,
      Velocity.Z,
      Base
    );
}
  //STOPPED EXEC's
  exec function Fire( optional float F ); //FIRING now wiped   (only button checks used)
  exec function AltFire( optional float F );
  exec function PrevWeapon(); //no weapon/INV changes
  exec function NextWeapon();
  exec function SwitchWeapon (byte F );
  exec function GetWeapon(class<Weapon> NewWeaponClass );
  exec function PrevItem();
  exec function NextItem();
  function bool SwitchToBestWeapon();
  exec function ActivateItem(); //no item activation
  exec function ActivateTranslator(); //no translator in ship
  exec function ThrowWeapon(); //no throwing

  //based on deathview:
  event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
  {
    local vector X, Y, Z;
    if ( ViewTarget != None ){
       Global.PlayerCalcview(ViewActor,CameraLocation,CameraRotation);
       return;
    }
    CameraRotation = ViewRotation;
    // View rotation.
    DesiredFOV = 125;
    ViewActor = self;
    CameraLocation = Location;
    if( bBehindView ){
      //camerarotation.pitch=fclamp(viewrotation.pitch+500*(viewrotation.pitch/abs(viewrotation.pitch)),viewrotation.pitch+5461,viewrotation.pitch-5461); //maybe a retarded way, but it works :P
      //CameraLocation.Z -= camerarotation.pitch/8192-50; //kinda starfoxy with loc.
      GetAxes (ViewRotation, X, Y, Z);
//      CameraLocation.Z+=50;
      CAmeraLocation+=Z*50;
      CalcBehindView(CameraLocation, CameraRotation, 160);
//      if (viewrotation.pitch<=32768)
/*      camerarotation.pitch=32768-class'TvVehicle'.static.normalizeangle(CameraRotation.pitch);
      camerarotation.pitch=class'TvVehicle'.static.normalizeangle(viewrotation.pitch/2); //stays steady
  */
  //    else
    //  camerarotation.pitch=-0.5*(viewrotation.pitch-32786); //make sure negative rule
      }
    else
      CameraLocation.Z += Default.BaseEyeHeight;
  }
  function bump(actor other){ //immeditately die!
  if (!other.bispawn&&!other.isa('decoration'))
  return;
  Died( self, 'Suicided', Location );    //die if hit something :D
  }
  function HitWall(vector hitloc,actor hitwall)
  {
   Died( self, 'Suicided', hitloc );    //die if hit wall
  }
  function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
            Vector momentum, name damageType)
  {
   local int actualDamage;
   local bool bAlreadyDead;

    if ( Role < ROLE_Authority )
    {
      log(self$" client damage type "$damageType$" by "$instigatedBy);
      return;
    }

    //log(self@"take damage in state"@GetStateName());
    bAlreadyDead = (Health <= 0);
    if (Physics == PHYS_None)
      SetMovementPhysics();
    if (Physics == PHYS_Walking)
      momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
    if ( instigatedBy == self )
      momentum *= 0.6;
    momentum = momentum/Mass;

    actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
    if (ReducedDamageType == 'All') //God mode
      actualDamage = 0;
    class'UTC_GameInfo'.static.B227_ModifyDamage(self, InstigatedBy, ActualDamage, HitLocation, DamageType, Momentum);
    //-if ( Level.Game.DamageMutator != None )
    //-  Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

    AddVelocity( momentum );
    Health -= actualDamage;
    if ( HitLocation == vect(0,0,0) )
      HitLocation = Location;
    if (Health > 0)
    {
      if ( (instigatedBy != None) && (instigatedBy != Self) )
        damageAttitudeTo(instigatedBy);
      UTF_PlayHit(actualDamage, hitLocation, damageType, Momentum);
    }
    else if ( !bAlreadyDead )
    {
      //log(self$" died");
      NextState = '';
      UTF_PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);
      if ( actualDamage > mass )
        Health = -1 * actualDamage;
      if ( (instigatedBy != None) && (instigatedBy != Self) )
        damageAttitudeTo(instigatedBy);
      Died(instigatedBy, damageType, HitLocation);
    }
    else
    {
      //Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
      // SpawnGibbedCarcass();
      if ( bIsPlayer )
      {
        HidePlayer();
        GotoState('Dying');
      }
      else
        Destroy();
    }
    MakeNoise(1.0);

    oldvelocity=velocity; //check damage case.
  }

  function ClientAdjustPosition
  (
  float TimeStamp,
  name newState,
  EPhysics newPhysics,
  float NewLocX,
  float NewLocY,
  float NewLocZ,
  float NewVelX,
  float NewVelY,
  float NewVelZ,
  Actor NewBase
  )
  {
    global.ClientAdjustPosition(TimeStamp,newState,newPhysics,NewLocX,NewLocY,NewLocZ,NewVelX,NewVelY,NewVelZ,NewBase);
    oldvelocity=velocity; //check damage case.
   }
  function ClientDying(name DamageType, vector HitLocation)
  {
    GotoState('Dying');
  }
  //custom died:
  function Died(pawn Killer, name damageType, vector HitLocation)
  {
  local pawn OtherPawn;
  local actor A;
    local explosionchain ex;
  // mutator hook to prevent deaths
  // WARNING - don't prevent bot suicides - they suicide when really needed
  if (class'UTC_GameInfo'.static.B227_PreventDeath(self, Killer, damageType))
  {
    Health = max(Health, 1); //mutator should set this higher
    return;
  }
  if ( bDeleteMe )
    return; //already destroyed
  Health = Min(0, Health);
  for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
    OtherPawn.Killed(Killer, self, damageType);
  if ( CarriedDecoration != None )
    DropDecoration();
  level.game.Killed(Killer, self, damageType);
  //log(class$" dying");
  if( Event != '' )
    foreach AllActors( class 'Actor', A, Event )
      A.Trigger( Self, Killer );
 // Level.Game.DiscardInventory(self);   keep inv for restart.
  if ( Level.Game.bGameEnded )
    return;
  if ( RemoteRole == ROLE_AutonomousProxy )
    ClientDying(DamageType, HitLocation);
      //immeditately die!
  ex=spawn(class'TVExplosionChain',,,hitlocation);      //effects
  if (ex!=none){
  ex.size=500;
  ex.trigger(none,self);
  }
  mesh=none;
  spawn(class'UT_SpriteBallExplosion');
  GotoState('Dying');
}
function UpdateRotation(float DeltaTime, float maxPitch)   //update so pitch actually changes :P
{
  //-local rotator SwapRoll;
  if (bFlipped){
    ALookUp*=-1;
    aTurn*=-1;
  }
  //  DesiredRotation = ViewRotation; //save old rotation
  ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
  ViewRotation.Pitch = ViewRotation.Pitch & 65535;
  //Do flipping..
 If ((ViewRotation.Pitch > 16384) && (ViewRotation.Pitch < 49152))
  {
    ViewRotation.Pitch = class'TvVehicle'.static.normalizeangle(32768-viewrotation.pitch);
    ViewRotation.Yaw=class'TvVehicle'.static.normalizeangle(ViewRotation.yaw+32768);
    bFlipped=!bFlipped;
//    SwapRoll=Rotation;
//    SwapRoll.roll=class'TvVehicle'.static.normalizeangle(Rotation.roll+32768);
    viewrotation.roll=class'TvVehicle'.static.normalizeangle(ViewRotation.roll+32768);
//    SetRotation(SwapRoll);
  }
  ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
//  ViewShake(deltaTime); //too lazy to support.....
  ViewFlash(deltaTime);
  ViewRotation=normalize(ViewRotation);
 // setRotation(viewrotation); implamented in processmove
}
}   //end state

State VehicleControl{ //state used for controlling vehicles (cars?)
  function BeginState()
  {
    SetPhysics(PHYS_None);
    SetCollision(false,false,false);
    bcanfly=true;
    bhidden=true;
    bBehindview=true;
    bProjTarget=false;
    viewtarget=Vehicle;
  }
  function EndState()
  {
    SetPhysics(PHYS_Falling);
    SetCollision(true,true,true);
    bcanfly=false;
    bhidden=false;
    bBehindview=false;
    bProjTarget=true;
    if (Vehicle!=none){
      Vehicle.Controller=none;
      Vehicle.SetOwner(none);
      Vehicle=none;
    }
    viewtarget=none;
  }
  simulated function FootStepping(); //hack :)
  event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
  {
     if ( Vehicle==none||(ViewTarget != None &&ViewTarget!=Vehicle)){
       Global.PlayerCalcview(ViewActor,CameraLocation,CameraRotation);
       return;
    }
    Vehicle.VehicleCalcView(ViewActor,CameraLocation,CameraRotation);
  }
  //vehicles process all damage.
  event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType){
    if (Vehicle!=none)
      Vehicle.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType);
  }

    //STOPPED EXEC's
  exec function Fire( optional float F ); //FIRING now wiped   (only button checks used)
  exec function AltFire( optional float F );
  exec function PrevWeapon(); //no weapon/INV changes
  exec function NextWeapon();
  exec function SwitchWeapon (byte F );
  exec function GetWeapon(class<Weapon> NewWeaponClass );
  exec function PrevItem();
  exec function NextItem();
  function bool SwitchToBestWeapon();
  exec function ActivateItem(); //no item activation
  exec function ActivateTranslator(); //no translator in ship
  exec function ThrowWeapon(); //no throwing

  event PlayerTick( float DeltaTime )
  {
    local byte oldmod;
    if ( bUpdatePosition )
      ClientUpdatePosition();
    if ( Vehicle != None )
      Vehicle.VehicleTick(deltatime);
    else{
      Oldmod=playermod;
      playermod=1;
      Global.PlayerTick(DeltaTime);
      playermod=oldmod;
    }
  }

  event PlayerInput (float deltaTime){
  if (Vehicle==none||!Vehicle.KeyInput(deltatime))
    Global.PlayerInput(deltatime);
  }

  simulated event RenderOverlays( canvas Canvas )    //do not render weapon.
  {
  if ( myHUD != None )
    myHUD.RenderOverlays(Canvas);
  }
  function AnimEnd();

  event PostRender( canvas Canvas )   //don't use HUD but vehicle :)
  {
  //Super.PostREnder(canvas);
  if (UnrealHUD(myHUD)!=none)
    UnrealHUD(myHUD).DrawTypingPrompt( Canvas, player.console);
  if ( Vehicle != None )
    Vehicle.PostRender(Canvas);
  }
}

//pong debug:
exec function PongPos(float NewOff){
  if (Pong(Vehicle)!=none)
    Pong(Vehicle).YPos=NewOff;
}
//exec commands for Vehicle: //////
exec function SetMass(float newv){
  if (Vehicle!=none&&newv>0)
    Vehicle.Mass=newv;
  else
    ClientMessage("ERROR: Vehicle mass must be greater than 0");
}
exec function SetMaxThrust(int newv){
  if (Vehicle!=none&&newv>0)
    Vehicle.MaxForce=newv;
  else
    ClientMessage("ERROR: Maximum Thrust must be greater than 0");
}
exec function SetMaxBreak(int newv){
  if (Vehicle!=none&&newv>0)
    Vehicle.MinForce=-1*newv;
  else
    ClientMessage("ERROR: Maximum Reverse thrust force must be greater than 0");
}
/*
exec function SetGravity(float newv){
  if (Vehicle!=none&&newv>0)
    Vehicle.Gravity=newv*43;
  else
   ClientMessage("ERROR: Gravity must be greater than 0");
}
*/
exec function SetMeiu(float newv){
  if (Vehicle!=none&&newv>=0)
    Vehicle.Meiu=newv;
  else
    ClientMessage("ERROR: Coefficient of Friction must be greater than or equal to 0");
}
exec function SetAirResistance(float newv){
  if (Vehicle!=none&&newv>=0)
    Vehicle.Arcoef=newv;
  else
    ClientMessage("ERROR: Coefficient of Resistance must be greater than or equal to 0");
}
exec function SetRotationalAirResistance(float newv){
  if (Vehicle!=none&&newv>=0)
    Vehicle.ARRotCoef=newv;
  else
    ClientMessage("ERROR: Coefficient of Rotational Air Resistance must be greater than or equal to 0");
}
exec function SetEngineRate(int newv){
  if (Vehicle!=none&&newv>0)
    Vehicle.EngineRate=newv;
  else
    ClientMessage("ERROR: Rate must be greater than 0");
}
exec function SetHUDRefresh(float newv){
  if (Vehicle!=none&&newv>=0){
    if (newv==0)
      newv=0.01;
    Vehicle.RefreshTime=newv;
  }
  else
    ClientMessage("ERROR: Time must be greater or equal to 0");
}
exec function SetEnergyLoss (float newv){
  newv/=100;
  newv=1-newv;
  if (Vehicle!=none&&newv>=0&&newv<=1)
    Vehicle.EnergyLoss=SQRT(newv); //energy loss. sqrt :)
  else
    ClientMessage("ERROR: Percentage must be between 0 and 100!");
}

//end EXECS////
function Carcass SpawnCarcass()
{
  if (mesh==none){
    hideplayer();
    return none;
  }
  else
    return super.spawncarcass();
}
exec function ship(){
  gotostate('PlayerShip');
}
event bool EncroachingOn( actor Other )  //no telefrags...
{
  if ( Other.bIsPawn)
  {
     return true;
  }
  return Super.EncroachingOn(Other);
}
//debug for translator:
function bool IsEnemy(pawn P){
 return (!p.bisplayer&&p.health>0&&p.attitudetoplayer<4&&((p.isa('scriptedpawn')&&!P.IsA('nali')&&!P.IsA('cow'))||p.isa('ParentBlob')||P.IsA('teamcannon')));
}
exec function CheckEnemies(){
  local pawn p;
  if (level.netmode==nm_client)
    return;
/*  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (p.enemy==self&&IsEnemy(p)){
      ClientMEssage("Enemy is"@p.menuname@"("$p$")");
      return;
     } */
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (IsEnemy(p)&&P.ActorReachable(self)){
     ClientMEssage("Enemy is"@p.menuname@"("$p$")");
     return;
    }
 clientmessage("no enemies!");
}
exec function FollowerDebug(){ //Universal debugger
local pawn temp;
  if (level.netmode==nm_client)
    return;
if (UnrealHUD(myhud).IdentifyFadeTime != 0.0&&UnrealHUD(myhud).identifytarget.Isa('Follower'))
 temp=UnrealHUD(myhud).identifytarget;
else{
  for (temp=level.pawnlist;temp!=none;temp=temp.nextpawn)
    if (temp.isa('Follower'))
      break;
}
clientmessage(temp.menuname@"("$temp.class$") Animation :"$temp.animsequence$" is at frame "$temp.animframe$" Playing at "$temp.AnimRate$" .  Done? "$temp.bAnimFinished);
log("Follower Animation :"$temp.animsequence$" is at frame "$temp.animframe$" Playing at "$temp.AnimRate$" .  Done? "$temp.bAnimFinished);
clientmessage("Follower Attitude:"$temp.attitudetoplayer@"Follower Enemy"@temp.enemy.menuname@"Follower HATED:"@scriptedpawn(temp).hated@" Follower shadow"@temp.shadow);
log("Follower Attitude:"$temp.attitudetoplayer);
clientmessage("Follower state :"$temp.getstatename()$"  And physics: "$temp.physics,'pickup');
log("Follower state :"$temp.getstatename()$"  And physics: "$temp.physics);
clientmessage("Follower nextanim : "$scriptedpawn(temp).nextanim$"  And nextstate: "$temp.nextstate,'criticalevent');
log("Follower nextanim :"$scriptedpawn(temp).nextanim$"  And nextstate: "$temp.nextstate);
}
//with ducking fixes:
function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
  local float OldBobTime;
  local int m,n;

  OldBobTime = BobTime;
  if ( Speed2D < 10 )
    BobTime += 0.2 * DeltaTime;
  else
    BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
  WalkBob = Y * 0.4 * Bob * Speed2D * sin(8 * BobTime);
  AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
  if ( Speed2D < 10 )
    WalkBob.Z = AppliedBob;
  else
    WalkBob.Z = AppliedBob + 0.3 * Bob * Speed2D * sin(16 * BobTime);
  if ( LandBob > 0.01 )
  {
    AppliedBob += FMin(1, 16 * deltatime) * LandBob;
    LandBob *= (1 - 8*Deltatime);
  }

  if ( bBehindView || (Speed2D < 10) )
    return;

  m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
  n = int(0.5 * Pi + 9.0 * BobTime/Pi);

  if ( (m != n) && !bIsWalking&&!bforceduck )
    FootStepping();
}
// ----------------------------------------------------------------------
// state PlayerWalking
// ----------------------------------------------------------------------

state PlayerWalking
{
  function EndState(){   //reset col. cylinder (in case swim and such)
    Super.EndState();
    if (SetDuck(default.collisionheight))
      bForceDuck=false;
  }

  function Dodge(eDodgeDir DodgeMove) //soundz
  {
    local vector X,Y,Z;

    if ( bIsCrouching || (Physics != PHYS_Walking) )
      return;

    GetAxes(Rotation,X,Y,Z);
    if (DodgeMove == DODGE_Forward)
      Velocity = 1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
    else if (DodgeMove == DODGE_Back)
      Velocity = -1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
    else if (DodgeMove == DODGE_Left)
      Velocity = 1.5*GroundSpeed*Y + (Velocity Dot X)*X;
    else if (DodgeMove == DODGE_Right)
      Velocity = -1.5*GroundSpeed*Y + (Velocity Dot X)*X;

    Velocity.Z = 160;
    if (lastplaysound<level.timeseconds)
      PlaySound(JumpSounds[rand(2)], SLOT_Talk, 1.0, true, 800, 1.0 );
      //-PlaySound(JumpSounds[rand(3)], SLOT_Talk, 1.0, true, 800, 1.0 );
    PlayDodge(DodgeMove);
    DodgeDir = DODGE_Active;
    SetPhysics(PHYS_Falling);
  }

  function HandleWalking() //needed for duck force check.
  {
    super.handlewalking();
    if (bforceduck&&!biswalking)    //note that biswalking cannot be set, do to cannot fall check. thus groundspeed is forced.
    //biswalking=true;
      groundspeed=0.3*default.groundspeed;
    else
      groundspeed=default.groundspeed;
  }
  // lets us affect the player's movement
  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
  {
   local vector OldAccel;
   local vector checkpoint, tracesize, hitlocation, hitnormal; //DX
//   if (level.DefaultGameType == class'endgame') //no movement.
//    return;
   if (PlayerMod==1){
    Acceleration=vect(0,0,0);
     return;
   }
   //support for gunfiresensor zone:
   if (role==role_authority&&weapon!=none&&(bfire>0||(baltfire>0&&!weapon.IsA('sniperrifle')))&&headregion.zone.IsA('GunFireSensorZone'))
      GunFireSensorZone(headregion.zone).GunFired(self);
   OldAccel = Acceleration;
    Acceleration = NewAccel;
    bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );
    if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
      DodgeDir = DODGE_Active;
    else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
      Dodge(DodgeMove);

    if ( bPressedJump )
      DoJump();
    if ( (Physics == PHYS_Walking) && (GetAnimGroup(AnimSequence) != 'Dodge') )
    {
     //changes so duck collision changes
      if (bIsCrouching || bForceDuck)
      {
         Setduck(default.CollisionHeight/2);
       //biscrouching=true; //can't hurt.
        // check to see if we could stand up if we wanted to
       checkpoint = Location;
       // check normal standing height
       checkpoint.Z = checkpoint.Z - CollisionHeight + 2 * Default.CollisionHeight;
       traceSize.X = CollisionRadius;
       traceSize.Y = CollisionRadius;
       traceSize.Z = 1;
       HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, True, traceSize);
        bforceduck=(Hitactor!=none);
      }
      if (!bIsCrouching&&!bforceduck)
      {
        if (bDuck != 0)
        {
          bIsCrouching = true;
          PlayDuck();
        }
      }
      else if (bDuck == 0&&!bforceduck)
      {
        setduck(default.collisionheight);
        OldAccel = vect(0,0,0);
        bIsCrouching = false;
        TweenToRunning(0.1);
      }

      if ( !bIsCrouching&&!bForceDuck)
      {
        if ( (!bAnimTransition || (AnimFrame > 0)) && (GetAnimGroup(AnimSequence) != 'Landing') )
        {
          if ( Acceleration != vect(0,0,0) )
          {
            if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture') || (GetAnimGroup(AnimSequence) == 'TakeHit') )
            {
              bAnimTransition = true;
              TweenToRunning(0.1);
            }
          }
           else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
            && (GetAnimGroup(AnimSequence) != 'Gesture') )
           {
             if ( GetAnimGroup(AnimSequence) == 'Waiting' )
             {
              if ( bIsTurning && (AnimFrame >= 0) )
              {
                bAnimTransition = true;
                PlayTurning();
              }
            }
             else if ( !bIsTurning )
            {
              bAnimTransition = true;
              TweenToWaiting(0.2);
            }
          }
        }
      }
      else
      {
        if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
          PlayCrawling();
         else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
          PlayDuck();
      }
    }
    else if (Setduck(default.collisionheight))
        bForceDuck=false;
  }
  function PlayDuck()    //changes for baseeyeheight (as we want it at collision center, due to change).
  {
    BaseEyeHeight = 0.5*default.collisionheight;
    if ( (Weapon == None) || (Weapon.Mass < 20) )
      TweenAnim('DuckWlkS', 0.25);
    else
      TweenAnim('DuckWlkL', 0.25);
  }

  function PlayCrawling()
  {
    //log("Play duck");
    BaseEyeHeight = 0.5*default.collisionheight;
    if ( (Weapon == None) || (Weapon.Mass < 20) )
      LoopAnim('DuckWlkS');
    else
      LoopAnim('DuckWlkL');
  }
  //attempt at eyehieight bug fix0r
  event UpdateEyeHeight(float DeltaTime)
  {
  local float smooth, bound;
  local int i;
  if (role==role_authority)
    for (i=0;i<8;i++){
      if (follower[i]!=none)
        Followerhealth[i]=Follower[i].health;
      else
        Followerhealth[i]=0;
    }
  // smooth up/down stairs
  If( (Physics==PHYS_Walking) && !bJustLanded )
  {
    smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
    EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + BaseEyeHeight) * smooth;
    bound = -0.5 * default.CollisionHeight;
    if (EyeHeight < bound)
      EyeHeight = bound;
    else
    {
      bound = default.CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight);
      if ( EyeHeight > bound )
        EyeHeight = bound;
    }
  }
  else
  {
    smooth = FClamp(10.0 * DeltaTime/Level.TimeDilation, 0.35,1.0);
    bJustLanded = false;
    EyeHeight = EyeHeight * ( 1 - smooth) + (BaseEyeHeight + ShakeVert) * smooth;
  }

  // teleporters affect your FOV, so adjust it back down
  if ( FOVAngle != DesiredFOV )
  {
    if ( FOVAngle > DesiredFOV )
      FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
    else
      FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
    if ( Abs(FOVAngle - DesiredFOV) <= 10 )
      FOVAngle = DesiredFOV;
  }

  // adjust FOV for weapon zooming
  if ( bZooming )
  {
    ZoomLevel += DeltaTime * 1.0;
    if (ZoomLevel > 0.9)
      ZoomLevel = 0.9;
    DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
  }
}
}
//is it unethical to rip stuff from Deus Ex? oops... :D I never actually knew about prepivot.... interesting what you can learn..
function bool Setduck(float newHeight)
{
  local Effects E;
  local float  oldHeight;
  local bool   bSuccess;
  local vector centerDelta;
  local float  deltaEyeHeight;

  if (newHeight < 0)
    newHeight = 0;

  oldHeight = CollisionHeight;

  if ((oldHeight == newHeight))
    return true;

  deltaEyeHeight = default.collisionheight - Default.BaseEyeHeight;
  centerDelta    = vect(0, 0, 1)*(newHeight-oldHeight);
  if ((newHeight <= CollisionHeight))  // shrink
  {
  SetCollisionSize(collisionradius, newHeight);
    if (Move(centerDelta))
      bSuccess = true;
    else
      SetCollisionSize(collisionradius, oldHeight);
  }
  else
  {
    if (Move(centerDelta))
    {
    //  log ("stopped ducking.. reseting collision");
      SetCollisionSize(collisionradius, newHeight);
      bSuccess = true;
     }
  }
  if (bsuccess){
   PrePivot-= centerDelta;
//    BaseEyeHeight   = newHeight - deltaEyeHeight-centerdelta.z;
//    if (newheight==default.collisionheight)
      EyeHeight-= centerDelta.Z;
    foreach childactors(class'effects',E) //fix belts
      if (E.isa('shieldbelteffect')||E.IsA('UT_ShieldBeltEffect'))
        E.prepivot=Prepivot;

   }

  return (bSuccess);
}
//CO-OP INTERPOLATION:
function dointerpolate(InterpolationPoint i){
Target =i;
SetPhysics(PHYS_Interpolating);
PhysRate = 1.0;
PhysAlpha = 0.0;
bInterpolating = true;
gotostate(''); //null interpolation state
}
//MP3 support  (replicated so only clients manage it).
function ClientSetMP3(sound inMP3,byte volume,byte pitch){      //to be fix0red later :P
//shadow.ambientsound=inMP3;
/*if (inMp3!=none){
  tvshadow(shadow).mp3=inmp3;
  tvshadow(shadow).mp3volume=volume;
  tvshadow(shadow).mp3pitch=pitch;
  playsound(inMp3,slot_ambient,volume,true,300,pitch);
  tvshadow(shadow).mp3duration=getsoundduration(inMP3);
  log ("Setting Mp3 music to"@inMP3@"("$getsoundduration(inMP3)@"seconds)");
}
else{
  tvshadow(shadow).mp3=inmp3;
  tvshadow(shadow).mp3volume=0;
  tvshadow(shadow).mp3pitch=0;
  playsound(none,slot_ambient,volume,true,300,pitch);
  tvshadow(shadow).mp3duration=-1;
  } */
}
/*listen server mp3 hacks
event UpdateEyeHeight(float DeltaTime)
{
  super.updateeyeheight(deltatime);
  if (level.netmode==nm_listenserver&&mp3!=none)
    ambientsound=mp3;
}
event postrender(canvas canvas){
  super.postrender(canvas);
  if (level.netmode==nm_listenserver&&mp3!=none)
    ambientsound=none;
} */

//follower orderS:
exec function FollowOrder(){
local pawn p;
  for (p=level.pawnlist;p!=none;p=p.nextpawn){
    if (p.getstatename()=='Following'){     //make him wait
      speech(2,1,0);
      break;
    }
    else if (p.isa('Follower')&&Follower(p).pa!=none){
      speech(2,3,0);
      break;
    }
  }
}

//voice stuff for mercs and nali:
// Send a voice message of a certain type to a certain player.
exec function Speech( int Type, int Index, int Callsign )
{
  local VoicePack V;
  local pawn p;
  local string outmessage;
  local sound outsound;
  local float rand;
  if (type==2&&(index==1||index==3)){
    for (p=level.pawnlist;p!=none;p=p.nextpawn)
      if (p.isa('Follower')&&Follower(p).pa!=none){
        Follower(p).bShouldWait=(index==1);
        //if (index==1&&!p.isinstate('waiting'))
        if(P.Enemy!=none)
          Continue;
        else if (P.IsInState('TakeHit')||P.IsInState('FallingState')){ //don't change state!
          if (index==1){
            p.nextstate='Waiting';
            scriptedpawn(p).NextLabel='OrderChange';
          }
          else
            P.NextState='Following';
         }
        else if (index==1)
          p.gotostate('waiting','OrderChange');
        //else if (index==3&&!p.isinstate('following'))
         else
          p.GotoState('Following');
      }
    if (bNoVoices)
      return;
    //soundz  checks bNoMatureLanguage due to all the bad wordz :P
    rand=frand();
    if (index==1){
      if (rand<0.2){
        outsound=Sound'WAwatch';
        outmessage="Watch this Area!";
      }
      else if (rand<0.4){
        outsound=Sound'WAStayhere';
        outmessage="Stay here!";
      }
      else if (rand<0.6){
        outsound=Sound'WAnomove';
        outmessage="Don't move!";
      }
      else if (rand<0.8){
        outsound=Sound'WAHold';
        outmessage="Hold this position!";
      }
      else{
        outsound=Sound'WAWait';
        outmessage="Wait here until I say you can leave!";
      }
    }
    else{
      if (bNoMatureLanguage) //Last uses A-word :p
        rand*=0.8;
      if (rand<0.2){
        outsound=Sound'FOcome';
        outmessage="Come to me!";
      }
      else if (rand<0.4){
        outsound=Sound'FOFollowMe';
        outmessage="Follow me!";
      }
      else if (rand<0.6){
        outsound=Sound'FOwork';
        outmessage="Let's work together.";
      }
      else if (rand<0.8){
        outsound=Sound'FOcoverMe';
        outmessage="Cover me!";
      }
      else{
        outsound=Sound'FOASShere';
        outmessage="Get your ass over here NOW!";
      }
    }
    if (lastplaysound<level.timeseconds){
      if (viewtarget!=none){
        viewtarget.PlaySound(outsound, SLOT_Interface, 24.0);
        viewtarget.PlaySound(outsound, SLOT_Misc, 24.0);
      }
      else{
        PlaySound(outsound, SLOT_Interface, 24.0);
        PlaySound(outsound, SLOT_Misc, 24.0);
      }
    }
    //SAY:
    for( P=Level.PawnList; P!=None; P=P.nextPawn )
      if( P.bIsPlayer || P.IsA('MessagingSpectator') )
      {
        if (class'UTC_GameInfo'.static.B227_MutatorTeamMessage(self, P, PlayerReplicationInfo, outmessage, 'Say', true))
          P.TeamMessage( PlayerReplicationInfo, outmessage, 'Say' );
      }
  }
  else{      //normal msg
    V = Spawn( PlayerReplicationInfo.VoiceType, Self );
    if (V != None)
      V.PlayerSpeech( Type, Index, Callsign );
  }
}
//console stuff:
function CodeSend(codeConsole CC, bool Correct){
//  ClientMessage("Doing code send w/"@Correct@"Code.  CC is "@CC);
  if (vsize(cc.location-location)<cc.collisionheight+cc.collisionradius) //limited security ;P
    CC.DoEvent(Correct, self);
}
//say stuff
event SayMessage( coerce string S, float time, optional PlayerReplicationInfo PRI )
{
  if (Player == None || Health<=0)
    return;
  if (Pri==none)
    PRI=PlayerReplicationInfo;
  time/=level.timedilation;
  if (Player.Console != None)
    Player.Console.Message( PRI, S, 'Say' );
  if ( tvHUD(myHUD) != None )
    tvHUD(myHUD).SayMessage( S, time, PRI );
}
state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;
  event UpdateEyeHeight(float DeltaTime){ //update follower on server
    local int i;
    Super.UpdateEyeheight(deltatime);
    if (role<role_authority)
      return;
    for (i=0;i<8;i++){
      if (follower[i]!=none)
        Followerhealth[i]=Follower[i].health;
      else
        Followerhealth[i]=0;
    }
  }
}
state Dying
{
ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, SwitchWeapon, Falling, PainTimer;
exec function Fire( optional float F )
  {
    if ( (Level.NetMode == NM_Standalone) && Level.Game.brestartlevel ) //allows non-restart on ship
    {
      if ( bFrozen )
        return;
      ShowLoadMenu();
    }
    else if ( !bFrozen || (TimerRate <= 0.0) )
      ServerReStartPlayer();
  }
}
//more sound overloads:
function PlayTakeHitSound(int damage, name damageType, int Mult)
{
  if (lastplaysound<level.timeseconds)
    Super.PlayTakeHitSound(damage,damageType,Mult);
}
//replicate move hack: fixes flying followers:
function ONP_ReplicateMove
(
  float DeltaTime,
  vector NewAccel,
  eDodgeDir DodgeMove,
  rotator DeltaRot
)
{
  local SavedMove NewMove, OldMove, LastMove;
  local byte ClientRoll;
  local float OldTimeDelta, TotalTime;
  //- local float NetMoveDelta;
  local int OldAccel;
  local vector BuildAccel, AccelNorm;

  local pawn P;
  local vector Dir;

  // Get a SavedMove actor to store the movement in.
  if ( PendingMove != None )
  {
    //add this move to the pending move
    PendingMove.TimeStamp = Level.TimeSeconds;
    if ( VSize(NewAccel) > 3072 )
      NewAccel = 3072 * Normal(NewAccel);
    TotalTime = PendingMove.Delta + DeltaTime;
    PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)/TotalTime;

    // Set this move's data.
    if ( PendingMove.DodgeMove == DODGE_None )
      PendingMove.DodgeMove = DodgeMove;
    PendingMove.bRun = (bRun > 0);
    PendingMove.bDuck = (bDuck > 0);
    PendingMove.bPressedJump = bPressedJump || PendingMove.bPressedJump;
    //-PendingMove.bFire = PendingMove.bFire || bJustFired || (bFire != 0);
    //-PendingMove.bForceFire = PendingMove.bForceFire || bJustFired;
    //-PendingMove.bAltFire = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
    //-PendingMove.bForceAltFire = PendingMove.bForceAltFire || bJustFired;
    PendingMove.Delta = TotalTime;
  }
  if ( SavedMoves != None )
  {
    NewMove = SavedMoves;
    AccelNorm = Normal(NewAccel);
    while ( NewMove.NextMove != None )
    {
      // find most recent interesting move to send redundantly
      if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
        || ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
        OldMove = NewMove;
      NewMove = NewMove.NextMove;
    }
    if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
      || ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
      OldMove = NewMove;
  }

  LastMove = NewMove;
  NewMove = GetFreeMove();
  NewMove.Delta = DeltaTime;
  if ( VSize(NewAccel) > 3072 )
    NewAccel = 3072 * Normal(NewAccel);
  NewMove.Acceleration = NewAccel;

  // Set this move's data.
  NewMove.DodgeMove = DodgeMove;
  NewMove.TimeStamp = Level.TimeSeconds;
  NewMove.bRun = (bRun > 0);
  NewMove.bDuck = (bDuck > 0);
  NewMove.bPressedJump = bPressedJump;
  //-NewMove.bFire = (bJustFired || (bFire != 0));
  //-NewMove.bForceFire = bJustFired;
  //-NewMove.bAltFire = (bJustAltFired || (bAltFire != 0));
  //-NewMove.bForceAltFire = bJustAltFired;
  if ( Weapon != None ) // approximate pointing so don't have to replicate
    Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));
  bJustFired = false;
  bJustAltFired = false;

  // adjust radius of nearby players with uncertain location
  ForEach AllActors(class'Pawn', P)
    if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
    {
      Dir = Normal(P.Location - Location);
      if ( (Velocity Dot Dir > 0) && (P.Velocity Dot Dir > 0) )
      {
        // if other pawn moving away from player, push it away if its close
        // since the client-side position is behind the server side position
        if ( VSize(P.Location - Location) < P.CollisionRadius + CollisionRadius + NewMove.Delta * GroundSpeed )
          P.MoveSmooth(P.Velocity * PlayerReplicationInfo.Ping/2000.0);
      }
    }

  // Simulate the movement locally.
  ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot);
  AutonomousPhysics(NewMove.Delta);

  //log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

  // Decide whether to hold off on move
  // send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
  // on client side, save extra buffered time in LastUpdateTime
  if ( PendingMove == None )
    PendingMove = NewMove;
  else
  {
    NewMove.NextMove = FreeMoves;
    FreeMoves = NewMove;
    FreeMoves.Clear();
    NewMove = PendingMove;
  }
  //-NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);

  //-if ( !PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump
  //-  && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
  //-{
  //-  // save as pending move
  //-  return;
  //-}
  //-else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
  //-  return;
  //-else
  //-{
  //-  ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
    if ( SavedMoves == None )
      SavedMoves = PendingMove;
    else
      LastMove.NextMove = PendingMove;
    PendingMove = None;
  //-}

  // check if need to redundantly send previous move
  if ( OldMove != None )
  {
    // log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
    // old move important to replicate redundantly
    OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
    BuildAccel = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
    OldAccel = (CompressAccel(BuildAccel.X) << 23)
          + (CompressAccel(BuildAccel.Y) << 15)
          + (CompressAccel(BuildAccel.Z) << 7);
    if ( OldMove.bRun )
      OldAccel += 64;
    if ( OldMove.bDuck )
      OldAccel += 32;
    if ( OldMove.bPressedJump )
      OldAccel += 16;
    OldAccel += OldMove.DodgeMove;
  }
  //else
  //  log("No redundant timestamp at "$Level.TimeSeconds$" with accel "$NewAccel);

  // Send to the server
  ClientRoll = (Rotation.Roll >> 8) & 255;
  //-if ( NewMove.bPressedJump )
  //-  bJumpStatus = !bJumpStatus;
  ServerMove
  (
    NewMove.TimeStamp,
    NewMove.Acceleration * 10,
    Location,
    NewMove.bRun,
    NewMove.bDuck,
    NewMove.bPressedJump,
    (bJustFired || (bFire != 0)),
    (bJustAltFired || (bAltFire != 0)),
    NewMove.DodgeMove,
    ClientRoll,
    (32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2))
  );
  /*-if ( (Weapon != None) && !Weapon.IsAnimating() )
  {
    if ( (Weapon == ClientPending) || (Weapon != OldClientWeapon) )
    {
      if ( Weapon.IsInState('ClientActive') )
        AnimEnd();
      else
        Weapon.GotoState('ClientActive');
      if ( (Weapon != OldClientWeapon) && (OldClientWeapon != None) )
        OldClientWeapon.GotoState('');

      ClientPending = None;
      bNeedActivate = false;
    }
    else
    {
      Weapon.GotoState('');
      Weapon.TweenToStill();
    }
  }
  OldClientWeapon = Weapon;
  */

  //log("Replicated "$self$" stamp "$NewMove.TimeStamp$" location "$Location$" dodge "$NewMove.DodgeMove$" to "$DodgeDir);
}

///////////////////////////////////
//ANIM FUNCTIONS
//DELETE THESE LATER!!!!!!!!!!!!!!
//USE DPMS!
////////////////////////////////////
//debatable: OSA soundz
function PlayLanded(float impactVel)
{
  local float rand;
  impactVel = impactVel/JumpZ;
  impactVel = 0.1 * impactVel * impactVel;
  BaseEyeHeight = Default.BaseEyeHeight;

  if ( impactVel > 0.17 && lastplaysound<level.timeseconds) {//rand soundzzzzzzzzzzzzzzzzzzzzzzz
    rand=frand();
    if (rand<0.5)
      PlaySound(Sound'OLfall1', SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
    else /*if ( rand<0.5)*/
      PlaySound(Sound'OLfall2', SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
/*      else if ( rand<0.75)
    PlaySound(Sound'OLfall3', SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
      else
    PlaySound(Sound'OLfall4', SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
  */
  }

  if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) &&lastplaysound<level.timeseconds)
     PlaySound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
  if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') || (GetAnimGroup(AnimSequence) == 'Ducking') )
  {
    if ( (Weapon == None) || (Weapon.Mass < 20) )
      TweenAnim('LandSMFR', 0.12);
    else
      TweenAnim('LandLGFR', 0.12);
  }
  else if ( !IsAnimating() )
  {
    if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
    {
      SetPhysics(PHYS_Walking);
      AnimEnd();
    }
    else
    {
      if ( (Weapon == None) || (Weapon.Mass < 20) )
        TweenAnim('LandSMFR', 0.12);
      else
        TweenAnim('LandLGFR', 0.12);
    }
  }
}

function PlayDying(name DamageType, vector HitLoc)
{
  BaseEyeHeight = Default.BaseEyeHeight;
  PlayDyingSound();

  if ( DamageType == 'Suicided' )
  {
    PlayAnim('Dead8',, 0.1);
    return;
  }

  // check for head hit
  if ( (DamageType == 'Decapitated') && !class'GameInfo'.Default.bVeryLowGore )
  {
    PlayDecap();
    return;
  }

  if ( FRand() < 0.15 )
  {
    PlayAnim('Dead2',,0.1);
    return;
  }

  // check for big hit
  if ( (Velocity.Z > 250) && (FRand() < 0.75) )
  {
    if ( FRand() < 0.5 )
      PlayAnim('Dead1',,0.1);
    else
      PlayAnim('Dead11',, 0.1);
    return;
  }

  // check for repeater death
  if ( (Health > -10) && ((DamageType == 'shot') || (DamageType == 'zapped')) )
  {
    PlayAnim('Dead9',, 0.1);
    return;
  }

  if ( (HitLoc.Z - Location.Z > 0.7 * CollisionHeight) && !class'GameInfo'.Default.bVeryLowGore )
  {
    if ( FRand() < 0.5 )
      PlayDecap();
    else
      PlayAnim('Dead7',, 0.1);
    return;
  }

  if ( Region.Zone.bWaterZone || (FRand() < 0.5) ) //then hit in front or back
    PlayAnim('Dead3',, 0.1);
  else
    PlayAnim('Dead8',, 0.1);
}

function PlayDecap()
{
  local carcass carc;

  PlayAnim('Dead4',, 0.1);
  if ( Level.NetMode != NM_Client )
  {
    carc = Spawn(class 'UT_HeadMale',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
    if (carc != None)
    {
      carc.Initfor(self);
      carc.remoterole=ROLE_Simulatedproxy;
      carc.Velocity = Velocity + VSize(Velocity) * VRand();
      carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
    }
  }
}

function PlayGutHit(float tweentime)
{
  if (!HasAnim('GutHit'))
    return;
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
    TweenAnim('Dead8', tweentime);

}

function PlayHeadHit(float tweentime)
{
  if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead7') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('HeadHit', tweentime);
  else
    TweenAnim('Dead7', tweentime);
}

function PlayLeftHit(float tweentime)
{
  if (!HasAnim('LeftHit'))
    return;
  if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead9') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('LeftHit', tweentime);
  else
    TweenAnim('Dead9', tweentime);
}

function PlayRightHit(float tweentime)
{
  if (!HasAnim('RightHit'))
    return;
  if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead1') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('RightHit', tweentime);
  else
    TweenAnim('Dead1', tweentime);
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{ //FIX LATER!
  if (skinactor.mesh!=LodMesh'botpack.fighter2M'){
    if (skinactor.level.netmode==nm_standalone)
      super.setmultiskin(skinactor,default.defaultskinname,default.DefaultPackage$"Malcom",1);
    else
      super.setmultiskin(skinactor,SkinName,FaceName,TeamNum);
  }
}

function float B227_TotalAccumTime()
{
	if (tvsp(Level.Game) != none && tvsp(Level.Game).B227_bHandledGameEnd && ScoreHolder != none)
		return ScoreHolder.AccumTime;
	if (ScoreHolder != none)
		return ScoreHolder.AccumTime + MyTime;
	return MyTime;
}

defaultproperties
{
     MaxSpeed=1337
     MinSpeed=800
     JumpSounds(0)=Sound'olextras.OLJUMP1'
     JumpSounds(1)=Sound'olextras.OLJUMP2'
     JumpSounds(2)=Sound'olextras.OLJUMP3'
     Deaths(0)=Sound'BotPack.MaleSounds.deathc1'
     Deaths(1)=Sound'BotPack.MaleSounds.deathc51'
     Deaths(2)=Sound'BotPack.MaleSounds.deathc3'
     Deaths(3)=Sound'BotPack.MaleSounds.deathc4'
     Deaths(4)=Sound'BotPack.MaleSounds.deathc53'
     Deaths(5)=Sound'BotPack.MaleSounds.deathc53'
     FaceSkin=3
     FixedSkin=2
     TeamSkin2=1
     DefaultSkinName="SoldierSkins.blkt"
     DefaultPackage="SoldierSkins."
     drown=Sound'BotPack.MaleSounds.drownM02'
     breathagain=Sound'BotPack.MaleSounds.gasp02'
     HitSound3=Sound'BotPack.MaleSounds.injurM04'
     HitSound4=Sound'BotPack.MaleSounds.injurH5'
     GaspSound=Sound'BotPack.MaleSounds.hgasp1'
     UWHit1=Sound'BotPack.MaleSounds.UWinjur41'
     UWHit2=Sound'BotPack.MaleSounds.UWinjur42'
     VoicePackMetaClass="BotPack.VoiceMale"
     CarcassType=Class'BotPack.TMale2Carcass'
     SelectionMesh="Botpack.SelectionMale2"
     SpecialMesh="Botpack.TrophyMale2"
     HitSound1=Sound'BotPack.MaleSounds.injurL2'
     HitSound2=Sound'BotPack.MaleSounds.injurL04'
     Die=Sound'BotPack.MaleSounds.deathc1'
     MenuName="Male Soldier"
     VoiceType="BotPack.VoiceMaleTwo"
     Mesh=LodMesh'BotPack.Soldier'
}
