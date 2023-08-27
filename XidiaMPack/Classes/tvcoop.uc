// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// tvcoop.  The co-op gameinfo for ONP
// ============================================================

class tvcoop expands coopgame2;

var XidiaLevelInfo LInfo; //info for some options
var Inventory B227_LastCreatedInventory;

//highly modified to use level actor :)
function AddDefaultInventory(pawn PlayerPawn ){
  local inventory inv;
  local int i;
  local byte PlayerHas[20];
  local bool bKilledSelected;

  //uses level actor.
  if (LInfo.DefaultWeapon%2==0)
    super(GameInfo).adddefaultinventory(PlayerPawn);    //skeeper
  //translator/flight
  if( PlayerPawn.IsA('Spectator'))
    return;
  if (Linfo.InventoryToDestroy[0]==class'inventory'&&Linfo.NetOptions[20]%2==0){
    for ( Inv=PlayerPawn.Inventory; Inv!=None; Inv=Inv.Inventory )
        Inv.Destroy();
    return;
  }
  if (Linfo.InventoryToDestroy[0]==class'Weapon'&&Linfo.NetOptions[20]%2==0){
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
        if (inv.class==class'XidiaAutoMag'&&Linfo.bAkimboMags)
          XidiaAutoMag(inv).hastwoMag=true;
        if (inv.IsA('Weapon'))
          CheckAmmo(playerpawn,Weapon(inv));
      }
      else if (i<8&&Linfo.InventoryToDestroy[i]==inv.class&&(Linfo.NetOptions[i+20]%2==0)){
        if (PlayerPawn.SelectedItem==Inv)
          bKilledSelected=true;
        Inv.destroy();       //remove
      }
    }
  for (i=0;i<20;i++){     //add
    if (Linfo.DefaultInventory[i]==none)
      break;
    if (PlayerHas[i]==1||(Linfo.NetOptions[i]%2==1))
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
  local Pickup Pickup;
  B227_LastCreatedInventory = none;
  Pickup = Spawn(pickupclass);
  if (Pickup == none)
  {
    if (Pickup(B227_LastCreatedInventory) == none || B227_LastCreatedInventory.bDeleteMe)
      return;
    Pickup = Pickup(B227_LastCreatedInventory);
  }
  Pickup.bhelditem=true;
  Pickup.GiveTo(PlayerPawn);
  if (Pickup.IsA('TvTranslator')||Playerpawn.selecteditem==none)
    PlayerPawn.selecteditem=Pickup;
  Pickup.PickupFunction(playerpawn);
  if (!PlayerPawn.IsA('playerpawn'))
    Pickup.Activate();
}
function GiveWeapon(class<weapon> weapclass, pawn playerpawn){
  local Weapon newWeapon;
  B227_LastCreatedInventory = none;
  newWeapon = Spawn(WeapClass,,,PlayerPawn.Location);
  if( newWeapon == None )
  {
    if (Weapon(B227_LastCreatedInventory) == none || B227_LastCreatedInventory.bDeleteMe)
      return;
    newweapon = Weapon(B227_LastCreatedInventory);
  }
  newWeapon.Instigator = PlayerPawn;
  newWeapon.BecomeItem();
  PlayerPawn.AddInventory(newWeapon);
  if (newweapon.isa('XidiaAutoMag')&&LInfo.bAkimboMags){
    XidiaAutoMag(newweapon).HasTwoMag=true;
    newweapon.travelpostaccept();
  }
  newWeapon.BringUp();
  newWeapon.GiveAmmo(PlayerPawn);
  newWeapon.SetSwitchPriority(PlayerPawn);
  newWeapon.WeaponSet(PlayerPawn);
}

function CheckAmmo(pawn p, Weapon w){ //force minimum ammo in co-op
  local Ammo Type;
  Type = Ammo(p.FindInventoryType(w.AmmoName));
  if (Type != None )
     Type.AmmoAmount=max(Type.AmmoAmount,w.PickupAmmoCount);
}

