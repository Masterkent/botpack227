// ============================================================
//This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
//TvScoreboard.  merely shows that keeling mercs is bad :P
// ============================================================

class TVScoreBoard expands OldSkoolScoreBoard;
var float rYL;
var string Uber, Goal;
function ShowScores( canvas Canvas )
{
  local int row;
  local float temp;
  local color Yellow, Red, White;
  local tvscorekeeper scoreholder;

  scoreholder = tvscorekeeper(Instigator.FindInventoryType(class 'tvscorekeeper'));

  if (scoreholder != None)
  {
    White.G = 255;
    White.A = 200;

    Yellow.R = 255;
    Yellow.G = 255;
    Yellow.B = 0;
    Yellow.A = 200;

    Red.R = 200;
    Red.G = 10;
    Red.B = 20;


    // Display the scoreboard.
    if (OldSkoolBaseHUD(Canvas.viewport.actor.myhud)!=none&&OldSkoolBaseHUD(Canvas.viewport.actor.myhud).myfonts!=none)
      Canvas.Font = OldSkoolBaseHUD(Canvas.viewport.actor.myhud).myfonts.GetSmallFont(class'UTC_HUD'.static.B227_ScaledFontScreenWidth(Canvas));
    else
      Canvas.Font = Canvas.MedFont;
    Canvas.DrawColor = Red;
    Canvas.StrLen("t",temp,rYL);
    rYL*=1.1;
    Canvas.SetPos(0.2 * Canvas.ClipX, 0.1 * Canvas.ClipY );
    Canvas.DrawText("Creatures", False);
    Canvas.SetPos(0.6 * Canvas.ClipX, 0.1 * Canvas.ClipY );
    Canvas.DrawText("Number Killed", False);

    Canvas.DrawColor = White;
    row = 1;

    if (scoreholder.Brutes > 0)
      DrawBodyCount("Brutes", scoreholder.Brutes, Canvas, row++);
    if (scoreholder.Gasbags > 0)
      DrawBodyCount("Gasbag", scoreholder.Gasbags, Canvas, row++);
    if (scoreholder.Krall > 0)
      DrawBodyCount("Spinners", scoreholder.Krall, Canvas, row++);
    if (scoreholder.blobs > 0)
      DrawBodyCount("Skaarj Eggs", scoreholder.blobs, Canvas, row++);  //blobs=eggs :p   Note: this don't work anyway!
    if (scoreholder.Sliths > 0)
      DrawBodyCount("Sliths", scoreholder.Sliths, Canvas, row++);
    if (scoreholder.flies > 0)
      DrawBodyCount("Flies", scoreholder.flies, Canvas, row++);    //not used in ONP! don't save value!
     if (scoreholder.tentacles > 0)
      DrawBodyCount("Tentacles", scoreholder.tentacles, Canvas, row++);
      if (scoreholder.pupae > 0)
      DrawBodyCount("Pupae", scoreholder.pupae, Canvas, row++);
    if (scoreholder.mantas > 0)
      DrawBodyCount("Mantas", scoreholder.mantas, Canvas, row++);
    if (scoreholder.fish > 0)
      DrawBodyCount("Fish", scoreholder.Fish, Canvas, row++);
     if (scoreholder.Titans > 0)
      DrawBodyCount("Titans", scoreholder.Titans, Canvas, row++);
    if (scoreholder.Skaarjw > 0)
      DrawBodyCount("Skaarj Warriors", scoreholder.Skaarjw, Canvas, row++);
    if (scoreholder.Skaarjt > 0)
      DrawBodyCount("Skaarj Troopers", scoreholder.Skaarjt, Canvas, row++);
    if (scoreholder.hugeguys > 0)
      DrawBodyCount("Skaarj Leaders", scoreholder.hugeguys, Canvas, row++);
    if (scoreholder.Mercs > 0){
      DrawBodyCount("Skaarj Hybrids", scoreholder.Mercs, Canvas, row++);
    }
    if (scoreholder.Humans > 0){
      DrawBodyCount("Terrans", scoreholder.Humans, Canvas, row++);
    }
    if (scoreholder.Nali > 0){
      DrawBodyCount("Robots", scoreholder.Nali, Canvas, row++);
    }
    if (scoreholder.ENali > 0)
      DrawBodyCount("Nali", scoreholder.ENali, Canvas, row++);
    if (scoreholder.animals > 0){
      Canvas.DrawColor = Red;
      DrawBodyCount("Harmless Critters", scoreholder.animals, Canvas, row++);
      Canvas.DrawColor = White;
    }
    row++;
    if (scoreholder.DamageInstigated>0)      //damage/kill stats
      DrawBodyCount("Damage Inflicted on enemies", scoreholder.DamageInstigated, Canvas, row++);
    if (scoreholder.FriendlyDamage>0){
      Canvas.DrawColor = Red;
      DrawBodyCount("Damage Inflicted on innocents", scoreholder.FriendlyDamage, Canvas, row++);
      Canvas.DrawColor = White;
    }
    if (scoreholder.DamageTaken>0){
      Canvas.DrawColor = Red;
      DrawBodyCount("Damage Taken", scoreholder.DamageTaken, Canvas, row++);
      Canvas.DrawColor = White;
    }
    DrawBodyCount("Your Enemy Kills", scoreholder.killtotal, Canvas, row++);
    if (scoreholder.KilledFollowers>0){
      Canvas.DrawColor = Red;
      DrawBodyCount("Innocents Dead", scoreholder.KilledFollowers, Canvas, row++);
      Canvas.DrawColor = White;
    }
    row++;
    if (level.game.SecretGoals!=0)
      DrawdiffCount("Secrets Found", string(Instigator.SecretCount)$"/"$string(level.game.SecretGoals), Canvas, row++);
    DrawdiffCount(class'UnrealCoopGameOptions'.default.MenuList[3], class'UMenuNewGameClientWindow'.default.Skills[Level.Game.Difficulty], Canvas, row++);
    DrawBodyCount("Score", scoreholder.score, Canvas, row++);
    if (level.game!=none&&Level.Game.class==class'tvsp')
      DrawDiffCount("Accumulated Play time", parseTime(TvPlayer(Canvas.viewport.actor).B227_TotalAccumTime()), Canvas, row++);
    row++;
    DrawdiffCount("Map Title", level.title, Canvas, row++);              //kinda mirror DM....
    DrawdiffCount("Author", level.author, Canvas, row++);



  } else {

    Canvas.Font = Canvas.MedFont;
    Canvas.SetPos(0.2 * Canvas.ClipX, 0.2 * Canvas.ClipY );
    Canvas.DrawText("Score Keeper inventory not found!!! Please stop ]-[4xx1ng the code!", False);

  }
  DrawTimes(canvas);
}

