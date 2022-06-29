// Allows configuration of crosshair and auto-hide times
// by Sergey 'Eater' Levin, 2002

class NCHUDConfigCW extends UMenuPageWindow;

// Auto-hide stuff
var UWindowEditControl spellHide, wepHide, invHide;
var localized string spellText, wepText, invText;
var localized string spellHelp, wepHelp, invHelp;

// Dialogue option

var UWindowComboControl ConvDelayCombo;
var localized string ConvDelayText;
var localized string ConvDelayHelp;

var localized string ConvDelayName[4];

// Crosshair
var UWindowHSliderControl CrosshairSlider;
var localized string CrosshairText;
var localized string CrosshairHelp;

var UWindowEditControl B227_HUDScaleEdit;
var localized string B227_HUDScaleText;
var localized string B227_HUDScaleHelp;

var bool B227_bInitialized;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int ControlOffset;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	DesiredWidth = 220;
	DesiredHeight = 70;

	ControlOffset = 15;

	// HUD Config
	spellHide = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	spellHide.SetText(spellText);
	spellHide.SetHelpText(spellHelp);
	spellHide.SetFont(F_Normal);
	spellHide.SetNumericOnly(True);
	spellHide.SetNumericFloat(True);
	spellHide.SetMaxLength(6);
	spellHide.Align = TA_Left;
	ControlOffset += 25;

	wepHide = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	wepHide.SetText(wepText);
	wepHide.SetHelpText(wepHelp);
	wepHide.SetFont(F_Normal);
	wepHide.SetNumericOnly(True);
	wepHide.SetNumericFloat(True);
	wepHide.SetMaxLength(6);
	wepHide.Align = TA_Left;
	ControlOffset += 25;

	invHide = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	invHide.SetText(invText);
	invHide.SetHelpText(invHelp);
	invHide.SetFont(F_Normal);
	invHide.SetNumericOnly(True);
	invHide.SetNumericFloat(True);
	invHide.SetMaxLength(6);
	invHide.Align = TA_Left;
	ControlOffset += 25;

	// Conv delay control

	ConvDelayCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlRight, ControlOffset, ControlWidth, 1));
	ConvDelayCombo.SetText(ConvDelayText);
	ConvDelayCombo.SetHelpText(ConvDelayHelp);
	ConvDelayCombo.SetFont(F_Normal);
	ConvDelayCombo.SetEditable(False);
	ConvDelayCombo.AddItem(ConvDelayName[0]);
	ConvDelayCombo.AddItem(ConvDelayName[1]);
	ConvDelayCombo.AddItem(ConvDelayName[2]);
	ConvDelayCombo.AddItem(ConvDelayName[3]);
	ControlOffset += 25;

	// 227j HUD scaling
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

	// Crosshair
	CrosshairSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	CrosshairSlider.SetRange(0, 5, 1);
	CrosshairSlider.SetText(CrosshairText);
	CrosshairSlider.SetHelpText(CrosshairHelp);
	CrosshairSlider.SetFont(F_Normal);
	ControlOffset += 25;

	B227_LoadCurrentValues();
}

function WindowShown()
{
	super.WindowShown();
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

	spellHide.SetSize(ControlWidth*2, 1);
	spellHide.WinLeft = ControlLeft;
	spellHide.EditBoxWidth = 60;

	wepHide.SetSize(ControlWidth*2, 1);
	wepHide.WinLeft = ControlLeft;
	wepHide.EditBoxWidth = 60;

	invHide.SetSize(ControlWidth*2, 1);
	invHide.WinLeft = ControlLeft;
	invHide.EditBoxWidth = 60;

	ConvDelayCombo.SetSize(ControlWidth*2, 1);
	ConvDelayCombo.WinLeft = ControlLeft;
	ConvDelayCombo.EditBoxWidth = 110;

	CrosshairSlider.SetSize(CenterWidth, 1);
	CrosshairSlider.SliderWidth = 90;
	CrosshairSlider.WinLeft = ControlLeft;

	if (B227_HUDScaleEdit != none)
	{
		B227_HUDScaleEdit.SetSize(CenterWidth, 1);
		B227_HUDScaleEdit.WinLeft = CenterPos;
		B227_HUDScaleEdit.EditBoxWidth = 90;
	}
}

