// ===============================================================
// XidiaMPack.TvSP: Really is "JonesGameInfo"
// ===============================================================

class TvSP expands singleplayer2;
var (zonelight) vector ViewFlash, ViewFog;               //following ripped from fadeviewtrigger and edited to reverse the effect....
var vector TargetFlash;
var float FadeSeconds, timey;
var vector OldViewFlash;
var TvPlayer theplayer;
var SevenLevelInfo LInfo; //info for some options
var zoneinfo fadezone; //in case player swaps zones :)
var bool bGODModeAllowed; //is god mode allowed?
//var byte XidiaMode; //0=orig xiida, 1=expansion, 2=incident (all)
var bool NoItems; //don't carry items?

var bool B227_bHandledGameEnd;

//new playerpawn:
event playerpawn Login
(
  string Portal,
  string Options,
  out string Error,
  class<playerpawn> SpawnClass
)
{
local PlayerPawn NewPlayer;
local codeconsole cc;
if (Linfo==none){ //check for info presence
  Log("No SevenLevelInfo placed in level!  Using default options.",'Seven');
  spawn(class'SevenLevelInfo'); //muty will add to ginfo
}
CheckPlayerStarts();
Newplayer=super.login(portal,options,error,class'TvPlayer');
tvplayer(NewPlayer).Linfo=Linfo;
if (Linfo.bjet) //SHIP
  Newplayer.PlayerReStartState='PlayerShip';
theplayer = tvplayer(newplayer);   //SP holder
//fade stuff moved here:
  if (!bloadingsave){  //save h4ck
   tvplayer(newplayer).playermod=1; //freeze player on start!
   OldViewFlash = Region.Zone.ViewFlash; //back up
//   newplayer.GroundSpeed = 0.01;
//   newplayer.JumpZ = 0.01;
   fadezone=newplayer.region.zone;
   fadezone.ViewFlash.X = TargetFlash.X;             //make dark
   fadezone.ViewFlash.Y =TargetFlash.Y;
   fadezone.ViewFlash.Z = TargetFlash.Z;
   //only when not loading save level options
   if (NewPlayer.Health>Linfo.maxhealth&&Linfo.Maxhealth!=0)
      NewPlayer.Health = Linfo.MaxHealth;
   if (LInfo.bVrikersTypeStart){
      NewPlayer.PlayerRestartState = 'PlayerWaking';
      NewPlayer.ViewRotation.Pitch = 16384;
   }
   else
     foreach AllActors(class'codeconsole',cc)
       cc.CheckTouching();
}
return newplayer;
}

