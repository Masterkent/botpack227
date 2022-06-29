// ============================================================
//oldskoolhudconfig.  configure da oldskool hud
// Psychic_313: FIXME make this save to default properties so it doesn't require that you're using an OS HUD?
// Needs to stay in Oldskool due to circular dependency...
// ============================================================

class oldskoolHUDConfig expands UMenuHUDConfigCW;

var uwindowcheckbox realicons, showtalktex, fragiconsp;

var UWindowEditControl B227_HUDScaleEdit;
var localized string B227_HUDScaleText;
var localized string B227_HUDScaleHelp;

var bool B227_bInitialized;

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
  DesiredHeight = 70;
  controloffset=50;

  // HUD Config
  HUDConfigSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft+64, controloffset, ControlWidth-64, 1));
  HUDConfigSlider.SetRange(0, 5, 1);
  HUDConfigSlider.SetValue(Root.Console.ViewPort.Actor.myHUD.HUDMode);
  HUDConfigSlider.SetText(HUDConfigText);
  HUDConfigSlider.SetHelpText(HUDConfigHelp);
  HUDConfigSlider.SetFont(F_Normal);
  controloffset+=25;

  // Crosshair
  CrosshairSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, controloffset, CenterWidth, 1));
  CrosshairSlider.SetRange(0, 5, 1);
  CrosshairSlider.SetValue(oldskoolbasehud(Root.Console.ViewPort.Actor.myHUD).olCrosshair);
  CrosshairSlider.SetText(CrosshairText);
  CrosshairSlider.SetHelpText(CrosshairHelp);
  CrosshairSlider.SetFont(F_Normal);
  controloffset+=25;
  //talktexture
  showtalktex = UWindowCheckBox(CreateControl(class'UWindowCheckBox', CenterPos, controloffset, centerwidth, 1));
showtalktex.SetText("Show talktexture");
showtalktex.SethelpText("If checked, the talktexture of players will appear in the HUD, when messages are sent.");
showtalktex.SetFont(F_Normal);
showtalktex.bChecked = oldskoolbasehud(Root.Console.ViewPort.Actor.myHUD).showtalkface;
controloffset+=25;

//Real-CTF icons
realicons = UWindowCheckBox(CreateControl(class'UWindowCheckBox', CenterPos, controloffset, centerwidth, 1));
realicons.SetText("Use Real CTF skulls");
realicons.SethelpText("If checked, the skulls from the Unreal Mod, 'Real CTF', will be used.");
realicons.SetFont(F_Normal);
realicons.bChecked = oldskoolbasehud(Root.Console.ViewPort.Actor.myHUD).realicons;
controloffset+=25;

//frag in SP....
fragiconsp = UWindowCheckBox(CreateControl(class'UWindowCheckBox', CenterPos, controloffset, centerwidth, 1));
fragiconsp.SetText("Show Frag count");
fragiconsp.SethelpText("Do you want the frag count to display on the HUD in Single Player and co-op?");
fragiconsp.SetFont(F_Normal);
fragiconsp.bChecked = oldskoolbasehud(Root.Console.ViewPort.Actor.myHUD).showfrag;
if (!Root.Console.ViewPort.Actor.myHUD.Isa('oldskoolhud'))
fragiconsp.hidewindow();

controloffset+=25;

	if (B227_HUDScalingSupported())
	{
		B227_HUDScaleEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, ControlWidth, 1));
		B227_HUDScaleEdit.SetText(B227_HUDScaleText);
		B227_HUDScaleEdit.SetHelpText(B227_HUDScaleHelp);
		B227_HUDScaleEdit.SetFont(F_Normal);
		B227_HUDScaleEdit.SetNumericOnly(true);
		B227_HUDScaleEdit.SetNumericFloat(true);
		B227_HUDScaleEdit.Align = TA_Left;
		ControlOffset += 25;
	}

	B227_bInitialized = true;
}

function WindowShown()
{
	super.WindowShown();
	B227_LoadCurrentValues();
}

