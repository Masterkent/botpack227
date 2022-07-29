// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVHSClient : High-score viewing window.  Also holds the saved stuff.
// ===============================================================

class TVHSClient expands UMenuDialogClientWindow
config (ONP);
//high score information:
var config string Players[10]; //player names
var config string Date[10]; //date of time set
var config int Score[10]; //player's scorez
var config string TimeDif[10]; //float 2 pt + dif. i.e. (321321.. time is 321.32 dif is 1)
var config string KillHash[10]; //hashed statistics..
var config string TimeHash[10]; //hashed Times for level
var config int MaxDif; //maximum difficulty beaten + 1

var UMenuLabelControl pnames[10];   //names
var UMenuLabelControl Dates[10];   //date score set.
var UMenuLabelControl Scores[10];    //scores
var UMenuLabelControl Difficulty[10];    //scores
var UMenuLabelControl times[10];    //total time
var UWindowSmallButton TimesButtons[10]; //time summary
var UWindowSmallButton KillsButtons[10]; //killz summary

function created(){ //build up window
local int i, dif;
local umenulabelcontrol tempcontrol;
  super.created();
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 10, 10,150, 1));
  tempcontrol.align=ta_left;
  tempcontrol.settext(class'ServerInfo'.default.BestNameText);   //name
  tempcontrol.SetFont( F_Bold );
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 160, 10,90, 1));
  tempcontrol.align=ta_left;
  tempcontrol.settext("Date");
  tempcontrol.SetFont( F_Bold );
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 260, 10,55, 1));
  tempcontrol.align=ta_center;
  tempcontrol.settext("Score");
  tempcontrol.SetFont( F_Bold );
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 325, 10,48, 1));
  tempcontrol.align=ta_right;
  tempcontrol.settext(class'UnrealCoopGameOptions'.default.MenuList[3]);   //difficulty
  tempcontrol.SetFont( F_Bold );
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 383, 10,54, 1));
  tempcontrol.align=ta_right;
  tempcontrol.settext("Play Time");
  tempcontrol.SetFont( F_Bold );
  for (i=0;i<10;i++){
    pnames[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 10, i*25+35,150, 1));
    pnames[i].settext(Players[i]);
    Dates[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 160, i*25+35,90, 1));
    if (Date[i]!="")
      Dates[i].settext(Date[i]);
    else
      Dates[i].settext("06/04/2002 10:00:00");
    Scores[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 260, i*25+35,55, 1));
    Scores[i].settext(string(Score[i]));
    Difficulty[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 325, i*25+35,48, 1));
    times[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 383, i*25+35,54, 1));
    if (TimeDif[i]!=""){
      dif=len(TimeDif[i])-1;
      Difficulty[i].settext(class'spoldskool'.static.B227_DifficultyString(int(mid(TimeDif[i], dif))));
      times[i].settext(GetTime(left(TimeDif[i],dif)));
    }
    else{
      Difficulty[i].settext(class'spoldskool'.static.B227_DifficultyString(i % 4));
      times[i].settext("0:00.00");
    }
    KillsButtons[i]=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 447, i*25+35, 50, 16));
    KillsButtons[i].settext("Statistics");
    KillsButtons[i].sethelptext("Click here to see a detailed list of enemies killed, weapons used, etc.");
    KillsButtons[i].bdisabled=(Score[i]==0);
    TimesButtons[i]=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 505, i*25+35, 54, 16));
    TimesButtons[i].settext("Map Times");
    TimesButtons[i].sethelptext("Click here to see a list of time per-level in Operation: Na Pali");
    TimesButtons[i].bdisabled=(Score[i]==0);
    times[i].align=ta_right;
    Difficulty[i].align=TA_right;
    Scores[i].align=TA_Center;
  }
}

static function string GetTime (string Float2Dig){  //reads a saved float in this 2 dig float format and return time
  return class'TvScoreBoard'.static.parseTime(float(UnFloat(Float2Dig)));
}

static function string UnFloat (string Float2Dig){    //reads a saved float in this 2 dig float format
  local int StrLen;
  StrLen=Len(Float2Dig);
  if (StrLen<3)
    return ""; //error
  return Left(Float2Dig,StrLen-2)$"."$mid(Float2Dig,StrLen-2);
}

static function string FloatString (float A){  //converts to saved float with 2 digit-no decimal point
  local string tmp;
  local int pos;
  tmp=string(A);
  pos=instr(A,".");
  return left(tmp,pos)$mid(tmp,pos+1,2);
}

static function EmptyScore(int Slot)
{
  local int i;
  for (i=8;i>=slot;i--){
    default.Players[i+1] = default.Players[i];
    default.Date[i+1] = default.Date[i];
    default.Score[i+1] = default.Score[i];
    default.TimeDif[i+1] = default.TimeDif[i];
    default.KillHash[i+1] = default.KillHash[i];
    default.TimeHash[i+1] = default.TimeHash[i];
  }
}

