class TournamentConsole extends UnrealConsole
	abstract;

// Speech
var bool				bShowSpeech;

function EvaluateMatch(int PendingChange, bool Evaluate)
{
}

function StartNewGame()
{
}

function LoadGame()
{
}

/*
 * Tutorial Message Interface
 */

function CreateMessage()
{
	// Implemented in child.
}

function ShowMessage()
{
	// Implemented in child.
}

function HideMessage()
{
	// Implemented in child.
}

function AddMessage(string NewMessage)
{
	// Implemented in child.
}

/*
 * Speech Interface
 */

function CreateSpeech()
{
	// Implemented in child.
}

function ShowSpeech()
{
	// Implemented in child.
}

function HideSpeech()
{
	// Implemented in child.
}

function PrintActionMessage( Canvas C, string BigMessage )
{
	local float XL, YL;
	local class<FontInfo> FC;

	FC = Class<FontInfo>(DynamicLoadObject(class'ChallengeHUD'.default.FontInfoClass, class'Class'));

	if ( Len(BigMessage) > 10 )
		C.Font = FC.Static.GetStaticBigFont(class'UTC_HUD'.static.B227_ScaledFontScreenWidth(C));
	else
		C.Font = FC.Static.GetStaticHugeFont(class'UTC_HUD'.static.B227_ScaledFontScreenWidth(C));
	C.bCenter = false;
	C.StrLen( BigMessage, XL, YL );
	C.SetPos(FrameX/2 - XL/2 + 1, (FrameY/3)*2 - YL/2 + 1);
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0; 
	C.DrawText( BigMessage, false );
	C.SetPos(FrameX/2 - XL/2, (FrameY/3)*2 - YL/2);
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 255; 
	C.DrawText( BigMessage, false );
}

static function UTSF_ShowMessage(Console Console)
{
	local B227_MessageOverlay MessageOverlay;

	if (TournamentConsole(Console) != none)
		TournamentConsole(Console).ShowMessage();
	else if (Console != none)
	{
		MessageOverlay = class'B227_MessageOverlay'.static.GetInstance(Console.Viewport.Actor);
		if (MessageOverlay != none)
			MessageOverlay.ShowMessage();
	}
}

static function UTSF_HideMessage(Console Console)
{
	local B227_MessageOverlay MessageOverlay;

	if (TournamentConsole(Console) != none)
		TournamentConsole(Console).HideMessage();
	else if (Console != none)
	{
		MessageOverlay = class'B227_MessageOverlay'.static.GetInstance(Console.Viewport.Actor);
		if (MessageOverlay != none)
			MessageOverlay.HideMessage();
	}
}

static function UTSF_AddMessage(Console Console, string NewMessage)
{
	local B227_MessageOverlay MessageOverlay;

	if (TournamentConsole(Console) != none)
		TournamentConsole(Console).AddMessage(NewMessage);
	else if (Console != none)
	{
		MessageOverlay = class'B227_MessageOverlay'.static.GetInstance(Console.Viewport.Actor);
		if (MessageOverlay != none)
			MessageOverlay.AddMessage(NewMessage);
	}
}

defaultproperties
{
}
