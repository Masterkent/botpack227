// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVHSClient : High-score viewing window.  Also holds the saved stuff.
// ===============================================================

class TVHSClient expands UMenuDialogClientWindow
config (Xidia);
//high score information:
var config string Players[10]; //player names
var config string Date[10]; //date of time set
var config int Score[10]; //player's scorez
var config string TimeDif[10]; //float 2 pt + dif. i.e. (321321.. time is 321.32 dif is 1)
var config string KillHash[10]; //hashed statistics..
var config string TimeHash[10]; //hashed Times for level
var config int MaxDif; //maximum difficulty beaten + 1

var UMenuLabelControl pnames[10];   //names
var UMenuLabelControl Gamez[10];    //game played
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
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 160, 10,50, 1));
  tempcontrol.align=ta_left;
  tempcontrol.settext("Xidia Part");   //game played
  tempcontrol.SetFont( F_Bold );
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 220, 10,90, 1));
  tempcontrol.align=ta_left;
  tempcontrol.settext("Date");
  tempcontrol.SetFont( F_Bold );
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 320, 10,55, 1));
  tempcontrol.align=ta_center;
  tempcontrol.settext("Score");
  tempcontrol.SetFont( F_Bold );
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 385, 10,48, 1));
  tempcontrol.align=ta_right;
  tempcontrol.settext(class'UnrealCoopGameOptions'.default.MenuList[3]);   //difficulty
  tempcontrol.SetFont( F_Bold );
  tempcontrol=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 463, 10,54, 1));
  tempcontrol.align=ta_right;
  tempcontrol.settext("Play Time");
  tempcontrol.SetFont( F_Bold );
  for (i=0;i<10;i++){
    pnames[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 10, i*25+35,150, 1));
    pnames[i].settext(Players[i]);
    Gamez[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 160, i*25+35,50, 1));
    Dates[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 220, i*25+35,90, 1));
    if (Date[i]!="")
      Dates[i].settext(Date[i]);
    else
      Dates[i].settext("06/04/2002 10:00:00");
    Scores[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 320, i*25+35,55, 1));
    Scores[i].settext(string(Score[i]));
    Difficulty[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 385, i*25+35,48, 1));
    times[i]=UMenuLabelControl(Createwindow(class'UMenuLabelControl', 463, i*25+35,54, 1));
    if (TimeDif[i]!=""){
      dif=len(TimeDif[i])-1;
      times[i].settext(GetTime(left(TimeDif[i],dif)));
      dif=int(mid(TimeDif[i],dif));
      if (dif>3){
         Gamez[i].SetText("Escape");
         dif-=4;
      }
      else
         Gamez[i].SetText("Incident");
      Difficulty[i].settext(class'spoldskool'.static.B227_DifficultyString(dif));
    }
    else{
      Difficulty[i].settext(class'spoldskool'.static.B227_DifficultyString((i + 3) % 4));
      times[i].settext("0:00.00");
      if (i%2==1)
        Gamez[i].SetText("Escape");
      else
        Gamez[i].SetText("Incident");
    }
    KillsButtons[i]=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 527, i*25+35, 50, 16));
    KillsButtons[i].settext("Statistics");
    KillsButtons[i].sethelptext("Click here to see a detailed list of enemies killed, weapons used, etc.");
    KillsButtons[i].bdisabled=(KillHash[i]=="");
    TimesButtons[i]=UWindowSmallButton(CreateControl(class'UWindowSmallButton', 587, i*25+35, 54, 16));
    TimesButtons[i].settext("Map Times");
    TimesButtons[i].sethelptext("Click here to see a list of time per-level in Xidia Gold");
    TimesButtons[i].bdisabled=(TimeHash[i]=="");
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

static function SaveScores(TVScoreKeeper Keeper, string PlayerName, bool escape){
  local int i, j, k;
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
  k=min(Keeper.level.game.difficulty,3);
  if (escape)
    k+=4;
  default.TimeDif[i]=FloatString(Keeper.AccumTime)$k;
  //Time hashing:
  for (j=0;j<36;j++){
    if (keeper.Times[j]<=0)
      break;
    default.TimeHash[i]=default.TimeHash[i]$FloatString(Keeper.Times[j])$chr(17);
  }
  //other stats hashing:
  default.KillHash[i]=Keeper.Skaarjw$chr(17)$Keeper.SkaarjT$chr(17)$Keeper.hugeGuys$chr(17)$Keeper.Nali$chr(17)$Keeper.ENali$chr(17)$Keeper.Tentacles$chr(17)$
   Keeper.Pupae$chr(17)$Keeper.Animals$chr(17)$Keeper.Brutes$chr(17)$Keeper.Gasbags$chr(17)$Keeper.Krall$chr(17)$
    Keeper.Mercs$chr(17)$Keeper.Sliths$chr(17)$Keeper.Titans$chr(17)$Keeper.Fish$chr(17)$Keeper.Flies$chr(17)$Keeper.Mantas$chr(17)$
     Keeper.Humans$chr(17)$Keeper.killtotal$chr(17)$Keeper.DamageTaken$chr(17)$
      Keeper.FriendlyDamage$chr(17)$Keeper.DamageInstigated$chr(17)$Keeper.KilledFollowers$chr(17)$Keeper.TotalSecretsFound$"/"$Keeper.TotalLevelSecrets$chr(17);
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
        T.SetTime(TimeHash[i],(Gamez[i].Text=="Escape"));
        return;
      }
      if (c==KillsButtons[i]){
        if (KillsButtons[i].bDisabled)
          return;
        K=TvKillStatWindow(root.Createwindow(class'TvKillStatWindow', 10, 10, 200, 200,self));
        GetParent(class'UWindowFramedWindow').ShowModal(K);
        K.SetStats(KillHash[i],(Gamez[i].Text=="Escape"));
        break;
      }
    }
}

defaultproperties
{
     Players(0)="Mr. Prophet"
     Players(1)="Hourences"
     Players(2)="UsAaR33"
     Players(3)="GMotha"
     Players(4)="Mr. Cope"
     Players(5)="Hellscrag"
     Players(6)="Teque"
     Players(7)="Jones"
     Players(8)="Spencer"
     Players(9)="Cray"
     Date(0)="09/22/2002 00:00:00"
     Date(1)="09/22/2002 00:00:00"
     Date(2)="09/22/2002 00:00:00"
     Date(3)="09/22/2002 00:00:00"
     Date(4)="09/22/2002 00:00:00"
     Date(5)="09/22/2002 00:00:00"
     Date(6)="09/22/2002 00:00:00"
     Date(7)="09/22/2002 00:00:00"
     Date(8)="09/22/2002 00:00:00"
     Date(9)="09/22/2002 00:00:00"
     Score(0)=133337
     Score(1)=13337
     Score(2)=1337
     Score(3)=1337
     Score(4)=1337
     Score(5)=1337
     Score(6)=1337
     Score(7)=1337
     Score(8)=1337
     TimeDif(0)="3607027"
     TimeDif(1)="13382"
     TimeDif(2)="793001"
     TimeDif(3)="180000001"
     TimeDif(4)="180000002"
     TimeDif(5)="49020003"
     TimeDif(6)="180000004"
     TimeDif(7)="180000005"
     TimeDif(8)="180000006"
     TimeDif(9)="180000007"
}