//called by muty.
function RegisterXidiaLevelInfo(actor newinfo){
  Linfo=XidiaLevelInfo(newinfo);
  brestartlevel=!Linfo.RespawnPlayer;
  log ("Successfully bound level information",'Xidia');
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
  Newplayer=super.login(portal,options,error,class'TvPlayer');
  tvplayer(NewPlayer).Linfo=Linfo;
  if (Linfo.bjet) //SHIP
    Newplayer.PlayerReStartState='PlayerShip';
  if (NewPlayer.Health>Linfo.maxhealth&&Linfo.Maxhealth!=0)
    NewPlayer.Health = Linfo.MaxHealth;
  return newplayer;
}
//David didn't like UT's
function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
  Super(UnrealGameInfo).PlayTeleportEffect(Incoming,bOut,bSound);
}
//merc stuff:
//STORE FRIENDLIES!
function SendPlayer( PlayerPawn aPlayer, string URL ){
if ( left(URL,4) ~= "np36")     //ADD CO-OP MAP HACK HERE!
  {
    Level.ServerTravel( "Np02DavidM", false);
    return;
  }
if (tvplayer(aPlayer) != none){
    if (Linfo.bJet)
      aPlayer.health=tvplayer(aplayer).oldhealth;
}
super.sendplayer(aplayer,URL);
}

event PostLogin (playerpawn newplayer)
{
  local actor A;
  Super.PostLogin(newplayer);
  if (Linfo.Event!='')
    ForEach AllActors(class'Actor',A,Linfo.Event)
      A.Trigger(Linfo,newplayer);
}

function float PlaySpawnEffect(inventory Inv)
{
  spawn( class 'ReSpawn',,, Inv.Location );
  return 0.3;
}

function bool ShouldRespawn(Actor Other)
{
  if (Inventory(Other)==none)
    return false;
  if (!Other.IsA('weapon')){
    Other.bAlwaysRelevant = Other.default.bAlwaysRelevant;
    Other.NetUpdateFrequency = Other.default.NetUpdateFrequency;
    return false;
  }
  //return ( (Inventory(Other) != None) && (Inventory(Other).ReSpawnTime!=0.0) );
  return (Inventory(Other).ReSpawnTime!=0.0 );
}

//hack for no weapon stays for dropped items
function DiscardInventory( Pawn Other )
{
  local actor dropped;
  local inventory Inv;
  local weapon weap;
  local float speed;

  if( Other.DropWhenKilled != None )
  {
    dropped = Spawn(Other.DropWhenKilled,,,Other.Location);
    Inv = Inventory(dropped);
    if ( Inv != None )
    {
      Inv.RespawnTime = 0.0; //don't respawn
      Inv.BecomePickup();
      Inv.bHeldItem=true;
    }
    if ( dropped != None )
    {
      dropped.RemoteRole = ROLE_DumbProxy;
      dropped.SetPhysics(PHYS_Falling);
      dropped.bCollideWorld = true;
      dropped.Velocity = Other.Velocity + VRand() * 280;
    }
    if ( Inv != None )
      Inv.GotoState('PickUp', 'Dropped');
  }
  if( (Other.Weapon!=None) && (Other.Weapon.Class!=Level.Game.BaseMutator.MutatedDefaultWeapon())
    && Other.Weapon.bCanThrow )
  {
    speed = VSize(Other.Velocity);
    weap = Other.Weapon;
    weap.bHeldItem=true; //hack
    if (speed != 0)
      weap.Velocity = Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280);
    else {
      weap.Velocity.X = 0;
      weap.Velocity.Y = 0;
      weap.Velocity.Z = 0;
    }
    Other.TossWeapon();
    if ( weap.PickupAmmoCount == 0 )
      weap.PickupAmmoCount = 1;
  }
  Other.Weapon = None;
  Other.SelectedItem = None;
  for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory )
    Inv.Destroy();
}

function BeginPlay(){ //use VA!
  local class<mutator> m;
  Super.BeginPlay();
  if (level.netmode==nm_dedicatedserver){
    m=class<mutator>(DynamicLoadObject("XiVa.VaServer",class'class'));
    if (m!=none)
      Spawn(m);
  }
}

