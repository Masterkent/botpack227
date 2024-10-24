class UTXMenuRootWindowSelector227 expands UWindowFramedWindow;

function SetupSelector()
{
	WinWidth = 300;
	WinHeight = 80;
	WinLeft = int((Root.WinWidth - WinWidth) / 2);
	WinTop = int((Root.WinHeight - WinHeight) / 2);
	WindowTitle = class'UTMenuModMenuItem227'.default.MenuCaption_SwitchToOtherMenu;
	UTXMenuRootWindowSelectorClientWindow227(ClientArea).SetupSelector();
}

defaultproperties
{
	ClientClass=Class'UTXMenuRootWindowSelectorClientWindow227'
}
