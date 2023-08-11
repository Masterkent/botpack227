// ============================================================
// This package is for use with Seven Bullets, by Team Phalanx
// SevenLevelInfo : This actor should be added to all levels.  It defines critical options for levels.
// If not added, the gameinfo will spawn one itself and use default properties.
// Note This actor's Event is triggered at level start.
// ============================================================

class SevenLevelInfo expands Info;
var (Inventory) class<inventory> DefaultInventory[20]; //inventory that the player will be given, if he doesn't already have them, at start of level or co-op restart.
var (Inventory) class<inventory> InventoryToDestroy[8]; //inventory to be destroyed when entering level.  do not use an item listed above!  Set the 0 element to inventory to remove all.
var (Inventory) bool bAkimboMags; //whether machinemag should be forced into akimbo mode (if added)
var (Inventory) enum ENetType
{
  Used_All,
  Used_SPOnly,
  Used_CoopOnly,
  Used_None
} NetOptions[28];    //for each inventory default and delete. default=0-19.  destroy=20-27
var (Inventory) class<inventory> TriggeredInv[8]; //items that will be added to defaults when this triggered (co-op)
var (Inventory) ENetType DefaultWeapon;  //whether default weapon (pistol, can be mutated) is used.
//var (PlayerMod) bool bIsMissionPack; //is this a mission pack level?
var (PlayerMod) bool bCutScene; //is this level a cutscene (fade in begins at 1/4&default motion freeze)  Note: FadeinTime should probably be reduced to 2.
var (PlayerMod) bool bJet; //Should the player be a jet?
var (PlayerMod) bool RespawnPlayer; //on death should the player respawn?
var (PlayerMod) float FadeInTime; //how long should the fade-in take (seconds)? Includes Title/Author time.
var (PlayerMod) bool bVrikersTypeStart; //where the player "awakes"
var (PlayerMod) int MaxHealth; //the maximum health a player can have when entering a level.
var (PlayerMod) bool ForceNoHUD; //forces no hud.     (is automatically true if bCutScene)
var (SpeedRun) float GoalTime; //high goal time. beat this to start having bonuses
var (SpeedRun) int GoalPoints; //how many points are given for beating the goal?
var (SpeedRun) float GoalMult; //how much to multiply additional bonus seconds by.
var (SpeedRun) float UberGoalTime; //Low goal time (done with secrets). beat this to start having uber-bonuses
var (SpeedRun) int UberGoalPoints; //how many points are given for beating the uber-goal?
var (SpeedRun) float UberGoalMult; //how much to multiply additional bonus seconds by.

//internal:
var int ItemCount;

replication{
  Reliable if (Role==role_authority) //send no hud info..
    ForceNoHUD;
}
//when triggered, items can be added to default inv.
function Trigger( actor Other, pawn EventInstigator )
{
  local int i;
  if (TriggeredInv[0]==none||Itemcount==20)
    return;
  DefaultInventory[ItemCount]=TriggeredInv[0];
  ItemCount++;
  for (i=0;i<7;i++)
    TriggeredInv[i]=TriggeredInv[i+1];
}
//fix mapper glitches:
function PreBeginPlay(){
  local byte i;
  bhidden=true;
  for (i=0;i<8;i++){
    if (InventoryToDestroy[i]==none)
      break;
  }
  for (i=0;i<20;i++){
    if (DefaultInventory[i]==none)
      break;            //use case statements?
   switch(DefaultInventory[i]){
    case class'PulseGun':
      DefaultInventory[i] = class'SevenPulsegun';
      break;
    case class'ShockRifle':
      DefaultInventory[i] = class'SevenShockRifle';
      break;
    case class'Minigun2':
      DefaultInventory[i] = class'SevenChainGun';
      break;
    case class'Enforcer': //or not :p
      DefaultInventory[i] = class'SevenMachineMag';
      break;
    case class'SniperRifle':
      DefaultInventory[i] = class'SevenSniperRifle';
      break;
    case class'UT_FlakCannon':
      DefaultInventory[i] = class'SBFlechetteCannon';
      break;
    case class'UT_Eightball':
      DefaultInventory[i] = class'TVeightball';
      break;
    case class'ripper':
      DefaultInventory[i] = class'SBBloodRipper';
      break;
    case class'Flashlight':
      DefaultInventory[i]=class'TVFlashLight';
      break;
    case class'SearchLight':
      DefaultInventory[i]=class'TVSearchLight';
      break;
  	}
  }
  ItemCount=i;
  if (level.defaultgametype!=none&&Level.defaultGameType.name=='MovieInfo'){ //UMS detection
    FadeInTime=0.1;
    bCutScene=true;
  }
  if (level.netmode!=nm_standalone) //hack
     bCutScene=false;
  if (bJet)
    ForceNoHUD=true;
  if (bCutScene)
    ForceNoHUD=true;
  Super.PreBeginPlay();
}

simulated function PostNetBeginPlay(){ //register on clients
  local tvplayer p;
  foreach AllActors (class'tvplayer',p)
//    if (viewport(p.player)!=none)
      p.Linfo=self;
}

function class<Actor> B227_SevenBVersionClass()
{
	return class'B227_SevenB_Version'; // makes class B227_SevenB_Version loaded
}

defaultproperties
{
     DefaultInventory(0)=Class'SevenB.TvTranslator'
     DefaultInventory(1)=Class'SevenB.TvFlashLight'
     bAkimboMags=True
     FadeInTime=11.000000
     MaxHealth=200
     GoalPoints=1000
     GoalMult=2.600000
     UberGoalPoints=6000
     UberGoalMult=7.100000
     bAlwaysRelevant=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'Engine.S_Weapon'
}
