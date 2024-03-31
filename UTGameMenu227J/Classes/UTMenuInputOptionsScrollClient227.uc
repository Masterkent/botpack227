class UTMenuInputOptionsScrollClient227 expands UWindowScrollingDialogClient;

function Created()
{
	if (DynamicLoadObject("UWindow.UWindowScrollingDialogClient.bAllowsMouseWheelScrolling", class'Property', true) != none)
		SetPropertyText("bAllowsMouseWheelScrolling", "true");
	ClientClass = class<UWindowDialogClientWindow>(DynamicLoadObject("UTMenu.UTInputOptionsCW", class'Class'));
	FixedAreaClass = none;
	super.Created();
}
