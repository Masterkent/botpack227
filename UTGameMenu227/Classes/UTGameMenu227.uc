class UTGameMenu227 extends UWindowPulldownMenu;

var UWindowPulldownMenuItem NewGame, Load, Save, Botmatch, Quit; // Unreal
var UWindowPulldownMenuItem NewUTGame, LoadUTGame, ReturnToGame; // UT

var localized string NewGameName;
var localized string NewGameHelp;
var localized string LoadGameName;
var localized string LoadGameHelp;
var localized string ReturnToGameName;
var localized string ReturnToGameHelp;

var UWindowMessageBox ConfirmQuit;

function Created()
{
	Super.Created();

	// Add menu items.
	NewGame = AddMenuItem(class'UMenu.UMenuGameMenu'.default.NewGameName, None);
	Load = AddMenuItem(class'UMenu.UMenuGameMenu'.default.LoadName, None);
	Save = AddMenuItem(class'UMenu.UMenuGameMenu'.default.SaveName, None);
	AddMenuItem("-", None);
	Botmatch = AddMenuItem(class'UMenu.UMenuGameMenu'.default.BotmatchName, None);
	AddMenuItem("-", None);
	NewUTGame = AddMenuItem(NewGameName, None);
	LoadUTGame = AddMenuItem(LoadGameName, None);
	ReturnToGame = AddMenuItem(ReturnToGameName, None);
	AddMenuItem("-", None);
	Quit = AddMenuItem(class'UMenu.UMenuGameMenu'.default.QuitName, None);
}

function WindowShown()
{
	local GameInfo Game;

	super.WindowShown();

	Game = GetLevel().Game;
	Save.bDisabled = Game == none || Game.bDeathMatch || Game.IsA('UTIntro');
	ReturnToGame.bDisabled = Game != none && Game.IsA('UTIntro');
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if (W == ConfirmQuit && Result == MR_Yes)
		Root.QuitGame();
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case NewGame:
		// Create new game dialog.
		Root.CreateWindow(class'UMenuNewGameWindow', 100, 100, 200, 200, Self, True);
		break;
	case Load:
		// Create load game dialog.
		Root.CreateWindow(class'UMenuLoadGameWindow', 100, 100, 200, 200, Self, True);
		break;
	case Save:
		// Create save game dialog.
		Root.CreateWindow(class'UMenuSaveGameWindow', 100, 100, 200, 200, Self, True);
		break;
	case Botmatch:
		// Create botmatch dialog.
		Root.CreateWindow(class'UMenuBotmatchWindow', 100, 100, 200, 200, Self, True);
		break;
	case NewUTGame:
		GetPlayerOwner().ClientTravel( "UT-Logo-Map.unr?Game=Botpack.LadderNewGame", TRAVEL_Absolute, True );
		break;
	case LoadUTGame:
		GetPlayerOwner().ClientTravel( "UT-Logo-Map.unr?Game=Botpack.LadderLoadGame", TRAVEL_Absolute, True );
		break;
	case ReturnToGame:
		Root.Console.CloseUWindow();
		break;
	case Quit:
		ConfirmQuit = MessageBox(class'UMenu.UMenuGameMenu'.default.QuitTitle, class'UMenu.UMenuGameMenu'.default.QuitText, MB_YesNo, MR_No, MR_Yes);
		break;
	}

	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case NewGame:
		UMenuMenuBar(GetMenuBar()).SetHelp(class'UMenu.UMenuGameMenu'.default.NewGameHelp);
		return;
	case Load:
		UMenuMenuBar(GetMenuBar()).SetHelp(class'UMenu.UMenuGameMenu'.default.LoadHelp);
		break;
	case Save:
		UMenuMenuBar(GetMenuBar()).SetHelp(class'UMenu.UMenuGameMenu'.default.SaveHelp);
		break;
	case Botmatch:
		UMenuMenuBar(GetMenuBar()).SetHelp(class'UMenu.UMenuGameMenu'.default.BotmatchHelp);
		break;
	case NewUTGame:
		UMenuMenuBar(GetMenuBar()).SetHelp(NewGameHelp);
		return;
	case LoadUTGame:
		UMenuMenuBar(GetMenuBar()).SetHelp(LoadGameHelp);
		return;
	case ReturnToGame:
		UMenuMenuBar(GetMenuBar()).SetHelp(ReturnToGameHelp);
	case Quit:
		UMenuMenuBar(GetMenuBar()).SetHelp(class'UMenu.UMenuGameMenu'.default.QuitHelp);
		break;
	}

	Super.Select(I);
}

defaultproperties
{
     NewGameName="Start Unreal &Tournament"
     NewGameHelp="Select to start a new Unreal Tournament game!"
     LoadGameName="&Resume Saved Tournament"
     LoadGameHelp="Select to resume a saved Unreal Tournament game."
     ReturnToGameName="Return to &Current Game"
     ReturnToGameHelp="Leave the menus and return to your current game.  Pressing the ESC key also returns you to the current game."
}
