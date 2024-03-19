// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// MonsterSmash : An SP game for any map....
// ===============================================================

class MonsterSmash expands TVSP
config (ONP);

var config int NumMonsters;
var config int NumFollowers;

var bool bTranslocator;
var bool bLoadingDone;
var int LoadedMonsters;
var int LoadNum;
var int KilledMonsters;
var float EndTime;
var bool bAlreadyChanged;
var int NumPoints;

event Tick(float DeltaTime)
{
  Super(GameInfo).Tick(deltatime);
  senttext=0;
}

function float PlayerJumpZScaling() //hard core jumping
{
    return 1.1;
}
function CheckPlayerStarts(){ //Taken from deathmatch plus
  local PlayerStart Dest, Candidate[16], Best;
  local float Score[16], BestScore;
  local int i, num;
  local NavigationPoint N;

  for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
  {
    Dest = PlayerStart(N);
    if (Dest!=none){
      Dest.bSinglePlayerStart=true;
      if (Dest.bEnabled && !Dest.Region.Zone.bWaterZone )
      {
        if (num<16)
          Candidate[num] = Dest;
        else if (Rand(num) < 16)
          Candidate[Rand(16)] = Dest;
        num++;
      }
    }
  }

  if (num == 0 ){
    log ("No starts found - Reverting to AllActors check",'ONP');
    foreach AllActors( class 'PlayerStart', Dest )
    {
      Dest.bSinglePlayerStart=true;
      if (num<16)
        Candidate[num] = Dest;
      else if (Rand(num) < 16)
        Candidate[Rand(16)] = Dest;
      num++;
    }
  }
  if (num>16) num = 16;
  else if (num == 0)
    return;

  //assess candidates
  for (i=0;i<num;i++)
    Score[i] = 3000 * FRand(); //randomize
  BestScore = Score[0];
  Best = Candidate[0];
  for (i=1;i<num;i++)
    if (Score[i] > BestScore)
    {
      BestScore = Score[i];
      Best = Candidate[i];
    }

  foreach AllActors( class 'PlayerStart', Dest )
    Dest.bEnabled=(Dest==Best);
}
function AddDefaultInventory(pawn PlayerPawn ){
  Super.AddDefaultInventory(PlayerPawn);
  super(GameInfo).adddefaultinventory(PlayerPawn);
  GivePickup(class'tvflashlight',PlayerPawn);
  GivePickup(class'seeds',PlayerPawn);
  GiveWeapon(class'SpEnf',PlayerPawn);
  if (bTranslocator) //give translocator in dom and ctf.
    GiveWeapon(class'TvTranslocator',PlayerPawn);
}

event playerpawn Login
(
  string Portal,
  string Options,
  out string Error,
  class<playerpawn> SpawnClass
)
{
local PlayerPawn NewPlayer;
  if (Linfo==none) //check for info presence
    spawn(class'ONPLevelInfo'); //muty will add to ginfo
  LInfo.bAkimboEnforcers=false;
  CheckPlayerStarts();
  Newplayer=super(SinglePlayer2).login(portal,options,error,class'TvPlayer');
  tvplayer(NewPlayer).Linfo=Linfo;
  if (Linfo.bjet) //SHIP
    Newplayer.PlayerReStartState='PlayerShip';
  theplayer = tvplayer(newplayer);   //SP holder
  return NewPlayer;
}

event PostLogin (playerpawn newplayer)
{
  local int i, loops;
  local NavigationPoint NP;
  Super.PostLogin(NewPlayer);
  SetTimer(5.0+rand(9),false);
  //hack to add friendlies  (no human support!)
  for (i=0;i<8;i++)
    thePlayer.friendlies[i]=0;
  i=0;
  while (i<NumFollowers&&Loops<NumFollowers+10){ //randomize:
    thePlayer.Friendlies[0]=rand(5);
    if (thePlayer.Friendlies[0]==0)
      thePlayer.Friendlies[0]=10*class'FollowingMercenary'.default.health;
    if (thePlayer.Friendlies[0]==2||thePlayer.Friendlies[0]==4)
      thePlayer.Friendlies[0]+=10*rand(10); //weapon
    if (LoadFriendlies(thePlayer))
      i++;
    Loops++;
  }
  // Calculate number of navigation points.
  for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
   if (NP.IsA('PathNode'))
      NumPoints++;
}

