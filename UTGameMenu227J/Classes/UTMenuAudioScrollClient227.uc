class UTMenuAudioScrollClient227 expands UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class<UWindowDialogClientWindow>(DynamicLoadObject("UTMenu.UTAudioClientWindow", class'Class'));
	FixedAreaClass = none;
	super.Created();

}