function DrawBodyCount(string thingy, int amount, canvas Canvas, int row)
{
  Canvas.SetPos(0.2 * Canvas.ClipX, 0.1 * Canvas.ClipY + rYL * row );
  Canvas.DrawText(thingy, False);
  Canvas.SetPos(0.6 * Canvas.ClipX, 0.1 * Canvas.ClipY + rYL * row );
  Canvas.DrawText(amount, False);
}
function DrawdiffCount(string thingy, string amount, canvas Canvas, int row)           //just for the difficulties...
{
  Canvas.SetPos(0.2 * Canvas.ClipX, 0.1 * Canvas.ClipY + ryl * row );
  Canvas.DrawText(thingy, False);
  Canvas.SetPos(0.6 * Canvas.ClipX, 0.1 * Canvas.ClipY + ryl * row );
  Canvas.DrawText(amount, False);
}
static function string parseTime( float time )
{
    local int hour, min, sec, ms;
    local string hourstr, minStr, secStr, msStr;

    hour = int (time / 3600);
    min = int(time / 60)%60;
    sec = int(time) % 60;
    ms = int((time - int(time)) * 100);

    if (hour>0)
      hourstr = string(hour)$":";
    minStr = string(min);

    if(min >= 10||hour==0) minStr = string(min); // If sec is one digit, add a zero
    else minstr = "0"$string(min);

    if(sec >= 10) secStr = string(sec); // If sec is one digit, add a zero
    else secStr = "0"$string(sec);

    if(ms >= 10) msStr = string(ms); // If ms is one digit, add a zero
    else msStr = "0"$string(ms);

    return hourstr$minStr$":"$secStr$"."$msStr;
}
//render times :)
function DrawTimes(canvas canvas){
  local TvPlayer P;
  local float YUp;
  P=TvPlayer(Canvas.viewport.actor);
  if (P==none||P.Linfo.bCutScene)
    return;
  if (Uber==""&&P.Linfo.UberGoalTime>0)
    Uber="Über-Goal Time:"@ParseTime(P.Linfo.UberGoalTime);
  if (Goal==""&&P.Linfo.GoalTime>0)
    Goal="Goal Time:"@ParseTime(P.Linfo.GoalTime);
  Canvas.bCenter=true;
  Yup=Canvas.ClipY-rYL;
  Canvas.SetPos(0,Yup);
  if (Uber!=""){
    Canvas.DrawText(Uber);
    Yup-=rYL;
    Canvas.SetPos(0,Yup);
  }
  if (Goal!=""){
    Canvas.DrawText(Goal);
    Yup-=rYL;
    Canvas.SetPos(0,Yup);
 }
  Canvas.DrawText(class'TournamentScoreBoard'.default.ElapsedTime@ParseTime(P.myTime));
  Canvas.bCenter=false;
}

defaultproperties
{
}
