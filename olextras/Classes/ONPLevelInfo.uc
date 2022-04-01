// ============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// ONPLevelInfo : This actor should be added to all levels.  It defines critical options for levels.
// If not added, the gameinfo will spawn one itself and use default properties.
// Note This actor's Event is triggered at level start.
// ============================================================

class ONPLevelInfo expands Info;
var (Inventory) class<inventory> DefaultInventory[20]; //inventory that the player will be given, if he doesn't already have them, at start of level or co-op restart.
var (Inventory) class<inventory> InventoryToDestroy[8]; //inventory to be destroyed when entering level.  do not use an item listed above!  Set the 0 element to inventory to remove all.
var (Inventory) bool bAkimboEnforcers; //whether enforcer should be forced into akimbo mode (if added)
var (Inventory) enum ENetType
{
  Used_All,
  Used_SPOnly,
  Used_CoopOnly,
  Used_None
} NetOptions[28];    //for each inventory default and delete. default=0-19.  destroy=20-27
var (Inventory) class<inventory> TriggeredInv[8]; //items that will be added to defaults when this triggered (co-op)
var (Inventory) ENetType DefaultWeapon;  //whether default weapon (pistol, can be mutated) is used.
var (PlayerMod) bool bCutScene; //is this level a cutscene (fade in begins at 1/4&default motion freeze)  Note: FadeinTime should probably be reduced to 2.
var (PlayerMod) bool bJet; //Should the player be a jet?
var (PlayerMod) bool RespawnPlayer; //on death should the player respawn?
var (PlayerMod) float FadeInTime; //how long should the fade-in take (seconds)? Includes Title/Author time.
var (PlayerMod) bool bVrikersTypeStart; //where the player "awakes"
var (PlayerMod) int MaxHealth; //the maximum health a player can have when entering a level.
var (PlayerMod) bool ForceNoHUD; //forces no hud. don't that if player is frozen (w/ actor or bcutscene, this is auto-true :))
var (PlayerMod) bool FollowersCanLeave; //can followes leave the level?
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
  for (i=0;i<20;i++){
    if (DefaultInventory[i]==none)
      break;            //use case statements?
    else if (DefaultInventory[i]==class'ShockRifle')
      DefaultInventory[i]=class'OsShockRifle';
    else if (DefaultInventory[i]==class'PulseGun'||DefaultInventory[i]==class'OSPulseGun')
      DefaultInventory[i]=class'TVPulseGun';
    else if (DefaultInventory[i]==class'Enforcer')
      DefaultInventory[i]=class'SpEnf';
    else if (DefaultInventory[i]==class'UT_EightBall')
      DefaultInventory[i]=class'TVEightball';
    else if (DefaultInventory[i]==class'Translator')
      DefaultInventory[i]=class'TVTranslator';
    else if (DefaultInventory[i]==class'FlashLight')
      DefaultInventory[i]=class'TVFlashLight';
    else if (DefaultInventory[i]==class'SearchLight')
      DefaultInventory[i]=class'TVSearchLight';
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
    if (viewport(p.player)!=none)
      p.Linfo=self;
}

defaultproperties
{
     DefaultInventory(0)=Class'olextras.TvTranslator'
     DefaultInventory(1)=Class'olextras.TvFlashLight'
     bAkimboEnforcers=True
     FadeInTime=11.000000
     MaxHealth=200
     FollowersCanLeave=True
     GoalPoints=1000
     GoalMult=2.600000
     UberGoalPoints=6000
     UberGoalMult=7.100000
     bAlwaysRelevant=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'Engine.S_Weapon'
}