function Timer(){ //master enemy adder:
  LoadNum++;
  SpawnMonster(0);
  if (LoadNum<NumMonsters)
    SetTimer(2+rand(4),false);
  else{
    bLoadingdone=true;
    BroadCastMessage("Monster's assault has concluded!",false,'criticalevent');
  }
}
function class<ScriptedPawn> GetMonster (int SizeMax, bool Water){ //lower size max=greater.. somethign like that.
  local float Dec;
  Dec=frand();
  if (Water){ //only return water creatures...
    if (SizeMax==3||Dec<0.3)
      return class'DevilFish';
    if (Dec<0.8)
      return class'Slith';
    return class'Squid';
  }
  if (SizeMax==3){ //only allow smallest around
    if (Dec<0.5)
      return class'Pupae';
    if (Dec<0.75)
      return class'CaveManta';
    return class'Manta';
  }
  if (SizeMax==0&&Dec<0.03){ //bosses
    Dec*=2;
    if (Dec<0.01)
      return class'Warlord';
    if (Dec<0.03)
      return class'GiantGasBag';
    if (Dec<0.04)
      return class'StoneTitan';
    return class'Titan';
  }
  if (SizeMax==0&&Dec<0.09)
    return class'Tentacle';
  if (Dec<0.2){ //brutes
    if (SizeMax==2){
      if (Dec<0.09)
        return class'BattleBrute';
      else
        return class'LesserBrute';
    }
    if (Dec<0.05*(2-min(SizeMAx,1)))
      return class'BattleBrute';
    if (Dec<0.11*((1-min(SizeMAx,1))*0.36+1))
      return class'LesserBrute';
    if (Dec<0.16*((1-min(SizeMAx,1))*0.19+1))
      return class'Brute';
    return class'Behemoth';
  }
  if (Dec<0.35){ //krall
    if (Dec<0.3)
      return class'Krall';
    else
      return class'KrallElite';
  }
  if (Dec<0.49){ //manta
    if (SizeMax<=1&&Dec<0.41)
      return class'GiantManta';
    if (Dec<0.43)
      return class'Manta';
    return class'CaveManta';
  }
  if (Dec<0.58)
    return class'GasBag';
  if (Dec<0.67)
    return class'Slith';
  if (Dec<0.74)
    return class'pupae';
  //lotta skaarj :p
  if (Dec<0.87){
    if (Dec<0.78)
      return class'SkaarjTrooper';
    if (Dec<0.80)
      return class'SkaarjSniper';
    if (Dec<0.82)
      return class'SkaarjGunner';
    if (Dec<0.84)
      return class'SkaarjOfficer';
    return class'SkaarjInfantry';
  }
  if (SizeMax<2&&Dec<0.89)
    return class'SkaarjBerserker';
  if (Dec<0.92)
    return class'SkaarjWarrior';
  if (Dec<0.95)
    return class'SkaarjScout';
  if (Dec<0.98)
    return class'SkaarjAssassin';
  return class'SkaarjLord';
}