//highly modified to use level actor :)
function AddDefaultInventory(pawn PlayerPawn ){
  local inventory inv;
  local int i;
  local byte PlayerHas[20];
  local tvscorekeeper scoreholder;
  local bool bKilledSelected;
  if( PlayerPawn.IsA('Spectator')||bLoadingSave)
    return;
  scoreholder=tvscorekeeper(playerpawn.FindInventoryType(class'tvscorekeeper'));
  if (scoreholder == None ){
    scoreholder = Spawn(class'tvscorekeeper',,, Location);
    scoreholder.bHeldItem = true;
    scoreholder.GiveTo(playerpawn);
  }
  tvPlayer(playerpawn).ScoreHolder=ScoreHolder;
  //uses level actor.
  if (LInfo.DefaultWeapon<2)
    super(GameInfo).adddefaultinventory(PlayerPawn);    //add dpistol
  //translator/flight
  if (Linfo.InventoryToDestroy[0]==class'inventory'&&Linfo.NetOptions[20]<2){
    for ( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
      if (!inv.isa('scorekeeper'))
        Inv.Destroy();
    return;
  }
  if (Linfo.InventoryToDestroy[0]==class'Weapon'&&Linfo.NetOptions[20]<2){
    for ( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
      if (inv.isa('Weapon'))
        Inv.Destroy();
  }
  For (inv=playerpawn.inventory;inv!=none;inv=inv.inventory) //check and destroy needed.
    for (i=0;i<20;i++){
      if (i>7&&Linfo.DefaultInventory[i]==none)
        break;
      else if (Linfo.defaultinventory[i]==inv.class){
        PlayerHas[i]=1;
        if (inv.class==class'SevenMachineMag'&&Linfo.bAkimboMags)
          SevenMachineMag(inv).hastwoMag=true; //post accept reads this :)
      }
      else if (i<8&&Linfo.InventoryToDestroy[i]==inv.class&&Linfo.NetOptions[i+20]<2){
        if (PlayerPawn.SelectedItem==Inv)
          bKilledSelected=true;
        Inv.destroy();       //remove
      }
    }
  for (i=0;i<20;i++){     //add
    if (Linfo.DefaultInventory[i]==none)
      break;
    if (PlayerHas[i]==1||Linfo.NetOptions[i]>1)
      continue;
    if (classisChildOf(LInfo.defaultInventory[i],class'weapon'))
      GiveWeapon(class<weapon>(LInfo.defaultInventory[i]),PlayerPawn);
    else
      GivePickup(class<pickup>(LInfo.defaultInventory[i]),PlayerPawn);
  }
  if (bKilledSelected)
    PlayerPawn.NextItem();
}

//gives a pickup to a pawn.
function GivePickup(class<pickup> pickupclass, pawn Playerpawn){
  local pickup pickup;
  Pickup=Spawn(pickupclass);
  if (Pickup==none)
    return;
  Pickup.bhelditem=true;
  Pickup.GiveTo(PlayerPawn);
  if (Pickup.IsA('TvTranslator')||Playerpawn.selecteditem==none)
    PlayerPawn.selecteditem=Pickup;
  Pickup.PickupFunction(playerpawn);
  if (!PlayerPawn.IsA('playerpawn'))
    Pickup.Activate();
}
function GiveWeapon(class<weapon> weapclass, pawn playerpawn){
  local weapon newweapon;
  newWeapon = Spawn(WeapClass,,,PlayerPawn.Location);
  if( newWeapon == None )
    return;
  newWeapon.Instigator = PlayerPawn;
  newWeapon.BecomeItem();
  PlayerPawn.AddInventory(newWeapon);
  if (newweapon.isa('SevenMachineMag')&&LInfo.bAkimboMags){
    SevenMachineMag(newweapon).HasTwoMag=true;
    newweapon.travelpostaccept();
  }
  newWeapon.BringUp();
  newWeapon.GiveAmmo(PlayerPawn);
  newWeapon.SetSwitchPriority(PlayerPawn);
  newWeapon.WeaponSet(PlayerPawn);
}

//called by muty.
function RegisterSevenLevelInfo(actor newinfo){
  Linfo=SevenLevelInfo(newinfo);
  Linfo.fadeintime/=2;
//  if (Linfo.bIsMissionPack) //force mode 1..
//    XidiaMode=1;
  brestartlevel=!Linfo.RespawnPlayer;
  if (Linfo.bcutscene||Linfo.bjet)    //this designates the map as a intermission (i.e flyby)
      timey=0.5*Linfo.fadeintime;
  log ("Successfully bound level information",'Seven');
}

function SendPlayer( PlayerPawn aPlayer, string URL ){
local int i;

	if (B227_bHandledGameEnd)
	{
		aPlayer.ClientTravel(URL, TRAVEL_Relative, true);
		return;
	}
	B227_bHandledGameEnd = true;

if (TvHUD(aPlayer.myhud)!=none)
  TVHUD(aPlayer.myhud).BlackOut=true;
if (tvplayer(aPlayer) != none){
  if (Linfo.bJet)
    aPlayer.health=tvplayer(aplayer).oldhealth;
  tvplayer(aPlayer).ScoreHolder.AccumTime+=tvplayer(aPlayer).MyTime;
}
//append to level times
if (!Linfo.bCutScene){
   for (i=0;i<36;i++)
     if (tvplayer(aPlayer).ScoreHolder.Times[i]<=0){
       tvplayer(aPlayer).ScoreHolder.Times[i]=tvplayer(aPlayer).MyTime;
       break;
     }
}
aPlayer.ClientTravel( URL, TRAVEL_Relative, !NoItems );
}

event PostLogin (playerpawn newplayer)
{
  local actor A;
  Pause=class'SinglePlayer2'.default.Pause; //hack-fix
  Super.PostLogin(newplayer);
  if (!bool(newplayer.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice VolumetricLighting"))&&!(class'TVFogWarning'.default.bnofog)){
    newplayer.setpause(true);              //fog alerts :P
    WindowConsole(newplayer.Player.Console).bQuickKeyEnable = true;  //ensures it will then close.....
    WindowConsole(newplayer.Player.Console).LaunchUWindow();   //open window.....
    if (!WindowConsole(newPlayer.player.console).bcreatedroot)
      WindowConsole(newPlayer.player.console).CreateRootWindow(none);
    WindowConsole(newplayer.Player.Console).Root.CreateWindow(class'TVFogWarning', 100, 100, 100, 100);
  }
  if (!bool(newplayer.ConsoleCommand("get ini:Engine.Engine.ViewportManager Decals"))&&!(class'TVDecalsWarning'.default.bnofog)){
    newplayer.setpause(true);              //fog alerts :P
    WindowConsole(newplayer.Player.Console).bQuickKeyEnable = true;  //ensures it will then close.....
    WindowConsole(newplayer.Player.Console).LaunchUWindow();   //open window.....
    if (!WindowConsole(newPlayer.player.console).bcreatedroot)
      WindowConsole(newPlayer.player.console).CreateRootWindow(none);
    WindowConsole(newplayer.Player.Console).Root.CreateWindow(class'TVDecalsWarning', 100, 100, 100, 100);
  }
  if (bool(newplayer.ConsoleCommand("get ini:Engine.Engine.ViewportManager NoDynamicLights"))&&!(class'TVDynLightWarning'.default.bnofog)){
    newplayer.setpause(true);              //fog alerts :P
    WindowConsole(newplayer.Player.Console).bQuickKeyEnable = true;  //ensures it will then close.....
    WindowConsole(newplayer.Player.Console).LaunchUWindow();   //open window.....
    if (!WindowConsole(newPlayer.player.console).bcreatedroot)
      WindowConsole(newPlayer.player.console).CreateRootWindow(none);
    WindowConsole(newplayer.Player.Console).Root.CreateWindow(class'TVDynLightWarning', 100, 100, 100, 100);
  }

  //USE FADE IN TIME WITH VORTEX MODE! NOT FOR CO-OP!
  if (NewPlayer.PlayerRestartState == 'PlayerWaking'&& !bloadingsave)
    NewPlayer.SetTimer(fmax(2*Linfo.FadeInTime-2.5,1.5*Linfo.FadeInTime),false);
  if (Linfo.Event!='' && !bLoadingSave)
    ForEach AllActors(class'Actor',A,Linfo.Event)
      A.Trigger(Linfo,newplayer);
  if (/*bLoadingSave&&*/newPlayer.IsInState('PlayerShip')) //hack
    NewPlayer.BeginState();
}

event Tick(float DeltaTime)
{
  local float X, Y, Z;
  local bool bXDone, bYDone, bZDone;

  timey+=deltatime;
  if (timey>Linfo.FadeInTime){
    if (!linfo.bcutscene&&theplayer.Region.Zone.ViewFlash.X == TargetFlash.X)
      theplayer.PlayerMod=0; //unfreeze
    bXDone = False;
    bYDone = False;
    bZDone = False;
    X = fadezone.Viewflash.X;
    Y = fadezone.ViewFlash.Y;
    Z = fadezone.ViewFlash.Z;
    X = X - (TargetFlash.X - OldViewFlash.X)*(DeltaTime / Linfo.FadeInTime);
    Y = Y - (TargetFlash.Y - OldViewFlash.Y)*(DeltaTime / Linfo.FadeInTime);
    Z = Z - (TargetFlash.Z - OldViewFlash.Z)*(DeltaTime / Linfo.FadeInTime);
    if( X > OldViewFlash.X ) { X = OldViewFlash.X; bXDone = True; }
    if( Y > OldViewFlash.Y ) { Y = OldViewFlash.Y; bYDone = True; }
    if( Z > OldViewFlash.Z ) { Z = OldViewFlash.Z; bZDone = True; }
    fadezone.ViewFlash.X = X;
    fadezone.ViewFlash.Y = Y;
    fadezone.ViewFlash.Z = Z;
    if(bXDone && bYDone && bZDone)
     disable('tick');
  }

}

function CheckPlayerStarts(){ //force singleplayer start...
  local NavigationPoint Np;
  local PlayerStart Last;
  for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
    if (NP.IsA('playerStart')){
      Last=PlayerStart(Np);
      if (Last.bSinglePlayerStart)
        return;
    }
  Last.bSinglePlayerStart=true;
}

function prebeginplay(){
  super.prebeginplay();
  bnomonsters=false;
}
//oops with OSA
function bool RestartPlayer(pawn aPlayer)
{
  return super(gameinfo).restartplayer(aPlayer);
}
//moved scoring to scorekill!
function Killed(pawn killer, pawn Other, name damageType)
{
  super(GameInfo).Killed(killer, Other, damageType);
}
function ScoreKill(pawn Killer, pawn Other)    //does not affect PRI stuff.
{
  local TvScoreKeeper ScoreHolder;
  local bool bSuicide;
  scoreholder = theplayer.ScoreHolder;
  if (Other!=none&&Other.bIsPlayer&&!bRestartLevel){  //for jet blow ups......
    scoreholder.AddPoints(-198);
    return;
  }
  if (Other==none||Other.bIsPlayer||((Killer==none||Killer==Other)&&(Other.IsInState('TriggerAlarm')||Other.Enemy==none||(!Other.Enemy.bIsPlayer))))
    return; //ignore (mapper forced kill/other enemy kill/whatever.
  if (Killer==none){
    Killer=Other.Enemy; //assume enemy killed other somehow (knocking into lava/whatever)
    bSuicide=true;
  }
  scoreholder.scoreit(Other); //count as thing dead.
  if ((theplayer.ReducedDamageType=='All'&&!bGODModeAllowed)||theplayer.IsInState('cheatflying'))
    Scoreholder.AddPoints(-200); //cheater!
  if (Other.IsA('nalirabbit')||Other.IsA('cow')||Other.IsA('nali')){
    scoreholder.KilledFollowers++;
    if (Killer.bisplayer) //stupid player killed him
      scoreholder.AddPoints(-90);
    else{ //other enemy killed him: player failed to save
      if (bSuicide)
        scoreholder.AddPoints(-10); //not much of a lost.
      else
        scoreholder.AddPoints(-20); //not much of a lost.
    }
    return;       //no points lost if killed in friendly fire by other followers.
  }
  ScoreHolder.killtotal++; //normal player killing enemies.
  if (ScriptedPawn(Other) != none && ScriptedPawn(Other).bIsBoss)
    ScoreHolder.AddPoints(150);
  else if (bSuicide) //knocked off ledge...
    ScoreHolder.AddPoints(50);
  else
    ScoreHolder.AddPoints(100);
}

function ScoreDamage(int Damage, Pawn Victim, Pawn Damager){
  local TvScoreKeeper ScoreHolder;
  local bool bSuicide; //suiciding
  local byte bTemp;
  local int RealDamage;
  if (thePlayer.weapon==none||theplayer.Weapon.IsA('Translocator')) //translocator cannot instigate damage. set this to "other" (rocket fired?)
    bTemp=11;
  else if (theplayer.Weapon.IsA('Pulsegun')) //extra
    bTemp=10;
  else
    bTemp=theplayer.Weapon.InventoryGroup%10;
  scoreholder = theplayer.ScoreHolder;
  if ((theplayer.ReducedDamageType=='All'&&!bGODModeAllowed)||theplayer.IsInState('cheatflying')){ //cheat punishing
    Damage=max(damage,1);
    Scoreholder.AddPoints(-13*Damage); //cheater!
  }
  if (Victim.bIsPlayer&&(Damager==none||Damager==Victim)){ //self-instigated. player sux
    ScoreHolder.DamageTaken+=min(Damage,600);
    ScoreHolder.AddPoints(-0.5*min(Damage,600));
    return;
  }
  if (Victim==none||((Damager==none||Damager==Victim)&&(Victim.Enemy==none||(!Victim.Enemy.bIsPlayer))))
    return; //ignore (mapper forced kill/other enemy kill/whatever.
  RealDamage=Victim.health-max(Victim.Health-damage,0); //limits damage to total health (so weapons like flak don't record extra damage)
  if (Damager==none){
    Damager=Victim.Enemy; //assume enemy killed other somehow :p
    bSuicide=true;
    bTemp=11; //"other" damage
  }
  if (bTemp==10)
    Damage=RealDamage; //or else too much points from SSL...
  if (Victim.bIsPlayer){
    ScoreHolder.DamageTaken+=min(Damage,600);
    ScoreHolder.AddPoints(-0.25*min(Damage,600));
    return;
  }
  if (Victim.IsA('nalirabbit')||Victim.IsA('cow')||Victim.IsA('nali')){
    if (Damager.bIsPlayer){   //friendly fire by player
      ScoreHolder.FriendlyDamage+=RealDamage;
      if (bTemp<12)
        ScoreHolder.Weapons[btemp].DamageInstigated+=RealDamage;
      ScoreHolder.AddPoints(-0.25*damage);
    }
    return;   //other-wise don't care
  }
  if (!Damager.bIsPlayer) //don't count follower instigated.
    return;
  ScoreHolder.DamageInstigated+=RealDamage;
  if (bTemp<12)
    ScoreHolder.Weapons[btemp].DamageInstigated+=RealDamage;
  if (bSuicide)
    ScoreHolder.AddPoints(0.15*damage);
  else
    ScoreHolder.AddPoints(0.5*damage);
}
//David didn't like UT's
function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
  Super(UnrealGameInfo).PlayTeleportEffect(Incoming,bOut,bSound);
}

defaultproperties
{
     TargetFlash=(X=-2.000000,Y=-2.000000,Z=-2.000000)
     bHumansOnly=False
     ScoreBoardType=Class'SevenB.TVScoreBoard'
     HUDType=Class'SevenB.TVHUD'
     GameName="Seven Bullets"
     MutatorClass=Class'SevenB.tvmutator'
}
