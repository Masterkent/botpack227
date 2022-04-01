// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TvKillStatsClient : General game statistics
// ===============================================================

class TvKillStatsClient expands UMenuDialogClientWindow;

var string Skaarjw;
var string Skaarjt;
var string hugeguys;
var string Nali;
var string ENali;
var string Tentacles;
var string Pupae;
var string Animals;
var string Brutes;
var string Gasbags;
var string Krall;
var string Mercs;
var string Sliths;
var string Titans;
var string Fish;
var string Mantas;
var string Humans;  //killed humans
var string killtotal;
var string DamageTaken; //damage self taken
var string FriendlyDamage; //damage friendlies took from player
var string DamageInstigated; //damage self instigated on others.
var string KilledFollowers; //total followers killed (by anyone)
var string KilledByFollowers; //creatures killed by the followers
var string Secrets; //x/y
var string WeaponDamages[12]; //by inv group. #11=SSL.  #10=SSL
var string WeaponTimes[12]; //by inv group. #10=translator
var string Weapons[10];

function Created(){
  Super.Created();
  Weapons[1]=class'DispersionPistol'.default.ItemName;
  Weapons[2]=class'Enforcer'.default.ItemName;
  Weapons[3]=class'UT_biorifle'.default.ItemName;
  Weapons[4]=class'ShockRifle'.default.ItemName;
  Weapons[5]=class'Pulsegun'.default.ItemName;
  Weapons[6]=class'Ripper'.default.ItemName;
  Weapons[7]=class'Minigun2'.default.ItemName;
  Weapons[8]=class'UT_Flakcannon'.default.ItemName;
  Weapons[9]=class'ut_eightball'.default.ItemName;
  Weapons[0]=class'sniperrifle'.default.ItemName;
}
function CutInfo(out string Info, out int i){
  Info=mid(Info,i+1);
  i=instr(Info,chr(17));
}

function SetStats (string Info){
  local int i, pos;
  pos=-1;
  CutInfo(Info,pos);
  SkaarjW=left(Info,pos);
  CutInfo(Info,pos);
  SkaarjT=left(Info,pos);
  CutInfo(Info,pos);
  hugeGuys=left(Info,pos);
  CutInfo(Info,pos);
  Nali=left(Info,pos);
  CutInfo(Info,pos);
  ENali=left(Info,pos);
  CutInfo(Info,pos);
  Tentacles=left(Info,pos);
  CutInfo(Info,pos);
  Pupae=left(Info,pos);
  CutInfo(Info,pos);
  Animals=left(Info,pos);
  CutInfo(Info,pos);
  Brutes=left(Info,pos);
  CutInfo(Info,pos);
  Gasbags=left(Info,pos);
  CutInfo(Info,pos);
  Krall=left(Info,pos);
  CutInfo(Info,pos);
  Mercs=left(Info,pos);
  CutInfo(Info,pos);
  Sliths=left(Info,pos);
  CutInfo(Info,pos);
  Titans=left(Info,pos);
  CutInfo(Info,pos);
  Fish=left(Info,pos);
  CutInfo(Info,pos);
  Mantas=left(Info,pos);
  CutInfo(Info,pos);
  Humans=left(Info,pos);
  CutInfo(Info,pos);
  killtotal=left(Info,pos);
  CutInfo(Info,pos);
  DamageTaken=left(Info,pos);
  CutInfo(Info,pos);
  FriendlyDamage=left(Info,pos);
  CutInfo(Info,pos);
  DamageInstigated=left(Info,pos);
  CutInfo(Info,pos);
  KilledFollowers=left(Info,pos);
  CutInfo(Info,pos);
  KilledByFollowers=left(Info,pos);
  CutInfo(Info,pos);
  Secrets=left(Info,pos);
  for (i=0;i<12;i++){
    CutInfo(Info,pos);
    WeaponTimes[i]=class'tvHSClient'.static.UnFloat(left(Info,pos))$"%";
    CutInfo(Info,pos);
    WeaponDamages[i]=class'tvHSClient'.static.UnFloat(left(Info,pos))$"%";
  }

}

