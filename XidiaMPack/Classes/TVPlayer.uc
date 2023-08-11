// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvPlayer.
// The purpose of this playerpawn is to allow several features.
// 1. Ducking that affects collision.  Note that this IS possible with an inv item, but unfortunately, there is no way to stop the player from getting stuck then
// 2. Anti-telefrag:  This is easily the best way to handle it.
// 3. The ship mode.  Player flying a ship. fun..
// ============================================================

class TVPlayer expands TournamentPlayer;
//sound imports:
#exec OBJ LOAD FILE="XidiaMPackResources.u" PACKAGE=XidiaMPack

#exec AUDIO IMPORT FILE="Sounds\B227_XiDodge.WAV" NAME="B227_XiDodge"
#exec AUDIO IMPORT FILE="Sounds\B227_XiHit3.WAV" NAME="B227_XiHit3"
#exec AUDIO IMPORT FILE="Sounds\B227_XiJump.WAV" NAME="B227_XiJump"
#exec AUDIO IMPORT FILE="Sounds\B227_XiLand1.WAV" NAME="B227_XiLand1"
#exec AUDIO IMPORT FILE="Sounds\B227_XiLand2.WAV" NAME="B227_XiLand2"

//ship model:

//#exec meshmap scale meshmap=shuttle x=0.50195 y=0.50195 z=1.00391

var bool checkwall;
var (Ship) int MaxSpeed, MinSpeed;
var float SmokeRate; //smoke stuff
var bool bForceDuck; //ya, Deus Exy.  if player cannot stand up because of too small an area.
var(Sounds) sound JumpSounds[3]; //for jump altering
var XidiaLevelInfo LInfo; //info for some options. set on server, but client must get it manually.....
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

//mp3 stuff:
var MP3Player RightMP3, LeftMp3;

var float MyTime; //current level time.
var TVScoreKeeper ScoreHolder; //scoring (sp only)

//wierd fov thing:
var float DrunkLevel;
var bool bDec;
const AverageChange = 23;
const drunkclamp = 13;

var globalconfig bool B227_bNoDrunkenness;
var CodeConsoleWindow B227_CodeConsoleWindow;