function SpawnMonster(int RecurseCount)
{
  local int PointCount, navpoint;
  local NavigationPoint NP;
  local pawn Touching;
  local float Dec;
  local scriptedpawn SpawnedMonster;
  local UTTeleportEffect PTE;
  local vector Loc, HitLoc, HitNorm;
  local class<ScriptedPawn> Monster;
  NavPoint = Rand(NumPoints);
  for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
    if ( NP.IsA('PathNode') )
    {
      if (PointCount == NavPoint)
      {
        // check that there are no other power ups here
        if ( RecurseCount < 3 )
          ForEach VisibleCollidingActors(class'pawn', Touching, 40, NP.Location)
          {
            SpawnMonster(RecurseCount + 1);
            return;
          }
         if (RecurseCount < 3 && NP.Region.Zone.bPainZone&&NP.Region.Zone.DamagePerSec>0)
         {
            SpawnMonster(RecurseCount + 1);
            return;
         }
        // Spawn it here.
        Monster=GetMonster(RecurseCount, NP.region.zone.bwaterzone);
        Loc=NP.location;
//        log (Monster@"Is at"@Loc);
        if (Monster==class'Tentacle'){
//          log ("Monster is tentacle");
          if (Trace(HitLoc,HitNorm,Loc+vect(0,0,750),Loc)!=level||HitNorm.Z>-0.98){
            SpawnMonster(RecurseCount + 1);
            return;
          }
          else{
            Loc=HitLoc-vect(0,0,1)*class'Tentacle'.default.collisionHeight;
//            log ("Tentacle passed! Loc is"@Loc);
          }
        }
        SpawnedMonster = Spawn(Monster, , , Loc);
        if ( SpawnedMonster != None){
          if (SpawnedMonster.class==class'SkaarjTrooper')
            SpawnedMonster.skin=Texture'sktrooper2';
          else if (SpawnedMonster.class==class'SkaarjInfantry')
            SpawnedMonster.skin=Texture'sktrooper3';
          else if (SpawnedMonster.Class==class'Pupae');
            SpawnedMonster.SetPhysics(Phys_Falling);
          if (LoadedMonsters==0)
            BroadCastMessage("Monsters have begun their assault!",false,'criticalevent');
          LoadedMonsters++;
          PTE = Spawn(class'UTTeleportEffect',SpawnedMonster,, SpawnedMonster.Location, SpawnedMonster.Rotation);
          PTE.PlaySound(sound'Resp2A',, 10.0);
          if (SpawnedMonster.class==class'Tentacle'){
            SpawnedMonster.SetMovementPhysics();
            return;
          }
          Dec=frand();
          if (dec<0.5)
            SpawnedMonster.Orders='attacking';
          else if (dec<0.8)
            SpawnedMonster.Orders='Wandering';
          return;
        }
        else if (RecurseCount < 3){
          SpawnMonster(RecurseCount + 1);
          return;
        }
      }
      PointCount++;
    }
}

function Killed( pawn Killer, pawn Other, name damageType )
{
  if (Other==ThePlayer)
    ThePlayer.PlayWinMessage(false);
  Super.Killed(Killer,Other,damagetype);
}

function ScoreKill(pawn Killer, pawn Other)    //does not affect PRI stuff.
{
  local string temp;
  local int OldScore;
  OldScore=theplayer.Scoreholder.Score;
  Super.ScoreKill(Killer,Other);
  if (!Other.Isa('scriptedPawn')||(Follower(Other) != none && Follower(Other).IsFriend()))
    return;
  if (Other.IsA('GasBag')&&GasBag(Other).ParentBag!=none) //giant hack
    return;
  KilledMonsters++;
  if (OldScore==ThePlayer.ScoreHolder.Score){ //not added. force:
    ThePlayer.scoreholder.scoreit(Other);
    ThePlayer.ScoreHolder.AddPoints(10);
    ThePlayer.ScoreHolder.KilledByFollowers++; //close enough :/
  }
  if (bLoadingDone&&KilledMonsters==LoadedMonsters){
    ThePlayer.ViewTarget=Other;
    EndGame("Won");
    Other.GotoState('Dying'); //hack!
    Other.SetTimer(0.0,false);
  }
  else{
    temp=Other.MenuName@"Defeated!";
    if (bLoadingDone)
      temp=temp$"  "$LoadedMonsters-KilledMonsters@"Monsters Remaining!";
    BroadCastMessage(temp,false,'criticalevent');
  }
}

function bool SetEndCams(string Reason)
{
  EndTime = Level.TimeSeconds + 3.0;
  GameReplicationInfo.GameEndedComments = theplayer.PlayerReplicationInfo.PlayerName@class'DeathMatchPlus'.default.GameEndedMessage;
  ThePlayer.PlayWinMessage(true);
  return Super.SetEndCams(Reason);
}

function RestartGame()
{
  local string NextMap;
  local MapList myList;

  if ( EndTime > Level.TimeSeconds ) // still showing end screen
    return;

  // these server travels should all be relative to the current URL
  if ( !bAlreadyChanged && (MapListType != None) )
  {
    // open a the nextmap actor for this game type and get the next map
    bAlreadyChanged = true;
    myList = spawn(MapListType);
    NextMap = myList.GetNextMap();
    myList.Destroy();
    if ( NextMap == "" )
      NextMap = GetMapName(MapPrefix, NextMap,1);

    if ( NextMap != "" )
    {
      Level.ServerTravel(NextMap, false);
      return;
    }
  }

  Level.ServerTravel("?Restart" , false);
}

defaultproperties
{
     NumMonsters=34
     NumFollowers=3
     MapListType=Class'olextras.MonsterSmashMapList'
     GameName="Operation: Na Pali ~ MoNsTeRSmASH"
}
