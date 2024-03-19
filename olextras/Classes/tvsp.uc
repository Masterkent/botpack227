// ============================================================
// olextras.TVSP: fade in and restart states....
// ============================================================

class TVSP expands singleplayer2;
var (zonelight) vector ViewFlash, ViewFog;               //following ripped from fadeviewtrigger and edited to reverse the effect....
var vector TargetFlash;
var float FadeSeconds, timey;
var vector OldViewFlash;
var TvPlayer theplayer;
var sound MP3;
var ONPLevelInfo LInfo; //info for some options
var zoneinfo fadezone; //in case player swaps zones :)
var bool bGODModeAllowed; //is god mode allowed?

var bool B227_bHandledGameEnd;

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
  if (class!=class'TVSP')
    return;
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
        if (inv.class==class'spenf'&&Linfo.bAkimboEnforcers)
          SpEnf(inv).hastwoenf=true; //post accept reads this :)
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
  if (newweapon.isa('spenf')&&LInfo.bAkimboEnforcers){
    spenf(newweapon).hastwoenf=true;
    newweapon.travelpostaccept();
  }
  newWeapon.BringUp();
  newWeapon.GiveAmmo(PlayerPawn);
  newWeapon.SetSwitchPriority(PlayerPawn);
  newWeapon.WeaponSet(PlayerPawn);
}

