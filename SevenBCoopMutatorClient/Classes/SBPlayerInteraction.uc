class SBPlayerInteraction expands Info;

var private bool bRealCrouching;
var private SBCodeConsoleWindow CodeConsoleWindow;

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


simulated event PostBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		SetupFootStepManager();
}

simulated event Tick(float DeltaTime)
{
	if (Level.NetMode == NM_Client)
		Level.bSupportsRealCrouching = bRealCrouching;
	else
		bRealCrouching = Level.bSupportsRealCrouching;

	if (Owner == none && Role == ROLE_Authority)
		Destroy();
}

static function SBPlayerInteraction FindFor(PlayerPawn Player)
{
	local SBPlayerInteraction SBPlayerInteraction;

	foreach Player.ChildActors(class'SBPlayerInteraction', SBPlayerInteraction)
		return SBPlayerInteraction;
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
		CodeConsoleWindow = SBCodeConsoleWindow(Console.Root.CreateWindow(class'SBCodeConsoleWindow', 0, 0, 200, 200));
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
	local SBCodeConsole CodeConsole;
	if (Owner == none)
		return;
	foreach Owner.TouchingActors(class'SBCodeConsole', CodeConsole)
		CodeConsole.TestCodeConsoleInput(Code, PlayerPawn(Owner));
}

function PlayCodeConsoleTypingSound()
{
	local SBCodeConsole CodeConsole;
	if (Owner == none)
		return;
	foreach Owner.TouchingActors(class'SBCodeConsole', CodeConsole)
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

simulated function SetupFootStepManager()
{
	if (Level.FootprintManager == none || Level.FootprintManager == class'FootStepManager')
		Level.FootprintManager = class'B227_XidiaFootStepManager';
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
