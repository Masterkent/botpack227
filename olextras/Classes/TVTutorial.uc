// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
//TvTutorial. Custom Gameinfo for the Operation: Na Pali tutorial.
// somewhat based on DM tutorials.
// ============================================================

class TVTutorial expands TVSP;
var localized string TutMessage[8];  //messages
var localized string ExtraMessage[11]; //for divided messages.
var string KeyAlias[255];
var string DM[8]; //sounds
var name Movers[8]; //movers to trigger
//var TVPlayer Trainee; //d00d we're training.
var bool bleaveon; //leave on message?
var int EventTimer, EventIndex, RealIndex; //Real index acts like a current. so old tuts can go back w/out requirements.
var Tvtranslator trans;
var int invcheck; //1=changed 2=used.  3=both
var inventory firstselected; //used for changed check.
var int oldcopies; //used for use check (flares only)
var Follower merc;
var bool bRecheckBindings; //if bindings should be tested again (after setting in window)

event PostLogin (playerpawn newplayer)  //set bindings here.
{
//trainee=tvplayer(newplayer);
Super.PostLogin(newplayer);
LoadKeyBindings(newplayer,true);
newplayer.ReducedDamageType = 'All';
}
function tick(float delta){
  Super.tick(delta);
  if (bReCheckBindings){
    bReCheckBindings=false;
    LoadKeyBindings(theplayer,false);
  }
}
function ProcessEvent(){ //main event processor
GotoState('');
invcheck=0;
switch (EventIndex)
    {
      case 0:
        TutEvent0();
        break;
      case 1:
        TutEvent1();
        break;
      case 2:
        TutEvent2();
        break;
      case 3:
        TutEvent3();
        break;
      case 4:
        TutEvent4();
        break;
      case 5:
        TutEvent5();
        break;
      case 6:
        TutEvent6();
        break;
      case 7:
        TutEvent7();
        break;
   }
}
function Timer()  //mover timer.   implamented further in substates to allow other events.
{
  local mover i;
  Super.Timer();
  if (eventtimer==0)
    return;
  EventTimer--;
  if (bleaveon&&realindex==eventindex)
    return;
  if (eventtimer==0){
    if (realindex==eventindex&&movers[eventindex]!='')  //trigger a mover that may now be opened
      foreach allactors(class'mover',i,movers[eventindex]){
        i.Trigger(self,theplayer);
        if (string(i.getstatename())~=getitemname(string(i.class)))
          i.gotostate('StandOpenTimed');
      }
    class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, ""); //wipe
    if (invcheck==5)  //1 case: read next MSG.
    {
      invcheck=0;
      EventIndex++;
      if (eventindex>realindex)
        realindex=eventindex;
      ProcessEvent();
    }
  }
}

function SendPlayer( PlayerPawn aPlayer, string URL ){ //no followers/items
  aPlayer.ClientTravel("NP01eVOLVE?Game=olextras.tvsp?Difficulty="$difficulty, TRAVEL_Relative, false );
}
function SetGameSpeed (float i){ //force it at 1.
  super.SetGameSpeed(1);
}

