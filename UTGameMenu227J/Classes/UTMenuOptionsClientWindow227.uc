class UTMenuOptionsClientWindow227 expands UWindowDialogClientWindow;

var UMenuPageControl Pages;
var UWindowSmallCloseButton CloseButton;

function Created()
{
	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight - 48));
	Pages.SetMultiLine(True);
	Pages.AddPage(class'UMenuOptionsClientWindow'.default.AudioTab, class'UTMenuAudioScrollClient227');
	Pages.AddPage(class'UMenuOptionsClientWindow'.default.ControlsTab, class'UTMenuCustomizeScrollClient227');
	Pages.AddPage(class'UMenuOptionsClientWindow'.default.InputTab, class'UTMenuInputOptionsScrollClient227');
	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth - 56, WinHeight - 24, 48, 16));
	super.Created();
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.WinHeight = WinHeight - 24;	// OK, Cancel area
	CloseButton.WinLeft = WinWidth-52;
	CloseButton.WinTop = WinHeight-20;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
}

function GetDesiredDimensions(out float W, out float H)
{
	Super(UWindowWindow).GetDesiredDimensions(W, H);
	H += 30;
}
