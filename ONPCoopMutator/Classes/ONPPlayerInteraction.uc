class ONPPlayerInteraction expands Info;

var private bool bRealCrouching;
var private ONPCodeConsoleWindow CodeConsoleWindow;

replication
{
	reliable if (Role < ROLE_Authority)
		TestCodeConsoleInput,
		PlayCodeConsoleTypingSound;

	reliable if (Role == ROLE_Authority)
		OpenCodeConsole,
		CloseCodeConsole,
		TransferTranslatorMessage,
		SetClientRealSpeed;

	reliable if (Role == ROLE_Authority)
		bRealCrouching;
}


simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	AdjustClientProperties();
}

simulated event Tick(float DeltaTime)
{
	if (Level.NetMode == NM_Client)
		Level.bSupportsRealCrouching = bRealCrouching;
	else
		bRealCrouching = Level.bSupportsRealCrouching;
}

static function ONPPlayerInteraction FindFor(PlayerPawn Player)
{
	local ONPPlayerInteraction PlayerInteraction;

	foreach Player.ChildActors(class'ONPPlayerInteraction', PlayerInteraction)
		return PlayerInteraction;
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
		CodeConsoleWindow = ONPCodeConsoleWindow(Console.Root.CreateWindow(class'ONPCodeConsoleWindow', 0, 0, 200, 200));
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
	local ONPCodeConsole CodeConsole;
	if (Owner == none)
		return;
	foreach Owner.TouchingActors(class'ONPCodeConsole', CodeConsole)
		CodeConsole.TestCodeConsoleInput(Code, PlayerPawn(Owner));
}

function PlayCodeConsoleTypingSound()
{
	local ONPCodeConsole CodeConsole;
	if (Owner == none)
		return;
	foreach Owner.TouchingActors(class'ONPCodeConsole', CodeConsole)
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

simulated function AdjustClientProperties()
{
	local tvplayer ONPPlayer;

	if (Level.NetMode == NM_DedicatedServer)
		return;

	ONPPlayer = tvplayer(Owner);
	if (ONPPlayer != none)
		ClientAdjustONPPlayerSounds(ONPPlayer);
}

simulated function ClientAdjustONPPlayerSounds(tvplayer Player)
{
	Player.BreathAgain = Sound'BotPack.MaleSounds.gasp02';
	Player.Deaths[0] = none;
	Player.Deaths[1] = none;
	Player.Deaths[2] = none;
	Player.Deaths[3] = none;
	Player.Deaths[4] = none;
	Player.Deaths[5] = none;
	Player.Die = none;
	Player.Drown = Sound'BotPack.MaleSounds.drownM02';
	Player.FootStep1 = Sound'BotPack.FemaleSounds.stone02';
	Player.FootStep2 = Sound'BotPack.FemaleSounds.stone04';
	Player.FootStep3 = Sound'BotPack.FemaleSounds.stone05';
	Player.GaspSound = Sound'BotPack.MaleSounds.hgasp1';
	Player.HitSound1 = Sound'BotPack.MaleSounds.injurL2';
	Player.HitSound2 = Sound'BotPack.MaleSounds.injurL04';
	Player.HitSound3 = Sound'BotPack.MaleSounds.injurM04';
	Player.HitSound4 = Sound'BotPack.MaleSounds.injurH5';
	Player.JumpSound = none;
	Player.JumpSounds[0] = Sound'BotPack.MaleSounds.jump1';
	Player.JumpSounds[1] = Sound'BotPack.MaleSounds.jump1';
	Player.JumpSounds[2] = Sound'BotPack.MaleSounds.jump1';
	Player.Land = Sound'UnrealShare.Generic.Land1';
	Player.LandGrunt = Sound'BotPack.MaleSounds.land01';
	Player.UWHit1 = Sound'BotPack.MaleSounds.UWinjur41';
	Player.UWHit2 = Sound'BotPack.MaleSounds.UWinjur42';
	Player.WaterStep = Sound'UnrealShare.Generic.LSplash';
}

simulated function SetClientRealSpeed(float Speed)
{
	if (tvplayer(Owner) != none)
		tvplayer(Owner).RealSpeed = Speed;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