function TutorialSound( int i )   //sound play
{
  local sound MySound;
   eventtimer=9;
   if (dm[i]=="")
   return;
  MySound = sound( DynamicLoadObject(Dm[i], class'Sound') );
  EventTimer = GetSoundDuration( MySound )+2 ;    //see how long sound lasts.
  theplayer.PlaySound(MySound, SLOT_Interface, 2.0);
}
function LoadKeyBindings(PlayerPawn P, bool Check)  //keyz
{
  local int i;
  local string k;
  local byte keyset;

  for (i=0; i<255; i++)
  {
    k = P.ConsoleCommand( "KEYNAME "$i );
    KeyAlias[i] = Caps(P.ConsoleCommand( "KEYBINDING "$k ));
    if (Check){
      if (keyset!=1&&instr(KeyAlias[i],"SPEECH 2 3 0") !=-1)
        keyset+=1;
      if (keyset!=2&&instr(KeyAlias[i],"SPEECH 2 1 0") !=-1)
        keyset+=2;
     }
  }
   if (Check&&keyset!=3){ //generate window
     class'KeyBinderOpener'.static.OpenBinder(P);
     bRecheckBindings=true;
  }
}
function advance (int i){ //advance event!
//if (i>eventindex||(eventtimer==0&&i==eventindex)){
eventindex=i;
IF (EVENTindex>realindex)
  realindex=eventindex;
ProcessEvent();
}
//}
//events:
function TutEvent0(){
theplayer.ProgressTimeOut = Level.TimeSeconds;
//  LoadKeyBindings(Trainee);
    bleaveon=false;
  class'TournamentConsole'.static.UTSF_ShowMessage(theplayer.Player.Console);
  TutorialSound(0);
  class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, TutMessage[0]);
  theplayer.Health = 100;
}
function TutEvent1(){ //new one
TutorialSound(7);
class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, TutMessage[7]);
bleaveon=true; //wait until pistol is picked up.
if (eventindex==realindex)
  GotoState('WaitPistol');
}
state WaitPistol    //Await dpistol pickup
{
function tick(float delta){
if (theplayer.weapon!=none&&theplayer.weapon.IsA('oldpistol')&&OLDPISTOL(theplayer.weapon).powerlevel==2){
  bleaveon=false;
  eventtimer=1;
  timer();
  realindex++;
  gotostate('');
}
}
function beginstate(){
enable('tick'); //?
}
}
function TutEvent2(){
  bleaveon=false;
TutorialSound(1);
class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, TutMessage[1]);
invcheck=5; //flag to wait for next MSG.
}
function TutEvent3(){
local int i;
local string Transkey;
local string NextKey, PrevKey;
local tvtranslatorevent tr;
TutorialSound(2);
for (i=0; i<255; i++){ //find transkey
  if (instr(KeyAlias[i],"ACTIVATETRANSLATOR") !=-1)
    {
      if (Transkey != "")
        Transkey = Transkey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        Transkey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
  if (instr(KeyAlias[i],"NEXTWEAPON") !=-1)
    {
      if (NextKey != "")
        NextKey = NextKey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        NextKey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
  if (instr(KeyAlias[i],"PREVWEAPON") !=-1)
    {
      if (PrevKey != "")
        PrevKey = PrevKey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        PrevKey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
}
invcheck=0; //reset
if (eventindex==realindex)
  eventtimer=0;
class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, TutMessage[2] $ transkey $ ExtraMessage[0] $ prevkey $ ExtraMessage[8] $ nextkey $ ExtraMessage[9]);
bleaveon=true; //leave on until player activates translator
trans=tvtranslator(theplayer.findinventorytype(class'tvtranslator'));
if (eventindex==realindex){
  gotostate('WaitRead');
  foreach allactors(class'tvtranslatorevent',tr,'r2trans'){ //allows TransEvent to show message now.
    tr.trigger(self,theplayer);
    break;
  }
}}
state WaitRead    //Await translator reading.
{
function tick(float delta){
if (trans!=none&&trans.bActive&&trans.GetMessage()!=class'translator'.default.NewMessage){
bleaveon=false;
eventtimer=1;
timer();
realindex++;
gotostate('');
//disable('tick');
//log("Ending Tut 2");
}
else if (trans==none)
trans=Tvtranslator(theplayer.findinventorytype(class'Tvtranslator'));
}
function beginstate(){
enable('tick'); //?
//log ("Waiting for translator to be checked trans is "$trans);
}
}
function TutEvent4(){
//log ("Trying Tut 3");
if (theplayer.findinventorytype(class'tvsearchlight')!=none)  //already grabbed. skip to next MSG.
advance(5);
else{
class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, TutMessage[3]);
TutorialSound(3);
bleaveon=true; //leave on until player gets INV
if (eventindex==realindex)
  gotostate('waitgrab');
}}
state waitgrab{
function tick(float delta){   //wait for light pickup
if (theplayer.findinventorytype(class'tvSearchLight')!=none){
gotostate('');
realindex++;
Advance(5);
}}}
function TutEvent5(){
local int i;
local string Nextkey, PrevKey, UseKey;
for (i=0; i<255; i++){ //find keys
  if (instr(KeyAlias[i],"INVENTORYNEXT") !=-1)
    {
      if (Nextkey != "")
        Nextkey = Nextkey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        Nextkey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
  if (instr(KeyAlias[i],"INVENTORYPREVIOUS") !=-1)
    {
      if (Prevkey != "")
        Prevkey = Prevkey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        Prevkey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
     if (instr(KeyAlias[i],"INVENTORYACTIVATE") !=-1)
    {
      if (Usekey != "")
        Usekey = Usekey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        Usekey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
}
TutorialSound(4);
class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, TutMessage[4] $ nextkey $ ExtraMessage[1] $ prevkey $ ExtraMessage[2] $ usekey $ ExtraMessage[3]);
if (eventindex==realindex)
  eventtimer=0; // a wait.
bleaveon=true; //leave on until player messes with INV.
if (eventindex==realindex)
  gotostate('WaitINV');

}
state WaitINV{  //wait for inventory use and swaps.
function tick(float delta){
if (theplayer.selecteditem!=firstselected){
  if (invcheck!=2)
    invcheck+=2;
  oldcopies=pickup(theplayer.selecteditem).numcopies; //update
  firstselected=theplayer.selecteditem;
}
if (invcheck!=1&&(pickup(theplayer.selecteditem).numcopies<oldcopies||theplayer.selecteditem.bActive))
  invcheck+=1;
if (invcheck==3){ //cheap way :P
  eventtimer=1;
bleaveon=false;
timer();
realindex++;
gotostate('');
}
}
function beginstate(){
invcheck=0;
firstselected=theplayer.selecteditem;
oldcopies=pickup(firstselected).numcopies;
}
}
function TutEvent6(){
local int i;
local string Fkey, Wkey;
bleaveon=false; //no more of this
for (i=0; i<255; i++){ //find transkey
  if (instr(KeyAlias[i],"SPEECH 2 3 0") !=-1)
    {
      if (FKey != "")
        FKey = FKey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        FKey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
    if (instr(KeyAlias[i],"SPEECH 2 1 0") !=-1)
    {
      if (WKey != "")
        WKey = WKey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        WKey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
 }
TutorialSound(5);
class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, TutMessage[5] $ FKey $ ExtraMessage[4] $ WKey $ ExtraMessage[7]);
bleaveon=true;
if (eventindex==realindex)
  gotostate('waitmerc');
}
state waitmerc  //wait for human to be ordered
{
function beginstate(){
local pawn p;
for (p=level.pawnlist;p!=none;p=p.nextpawn)
if (p.isa('ScriptedMale'))
break;
merc=Follower(p);
}
function tick(float delta){
local actor trig;
if (merc!=none&&!merc.bshouldwait){
eventtimer=1;
bleaveon=false;
timer();
realindex++;
foreach allactors(class'actor',trig,'lifttrig')   //enable lift trigger.
  Trig.Trigger(self,theplayer);
gotostate('');
}
} }

function TutEvent7(){
local int i;
local string Nextkey, PrevKey, ScoreKey;
bLeaveOn=false;
for (i=0; i<255; i++){ //find keys
  if (instr(KeyAlias[i],"QUICKSAVE") !=-1)
    {
      if (Nextkey != "")
        Nextkey = Nextkey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        Nextkey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
  if (instr(KeyAlias[i],"QUICKLOAD") !=-1)
    {
      if (Prevkey != "")
        Prevkey = Prevkey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        Prevkey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
  if (instr(KeyAlias[i],"SHOWSCORES") !=-1)
    {
      if (Prevkey != "")
        ScoreKey = ScoreKey$","@class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
      else
        ScoreKey = class'UMenuCustomizeClientWindow'.default.LocalizedKeyName[i];
    }
}
TutorialSound(6);
class'TournamentConsole'.static.UTSF_AddMessage(theplayer.Player.Console, TutMessage[6] $ nextkey $ ExtraMessage[5] $ prevkey $ ExtraMessage[6] $ ScoreKey $ ExtraMessage[10]);
}

function Killed(pawn killer, pawn Other, name damageType)
{
  local int NextTaunt, i;
  local bool bAutoTaunt;
  if ( (damageType == 'Decapitated') && (Killer != Other) && (Killer != None) &&(TournamentPlayer(Killer) != None) && TournamentPlayer(Killer).bAutoTaunt)       //play headshot thingy :D
  class'UTC_Pawn'.static.UTSF_ReceiveLocalizedMessage(Killer, class'DecapitationMessage');
//  super.Killed(killer, Other, damageType);
  bAutoTaunt = ((TournamentPlayer(Killer) != None) && TournamentPlayer(Killer).bAutoTaunt);     //stupid auto taunting
  if (bAutoTaunt
    && (Killer != Other) && (DamageType != 'gibbed') && (Killer.Health > 0)
    && (Level.TimeSeconds - LastTauntTime > 3) )
  {
    LastTauntTime = Level.TimeSeconds;
    NextTaunt = Rand(class<ChallengeVoicePack>(Killer.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
    for ( i=0; i<4; i++ )                                   //keeps taunts unique.....
    {
      if ( NextTaunt == LastTaunt[i] )
        NextTaunt = Rand(class<ChallengeVoicePack>(Killer.PlayerReplicationInfo.VoiceType).Default.NumTaunts);
      if ( i > 0 )
        LastTaunt[i-1] = LastTaunt[i];
    }
    LastTaunt[3] = NextTaunt;
    class'UTC_Pawn'.static.UTSF_SendGlobalMessage(killer, None, 'AUTOTAUNT', NextTaunt, 5);
  }
}
/*
function ScoreKill(pawn Killer, pawn Other);   //no scorekeeper.  change later?
function ScoreDamage(int Damage, Pawn Victim, Pawn Damager);
*/

defaultproperties
{
     TutMessage(0)="Welcome to the Operation: Na Pali Tutorial. This tutorial will teach you the basic skills necessary to Operation: Na Pali's adventure style gameplay."
     TutMessage(1)="Here you find the universal translator. It will translate all alien languages into English. You will find translator messages on various signs, books, computers, and other objects throughout the game.  It is important to pay attention to translator messages; they often include necessary, and sometimes entertaining, information."
     TutMessage(2)="Now go over to the book. When you get there, the translator will pop up and display the message the book contains.  Translator messages will not pop up during combat.  To View translator messages during combat, just hit the translator ["
     TutMessage(3)="Now go grab all the items on the other side of the room."
     TutMessage(4)="Check out your HUD!  Inventory is displayed in the top right corner of the screen. You can toggle between items with the next ["
     TutMessage(5)="While playing Operation: Na Pali, you will encounter aliens, some who are friendly and can help you, so be careful who you shoot! The blue color of your crosshair designates these humans as allies in combat. If ordered, most allies will follow you and attack your enemies. Pressing the follow ["
     TutMessage(6)="Remember where your quicksave ["
     TutMessage(7)="Crates will break open when you walk into them.  Go ahead and walk into the crates you see here.  Inside you will find some power-ups and the Dispersion Pistol, your primary weapon.  Pick up these items and proceed to the next room."
     ExtraMessage(0)="] key.  When the translator is active, you can read old messages by using the previous weapon ["
     ExtraMessage(1)="] and previous ["
     ExtraMessage(2)="] keys. The use ["
     ExtraMessage(3)="] key will activate and deactivate items. Use and switch items now to proceed to the next room."
     ExtraMessage(4)="] key orders friendly characters to follow you and pressing the wait ["
     ExtraMessage(5)="] and quickload ["
     ExtraMessage(6)="] buttons are to save and load the game! You can also save your game position by using the save game menu under the Unreal Tournament Game Menu.  Use the Scoreboard ["
     ExtraMessage(7)="] key orders them to stop. Friendly characters will accept orders from you regardless of location.  Other crosshair colors include red for enemies, green for civilians, and yellow for hazardous objects.  Now order the humans to follow you and proceed to the next room."
     ExtraMessage(8)="] key and new messages by using next weapon ["
     ExtraMessage(9)="] key."
     ExtraMessage(10)="] key to view your current game statistics.  Now it's time to enter the next room and begin Operation: Na Pali!"
     DM(0)="NPTutorial.tut1"
     DM(1)="NPTutorial.tut3"
     DM(2)="NPTutorial.tut4"
     DM(3)="NPTutorial.tut5"
     DM(4)="NPTutorial.tut6"
     DM(5)="NPTutorial.tut7"
     DM(6)="NPTutorial.tut8"
     DM(7)="NPTutorial.tut2"
     Movers(0)=ru
     Movers(1)=crate
     Movers(3)=ru2
     Movers(5)=ru3
     EventIndex=-1
     bGODModeAllowed=True
     bRestartLevel=False
}