//STATE PLAYERSHIP: This is a state which simulates the player flying a ship.
replication {
reliable if (role==role_authority&&bnetowner) //server -> client functions & varz
  dointerpolate, ClientSetMP3, PlayerMod, minspeed;
reliable if (role==role_authority&&!bdemorecording) //only in net game.. not demo
  TouchTrans;
reliable if ( (!bDemoRecording || (Level.NetMode==NM_Standalone)) && Role == ROLE_Authority )
    SayMessage; //new say.
reliable if (role<role_authority)  //client -> server functions.
   smovedump, CodeSend;   //debug stuff; console stuff respectfully.
unreliable if (role<role_authority) //unreliable server move.
  ServerJetMove;
}
//HACK FOR TELSA!
function AddVelocity( vector NewVelocity){
  if (Velocity!=vect(0,0,0))
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
/*function Inventory FindInventoryType( class DesiredClass )
{
  if (DesiredClass==class'OldPistol')
    DesiredClass=class'NoAmmoDPistol';
  return Super.FindInventoryType(DesiredClass);
} */
//maths:
final static function int Sign (float a){
  if (a>0)
    return 1;
  else if (a<0)
    return -1;
  else return 0;
}
final static function float normalizeangle(float inangle)
{
 local int divisions;

 divisions = sign(inangle)*int(abs(inangle)/32768);

 return inangle-divisions*65536;
}
simulated function PostBeginPlay() //new shadow
{
  Super(playerpawn).PostBeginPlay();
  //-if ( Level.NetMode != NM_DedicatedServer )
  //-  Shadow = Spawn(class'TVshadow',self);
  if (Level.NetMode != NM_DedicatedServer)
  {
    class'UTC_Pawn'.static.B227_InitPawnShadow(self);
    if (Level.FootprintManager == none || Level.FootprintManager == class'FootStepManager')
      Level.FootprintManager = class'B227_XidiaFootStepManager';
  }
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
  //-else
    Super.FootStepping();
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
  if (shadow!=none){
    shadow.destroy();
    shadow=none;
  }
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
//get weapon hack:
exec function GetWeapon(class<Weapon> NewWeaponClass )
{
  if (PlayerMod==1)
    return;

  switch(NewWeaponClass){
    case class'Translocator':
      NewWeaponClass = class'TvTranslocator';
      break;
    case class'PulseGun':
      NewWeaponClass = class'TvPulsegun';
      break;
    case class'ShockRifle':
      NewWeaponClass = class'XidiaShockRifle';
      break;
    case class'Minigun2':
      NewWeaponClass = class'XidiaMinigun2';
      break;
    case class'Translocator':
      NewWeaponClass = class'TvTranslocator';
      break;
    case class'Enforcer': //...
      NewWeaponClass = class'XidiaAutoMag';
      break;
    case class'SniperRifle':
      NewWeaponClass = class'XidiaSniperRifle';
      break;
    case class'UT_Eightball':
      NewWeaponClass = class'oleightball';
      break;
  }
  Super.GetWeapon(NewWeaponClass);
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
if (role==role_simulatedproxy)
  SetTimer(0.3,false); //smoke crap
}
exec function smovedump() //testing
{
  sdump=!sdump;
}
//hack to detect player talk time.
simulated function UTF_ClientPlaySound(sound ASound, optional bool bInterrupt, optional bool bVolumeControl )
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
  //-local XidiaJumpBoots boots;
  if ( CarriedDecoration != None )
    return;
  if ( !bIsCrouching && (Physics == PHYS_Walking) )
  {
    if ( !bUpdating&&lastplaysound<level.timeseconds)  //rand sounz
      B227_PlayOwnedSound(JumpSounds[rand(3)], SLOT_Talk, 1.5, true, 1200, 1.0 );
    if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
      MakeNoise(0.1 * Level.Game.Difficulty);
    if (!bUpdating)
      PlayInAir();
    //-if ( bCountJumps){
    //-  boots=XidiaJumpBoots(FindInventoryType(class'XidiaJumpBoots'));
    //-  if (Boots!=none)
    //-    Boots.SetJumpZ();
    //-}
    if (bCountJumps && Role == ROLE_Authority && Inventory != none)
      Inventory.OwnerJumped();
    Velocity.Z = JumpZ;
    if ( (Base != Level) && (Base != None) )
      Velocity += Base.Velocity;
    SetPhysics(PHYS_Falling);
  }
}

event UpdateEyeHeight (float DeltaTime){
  Super.UpdateEyeHeight(DeltaTime);
  if (B227_bNoDrunkenness || 4*Health>=default.Health){
    DrunkLevel=0;
  }
  else{
    if (bDec)
      DrunkLevel -= DeltaTime * AverageChange*fclamp(frand(),0.1,0.9);
    else
      DrunkLevel += DeltaTime * AverageChange*fclamp(frand(),0.1,0.9);
    if (DrunkLevel<-drunkclamp){
      DrunkLevel=-drunkclamp;
      bdec=false;
   }
   else if (DrunkLevel>drunkclamp){
     DrunkLevel=drunkclamp;
     bdec=true;
   }
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
     if (level.netmode!=NM_dedicatedserver){
//        SetTimer(0.3,false);
        timer(); //time now!
     }
  }
  function PlayWaiting();
  function playchatting(); //no anim

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
    //- local int rollmag;
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
 NewRot.Roll=10430*aTan(airspeed*normalizeangle(newrot.yaw-rotation.yaw)/(-10430*deltatime*region.zone.zonegravity.z));
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
      XMP_ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
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
function XMP_ReplicateMove
(
  float DeltaTime,
  vector NewAccel,
  eDodgeDir DodgeMove,
  rotator DeltaRot
)
{
  local SavedMove NewMove, OldMove, LastMove;
  local float OldTimeDelta, TotalTime;
  //- local float NetMoveDelta;
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
  //-if ( Level.Game.BaseMutator.PreventDeath(self, Killer, damageType, HitLocation) )
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
  //- local rotator SwapRoll;
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
    ViewRotation.Pitch = normalizeangle(32768-viewrotation.pitch);
    ViewRotation.Yaw=normalizeangle(ViewRotation.yaw+32768);
    bFlipped=!bFlipped;
//    SwapRoll=Rotation;
//    SwapRoll.roll=class'TvVehicle'.static.normalizeangle(Rotation.roll+32768);
    viewrotation.roll=normalizeangle(ViewRotation.roll+32768);
//    SetRotation(SwapRoll);
  }
  ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
//  ViewShake(deltaTime); //too lazy to support.....
  ViewFlash(deltaTime);
  ViewRotation=normalize(ViewRotation);
 // setRotation(viewrotation); implamented in processmove
}
}   //end state

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
exec function LogInv(){
  local inventory i;
  for (i=inventory;i!=none;i=i.inventory)
   if(i.IsA('pickup'))
    log (i,'xidebug');
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

exec function GetHUD(){
  clientmessage(myhud);
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
//sound dampening in water.. oh well.. no more support for dampener :(
function HandleWalking(){
    if (HeadRegion.Zone.bWaterZone)
      SoundDampening = 0.1;
    else
      SoundDampening = default.SoundDampening;
    super.handlewalking();
}

// ----------------------------------------------------------------------
// state PlayerWalking
// ----------------------------------------------------------------------

state PlayerWalking
{
  function EndState(){   //reset col. cylinder (in case swim and such)
    Super.EndState();
    //- SetTimer(0.0,false);
    if (SetDuck(default.collisionheight))
      bForceDuck=false;
  }
  /*- function PlayWaiting()  //humming
  {
    Global.PlayWaiting();
    enable('timer'); //in case disabled
    if (TimerRate==0 && linfo.bIsMissionPack)
      SetTimer(260+81*frand(),false);
  }

  function Timer(){
     if (!bIsTyping && velocity == vect(0,0,0) && playermod!=1)
       PlaySound(Sound'XiHumm', SLOT_Interact, 16, true); //interact so footsteps override it
     SetTimer(GetSoundDuration(Sound'XiHumm')+4*frand(),false);
  }*/

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
    if (!bUpdating)
    {
      if (lastplaysound<level.timeseconds){
        if (linfo.bisMissionPack)
          B227_PlayOwnedSound(Sound'B227_XiDodge', SLOT_Talk, 1.0, true, 800, 1.0 );
        else
          B227_PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
      }
      setTimer(0.0,false);
    }
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
    else if (4*Health<default.health)
      groundspeed=0.75*default.groundspeed;
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
            if (TimerRate!=0){
              setTimer(0.0,false);
              playsound(none,slot_talk);
            }
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
  //player "drunkenness" if under 25% health
  if (B227_bNoDrunkenness || 4*Health>=default.Health){
    DrunkLevel=0;
  }
  else{
    if (bDec)
      DrunkLevel -= DeltaTime * AverageChange*fclamp(frand(),0.1,0.9);
    else
      DrunkLevel += DeltaTime * AverageChange*fclamp(frand(),0.1,0.9);
    if (DrunkLevel<-drunkclamp){
      DrunkLevel=-drunkclamp;
      bdec=false;
   }
   else if (DrunkLevel>drunkclamp){
     DrunkLevel=drunkclamp;
     bdec=true;
   }
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
  if (playermod!=1)
    FOVAngle+=DrunkLevel*DesiredFOV/100.0;
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
function ClientSetMP3(sound inRightMP3, sound inLeftMp3){
   clientsetmusic(music'olroot.null',0,255,MTRAN_FADE);  //force no musac
   if (RightMp3!=none)
     RightMp3.destroy();
   if (LeftMp3!=none)
     LeftMp3.destroy();
   if (inRightMp3==none)
     return;
   RightMp3=spawn(class'Mp3Player',self);
   RightMp3.setMp3(inRightMp3,int(inLeftMp3!=none));
   if (inLeftMp3==none)
     return;
   LeftMp3=spawn(class'Mp3Player',self);
   LeftMp3.setMp3(inLeftMp3,-1);
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

//voice stuff for mercs and nali:
// Send a voice message of a certain type to a certain player.
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
function XMP_ReplicateMove
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
      B227_PlayOwnedSound(Sound'B227_XiLand2', SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
    else /*if ( rand<0.5)*/
      B227_PlayOwnedSound(Sound'B227_XiLand1', SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
/*      else if ( rand<0.75)
    PlayOwnedSound(Sound'OLfall3', SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
      else
    PlayOwnedSound(Sound'OLfall4', SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
  */
  }

  if (LastPlaySound < Level.TimeSeconds)
  {
    if ( Level.FootprintManager != none )
      B227_PlayLandingNoise(self, 0, impactVel);
    else if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
       B227_PlayOwnedSound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
  }
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

  if ( DamageType == 'Suicided' )
  {
    PlayAnim('Dead8',, 0.1);
    PlayDyingSound();
    return;
  }

  // check for head hit
  if ( (DamageType == 'Decapitated') && !class'GameInfo'.Default.bVeryLowGore )
  {
    PlayDecap();
    return;
  }

  PlayDyingSound();

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
  PlaySound(Sound'XiDecap', SLOT_Talk, 16); //special decap sounds
  PlaySound(Sound'XiDecap', SLOT_Pain, 16);
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
  if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead9') )
    TweenAnim('GutHit', tweentime);
  else if ( FRand() < 0.6 )
    TweenAnim('LeftHit', tweentime);
  else
    TweenAnim('Dead9', tweentime);
}

function PlayRightHit(float tweentime)
{
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
    if (skinactor.level.netmode==nm_standalone){
      if (skinactor.Isa('tvplayer') && tvsp(skinactor.level.game).linfo!=none && !tvsp(skinactor.level.game).linfo.bIsMissionPack) //change skin
        SetXiGoldSkin(tvplayer(skinactor));
      else
        SetXidiaSkin(skinactor,default.defaultskinname,Default.DefaultPackage$"cmdo2Blake",255);
    }
    else
      super.setmultiskin(skinactor,SkinName,FaceName,TeamNum);
  }
}

static function SetXiGoldskin (tvplayer SkinActor){
   local int i;
   SkinActor.Mesh=LodMesh'Soldier';
   SkinActor.MultiSkins[0]=Texture(DynamicLoadObject("SoldierSkins.blkt1",class'Texture'));
   SkinActor.MultiSkins[1]=Texture(DynamicLoadObject("SoldierSkins.blkt2",class'Texture'));
   SkinActor.MultiSkins[2]=Texture(DynamicLoadObject("SoldierSkins.blkt3",class'Texture'));
   SkinActor.MultiSkins[3]=Texture(DynamicLoadObject("soldierskins.sldr4rankin",class'Texture'));
   //now sound hacking for Jones
     for (i=0;i<5;i++)
       SkinActor.Deaths[i]=class'TMale2'.default.Deaths[i];
     SkinActor.drown=class'TMale2'.default.drown;
     SkinActor.breathagain=class'TMale2'.default.breathagain;
     SkinActor.HitSound1=class'TMale2'.default.HitSound1;
     SkinActor.HitSound2=class'TMale2'.default.HitSound2;
     SkinActor.HitSound3=class'TMale2'.default.HitSound3;
     SkinActor.HitSound4=class'TMale2'.default.HitSound4;
     SkinActor.GaspSound=class'TMale2'.default.GaspSound;
     SkinActor.UWHit1=class'TMale2'.default.UWHit1;
     SkinActor.UWHit2=class'TMale2'.default.UWHit2;
     SkinActor.Die=class'TMale2'.default.Die;
     for (i=0;i<3;i++)
       SkinActor.JumpSounds[i]=class'TMale2'.default.JumpSound;
}

static function SetXidiaSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
{
  local string MeshName, FacePackage, SkinItem, FaceItem, SkinPackage;

  MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));

  SkinItem = SkinActor.GetItemName(SkinName);
  FaceItem = SkinActor.GetItemName(FaceName);
  FacePackage = Left(FaceName, Len(FaceName) - Len(FaceItem));
  SkinPackage = Left(SkinName, Len(SkinName) - Len(SkinItem));

  if(SkinPackage == "")
  {
    SkinPackage=default.DefaultPackage;
    SkinName=SkinPackage$SkinName;
  }
  if(FacePackage == "")
  {
    FacePackage=default.DefaultPackage;
    FaceName=FacePackage$FaceName;
  }

  // Set the fixed skin element.  If it fails, go to default skin & no face.
  if(!SetSkinElement(SkinActor, default.FixedSkin, SkinName$string(default.FixedSkin+1), default.DefaultSkinName$string(default.FixedSkin+1)))
  {
    SkinName = default.DefaultSkinName;
    FaceName = "";
  }

  // Set the face - if it fails, set the default skin for that face element.
  SetSkinElement(SkinActor, default.FaceSkin, FaceName, SkinName$String(default.FaceSkin+1));

  // Set the team elements
  if( TeamNum != 255 )
  {
    SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin1+1));
    SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1)$"T_"$String(TeamNum), SkinName$string(default.TeamSkin2+1));
  }
  else
  {
    SetSkinElement(SkinActor, default.TeamSkin1, SkinName$string(default.TeamSkin1+1), "");
    SetSkinElement(SkinActor, default.TeamSkin2, SkinName$string(default.TeamSkin2+1), "");
  }

  // Set the talktexture
  if(Pawn(SkinActor) != None)
  {
    if(FaceName != "")
      Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = Texture(DynamicLoadObject(FacePackage$SkinItem$"5"$FaceItem, class'Texture'));
    else
      Pawn(SkinActor).PlayerReplicationInfo.TalkTexture = None;
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

function B227_OpenCodeConsoleWindow(CodeConsole CC)
{
	Acceleration=vect(0,0,0);
	WindowConsole(Player.Console).bQuickKeyEnable = true;
	WindowConsole(Player.Console).LaunchUWindow();
	if (!WindowConsole(Player.Console).bcreatedroot) //must generate root
		WindowConsole(Player.Console).createrootwindow(none);
	B227_CodeConsoleWindow = CodeConsoleWindow(WindowConsole(Player.Console).Root.CreateWindow(class'CodeConsoleWindow', 0, 0, 200, 200));
	B227_CodeConsoleWindow.CC = CC;
}

function B227_CloseCodeConsoleWindow()
{
	if (B227_CodeConsoleWindow != none && B227_CodeConsoleWindow.bWindowVisible)
		B227_CodeConsoleWindow.Close();
}

defaultproperties
{
     MaxSpeed=1337
     MinSpeed=800
     JumpSounds(0)=Sound'XidiaMPack.B227_XiJump'
     JumpSounds(1)=Sound'XidiaMPack.B227_XiJump'
     JumpSounds(2)=Sound'XidiaMPack.B227_XiJump'
     Deaths(0)=Sound'XidiaMPack.XiDie1'
     Deaths(1)=Sound'XidiaMPack.XiDie2'
     Deaths(2)=Sound'XidiaMPack.XiDie3'
     Deaths(3)=Sound'XidiaMPack.XiDie2'
     Deaths(4)=Sound'XidiaMPack.XiDie3'
     Deaths(5)=Sound'XidiaMPack.XiDie3'
     FaceSkin=1
     TeamSkin1=2
     TeamSkin2=3
     DefaultSkinName="CommandoSkins.daco"
     DefaultPackage="CommandoSkins."
     drown=Sound'XidiaMPack.XiDrown'
     breathagain=Sound'XidiaMPack.XiGasp2'
     HitSound3=Sound'XidiaMPack.XiHit4'
     HitSound4=Sound'XidiaMPack.XiHit5'
     GaspSound=Sound'XidiaMPack.XiGasp1'
     UWHit1=Sound'XidiaMPack.XiUWHit'
     UWHit2=Sound'XidiaMPack.XiUWHit'
     VoicePackMetaClass="BotPack.VoiceMale"
     CarcassType=Class'BotPack.TMale1Carcass'
     JumpSound=Sound'BotPack.MaleSounds.jump1'
     SelectionMesh="Botpack.SelectionMale1"
     SpecialMesh="Botpack.TrophyMale2"
     HitSound1=Sound'XidiaMPack.XiHit2'
     HitSound2=Sound'XidiaMPack.B227_XiHit3'
     Die=Sound'XidiaMPack.XiDie1'
     MenuName="Male Soldier"
     VoiceType="BotPack.VoiceMaleTwo"
     Mesh=LodMesh'BotPack.Commando'
}
