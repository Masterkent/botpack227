// ===============================================================
// This package is for use with the Partial Conversion, Operation: Na Pali, by Team Vortex.
// TVHUDConfig : Configures the operation: Na Pali HUD (in normal preferences menu under HUD)
// ===============================================================

class TVHUDConfig expands oldskoolHUDConfig;

var uwindowcheckbox ShowHUD;
var localized string B227_ShowHUDText;
var localized string B227_ShowHUDHelp;

var UWindowEditControl B227_UpscaleHUDEdit;
var localized string B227_UpscaleHUDText;
var localized string B227_UpscaleHUDHelp;

var UWindowCheckbox B227_VerticalScalingCheck;
var localized string B227_VerticalScalingText;
var localized string B227_VerticalScalingHelp;

// Crosshair
var UWindowCheckbox B227_VerticalCrosshairScalingCheck;
var localized string B227_VerticalCrosshairScalingText;
var localized string B227_VerticalCrosshairScalingHelp;

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
controloffset+=25;

//Hide HUD
ShowHUD = UWindowCheckBox(CreateControl(class'UWindowCheckBox', CenterPos, controloffset, centerwidth, 1));
ShowHUD.SetText(B227_ShowHUDText);
ShowHUD.SethelpText(B227_ShowHUDHelp);
ShowHUD.SetFont(F_Normal);
controloffset+=25;

	if (B227_CanvasScalingSupported())
	{
		B227_UpscaleHUDEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, ControlWidth, 1));
		B227_UpscaleHUDEdit.SetText(B227_UpscaleHUDText);
		B227_UpscaleHUDEdit.SetHelpText(B227_UpscaleHUDHelp);
		B227_UpscaleHUDEdit.SetFont(F_Normal);
		B227_UpscaleHUDEdit.SetNumericOnly(true);
		B227_UpscaleHUDEdit.SetNumericFloat(true);
		B227_UpscaleHUDEdit.Align = TA_Left;
		ControlOffset += 25;
	}

	B227_VerticalScalingCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	B227_VerticalScalingCheck.SetText(B227_VerticalScalingText);
	B227_VerticalScalingCheck.SetHelpText(B227_VerticalScalingHelp);
	B227_VerticalScalingCheck.SetFont(F_Normal);
	B227_VerticalScalingCheck.Align = TA_Left;
	ControlOffset += 25;

	B227_VerticalCrosshairScalingCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	B227_VerticalCrosshairScalingCheck.SetText(B227_VerticalCrosshairScalingText);
	B227_VerticalCrosshairScalingCheck.SetHelpText(B227_VerticalCrosshairScalingHelp);
	B227_VerticalCrosshairScalingCheck.SetFont(F_Normal);
	B227_VerticalCrosshairScalingCheck.Align = TA_Left;
	ControlOffset += 25;

// Crosshair
CrosshairSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, controloffset, CenterWidth, 1));
CrosshairSlider.SetRange(0, class'ChallengeHUD'.default.CrossHairCount-1, 1);
CrosshairSlider.SetText(CrosshairText);
CrosshairSlider.SetHelpText(CrosshairHelp);
CrosshairSlider.SetFont(F_Normal);
controloffset+=25;

DesiredHeight = ControlOffset + 70;

	B227_LoadCurrentValues();
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

	if (B227_UpscaleHUDEdit != none)
	{
		B227_UpscaleHUDEdit.SetSize(CenterWidth, 1);
		B227_UpscaleHUDEdit.WinLeft = CenterPos;
		B227_UpscaleHUDEdit.EditBoxWidth = 90;
	}
	B227_VerticalScalingCheck.SetSize(CenterWidth, 1);
	B227_VerticalScalingCheck.WinLeft = CenterPos;
	B227_VerticalCrosshairScalingCheck.SetSize(CenterWidth, 1);
	B227_VerticalCrosshairScalingCheck.WinLeft = CenterPos;
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
    ClipText(C, ShowHUD.WinLeft, CrosshairSlider.WinTop + 20, "7Bullets no longer active!  Changes will not be saved!", false);
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
	local TVHUD H;

	super.Notify(C, E);

	H = TVHUD(GetPlayerOwner().myHUD);
	if (H == none || !B227_bInitialized)
		return;

	switch(E)
	{
		case DE_Change:
			switch(C)
			{
				case ShowHUD:
					H.bHideHud = !ShowHUD.bchecked;
					H.SaveConfig();
					break;

				case B227_UpscaleHUDEdit:
					if (B227_UpscaleHUDEdit != none)
					{
						H.B227_UpscaleHUD = FMax(1.0, float(B227_UpscaleHUDEdit.GetValue()));
						H.SaveConfig();
					}
					break;

				case B227_VerticalScalingCheck:
					H.B227_bVerticalScaling = B227_VerticalScalingCheck.bChecked;
					H.SaveConfig();
					break;

				case B227_VerticalCrosshairScalingCheck:
					class'UTC_HUD'.default.B227_bVerticalCrosshairScaling = B227_VerticalCrosshairScalingCheck.bChecked;
					class'UTC_HUD'.static.StaticSaveConfig();
					break;
			}
	}
}

function bool B227_CanvasScalingSupported()
{
	return DynamicLoadObject("Engine.Canvas.ScaleFactor", class'Object', true) != none;
}

function B227_LoadCurrentValues()
{
	local TVHUD H;

	H = TVHUD(GetPlayerOwner().myHUD);
	if (H == none)
		return;

	B227_bInitialized = false;

	showtalktex.bChecked = H.showtalkface;
	ShowHUD.bChecked = !H.bHideHUD;
	CrosshairSlider.SetValue(H.Crosshair);
	if (B227_UpscaleHUDEdit != none)
		B227_UpscaleHUDEdit.SetValue(string(H.B227_UpscaleHUD));
	B227_VerticalScalingCheck.bChecked = H.B227_bVerticalScaling;
	B227_VerticalCrosshairScalingCheck.bChecked = class'UTC_HUD'.default.B227_bVerticalCrosshairScaling;

	B227_bInitialized = true;
}

defaultproperties
{
	B227_ShowHUDText="Show HUD"
	B227_ShowHUDHelp="Show the Heads-up Display (HUD)."
	B227_UpscaleHUDText="Upscale HUD"
	B227_UpscaleHUDHelp="If this factor is greater than 1, HUD is rendered at a lower resolution and stretched to full screen."
	B227_VerticalScalingText="Vertical Icon Scaling"
	B227_VerticalScalingHelp="Scale size of HUD icons by screen height instead of screen width."
	B227_VerticalCrosshairScalingText="Vertical Crosshair Scaling"
	B227_VerticalCrosshairScalingHelp="Scale size of crosshair by screen height instead of screen width."
}
