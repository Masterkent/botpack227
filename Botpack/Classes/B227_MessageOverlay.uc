class B227_MessageOverlay expands HudOverlay;

var bool bShowMessage;

var float WinLeft, WinTop;
var float WinWidth, WinHeight;

var B227_UTFadeTextArea TextArea;
var Color TextColor;

static function B227_MessageOverlay GetInstance(PlayerPawn Player)
{
	local B227_MessageOverlay Overlay;

	if (Player == none || Player.myHUD == none || Player.myHUD.bDeleteMe)
		return none;

	// Using ChildActors instead of accessing array Player.myHUD.Overlays in order to avoid memory leaks in 227i when retrieving the array size
	// B227-TODO: this code should be optimized if 227i won't be supported
	foreach Player.ChildActors(class'B227_MessageOverlay', Overlay)
		return Overlay;
	return B227_MessageOverlay(Player.myHUD.AddOverlay(class'B227_MessageOverlay', true));
}

function ShowMessage()
{
	bShowMessage = true;
}

function HideMessage()
{
	bShowMessage = false;
}

function AddMessage(string NewMessage)
{
	if (TextArea != none)
	{
		TextArea.Clear();
		TextArea.B227_AddText(NewMessage);
	}
}

event PostBeginPlay()
{
	TextArea = new class'B227_UTFadeTextArea';
	TextArea.FadeFactor = 3;
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 255;
	TextArea.SetTextColor(TextColor);
}

function UWindowRootWindow GetRootWindow()
{
	if (PlayerPawn(Owner) != none && WindowConsole(PlayerPawn(Owner).Player.Console) != none)
		return WindowConsole(PlayerPawn(Owner).Player.Console).Root;
	return none;
}

static function Font GetBigFont(Canvas C)
{
	local float SizeX;

	SizeX = class'ChallengeHUD'.static.B227_ScaledFontScreenWidth(C);

	if (SizeX < 640)
		return Font(DynamicLoadObject("LadderFonts.UTLadder10", class'Font'));
	else if (SizeX < 800)
		return Font(DynamicLoadObject("LadderFonts.UTLadder12", class'Font'));
	else if (SizeX < 1024)
		return Font(DynamicLoadObject("LadderFonts.UTLadder16", class'Font'));
	else if (SizeX < 1440)
		return Font(DynamicLoadObject("LadderFonts.UTLadder18", class'Font'));
	else
		return Font(DynamicLoadObject("LadderFonts.UTLadder22", class'Font'));
}

function BeforePaint(Canvas C, float X, float Y)
{
	WinLeft = C.SizeX / 4;
	WinTop = C.SizeY / 4;
	WinWidth = C.SizeX / 2;
	WinHeight = C.SizeY / 2 ;

	TextArea.WinLeft = WinLeft;
	TextArea.WinTop = WinTop;
	TextArea.WinWidth = WinWidth;
	TextArea.WinHeight = WinHeight;
	TextArea.MyFont = GetBigFont(C);
}

event PostRender(Canvas Canvas)
{
	if (bShowMessage &&
		PlayerPawn(Owner) != none &&
		Viewport(PlayerPawn(Owner).Player) != none &&
		(GetRootWindow() == none || !GetRootWindow().bWindowVisible) &&
		TextArea != none)
	{
		BeforePaint(Canvas, 0, 0);
		TextArea.BeforePaint(Canvas, 0, 0);
		TextArea.Paint(Canvas, 0, 0);
	}
}

event Tick(float DeltaTime)
{
	if (TextArea != none)
		TextArea.Tick(DeltaTime);
}