//called by muty.
function RegisterONPLevelInfo(actor newinfo){
  Linfo=ONPLevelInfo(newinfo);
  Linfo.fadeintime/=2;
  brestartlevel=!Linfo.RespawnPlayer;
  if (Linfo.bcutscene||Linfo.bjet)    //this designates the map as a intermission (i.e flyby)
      timey=0.5*Linfo.fadeintime;
  log ("Successfully bound level information",'ONP');
}
//STORE FRIENDLIES!
//(this will need to be redone somehow for co-op!)
function SendPlayer( PlayerPawn aPlayer, string URL ){
local pawn p;
local int i;

	if (B227_bHandledGameEnd)
	{
		aPlayer.ClientTravel(URL, TRAVEL_Relative, true);
		return;
	}
	B227_bHandledGameEnd = true;

//URL=URL$"?Difficulty="$difficulty; //hack!!!!!!!!!!!!!
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
if (!Linfo.FollowersCanLeave){
  aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
  return;
}
i=0;
for (p=level.pawnlist;p!=none;p=p.nextpawn){
  if (i>7){
    log ("WARNING: OUT OF FOLLOWER ARRAY SPACE",'ONP');
    break;
  }
  if (Follower(P) != none && Follower(p).DoTravel(tvplayer(aPlayer),i)){
    if (p.class==class'followingmercenaryelite')  //elite flag.
      tvPlayer(aPlayer).Friendlies[i]+=1;
    if (p.class==class'nalitrooper') //nali flags
      tvPlayer(aPlayer).Friendlies[i]+=2;
    if (p.class==class'rebelskaarj')  //sk
      tvPlayer(aPlayer).Friendlies[i]+=3;
    if (p.class==class'rebelskaarjtrooper')//sktroop flags
      tvPlayer(aPlayer).Friendlies[i]+=4;
    if (p.class==class'scriptedmale')//male
      tvPlayer(aPlayer).Friendlies[i]+=5;
    if (p.class==class'scriptedfemale')//female
      tvPlayer(aPlayer).Friendlies[i]+=6;
    if (p.class==class'FollowingKrall')//krall
      tvPlayer(aPlayer).Friendlies[i]+=7;
    if (p.class==class'FollowingKrallElite')//1337 krall
      tvPlayer(aPlayer).Friendlies[i]+=8;
    i++;
  }
}
log (i@"followers being transported to next level.",'ONP');
aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}
function bool LoadFriendlies(tvplayer p){ //This spawns the monsters again.
local int i;
local bool bSuccess;
local Follower pa;
local class<follower>PaCl;
local navigationpoint pstart;
for (i=0;i<8;i++){
//log ("TVSP: Friendlies incoming: "$p.Friendlies[i]);
  if (p.Friendlies[i]==0) //end of array
    break;
  //log ("TVSP: non-breaked Friendlies incoming: "$p.Friendlies[i]);
  switch (p.friendlies[i]%10){
    case 0:
      PaCl=class'followingmercenary';
      break;
    case 1:
      paCl=class'followingmercenaryelite';
      break;
    case 2:
      paCl=class'nalitrooper';
      break;
    case 3:
      paCl=class'rebelskaarj';
      break;
    case 4:
      paCl=class'rebelskaarjtrooper';
      break;
    case 5:
      paCl=class'scriptedmale';
      break;
    case 6:
      paCl=class'scriptedfemale';
      break;
    case 7:
      paCl=class'FollowingKrall';
      break;
    case 8:
      paCl=class'FollowingKrallElite';
      break;
  }
  if (paCl==class'rebelskaarjtrooper'){ //set up weapon default.
    p.friendlies[i]-=4; //easier to add :P
    p.friendlies[i]/=10; //so health convert works.
    switch(p.friendlies[i]%10){
      case 0:
        class'rebelskaarjtrooper'.default.weapontype=class'sniperrifle';
        break;
      case 1:
        class'rebelskaarjtrooper'.default.weapontype=class'NoammoDpistol';
        break;
      case 2:
        class'rebelskaarjtrooper'.default.weapontype=class'SPenf';
        break;
      case 3:
        class'rebelskaarjtrooper'.default.weapontype=class'ut_biorifle';
        break;
      case 4:
        class'rebelskaarjtrooper'.default.weapontype=class'OSShockrifle';
        break;
      case 5:
        class'rebelskaarjtrooper'.default.weapontype=class'TVpulsegun';
        break;
      case 6:
        class'rebelskaarjtrooper'.default.weapontype=class'ripper';
        break;
      case 7:
        class'rebelskaarjtrooper'.default.weapontype=class'minigun2';
        break;
      case 8:
        class'rebelskaarjtrooper'.default.weapontype=class'ut_flakcannon';
        break;
      case 9:
        class'rebelskaarjtrooper'.default.weapontype=class'TVEightball';
      break;
    }
  }

  pstart=FindFriendlyStart();
  if (pstart==none){
    Log ("NOT ENOUGH PLAYERSTARTS TO SPAWN INCOMING FRIENDLY CREATURES!!!!!!!",'ONP');
    return false;
  }
  pa=spawn(paCL,,'traveled',pstart.location,pstart.rotation);
  if (pa!=none){
    bSuccess=true;
    if (WeaponHolder(pa) != none){ //weapon holder altering
      p.friendlies[i]/=10;
      switch(p.friendlies[i]%10){
        case 0:
          WeaponHolder(pa).weapontype=class'sniperrifle';
          break;
        case 1:
          WeaponHolder(pa).weapontype=class'NoammoDpistol';
          break;
        case 2:
          WeaponHolder(pa).weapontype=class'SPenf';
          break;
        case 3:
          WeaponHolder(pa).weapontype=class'ut_biorifle';
          break;
        case 4:
          WeaponHolder(pa).weapontype=class'OSShockrifle';
          break;
        case 5:
          WeaponHolder(pa).weapontype=class'TVpulsegun';
          break;
        case 6:
          WeaponHolder(pa).weapontype=class'ripper';
          break;
        case 7:
          WeaponHolder(pa).weapontype=class'minigun2';
          break;
        case 8:
          WeaponHolder(pa).weapontype=class'ut_flakcannon';
          break;
        case 9:
          WeaponHolder(pa).weapontype=class'TVEightball';
          break;
      }
    }
    if (p.friendlies[i]/10>0)
      pa.health=p.friendlies[i]/10; //health :P
    if (ScriptedHuman(pa) != none)
      scriptedhuman(pa).ParseSkinInfo(p.friendlynames[i]);
    else if (p.friendlynames[i]!="")
      pa.menuname=p.friendlynames[i];  //more options
    if (pa.menuname!=pa.default.menuname)
      pa.NameArticle=" ";
    pa.MyName=pa.menuname;
//    pa.groundspeed=p.FriendlySpeeds[i];
 //   pa.maxstepheight=p.FriendlyMaxStepHeights[i];
    if (p.FriendlyDrawScales[i]>0)
      pa.drawscale=p.FriendlyDrawScales[i];
    if (p.FriendlyFatness[i]>0)
      pa.fatness=p.FriendlyFatness[i];
    log ("Follower"@pa.menuname$" ("$paCL$") spawned with"@pa.health@"health.",'ONP');
    if (class==class'TvSP') //hack for monster mash
      pa.Setpa(p); //only in SP!
    else
      pa.OnlyAttackWhenControlled=true;
  }
  else
    Log("Failed to spawn"@pacl,'ONP');
}
//log (i@"followers loaded into new level.",'ONP');
for (i=0;i<8;i++) //reset
  p.friendlies[i]=0;
//set back skaarj default.
class'rebelskaarjtrooper'.default.weapontype=class'NoammoDpistol';
return bSuccess;
}
//Find a suitable start for friendly creatures.  This uses the co-op algorithm.
function NavigationPoint FindFriendlyStart()
{
  local PlayerStart Dest, Candidate[8], Best;
  local float Score[8], BestScore, NextDist;
  local pawn OtherPlayer;
  local int i, num;

  num = 0;
  //choose candidates
  foreach AllActors( class 'PlayerStart', Dest )
  {
    if ( (Dest.bSinglePlayerStart || Dest.bCoopStart) && !Dest.Region.Zone.bWaterZone && (class!=class'TVSP'||Dest.bEnabled))
    {
      if (num<4)
        Candidate[num] = Dest;
      else if (Rand(num) < 4)
        Candidate[Rand(4)] = Dest;
      num++;
    }
  }

  if (num>4) num = 4;
  else if (num == 0)
    return None;

  //assess candidates
  for (i=0;i<num;i++)
    Score[i] = 4000 * FRand(); //randomize

 // foreach AllActors( class 'Pawn', OtherPlayer )
  for (OtherPlayer=level.pawnlist;OtherPlayer!=none;OtherPlayer=OtherPlayer.nextpawn)
  { //above safe?
    if (OtherPlayer.bIsPlayer)
    {
      for (i=0;i<num;i++)
      {
        NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
        Score[i] += NextDist;
        if (NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight)
          Score[i] -= 1000000.0;
      }
    }
  }

  BestScore = Score[0];
  Best = Candidate[0];
  for (i=1;i<num;i++)
  {
    if (Score[i] > BestScore)
    {
      BestScore = Score[i];
      Best = Candidate[i];
    }
  }

  return Best;
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
  Log("No ONPLevelInfo placed in level!  Using default options.",'ONP');
  spawn(class'ONPLevelInfo'); //muty will add to ginfo
}
CheckPlayerStarts();
Newplayer=super.login(portal,options,error,class'TvPlayer');
tvplayer(NewPlayer).Linfo=Linfo;
if (Linfo.bjet) //SHIP
  Newplayer.PlayerReStartState='PlayerShip';
