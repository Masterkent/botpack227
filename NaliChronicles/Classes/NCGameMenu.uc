// The Game menu - different in order to get rid of Botmatch and to change the new game menu
// by Sergey 'Eater' Levin, 2002

class NCGameMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem NewGame, Tutorial, Load, Save, Quit;

var localized string NewGameName;
var localized string NewGameHelp;
var localized string TutorialName;
var localized string TutorialHelp;
var localized string LoadName;
var localized string LoadHelp;
var localized string SaveName;
var localized string SaveHelp;
var localized string QuitName;
var localized string QuitHelp;
var localized string QuitTitle;
var localized string QuitText;

var UWindowMessageBox ConfirmQuit;

function Created()
{
	Super.Created();

	// Add menu items.
	NewGame = AddMenuItem(NewGameName, None);
	Tutorial = AddMenuItem(TutorialName, None);
	Load = AddMenuItem(LoadName, None);
	Save = AddMenuItem(SaveName, None);
	AddMenuItem("-", None);
	Quit = AddMenuItem(QuitName, None);
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == ConfirmQuit && Result == MR_Yes)
		Root.QuitGame();
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	switch(I)
	{
	case NewGame:
		// Create new game dialog.
		Root.CreateWindow(class'NCNewGameWindow', 100, 100, 200, 200, Self, True);
		break;
	case Tutorial:
		// Create new game dialog.
		Root.CreateWindow(class'NCTutorialWindow', 100, 100, 200, 200, Self, True);
		break;
	case Load:
		// Create load game dialog.
		Root.CreateWindow(class'UMenuLoadGameWindow', 100, 100, 200, 200, Self, True);
		break;
	case Save:
		// Create save game dialog.
		Root.CreateWindow(class'UMenuSaveGameWindow', 100, 100, 200, 200, Self, True);
		break;
	case Quit:
		ConfirmQuit = MessageBox(QuitTitle, QuitText, MB_YesNo, MR_No, MR_Yes);
		break;
	}

	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch(I)
	{
	case Tutorial:
		UMenuMenuBar(GetMenuBar()).SetHelp(TutorialHelp);
		return;
	case NewGame:
		UMenuMenuBar(GetMenuBar()).SetHelp(NewGameHelp);
		return;
	case Load:
		UMenuMenuBar(GetMenuBar()).SetHelp(LoadHelp);
		break;
	case Save:
		UMenuMenuBar(GetMenuBar()).SetHelp(SaveHelp);
		break;
	case Quit:
		UMenuMenuBar(GetMenuBar()).SetHelp(QuitHelp);
		break;
	}

	Super.Select(I);
}

defaultproperties
{
     NewGameName="&Skip Tutorial"
     NewGameHelp="Select to setup a new single player game of Nali Chronicles and skip the tutorial."
     TutorialName="&New Game"
     TutorialHelp="Select to setup a new single player game of Nali Chronicles."
     LoadName="&Load"
     LoadHelp="Select to load a previously saved game."
     SaveName="&Save"
     SaveHelp="Select to save your current game."
     QuitName="&Quit"
     QuitHelp="Select to save preferences and exit Nali Chronicles."
     QuitTitle="Confirm Quit"
     QuitText="Are you sure you want to exit Nali Chronicles?"
}
