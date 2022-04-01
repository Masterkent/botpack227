// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVHUDConfig : Configures the operation: Na Pali HUD (in normal preferences menu under HUD)
// ===============================================================

class TVHUDConfig expands oldskoolHUDConfig;
var uwindowcheckbox ShowHUD;
function Created()
{
  local int ControlWidth, ControlLeft, ControlRight, controloffset;
  local int CenterWidth, CenterPos;

  Super(umenupagewindow).Created();

  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  DesiredWidth = 220;
  controloffset=50;

//TalkTexture
showtalktex = UWindowCheckBox(CreateControl(class'UWindowCheckBox', CenterPos, controloffset, centerwidth, 1));
showtalktex.SetText("Show talktexture");
showtalktex.SethelpText("If checked, the talktexture of players will appear in the HUD, when messages are sent.");
showtalktex.SetFont(F_Normal);
showtalktex.bChecked = oldskoolbasehud(GetPlayerOwner().myHUD).showtalkface;
controloffset+=25;

//Hide HUD
ShowHUD = UWindowCheckBox(CreateControl(class'UWindowCheckBox', CenterPos, controloffset, centerwidth, 1));
ShowHUD.SetText("Show HUD");
ShowHUD.SethelpText("Show the Heads-up Display (HUD).");
ShowHUD.SetFont(F_Normal);
ShowHUD.bChecked = !TVHUD(GetPlayerOwner().myHUD).bHideHUD;
controloffset+=25;

// Crosshair
CrosshairSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, controloffset, CenterWidth, 1));
CrosshairSlider.SetRange(0, class'ChallengeHUD'.default.CrossHairCount-1, 1);
CrosshairSlider.SetValue(class'HUD'.default.Crosshair);
CrosshairSlider.SetText(CrosshairText);
CrosshairSlider.SetHelpText(CrosshairHelp);
CrosshairSlider.SetFont(F_Normal);
controloffset+=25;

DesiredHeight = ControlOffset + 70;
}

function BeforePaint(Canvas C, float X, float Y)
{
  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos;

  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  CrosshairSlider.SetSize(CenterWidth, 1);
  CrosshairSlider.SliderWidth = 90;
  CrosshairSlider.WinLeft = CenterPos;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  ShowHUD.WinLeft = CenterPos;
  showtalktex.WinLeft = CenterPos;
}

function Paint(Canvas C, float X, float Y)      //Draw UT HUD crosshair preview
{
  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos, CrosshairX;
  local TVHUD H;
  local Texture CrossHair;
  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  Super(umenupagewindow).Paint(C, X, Y);

  H = TVHUD(GetPlayerOwner().MyHUD);
  if (H==none){
    ClipText(C, ShowHUD.WinLeft, CrosshairSlider.WinTop + 20, "Xidia no longer active!  Changes will not be saved!", false);
    return;
  }
  CrossHair = H.CrosshairTextures[class'HUD'.default.Crosshair];
  if(CrossHair == None)
    CrossHair = H.LoadCrosshair(class'HUD'.default.Crosshair);

  CrosshairX = (WinWidth - Crosshair.USize) / 2;
  DrawUpBevel(C, CrosshairX - 3, CrosshairSlider.WinTop + 20 - 3, CrossHair.USize + 6, CrossHair.VSize + 6, GetLookAndFeelTexture());
  DrawStretchedTexture(C, CrosshairX, CrosshairSlider.WinTop + 20, CrossHair.USize, CrossHair.VSize, Texture'BlackTexture');

  C.DrawColor = H.WhiteColor;
  DrawClippedTexture(C, CrosshairX, CrosshairSlider.WinTop + 20, CrossHair);
}
function CrosshairChanged()  //ol crosshair stuff.....
{
  local tvhud h;
  class'HUD'.default.CrossHair = int(CrosshairSlider.Value);
  class'HUD'.static.StaticSaveConfig();
  H = TVHUD(GetPlayerOwner().MyHUD);
  if (H!=none){
    H.CrossHair = int(CrosshairSlider.Value);
    H.SaveConfig();
  }
}

function Notify(UWindowDialogControl C, byte E)
{
  super.notify(c,e);
  switch(E)
  {
    case DE_Change:
      switch(C)
      {
      case ShowHUD:
        if (TvHUD(GetPlayerOwner().myHUD)!=none)
          TvHUD(GetPlayerOwner().myHUD).bHideHud=!ShowHUD.bchecked;
      }
  }
}

defaultproperties
{
}