function Paint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, CrosshairX, CrosshairY;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	Super.Paint(C, X, Y);

	CrosshairX = CenterPos + (CenterWidth/2) - 8;
	CrosshairY = CrosshairSlider.WinTop + 25;

	// DrawCrosshair
	if (GetPlayerOwner().myHUD.Crosshair==0)
		DrawClippedTexture(C, CrosshairX, CrosshairY, Texture'Crosshair1');
	else if (GetPlayerOwner().myHUD.Crosshair==1)
		DrawClippedTexture(C, CrosshairX, CrosshairY, Texture'Crosshair2');
	else if (GetPlayerOwner().myHUD.Crosshair==2)
		DrawClippedTexture(C, CrosshairX, CrosshairY, Texture'Crosshair3');
	else if (GetPlayerOwner().myHUD.Crosshair==3)
		DrawClippedTexture(C, CrosshairX, CrosshairY, Texture'Crosshair4');
	else if (GetPlayerOwner().myHUD.Crosshair==4)
		DrawClippedTexture(C, CrosshairX, CrosshairY, Texture'Crosshair5');
	else if (GetPlayerOwner().myHUD.Crosshair==5)
		DrawClippedTexture(C, CrosshairX, CrosshairY, Texture'Crosshair7');
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
		case DE_Change:
			if (!B227_bInitialized)
				return;

			switch(C)
			{
				case CrosshairSlider:
					CrosshairChanged();
					break;
				case spellHide:
					spellHideChanged();
					break;
				case wepHide:
					wepHideChanged();
					break;
				case invHide:
					invHideChanged();
					break;
				case ConvDelayCombo:
					ConvDelayChanged();
					break;
				case B227_HUDScaleEdit:
					if (B227_HUDScaleEdit != none)
						B227_HUDScaleChanged();
					break;
			}
			break;

		case DE_MouseMove:
			if (UMenuRootWindow(Root) != None && UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);
			break;

		case DE_MouseLeave:
			if (UMenuRootWindow(Root) != None && UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp("");
			break;
	}
}

// 208

function CrosshairChanged()
{
	getPlayerOwner().myHUD.Crosshair = int(CrosshairSlider.Value);
}

function spellHideChanged()
{
	NCHUD(getPlayerOwner().myHUD).spellmTime = float(spellHide.EditBox.Value);
}

function wepHideChanged()
{
	NCHUD(getPlayerOwner().myHUD).weaponmTime = float(wepHide.EditBox.Value);
}

function invHideChanged()
{
	NCHUD(getPlayerOwner().myHUD).inventorymTime = float(invHide.EditBox.Value);
}

function ConvDelayChanged()
{
	NCHUD(getPlayerOwner().myHUD).convDelayType = ConvDelayCombo.GetSelectedIndex();
}

function B227_HUDScaleChanged()
{
	if (float(B227_HUDScaleEdit.GetValue()) > 0)
		GetPlayerOwner().myHUD.SetPropertyText("HudScaler", string(FClamp(float(B227_HUDScaleEdit.GetValue()), 1.0, 16.0)));
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	GetPlayerOwner().myHUD.SaveConfig();
	Super.SaveConfigs();
}

function B227_LoadCurrentValues()
{
	local NCHUD H;

	H = NCHUD(getPlayerOwner().myHUD);
	if (H == none)
		return;

	B227_bInitialized = false;

	spellHide.SetValue(B227_FloatToStr(H.spellmTime));
	wepHide.SetValue(B227_FloatToStr(H.weaponmTime));
	invHide.SetValue(B227_FloatToStr(H.inventorymTime));
	ConvDelayCombo.SetSelectedIndex(Clamp(H.convDelayType, 0, 3));
	CrosshairSlider.SetValue(H.Crosshair);
	if (B227_HUDScaleEdit != none)
		B227_HUDScaleEdit.SetValue(H.GetPropertyText("HudScaler"));

	B227_bInitialized = true;
}

static function string B227_FloatToStr(float Value)
{
	local string S;
	local int i;

	S = string(Value);
	i = InStr(S, ".");
	return Left(S, i + 3);
}

function bool B227_HUDScalingSupported()
{
	return DynamicLoadObject("Engine.HUD.HudScaler", class'Object', true) != none;
}

defaultproperties
{
     spellText="Spell box auto-hide time"
     wepText="Weapon list auto-hide time"
     invText="Inventory info auto-hide time"
     spellHelp="Set the amount of time until the spell box is hidden - 0 to disable auto-hide."
     wepHelp="Set the amount of time until the non-selected weapons list is hidden - 0 to disable auto-hide."
     invHelp="Set the amount of time until the selected item boxes are hidden - 0 to disable auto-hide."
     ConvDelayText="Dialogue Delay"
     ConvDelayHelp="How long each line of dialogue stays on the screen before the next line is said."
     ConvDelayName(0)="Default"
     ConvDelayName(1)="Increased"
     ConvDelayName(2)="Double"
     ConvDelayName(3)="Until Acknowledged"
     CrosshairText="Crosshair Style"
     CrosshairHelp="Choose the crosshair appearing at the center of your screen."
     B227_HUDScaleText="HUD Scale"
     B227_HUDScaleHelp="If this factor is greater than 1, HUD is rendered at a lower resolution and stretched to full screen."
}
