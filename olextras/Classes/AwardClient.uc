// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// AwardClient : Display Award info..... as well as control max dif updating...
// ===============================================================

class AwardClient expands UMenuDialogClientWindow;

var string AwardText;
var string Awards[5];

function string GetMessage(int i){
  if (i!=2)
    return Awards[i];
 //process crosshair.. ugh..
 if (class'ChallengeHUD'.default.CrosshairCount<20){
   class'ChallengeHUD'.default.CrossHairs[class'ChallengeHUD'.default.CrosshairCount++]="olextras.Main_00";
   class'ChallengeHUD'.static.StaticSaveConfig();
   return Awards[2];
 }
 return Awards[4]; //ugh.. no space...
}

function SetAwards (int NewDifficulty){
  AwardText="You beat Operation: Na Pali for the first time on"@
   class'UnrealCoopGameOptions'.default.Difficulties[NewDifficulty]$"!\\n\\nYou have just won:\\n";
  NewDifficulty++;
  While (class'TVHSClient'.default.MaxDif<NewDifficulty){
    class'TVHSClient'.default.MaxDif++;
    AwardText=AwardText$GetMessage(class'TVHSClient'.default.MaxDif-1);
  }
}

//ripped from message box :p
function Paint(Canvas C, float X, float Y)
{
  Super.Paint(C,X,Y);
  C.Font = Root.Fonts[F_Bold];
  C.DrawColor.R = 0;
  C.DrawColor.G = 0;
  C.DrawColor.B = 0;
  WrapClipText(C, 0, 0, AwardText);
  C.DrawColor.R = 255;
  C.DrawColor.G = 255;
  C.DrawColor.B = 255;
}

defaultproperties
{
     Awards(0)="-MoNsTeRSmASH (Secret A) - Play a fun ONP game on any map you have!\n"
     Awards(1)="-Heavy Trooper Player/Bot Model by Chicoverde.  Use in any DM game!\n"
     Awards(2)="-ONP CrossHair in DM - You can now select the ONP crosshair in the normal UT HUD config window!\n"
     Awards(3)="-PoNg (Secret B) - You know it, you love it!  With multiple difficulty levels support!  What? You thought you deserved something GOOD for somehow beating ONP on UNREAL mode? hahaha...\n"
     Awards(4)="-ONP CrossHair in DM - Unfortunately, all your crosshair slots are used up!  For support manually replace an entry with 'olextras.Main_00'\n"
}