static function SaveScores(TVScoreKeeper Keeper, string PlayerName){
  local int i, j;
  for (i=0;i<10;i++)
    if (Keeper.score>default.Score[i])
      break;
  if (i==10){
    StaticSaveConfig();
    return; //no scores that are worse
  }
  EmptyScore(i);
  default.Players[i]=PlayerName;
  default.Score[i]=Keeper.Score;
  GetTimeStamp(default.Date[i],Keeper.Level);
  default.TimeDif[i]=FloatString(Keeper.AccumTime)$Keeper.level.game.difficulty;
  //Time hashing:
  for (j=0;j<36;j++){
    if (keeper.Times[j]<=0)
      break;
    default.TimeHash[i]=default.TimeHash[i]$FloatString(Keeper.Times[j])$chr(17);
  }
  //other stats hashing:
  default.KillHash[i]=Keeper.Skaarjw$chr(17)$Keeper.SkaarjT$chr(17)$Keeper.hugeGuys$chr(17)$Keeper.Nali$chr(17)$Keeper.ENali$chr(17)$Keeper.Tentacles$chr(17)$
   Keeper.Pupae$chr(17)$Keeper.Animals$chr(17)$Keeper.Brutes$chr(17)$Keeper.Gasbags$chr(17)$Keeper.Krall$chr(17)$
    Keeper.Mercs$chr(17)$Keeper.Sliths$chr(17)$Keeper.Titans$chr(17)$Keeper.Fish$chr(17)$Keeper.Mantas$chr(17)$
     Keeper.Humans$chr(17)$Keeper.killtotal$chr(17)$Keeper.DamageTaken$chr(17)$
      Keeper.FriendlyDamage$chr(17)$Keeper.DamageInstigated$chr(17)$Keeper.KilledFollowers$chr(17)$
       Keeper.KilledByFollowers$chr(17)$Keeper.TotalSecretsFound$"/"$Keeper.TotalLevelSecrets$chr(17);
  for (j=0;j<12;j++)
    default.KillHash[i]=default.KillHash[i]$FloatString(100*Keeper.Weapons[j].TimeHeld/Keeper.AccumTime)$chr(17)$
      FloatString(100*float(Keeper.Weapons[j].DamageInstigated)/float(Keeper.DamageInstigated+Keeper.FriendlyDamage))$chr(17);
  StaticSaveConfig();
}

static function GetTimeStamp(out string AbsoluteTime, LevelInfo Level)
{
  if (Level.Month < 10)
    AbsoluteTime = "0"$Level.Month;
  else
    AbsoluteTime = string(Level.Month);

  if (Level.Day < 10)
    AbsoluteTime = AbsoluteTime$"/0"$Level.Day;
  else
    AbsoluteTime = AbsoluteTime$"/"$Level.Day;

  AbsoluteTime = AbsoluteTime$"/"$Level.Year;

  if (Level.Hour < 10)
    AbsoluteTime = AbsoluteTime$" 0"$Level.Hour;
  else
    AbsoluteTime = AbsoluteTime$" "$Level.Hour;

  if (Level.Minute < 10)
    AbsoluteTime = AbsoluteTime$":0"$Level.Minute;
  else
    AbsoluteTime = AbsoluteTime$":"$Level.Minute;

  if (Level.Second < 10)
    AbsoluteTime = AbsoluteTime$":0"$Level.Second;
  else
    AbsoluteTime = AbsoluteTime$":"$Level.Second;
}

function Notify(UWindowDialogControl C, byte E){          //button notification
local int i;
local TvTimeWindow T;
local TvKillStatWindow K;
  Super.Notify(C, E);
  if (e==de_click)
    for (i=0;i<10;i++){
      if (c==TimesButtons[i]){
        if (TimesButtons[i].bDisabled)
          return;
        T=TvTimeWindow(root.Createwindow(class'TvTimeWindow', 10, 10, 200, 200,self));
        GetParent(class'UWindowFramedWindow').ShowModal(T);
        T.SetTime(TimeHash[i]);
        return;
      }
      if (c==KillsButtons[i]){
        if (KillsButtons[i].bDisabled)
          return;
        K=TvKillStatWindow(root.Createwindow(class'TvKillStatWindow', 10, 10, 200, 200,self));
        GetParent(class'UWindowFramedWindow').ShowModal(K);
        K.SetStats(KillHash[i]);
        break;
      }
    }
}

defaultproperties
{
     Players(0)="Tonnberry"
     Players(1)="DavidM"
     Players(2)="UsAaR33"
     Players(3)="Strogg"
     Players(4)="Chicoverde"
     Players(5)="Dr. Pest"
     Players(6)="MClane"
     Players(7)="Chrome"
     Players(8)="Atje"
     Players(9)="Hourences"
     Score(0)=915886
     Score(1)=899079
     TimeDif(0)="10403751"
     TimeDif(1)="11651361"
     KillHash(0)="19711711362542036131191325404651426106887963314158/10175279718532736730379990673758414218525204293473131450175627152514294895102317"
     KillHash(1)="2021221156182103713314132250443917118287037294668/10170811331703583221305225349996141562104429027624129419991834245623132431101118363"
     TimeHash(0)="200662306036853074412572455791917329602277527980497521611634967306963402628593347383253029419361751180451941914732683154596882652453154011540105130024245083439512866290953372756331"
     TimeHash(1)="28216308333665271804916923159302552899221297833111635445358358574105129060502453083935149401631565862112520932733131795677850122213242132404141216348213016211620232442883357977"
}
