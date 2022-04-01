///////////////////////////////////////////////////////
// CTFScoreCfgWindow
///////////////////////////////////////////////////////
class CombatZoneWeaponCfgWindowCW extends UMenuPageWindow;


// Hkg11 control
var UWindowHSliderControl HKG11Slider;
var localized string HKG11Text;
var localized string HKG11Help;


function Created()
{
	local int FFS;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;




	HKG11Slider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, 100, CenterWidth, 1));
	HKG11Slider.SetRange(0, 100, 1);
	FFS = Class'addweap.hkg11'.Default.ArmorDamage ;
	HKG11Slider.SetValue(FFS);
	HKG11Slider.SetText(HKG11Text$" ["$FFS$"%]:");
	//HKG11Slider.SetHelpText(HKG11Help);
	HKG11Slider.SetFont(F_Normal);



	Super.Created();
}



function Notify(UWindowDialogControl C, byte E)
{

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch (C)
		{

			case HKG11Slider:
				HKG11SliderChanged();
				break;

		}
	}
}


function HKG11SliderChanged()
{
	Class'addweap.hkg11'.Default.ArmorDamage = HKG11Slider.GetValue();
	HKG11Slider.SetText(HKG11Text$" ["$int(HKG11Slider.GetValue())$"]:");
}

defaultproperties
{
     HKG11Text="Standart damage"
}