function BeforePaint(Canvas C, float X, float Y)   //more shtuff......
{
  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos;

  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  HUDConfigSlider.SetSize(CenterWidth-60, 1);
  HUDConfigSlider.SliderWidth = 90;
  HUDConfigSlider.WinLeft = CenterPos+60;

  CrosshairSlider.SetSize(CenterWidth, 1);
  CrosshairSlider.SliderWidth = 90;
  CrosshairSlider.WinLeft = CenterPos;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  fragiconsp.WinLeft = CenterPos;
  realicons.WinLeft = CenterPos;
  showtalktex.WinLeft = CenterPos;

	if (B227_HUDScaleEdit != none)
	{
		B227_HUDScaleEdit.SetSize(CenterWidth, 1);
		B227_HUDScaleEdit.WinLeft = CenterPos;
		B227_HUDScaleEdit.EditBoxWidth = 90;
	}
}
function Paint(Canvas C, float X, float Y)      //over-ride and add too......
{
  local int ControlWidth, ControlLeft, ControlRight;
  local int CenterWidth, CenterPos, CrosshairX;

  ControlWidth = WinWidth/2.5;
  ControlLeft = (WinWidth/2 - ControlWidth)/2;
  ControlRight = WinWidth/2 + ControlLeft;

  CenterWidth = (WinWidth/4)*3;
  CenterPos = (WinWidth - CenterWidth)/2;

  Super(umenupagewindow).Paint(C, X, Y);

  CrosshairX = CenterPos + CenterWidth + 5;

  // DrawCrosshair
  if (oldskoolbasehud(GetPlayerOwner().myHUD).olCrosshair==0)
    DrawClippedTexture(C, CrosshairX, 75, Texture'Crosshair1');
  else if (oldskoolbasehud(GetPlayerOwner().myHUD).olCrosshair==1)
    DrawClippedTexture(C, CrosshairX, 75, Texture'Crosshair2');
  else if (oldskoolbasehud(GetPlayerOwner().myHUD).olCrosshair==2)
    DrawClippedTexture(C, CrosshairX, 75, Texture'Crosshair3');
  else if (oldskoolbasehud(GetPlayerOwner().myHUD).olCrosshair==3)
    DrawClippedTexture(C, CrosshairX, 75, Texture'Crosshair4');
  else if (oldskoolbasehud(GetPlayerOwner().myHUD).olCrosshair==4)
    DrawClippedTexture(C, CrosshairX, 75, Texture'Crosshair5');
  else if (oldskoolbasehud(GetPlayerOwner().myHUD).olCrosshair==5)
    DrawClippedTexture(C, CrosshairX, 75, Texture'Crosshair7');
  //hud iconz
  if (GetPlayerOwner().myHUD.hudmode==0)
    DrawClippedTexture(C, centerpos-10, 5, Texture'unrealshare.hud1');
  else if (GetPlayerOwner().myHUD.hudmode==1)
    DrawClippedTexture(C, centerpos-10, 5, Texture'unrealshare.hud2');
  else if (GetPlayerOwner().myHUD.hudmode==2)
    DrawClippedTexture(C, centerpos-10, 5, Texture'unrealshare.hud3');
  else if (GetPlayerOwner().myHUD.hudmode==3)
    DrawClippedTexture(C, centerpos-10, 5, Texture'unrealshare.hud4');
  else if (GetPlayerOwner().myHUD.hudmode==4)
    DrawClippedTexture(C, centerpos-10, 5, Texture'unrealshare.hud5');
  else if (GetPlayerOwner().myHUD.hudmode==5)
    DrawClippedTexture(C, centerpos-10, 5, Texture'unrealshare.hud6');
}
function Notify(UWindowDialogControl C, byte E)
{
  super(umenupagewindow).notify(c,e); //stupid thing wouldn't show help then :D
  switch(E)
  {
  case DE_Change:
    switch(C)
    {
    case CrosshairSlider:
      CrosshairChanged();
      break;
    case HUDConfigSlider:
      HUDConfigChanged();
      break;
    case showtalktex:
      oldskoolbasehud(GetPlayerOwner().myHUD).showtalkface=showtalktex.bchecked;
      break;
    case realicons:
      oldskoolbasehud(GetPlayerOwner().myHUD).realicons=realicons.bchecked;
      break;
    case fragiconsp:
      oldskoolbasehud(GetPlayerOwner().myHUD).showfrag=fragiconsp.bchecked;
      break;
    case B227_HUDScaleEdit:
      if (B227_HUDScaleEdit != none && float(B227_HUDScaleEdit.GetValue()) > 0)
        GetPlayerOwner().myHUD.SetPropertyText("HudScaler", string(FClamp(float(B227_HUDScaleEdit.GetValue()), 1.0, 16.0)));
      break;
    }
    break;
    }
}
function CrosshairChanged()  //ol crosshair stuff.....
{
  oldskoolbasehud(GetPlayerOwner().myHUD).olCrosshair = int(CrosshairSlider.Value);
}

function B227_LoadCurrentValues()
{
	local oldskoolbasehud H;

	H = oldskoolbasehud(Root.Console.ViewPort.Actor.myHUD);
	if (H == none)
		return;

	B227_bInitialized = false;

	HUDConfigSlider.SetValue(Root.Console.ViewPort.Actor.myHUD.HUDMode);
	CrosshairSlider.SetValue(H.olCrosshair);
	showtalktex.bChecked = H.showtalkface;
	realicons.bChecked = H.realicons;
	fragiconsp.bChecked = H.showfrag;
	if (B227_HUDScaleEdit != none)
		B227_HUDScaleEdit.SetValue(H.GetPropertyText("HudScaler"));

	B227_bInitialized = true;
}

function bool B227_HUDScalingSupported()
{
	return DynamicLoadObject("Engine.HUD.HudScaler", class'Object', true) != none;
}

defaultproperties
{
	B227_HUDScaleText="HUD Scale"
	B227_HUDScaleHelp="If this factor is greater than 1, HUD is rendered at a lower resolution and stretched to full screen."
}