function DrawBodyCount(string thingy, string amount, canvas C, int row)           //just for the difficulties...
{
  local float W, H;
  TextSize(C, amount, W, H);
  DesiredHeight=H*1.1*row;
  ClipText(C, 5, DesiredHeight, thingy, false);
  if (UWindowScrollingDialogClient(ParentWindow).bShowVertSB)
    W+=UWindowScrollingDialogClient(ParentWindow).VertSb.WinWidth;
  ClipText(C, WinWidth - W - 5, DesiredHeight, amount, false);
}
//entry point of render info.
function Paint(Canvas Canvas, float X, float Y)
{
  local int i, row;
  Super.Paint(Canvas,X,Y);
  //Set black:
  Canvas.drawcolor.R=0;
  Canvas.drawcolor.G=0;
  Canvas.drawcolor.B=0;
  Canvas.Font=root.fonts[F_Bold];
  row=1;
  DrawBodyCount("Creatures", "Number Killed", Canvas, row++);
  Canvas.Font=root.fonts[F_Normal];
  DrawBodyCount("Brutes", Brutes, Canvas, row++);
  DrawBodyCount("Gasbag", Gasbags, Canvas, row++);
  DrawBodyCount("Krall", Krall, Canvas, row++);
  DrawBodyCount("Sliths", Sliths, Canvas, row++);
  DrawBodyCount("Tentacles", tentacles, Canvas, row++);
  DrawBodyCount("Pupae", pupae, Canvas, row++);
  DrawBodyCount("Mantas", mantas, Canvas, row++);
  DrawBodyCount("Fish", Fish, Canvas, row++);
  DrawBodyCount("Titans", Titans, Canvas, row++);
  DrawBodyCount("Skaarj Warriors", Skaarjw, Canvas, row++);
  DrawBodyCount("Skaarj Troopers", Skaarjt, Canvas, row++);
  DrawBodyCount("Skaarj Leaders", hugeguys, Canvas, row++);
  DrawBodyCount("Mercenaries", Mercs, Canvas, row++);
  DrawBodyCount("Terrans", Humans, Canvas, row++);
  DrawBodyCount("Nali", Nali, Canvas, row++);
  DrawBodyCount("'Evil' Nali", ENali, Canvas, row++);
  DrawBodyCount("Harmless Critters", animals, Canvas, row++);
  row++;
  Canvas.Font=root.fonts[F_Bold];
  DrawBodyCount("Damage Inflicted on enemies", DamageInstigated, Canvas, row++);
  DrawBodyCount("Damage Inflicted on allies", FriendlyDamage, Canvas, row++);
  DrawBodyCount("Damage Taken", DamageTaken, Canvas, row++);
  DrawBodyCount("Your Enemy Kills", killtotal, Canvas, row++);
  DrawBodyCount("Kills by Allies", KilledByFollowers, Canvas, row++);
  DrawBodyCount("Allies Dead", KilledFollowers, Canvas, row++);
  row++;
  DrawBodyCount("Secrets Found", Secrets, Canvas, row++);
  row++;
  DrawBodyCount("Weapon", "Damage Caused", Canvas, row++);
  Canvas.Font=root.fonts[F_Normal];
  for (i=1;i<10;i++)
    DrawBodyCount(Weapons[i], WeaponDamages[i], Canvas, row++);
  DrawBodyCount(Weapons[0], WeaponDamages[0], Canvas, row++);
  DrawBodyCount(class'SuperShockRifle'.default.ItemName, WeaponDamages[10], Canvas, row++);
  DrawBodyCount("Other", WeaponDamages[11], Canvas, row++);
  row++;
  Canvas.Font=root.fonts[F_Bold];
  DrawBodyCount("Weapon", "Play Time Held", Canvas, row++);
  Canvas.Font=root.fonts[F_Normal];
  for (i=1;i<10;i++)
    DrawBodyCount(Weapons[i], WeaponTimes[i], Canvas, row++);
  DrawBodyCount(Weapons[0], WeaponTimes[0], Canvas, row++);
  DrawBodyCount(class'Translocator'.default.ItemName, WeaponTimes[10], Canvas, row++);
  DrawBodyCount(class'SuperShockRifle'.default.ItemName, WeaponTimes[11], Canvas, row++);
  DesiredHeight+=15;
  DesiredWidth=10;
}

defaultproperties
{
}