//support benabled:
function NavigationPoint FindPlayerStart(optional byte InTeam, optional string incomingName)
{
  local PlayerStart Dest, Candidate[8], Best;
  local float Score[8], BestScore, NextDist;
  local pawn OtherPlayer;
  local int i, num;

  num = 0;
  //choose candidates
  foreach AllActors( class 'PlayerStart', Dest )
  {
    if ( (Dest.bSinglePlayerStart || Dest.bCoopStart) && !Dest.Region.Zone.bWaterZone && Dest.bEnabled)
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

  foreach AllActors( class 'Pawn', OtherPlayer )
  {
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

function Killed(pawn killer, pawn Other, name damageType)      //no taunts....
{
  Super(UnrealGameInfo).Killed(Killer,Other,DamageType);
}
function CoOpPoints(float Points){
  local pawn p;
  for (p=level.pawnlist;p!=none;p=p.nextpawn)
    if (p.IsA('tvPlayer')&&p.playerreplicationinfo!=none)
      P.PlayerREplicationInfo.Score+=Points;
}

function ScoreKill(pawn Killer, pawn Other)    //Use singleplayer scoring system
{
  local bool bSuicide;
  if (Other==none)
    return;
  if (Other.bIsPlayer){
    Other.PlayerReplicationInfo.Score-=170; //yuo suck!
    return;
  }
  if ((Killer==none||Killer==Other)&&(Other.Enemy==none||(!Other.Enemy.bIsPlayer)))
    return; //ignore (mapper forced kill/other enemy kill/whatever.
  if (Killer==none){
    Killer=Other.Enemy; //assume enemy killed other somehow (knocking into lava/whatever)
    bSuicide=true;
  }
  if (Killer.PlayerReplicationInfo==none)
    return;
  //now guarenteed to be a player.
  if (Other.Isa('scriptedpawn')&&ScriptedPawn(Other).bIsBoss)
    Killer.PlayerReplicationInfo.Score+=150;
  else if (bSuicide) //knocked off ledge...
    Killer.PlayerReplicationInfo.Score+=50;
  else
    Killer.PlayerReplicationInfo.Score+=100;
}

function ScoreDamage(int Damage, Pawn Victim, Pawn Damager){
  local bool bSuicide; //suiciding
  if (Victim.bIsPlayer&&(Damager==none||Damager==Victim)){ //self-instigated. player sux
    Victim.PlayerReplicationInfo.Score-=min(Damage,600);
    return;
  }
  if (Victim.bIsPlayer&&Damager.bIsPlayer){ //lamer
    Damager.PlayerReplicationInfo.Score-=1.5*Damage;
    return;
  }
  if (Victim==none||((Damager==none||Damager==Victim)&&(Victim.Enemy==none||(!Victim.Enemy.bIsPlayer))))
    return; //ignore (mapper forced kill/other enemy kill/whatever.
  if (Damager==none){
    Damager=Victim.Enemy; //assume enemy killed other somehow :p
    bSuicide=true;
  }
  if (Victim.bIsPlayer){
     Victim.PlayerReplicationInfo.Score-=0.25*min(Damage,600);
    return;
  }
  if (!Damager.bIsPlayer||Damager.PlayerReplicationInfo==none) //don't count follower instigated.
    return;
  if (bSuicide)
    CoopPoints(0.15*damage);
  else
    CoopPoints(0.5*damage);
}


 /*
//ONP 1.3: Prisoned hack...
function PreBeginPlay()
{
  local actor a;
  local int n;

  Super.PreBeginPlay();
  if (!(level.title~="Prisoned"))
    return;
  log ("Hack-fixing np02DavidM.unr",'ONP');
  ForEach AllActors (class'Actor',a){
    if (a.class.name=='Mercenary'&&right(string(a),2)~="y1")
      a.bnet=false;
    else if (a.class.name=='Trigger'&& (right(string(a),2)=="52" || right(string(a),2)=="45") )
      a.bnet=false;
    else if (a.class.name=='SkaarjScout'&&right(string(a),2)~="t0")
      a.bnet=false;
    else if (a.IsA('mover')){ //this is where it gets ugly..
      n=int(right(string(a),2));
      if ( (n>=72&&n<=76) || (n>=34 && n<=40) || n==10 || n==11 || n==66 || n==29 || n==30)
        a.bnet=false;
    }
  }
}      */

function bool IsRelevant(Actor A)
{
	if (Inventory(A) != none)
		B227_LastCreatedInventory = Inventory(A);
	return super.IsRelevant(A);
}

defaultproperties
{
     HUDType=Class'XidiaMPack.TVHUD'
     GameName="Xidia Co-Op"
     MutatorClass=Class'XidiaMPack.tvmutator'
}
