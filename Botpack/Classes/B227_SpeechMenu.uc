class B227_SpeechMenu expands Object;

var B227_SpeechMenuWindow MenuWindow;
var Viewport Viewport;
var bool bShowSpeech;

static function B227_SpeechMenu MakeInstance(Viewport Viewport)
{
	local B227_SpeechMenu Result;

	Result = new class'B227_SpeechMenu';
	Result.Viewport = Viewport;
	return Result;
}

function WindowConsole Console()
{
	return WindowConsole(Viewport.Console);
}

function UWindowRootWindow Root()
{
	return WindowConsole(Viewport.Console).Root;
}

static function ShowMenu(PlayerPawn PlayerOwner, out B227_SpeechMenu B227_SpeechMenu)
{
	if (PlayerOwner == none ||
		Viewport(PlayerOwner.Player) == none ||
		WindowConsole(PlayerOwner.Player.Console) == none ||
		PlayerOwner.PlayerReplicationInfo == none ||
		PlayerOwner.PlayerReplicationInfo.VoiceType == none)
	{
		return;
	}

	if (B227_SpeechMenu == none)
		B227_SpeechMenu = class'B227_SpeechMenu'.static.MakeInstance(Viewport(PlayerOwner.Player));

	if (!B227_SpeechMenu.bShowSpeech)
		B227_SpeechMenu.ShowSpeech();
}

function GetSpeechWindow()
{
	if (MenuWindow == none)
	{
		MenuWindow = B227_SpeechMenuWindow(Root().CreateWindow(class'B227_SpeechMenuWindow', 100, 100, 200, 200));
		MenuWindow.bLeaveOnScreen = true;
		MenuWindow.HideWindow();
	}
}

function ShowSpeech()
{
	if (Console().bUWindowActive)
		return;

	bShowSpeech = true;
	if (!Console().bCreatedRoot)
		Console().CreateRootWindow(none);

	Console().bQuickKeyEnable = true;
	Console().LaunchUWindow();

	Root().SetMousePos(0, 132.0/768 * Root().WinWidth);
	if (ChallengeHUD(Viewport.Actor.myHUD) != none)
		ChallengeHUD(Viewport.Actor.myHUD).bHideCenterMessages = true;

	if (MenuWindow == none)
	{
		MenuWindow = B227_SpeechMenuWindow(Root().CreateWindow(class'B227_SpeechMenuWindow', 100, 100, 200, 200));
		MenuWindow.B227_SpeechMenu = self;
		MenuWindow.WindowShown();
	}
	else
		MenuWindow.ShowWindow();
}

function HideSpeech()
{
	if (!bShowSpeech)
		return;

	bShowSpeech = false;
	if (ChallengeHUD(Viewport.Actor.myHUD) != none)
		ChallengeHUD(Viewport.Actor.myHUD).bHideCenterMessages = false;

	if (MenuWindow != none && MenuWindow.bWindowVisible)
		MenuWindow.HideWindow();
}

static function bool HasActiveSpeechWindow(PlayerPawn Player)
{
	local TournamentPlayer TPlayer;
	local TournamentConsole TConsole;

	if (Player == none)
		return false;

	TPlayer = TournamentPlayer(Player);
	if (TPlayer != none && TPlayer.B227_SpeechMenu != none && TPlayer.B227_SpeechMenu.bShowSpeech)
		return true;

	TConsole = TournamentConsole(Player.Player.Console);
	if (TConsole != none && TConsole.bShowSpeech)
		return true;

	return false;
}