theplayer = tvplayer(newplayer);   //SP holder
if (MP3!=none) //MP3 support
  tvplayer(NewPlayer).ClientSetMp3(MP3,soundvolume,soundpitch);
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
function prebeginplay(){ //designed for MP3's
  MP3=level.ambientsound;
  level.ambientsound=none; //not needed.
  SoundVolume=level.soundvolume;
  SoundPitch=level.SoundPitch;
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
  if (Other==none||Other.bIsPlayer||((Killer==none||Killer==Other)&&(Other.Enemy==none||(!Other.Enemy.bIsPlayer && Follower(Other.Enemy) == none))))
    return; //ignore (mapper forced kill/other enemy kill/whatever.
  if (Killer==none){
    Killer=Other.Enemy; //assume enemy killed other somehow (knocking into lava/whatever)
    bSuicide=true;
  }
  scoreholder.scoreit(Other); //count as thing dead.
  if ((theplayer.ReducedDamageType=='All'&&!bGODModeAllowed)||theplayer.IsInState('cheatflying'))
    Scoreholder.AddPoints(-200); //cheater!
  if ((Follower(Other) != none && Follower(Other).IsFriend())||Other.IsA('nalirabbit')||Other.IsA('cow')||Other.IsA('nali')){
    scoreholder.KilledFollowers++;
    if (Killer.bisplayer) //stupid player killed him
      scoreholder.AddPoints(-90);
    else if (Follower(Killer) == none || !Follower(Killer).IsFriend()){ //other enemy killed him: player failed to save
      if (bSuicide)
        scoreholder.AddPoints(-10); //not much of a lost.
      else
        scoreholder.AddPoints(-20); //not much of a lost.
    }
    return;       //no points lost if killed in friendly fire by other followers.
  }
  if (Follower(Killer) != none && Follower(Killer).IsFriend()){
    ScoreHolder.KilledByFollowers++;
    if (Other.Isa('scriptedpawn')&&ScriptedPawn(Other).bIsBoss)
      ScoreHolder.AddPoints(75);
    else if (bSuicide)
      ScoreHolder.AddPoints(25);
    else
      ScoreHolder.AddPoints(50); //5 points for follower killing d00d
    return;
  }
  ScoreHolder.killtotal++; //normal player killing enemies.
  if (Other.Isa('scriptedpawn')&&ScriptedPawn(Other).bIsBoss)
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
  if (theplayer.Weapon==none)
    bTemp=12;
  else if (theplayer.Weapon.IsA('Translocator')) //translocator cannot instigate damage. set this to "other" (rocket fired?)
    bTemp=11;
  else if (theplayer.Weapon.IsA('SuperShockRifle'))
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
  if (Victim==none||((Damager==none||Damager==Victim)&&(Victim.Enemy==none||(!Victim.Enemy.bIsPlayer && Follower(Victim.Enemy) == none))))
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
    if (Follower(Damager) == none || !Follower(Damager).IsFriend()) //followers suck and like to hit player
      ScoreHolder.AddPoints(-0.25*min(Damage,600));
    return;
  }
  if ((Follower(Victim) != none && Follower(Victim).IsFriend())||Victim.IsA('nalirabbit')||Victim.IsA('cow')||Victim.IsA('nali')){
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

//New in ONP 1.3: Reduced follower damage:
function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
  if (injured!=none && InstigatedBy!=none){
    if (injured.bIsPlayer && Follower(InstigatedBy) != none && Follower(InstigatedBy).IsFriend())
      Damage*=fmin(difficulty*difficulty/9.0,1.0);
   }
   return Super.ReduceDamage(Damage,DamageType,injured,instigatedby);
}

defaultproperties
{
     TargetFlash=(X=-2.000000,Y=-2.000000,Z=-2.000000)
     DefaultWeapon=Class'olextras.NoammoDpistol'
     ScoreBoardType=Class'olextras.TVScoreBoard'
     HUDType=Class'olextras.TVHUD'
     GameName="Operation: Na Pali"
     MutatorClass=Class'olextras.tvmutator'
}
