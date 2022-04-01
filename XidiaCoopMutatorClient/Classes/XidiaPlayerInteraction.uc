class XidiaPlayerInteraction expands Info;

var private bool bRealCrouching;
var private XidiaCodeConsoleWindow CodeConsoleWindow;

replication
{
	reliable if (Role < ROLE_Authority)
		TestCodeConsoleInput,
		PlayCodeConsoleTypingSound;

	reliable if (Role == ROLE_Authority)
		OpenCodeConsole,
		CloseCodeConsole,
		TransferTranslatorMessage;

	reliable if (Role == ROLE_Authority)
		bRealCrouching;
}


simulated function Tick(float DeltaTime)
{
	if (Level.NetMode == NM_Client)
		Level.bSupportsRealCrouching = bRealCrouching;
	else
		bRealCrouching = Level.bSupportsRealCrouching;
}

static function XidiaPlayerInteraction FindFor(PlayerPawn Player)
{
	local XidiaPlayerInteraction XidiaPlayerInteraction;

	foreach Player.ChildActors(class'XidiaPlayerInteraction', XidiaPlayerInteraction)
		return XidiaPlayerInteraction;
	return none;
}

simulated function OpenCodeConsole(string SecurityPrompt, int Digits)
{
	local WindowConsole Console;
	if (PlayerPawn(Owner) == none || PlayerPawn(Owner).Player == none || WindowConsole(PlayerPawn(Owner).Player.Console) == none)
		return;

	Console = WindowConsole(PlayerPawn(Owner).Player.Console);
	Console.bQuickKeyEnable = true;
	Console.LaunchUWindow();
	if (!Console.bCreatedRoot) //must generate root
		Console.CreateRootWindow(none);
	if (CodeConsoleWindow == none)
		CodeConsoleWindow = XidiaCodeConsoleWindow(Console.Root.CreateWindow(class'XidiaCodeConsoleWindow', 0, 0, 200, 200));
	else
	{
		CodeConsoleWindow.ShowWindow();
		CodeConsoleWindow.BringToFront();
	}
	if (CodeConsoleWindow != none)
	{
		CodeConsoleWindow.TypedCode = "";
		CodeConsoleWindow.SecurityPrompt = SecurityPrompt;
		CodeConsoleWindow.Digits = Digits;
	}
}

simulated function CloseCodeConsole()
{
	if (CodeConsoleWindow != none && CodeConsoleWindow.bWindowVisible)
		CodeConsoleWindow.Close();
}

function TestCodeConsoleInput(int Code)
{
	local XidiaCodeConsole CodeConsole;
	if (Owner == none)
		return;
	foreach Owner.TouchingActors(class'XidiaCodeConsole', CodeConsole)
		CodeConsole.TestCodeConsoleInput(Code, PlayerPawn(Owner));
}

function PlayCodeConsoleTypingSound()
{
	local XidiaCodeConsole CodeConsole;
	if (Owner == none)
		return;
	foreach Owner.TouchingActors(class'XidiaCodeConsole', CodeConsole)
		CodeConsole.PlayCodeConsoleTypingSound();
}

simulated function TransferTranslatorMessage(Translator PlayerTranslator, string Message, bool bAppend)
{
	if (bAppend)
		PlayerTranslator.NewMessage $= Message;
	else
		PlayerTranslator.NewMessage = Message;

	if (PlayerTranslator.TranslatorScale < 3)
		PlayerTranslator.TranslatorScale = 3;
}

function SetTranslatorMessage(Translator PlayerTranslator, string Message)
{
	const MaxMessagePartLength = 192;
	const MaxMessageLength = 1200;
	local bool bAppend;

	if (Len(Message) > MaxMessageLength)
		Message = Left(Message, MaxMessageLength);
	while (Len(Message) > MaxMessagePartLength)
	{
		TransferTranslatorMessage(PlayerTranslator, Left(Message, MaxMessagePartLength), bAppend);
		Message = Mid(Message, MaxMessagePartLength);
		bAppend = true;
	}
	TransferTranslatorMessage(PlayerTranslator, Message, bAppend);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
