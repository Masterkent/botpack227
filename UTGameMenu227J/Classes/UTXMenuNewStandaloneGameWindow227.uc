class UTXMenuNewStandaloneGameWindow227 extends UMenuBotmatchWindow;

function SetSizePos()
{
	SetSize(Min(Root.WinWidth-10, 547), 299);

	WinLeft = int(Root.WinWidth/2 - WinWidth/2);
	WinTop = int(Root.WinHeight/2 - WinHeight/2);
}

defaultproperties
{
	ClientClass=Class'UTXMenuNewStandaloneGameClientWindow227'
	WindowTitle="New Game"
}
