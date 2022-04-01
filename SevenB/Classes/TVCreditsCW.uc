// ============================================================
// SevenB.TVCreditsCW: This is a redrawn credits window!
// ============================================================

class TVCreditsCW expands UnrealCreditsCW;

function Created()
{
	super(UMenuDialogClientWindow).Created();
}

function BeforePaint(Canvas C, float X, float Y)
{
	super(UMenuDialogClientWindow).BeforePaint(C,X,Y);
}

//master credits function
//write text:
function WriteText(canvas C, string text, out float Y, optional string TestTEx){
  local float W, H;
  if (testtex=="")
    testtex=text;
  TextSize(C, TestTex, W, H);
  Y+=H;
  ClipText(C, (WinWidth - W)/2, Y, text, true);
}
function Paint(Canvas C, float X, float Y)
{
  Super.Paint(C,X,Y);
  //Set black:
  c.drawcolor.R=0;
  c.drawcolor.G=0;
  c.drawcolor.B=0;
  C.Font=root.fonts[F_Bold];
  Y=5;
  WriteText(C, "Seven Bullets", Y);
  Y+=8;
  WriteText(C, "A \"Red Nemesis\" Production", Y);
  Y+=5;
  WriteText(C, "In association with Team Phalanx & Unreal SP.Org", Y);
  Y+=8;
  C.Font=root.fonts[F_Normal];
  WriteText(C, "Will-\"Mr.Prophet\"-Drekker", Y);
  y+=5;
  WriteText(C, "James-\"eVOLVE\"-Hamer-Morton", Y);
  y+=5;
  WriteText(C, "Kevin-\"Waffnuffly\"-Letz", Y);
  y+=5;
  WriteText(C, "Graeme-\"Darth_Weasel\"-Hutton", Y);
  y+=5;
  WriteText(C, "Eric-\"EightballManiac\"-Stryker", Y);
  y+=5;
  WriteText(C, "Aaron-\"UsAaR33\"- Staley", Y);
  y+=5;
  WriteText(C, "Soundtrack composed by \"Darkbeat\"", Y);
  y+=5;
  WriteText(C, "Additional music by Zynthetic", Y);
  y+=5;
  WriteText(C, "Original Work from Pancho and Myscha included and remixed", Y);
  c.drawcolor.R=255;  //reset
  c.drawcolor.G=255;
  c.drawcolor.B=255;
}

defaultproperties
{
}
