class ONPCodeConsoleWindow expands CodeConsoleWindow;

const WindowScale = 3.0;
var Font WindowFont;
var Texture WindowTexture;

var string SecurityPrompt;
var int Digits;

// draw like a translator window
function Paint(Canvas Canvas, float X, float Y)
{
	local float tempx, tempy;
	local byte oldstyle;
	local color OldColor;

	if (Root.bUWindowActive || !bAcceptsFocus)
		return;
	Canvas.bCenter = false;
	Canvas.Font = GetConsoleWindowFont(Canvas);
	Canvas.SetClip(Root.RealWidth,Root.RealHeight);
	TempX = Canvas.CurX;
	TempY = Canvas.CurY;
	OldStyle = Canvas.Style;
	OldColor = Canvas.DrawColor;
	Canvas.Style = 2;
	Canvas.DrawColor = MakeColor(255, 255, 255);
	Canvas.SetPos(Root.RealWidth/2 - 128 * WindowScale, Root.RealHeight/2 - 68 * WindowScale);
	GetConsoleWindowTexture();
	Canvas.DrawTile(WindowTexture, WindowScale * 256.f, WindowScale * 256.f, 0, 0, WindowTexture.USize, WindowTexture.VSize);
	Canvas.SetPos(Root.RealWidth/2 - 110 * WindowScale, Root.RealHeight/2 - 52 * WindowScale);
	Canvas.Style = 1;
	Canvas.DrawColor = MakeColor(0, 255, 0);
	Canvas.DrawText(SecurityPrompt, False);
	Canvas.SetPos(Root.RealWidth/2 - 110 * WindowScale, Root.RealHeight/2 - 42 * WindowScale);
	Canvas.DrawText("(> " $ TypedCode $ "_", False);
	Canvas.CurX = TempX;
	Canvas.CurY = TempY;
	Canvas.Style = OldStyle;
	Canvas.DrawColor = OldColor;
}

function Font GetConsoleWindowFont(Canvas Canvas)
{
	if (WindowFont != none)
		return WindowFont;
	WindowFont = Font(DynamicLoadObject("UWindowFonts.Tahoma20", class'Font', true));
	if (WindowFont != none)
		return WindowFont;
	WindowFont = Canvas.MedFont;
	return WindowFont;
}

function Texture GetConsoleWindowTexture()
{
	if (WindowTexture != none)
		return WindowTexture;
	WindowTexture = class'Translator'.default.HiResHUD;
	if (WindowTexture == none)
		WindowTexture = Texture'UnrealShare.Icons.TranslatorHUD3';
	return WindowTexture;
}

function KeyDown(int Key, float MouseX, float MouseY)
{
	if (Key >= 0x30 && Key <= 0x39)  // numeric only
	{
		TypedCode = TypedCode $ chr(Key);
		if (Len(TypedCode) >= Digits)
		{
			TestCodeConsoleInput(GetPlayerOwner(), int(TypedCode));
			Close();  // done, so close this.
		}
		else //sound
			PlayTypingSound(GetPlayerOwner());
	}
	else if (Key == 0x8) // backspace
		TypedCode = Left(TypedCode, Max(0, Len(TypedCode) - 1));
}

// closing menu stuff:
function Close(optional bool bByParent)
{
	super(UWindowWindow).Close(bByParent);
/*	//log ("closing code console window");
	bWindowVisible = true;
	bLeaveOnScreen = false;
	CancelAcceptsFocus();
	HideWindow();
	Root.Console.CloseUWindow();*/
}

function TestCodeConsoleInput(PlayerPawn Player, int Code)
{
	local ONPPlayerInteraction PlayerInteraction;

	if (Player == none)
		return;
	foreach Player.ChildActors(class'ONPPlayerInteraction', PlayerInteraction)
	{
		PlayerInteraction.TestCodeConsoleInput(Code);
		break;
	}
}

function PlayTypingSound(PlayerPawn Player)
{
	local ONPPlayerInteraction PlayerInteraction;

	if (Player == none)
		return;
	foreach Player.ChildActors(class'ONPPlayerInteraction', PlayerInteraction)
	{
		PlayerInteraction.PlayCodeConsoleTypingSound();
		break;
	}
}
